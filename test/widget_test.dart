import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:gestion_redacteurs/main.dart';

void main() {
  setUpAll(() {
    // Initialise SQLite pour les tests Flutter.
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  testWidgets('L’application démarre', (WidgetTester tester) async {
    await tester.pumpWidget(
      const GestionRedacteursApp(),
    );

    // On laisse simplement le premier cycle de rendu
    // se terminer sans attendre tous les flux/animations.
    await tester.pump();

    expect(
      find.byType(GestionRedacteursApp),
      findsOneWidget,
    );
  });
}