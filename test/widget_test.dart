import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:water_conditioner/injection_container.dart' as di;
import 'package:water_conditioner/main.dart';

void main() {
  setUp(() async {
    // Mock SharedPreferences
    SharedPreferences.setMockInitialValues({});
    
    // Reset di instances if any, then register mock/real dependencies
    await di.sl.reset();
    await di.init();
  });

  testWidgets('Login screen loads successfully smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      const MyApp(
        isLoggedIn: false,
        userId: "",
        technicianId: "",
        deviceId: "",
        name: "",
        role: "",
      ),
    );

    // Re-render layout frame
    await tester.pumpAndSettle();

    // Verify that login screen is shown and text elements are rendered.
    expect(find.text('WATER CONDITIONER'), findsOneWidget);
    expect(find.text('Welcome Back'), findsOneWidget);
  });
}
