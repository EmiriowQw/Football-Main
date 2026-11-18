# Football Day — Game Format & Concept

> The app already exists. This file only describes the **Football Day format** that the existing app must be adapted to. Do not restructure the project; change logic, texts and flows to match the rules below.

---

## 1. Concept

**Football Day** is a daily pickup football format. The organizer (Football Day) runs the games themselves, outside the app.

- There is **no organizer account** in the app.
- **Nobody creates games in the app.** Players cannot create, edit or delete games.
- Games **already exist by default**. Players only join them.

---

## 2. Daily schedule

Every day there are preset games at fixed evening times, for example **18:00 and 19:00**.
Each time slot is played on **3 pitches** at the same time.

So on any given day a player sees a ready list like:

- 18:00 — Pitch 1, Pitch 2, Pitch 3
- 19:00 — Pitch 1, Pitch 2, Pitch 3

Each of these is one game: **one pitch + one start time**. Slots and pitches are fixed defaults and the app shows them for each upcoming day automatically. *(Assumption: exact times and pitch names are placeholders and must be easy to change.)*

---

## 3. Game format: team size depends on the pitch

Each game has **4 teams**. The number of players per team is **not the same on every pitch**. Every pitch has its own format:

| Format | Outfield players | Goalkeeper | Players per team | Places in the game (4 teams) |
|---|---|---|---|---|
| **5 + 1** | 5 | 1 | **6** | 24 |
| **4 + 1** | 4 | 1 | **5** | 20 |

- Each team always includes **one goalkeeper**; the team size already counts him (6 = 5 outfield + 1 goalkeeper, 5 = 4 outfield + 1 goalkeeper).
- The format is set **per pitch** and is preset by default. Players cannot choose or change it. *(Assumption: which pitch uses which format is a placeholder, e.g. Pitch 1 and Pitch 2 = 5 + 1, Pitch 3 = 4 + 1, and must be easy to change.)*
- Team capacity, free places and "team full" status in every game are calculated from that pitch's format.
- Teams are labeled **Red, Blue, Yellow, Green** *(assumption — easy to rename)*.
- The per-player fee is **shown as information only**. No payment is collected and there is no paid/unpaid status.

---

## 4. Players

A player signs in with **Google**, picks a game, chooses a team, sets the number of places, optionally enters friends' names, and books.

A player can reserve:
- **one place**,
- **several places** (for friends),
- or **all the places in a team**.

Everyone in a group booking is placed on the **same team**. Team availability updates as reservations are made.

The goalkeeper is one of the places in the team, not a separate booking type. *(Assumption: the app does not enforce who plays in goal; it only shows the format, e.g. "5 + 1".)*

---

## 5. Booking rules

1. A booking = one user, one game, one team, N places (N ≥ 1).
2. **A group booking always lands on one team.** It is never split across teams.
3. N cannot exceed the free places left in the chosen team (6 or 5 per team, depending on the pitch).
4. Booking a whole team = taking all its free places.
5. Friends' names are optional, at most N − 1 (the booker takes one place). Friends do not need accounts. Places without a name are shown as "Guest of <booker>".
6. A team with 0 free places is **full** and cannot be chosen. A game is full when all four teams are full.
7. Availability per team (`free / capacity`) updates live as people book or cancel.
8. Two people must never be able to overbook the same team at the same time. If the last places are taken first by someone else, the second user gets a clear message and refreshed availability.
9. *(Assumption)* One user has one active booking per game. To change the team they cancel and rebook. Changing the number of places or friends' names is allowed until the game starts.
10. *(Assumption)* Cancelling frees the places immediately; allowed until the game starts.
11. Past games are read-only.

---

## 6. Not implemented in this version

- Payments of any kind.
- Checking whether the pitch is actually free with the pitch provider.
- Any organizer or admin accounts, and any way to create games from the app.
- Match scheduling, results, stats.
