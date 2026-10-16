import 'package:flutter_test/flutter_test.dart';
import 'package:desastres_naturales/main.dart';

void main() {
  testWidgets('Muestra la pantalla inicial', (WidgetTester tester) async {
    await tester.pumpWidget(const DesastresNaturalesApp());

    expect(find.text('Desastres Naturales'), findsOneWidget);
    expect(find.text('Firebase conectado correctamente'), findsOneWidget);
  });
}
