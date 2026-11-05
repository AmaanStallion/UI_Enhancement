import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stallion/ui/views/accountmanagement/po_action_feedback.dart';

void main() {
  testWidgets('PO actions show hover and press feedback without moving layout',
      (tester) async {
    var taps = 0;
    await tester.pumpWidget(MaterialApp(
        home: Scaffold(
            body: Center(
      child: PoActionFeedback(
          child: InkWell(
              onTap: () => taps++,
              child: const SizedBox(
                  width: 120, height: 44, child: Text('Action')))),
    ))));
    final feedback = find.byType(PoActionFeedback);
    final original = tester.getRect(feedback);
    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await mouse.addPointer(location: Offset.zero);
    await mouse.moveTo(original.center);
    await tester.pumpAndSettle();
    final decoration = tester
        .widget<AnimatedContainer>(find.descendant(
            of: feedback, matching: find.byType(AnimatedContainer)))
        .decoration as BoxDecoration;
    expect(decoration.boxShadow, isEmpty);
    expect(decoration.color, const Color(0x08000000));
    final touch = await tester.startGesture(original.center);
    await tester.pump(const Duration(milliseconds: 120));
    expect(
        tester.widget<AnimatedScale>(find.byType(AnimatedScale)).scale, 0.96);
    expect(tester.getRect(feedback), original);
    await touch.up();
    await tester.pumpAndSettle();
    expect(taps, 1);
    expect(tester.widget<AnimatedScale>(find.byType(AnimatedScale)).scale, 1);
    await mouse.removePointer();
  });
}
