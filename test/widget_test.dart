import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:elio/main.dart';

void main() {
  testWidgets('splash shows and navigates to login when signed out',
      (WidgetTester tester) async {
    final mockAuth = MockFirebaseAuth(signedIn: false);
    await tester.pumpWidget(ElioApp(auth: mockAuth));
    expect(find.text('ELIO'), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 2500));
    await tester.pumpAndSettle();
    expect(find.text('Login — coming soon'), findsOneWidget);
  });

  testWidgets('splash navigates to home when already signed in',
      (WidgetTester tester) async {
    final mockAuth = MockFirebaseAuth(signedIn: true);
    await tester.pumpWidget(ElioApp(auth: mockAuth));
    await tester.pump(const Duration(milliseconds: 2500));
    await tester.pumpAndSettle();
    expect(find.text('Home — coming soon'), findsOneWidget);
  });
}