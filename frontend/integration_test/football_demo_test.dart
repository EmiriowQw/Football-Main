import 'package:basketvibe/main.dart' as app;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Android demo signs in, books, edits and cancels', (
    tester,
  ) async {
    app.main();
    Future<void> waitFor(Finder finder) async {
      for (var i = 0; i < 100; i++) {
        await tester.pump(const Duration(milliseconds: 150));
        if (finder.evaluate().isNotEmpty) return;
      }
      fail('Timed out waiting for $finder');
    }

    Future<void> tapText(String text) async {
      final target = find.text(text).hitTestable();
      await waitFor(target);
      await tester.tap(target.first);
      await tester.pumpAndSettle();
    }

    await waitFor(find.text('FOOTBALL DAY'));
    final signOut = find.byTooltip('Выйти');
    if (signOut.evaluate().isNotEmpty) {
      await tester.tap(signOut);
      await tester.pumpAndSettle();
    }
    await tapText('Мои брони');
    await tapText('Войти как демо-игрок');
    await tapText('Войти как демо-игрок');
    final skip = find.text('Пропустить');
    for (
      var i = 0;
      i < 80 &&
          skip.evaluate().isEmpty &&
          find.text('FOOTBALL DAY').evaluate().isEmpty;
      i++
    ) {
      await tester.pump(const Duration(milliseconds: 150));
    }
    if (skip.evaluate().isNotEmpty) await tapText('Пропустить');
    await waitFor(find.text('FOOTBALL DAY'));
    await tapText('Расписание');
    await tapText('Завтра');
    final choose = find.text('Выбрать команду');
    for (var i = 0; i < 8 && choose.hitTestable().evaluate().isEmpty; i++) {
      await tester.drag(find.byType(ListView).first, const Offset(0, -220));
      await tester.pumpAndSettle();
    }
    await tapText('Выбрать команду');
    await tester.pumpAndSettle();
    await waitFor(find.text('Бронь поля'));
    await tapText('Красная');
    await tester.scrollUntilVisible(
      find.byTooltip('Больше мест'),
      230,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.tap(find.byTooltip('Больше мест'));
    await tester.pumpAndSettle();
    final defender = find.widgetWithText(ChoiceChip, 'Защитник');
    await tester.ensureVisible(defender);
    await tapText('Защитник');
    final friend = find.byType(TextField).first;
    await tester.ensureVisible(friend);
    await tester.enterText(friend, 'Марат');
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pumpAndSettle();
    final friendPosition = find.byKey(const ValueKey('friend-position-0'));
    await tester.ensureVisible(friendPosition);
    await tester.tap(friendPosition);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Вратарь').last);
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Забронировать'));
    await tapText('Забронировать');
    await waitFor(find.text('Бронь подтверждена'));
    await waitFor(find.text('Ты в игре'));
    await tapText('Готово');
    await tapText('Мои брони');
    await tapText('Ваша бронь');
    await waitFor(defender);
    expect(tester.widget<ChoiceChip>(defender).selected, isTrue);
    expect(
      tester
          .widget<DropdownButtonFormField>(friendPosition)
          .initialValue
          .toString(),
      endsWith('.goalkeeper'),
    );
    await tester.ensureVisible(friend);
    expect(find.text('Марат'), findsWidgets);
    await tester.enterText(friend, 'Данияр');
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Сохранить'));
    await tapText('Сохранить');
    await waitFor(find.text('Бронь подтверждена'));
    await tapText('Ваша бронь');
    await tester.scrollUntilVisible(
      find.text('Отменить бронь'),
      230,
      scrollable: find.byType(Scrollable).last,
    );
    await tapText('Отменить бронь');
    await tester.tap(find.widgetWithText(FilledButton, 'Отменить бронь'));
    await tester.pumpAndSettle();
    await waitFor(find.text('Бронь отменена, места освобождены'));
    await tester.tap(signOut);
    await tester.pumpAndSettle();
    await waitFor(find.text('Войти как демо-игрок'));
  });
}
