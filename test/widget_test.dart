import 'package:flutter_test/flutter_test.dart';
import 'package:jp_portfolio/main.dart';

void main() {
  testWidgets('portfolio renders hero and navigation', (tester) async {
    await tester.pumpWidget(const PortfolioApp());
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.textContaining('Hello, I’m'), findsOneWidget);
    expect(find.text('Explore projects  ↗'), findsOneWidget);
  });
}
