import 'package:cv_flutter_bryan/main.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('login validates credentials and opens the portfolio', (
    tester,
  ) async {
    _usePhoneViewport(tester);
    await tester.pumpWidget(const CvFlutterApp());

    expect(find.text('Se connecter'), findsOneWidget);
    expect(find.text('Saisissez votre identifiant.'), findsNothing);

    await tester.tap(find.text('Se connecter'));
    await tester.pump();
    expect(find.text('Saisissez votre identifiant.'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField).at(0), 'incorrect');
    await tester.enterText(find.byType(TextFormField).at(1), 'incorrect');
    await tester.tap(find.text('Se connecter'));
    await tester.pump();
    expect(find.text('Identifiant ou mot de passe incorrect.'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField).at(0), 'bryan');
    await tester.enterText(find.byType(TextFormField).at(1), 'cvflutter2026');
    await tester.tap(find.text('Se connecter'));
    await tester.pumpAndSettle();
    expect(find.text('Mon parcours'), findsOneWidget);
    expect(find.text('NTAMBWE MATANDA BRYAN'), findsOneWidget);
  });

  testWidgets('navigation shows the family and contact pages', (tester) async {
    _usePhoneViewport(tester);
    await tester.pumpWidget(const CvFlutterApp());
    await tester.enterText(find.byType(TextFormField).at(0), 'bryan');
    await tester.enterText(find.byType(TextFormField).at(1), 'cvflutter2026');
    await tester.tap(find.text('Se connecter'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Famille'));
    await tester.pumpAndSettle();
    expect(find.text('Suzanne Waridi'), findsOneWidget);
    expect(find.text('Raphael Nfune'), findsOneWidget);

    await tester.tap(find.text('Contact'));
    await tester.pumpAndSettle();
    expect(find.text('+243 971 023 985'), findsOneWidget);
    expect(find.text('bryanntambwe07@gmail.com'), findsOneWidget);

    await tester.tap(find.byTooltip('Se déconnecter'));
    await tester.pumpAndSettle();
    expect(find.text('Se connecter'), findsOneWidget);
  });

  testWidgets('password is masked on the login screen', (tester) async {
    _usePhoneViewport(tester);
    await tester.pumpWidget(const CvFlutterApp());

    final passwordField = tester.widget<TextField>(find.byType(TextField).last);
    expect(passwordField.obscureText, isTrue);
  });
}

void _usePhoneViewport(WidgetTester tester) {
  tester.view.physicalSize = const Size(430, 932);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}
