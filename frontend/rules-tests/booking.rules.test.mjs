import { before, after, beforeEach, test } from 'node:test';
import assert from 'node:assert/strict';
import { readFile } from 'node:fs/promises';
import { initializeTestEnvironment, assertSucceeds, assertFails } from '@firebase/rules-unit-testing';
import { doc, getDoc, setDoc, deleteDoc, runTransaction, Timestamp, onSnapshot } from 'firebase/firestore';

let env;
const teams = ['red', 'blue', 'yellow', 'green'];
const tomorrow = new Date();
tomorrow.setUTCDate(tomorrow.getUTCDate() + 1);
tomorrow.setUTCHours(12, 0, 0, 0);
const startTime = Timestamp.fromDate(tomorrow);
const id = `${startTime.seconds}_pitch1`;
const path = `footballBookings/${id}`;
const booking = (places = 1, team = 'red', friendNames = []) => ({ places, team, friendNames, bookerName: 'Alice' });
const data = (bookings = {}, pitchId = 'pitch1', start = startTime) => ({
  startTime: start, pitchId, bookings,
  counts: Object.fromEntries(teams.map(team => [team,
    Object.values(bookings).filter(b => b.team === team).reduce((n, b) => n + b.places, 0)])),
});
const db = uid => env.authenticatedContext(uid, { firebase: { sign_in_provider: 'google.com' } }).firestore();

before(async () => {
  env = await initializeTestEnvironment({ projectId: 'demo-football-day',
    firestore: { host: '127.0.0.1', port: 8088, rules: await readFile('../firestore.rules', 'utf8') } });
});
beforeEach(async () => env.clearFirestore());
after(async () => env?.cleanup());

test('public read, Google-only writes, no legacy creation', async () => {
  const guest = env.unauthenticatedContext().firestore();
  await assertSucceeds(getDoc(doc(guest, path)));
  await assertFails(setDoc(doc(guest, path), data({ alice: booking() })));
  const password = env.authenticatedContext('alice', { firebase: { sign_in_provider: 'password' } }).firestore();
  await assertFails(setDoc(doc(password, path), data({ alice: booking() })));
  await assertFails(setDoc(doc(db('alice'), 'games/new'), { hostId: 'alice', playerIds: ['alice'] }));
  await assertSucceeds(setDoc(doc(db('alice'), path), data({ alice: booking(6) })));
});

test('owner can edit quantity/names and cancel; other bookings unchanged', async () => {
  const alice = doc(db('alice'), path);
  const bob = doc(db('bob'), path);
  await assertSucceeds(setDoc(alice, data({ alice: booking(3, 'red', ['Sam', '']) })));
  await assertSucceeds(setDoc(bob, data({ alice: booking(3, 'red', ['Sam', '']), bob: booking(2) })));
  await assertSucceeds(setDoc(alice, data({ alice: booking(4), bob: booking(2) })));
  await assertSucceeds(setDoc(alice, data({ bob: booking(2) })));
  assert.equal((await getDoc(bob)).data().counts.red, 2);
  await assertFails(deleteDoc(bob));
});

test('cannot edit someone else, transfer teams, forge counters or metadata', async () => {
  const ref = doc(db('alice'), path);
  await setDoc(ref, data({ alice: booking(2) }));
  await assertFails(setDoc(doc(db('bob'), path), data({ alice: booking(1), bob: booking(1) })));
  await assertFails(setDoc(ref, data({ alice: booking(2, 'blue') })));
  await assertFails(setDoc(ref, { ...data({ alice: booking(3) }), counts: { red: 2, blue: 0, yellow: 0, green: 0 } }));
  await assertFails(setDoc(ref, { ...data({ alice: booking(3) }), paid: true }));
  await assertFails(setDoc(ref, data({ alice: booking(2) }, 'pitch2')));
});

test('only canonical preset IDs and exact hours allowed', async () => {
  await assertFails(setDoc(doc(db('alice'), 'footballBookings/arbitrary-game'), data({ alice: booking() })));
  const wrong = Timestamp.fromMillis(startTime.toMillis() + 60 * 1000);
  await assertFails(setDoc(doc(db('alice'), `footballBookings/${wrong.seconds}_pitch1`), data({ alice: booking() }, 'pitch1', wrong)));
  await assertFails(setDoc(doc(db('alice'), `footballBookings/${startTime.seconds}_pitch4`), data({ alice: booking() }, 'pitch4')));
  const far = Timestamp.fromMillis(startTime.toMillis() + 10 * 86400000);
  await assertFails(setDoc(doc(db('alice'), `footballBookings/${far.seconds}_pitch1`), data({ alice: booking() }, 'pitch1', far)));
});

test('capacity, positive integer quantities and friend-name validation enforced', async () => {
  const ref = doc(db('alice'), path);
  for (const invalid of [booking(0), booking(7), booking(1.5), booking(1, 'red', ['Extra']),
    booking(2, 'red', [123]), booking(2, 'red', ['x'.repeat(81)]),
    { ...booking(), bookerName: '' }, booking(1, 'purple')]) {
    await assertFails(setDoc(ref, data({ alice: invalid })));
  }
  const small = doc(db('alice'), `footballBookings/${startTime.seconds}_pitch3`);
  await assertFails(setDoc(small, data({ alice: booking(6) }, 'pitch3')));
  await assertSucceeds(setDoc(small, data({ alice: booking(5) }, 'pitch3')));
});

test('past games are read-only using server time', async () => {
  const past = Timestamp.fromMillis(startTime.toMillis() - 3 * 86400000);
  const pastPath = `footballBookings/${past.seconds}_pitch1`;
  await env.withSecurityRulesDisabled(async context => {
    await setDoc(doc(context.firestore(), pastPath), data({ alice: booking() }, 'pitch1', past));
  });
  await assertSucceeds(getDoc(doc(db('alice'), pastPath)));
  await assertFails(setDoc(doc(db('alice'), pastPath), data({}, 'pitch1', past)));
  await assertFails(setDoc(doc(db('alice'), pastPath), data({ alice: booking(2) }, 'pitch1', past)));
});

test('concurrent group bookings cannot take the same last two places', async () => {
  await setDoc(doc(db('hostless-player'), path), data({ 'hostless-player': booking(4) }));
  const reserve = uid => {
    const client = db(uid);
    return runTransaction(client, async transaction => {
      const ref = doc(client, path);
      const current = (await transaction.get(ref)).data();
      if (current.counts.red + 2 > 6) throw new Error('team-full');
      transaction.set(ref, data({ ...current.bookings, [uid]: booking(2) }));
    });
  };
  const outcomes = await Promise.allSettled([reserve('alice'), reserve('bob')]);
  assert.equal(outcomes.filter(r => r.status === 'fulfilled').length, 1);
  const result = (await getDoc(doc(db('alice'), path))).data();
  assert.equal(result.counts.red, 6);
  assert.equal(Object.keys(result.bookings).length, 2);
});

test('cancellation updates the live availability stream', async () => {
  const ref = doc(db('alice'), path);
  await setDoc(ref, data({ alice: booking(6) }));
  let unsubscribe;
  let timer;
  const released = new Promise((resolve, reject) => {
    timer = setTimeout(() => reject(new Error('No live update')), 10000);
    unsubscribe = onSnapshot(doc(db('observer'), path), snapshot => {
      if (snapshot.data()?.counts.red === 0) resolve();
    }, reject);
  });
  try {
    await setDoc(ref, data());
    await released;
  } finally { clearTimeout(timer); unsubscribe?.(); }
});
