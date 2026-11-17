import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

/// Mirrors the progress summary and form while their data is being loaded.
class SupplyFormSkeleton extends StatelessWidget {
  const SupplyFormSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    Widget bar(double width, double height, {double radius = 6}) => Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(radius)),
        );

    final content = LayoutBuilder(builder: (context, constraints) {
      final compact = constraints.maxWidth < 600;
      final padding = compact ? 12.0 : 30.0;
      final width = constraints.maxWidth - padding * 2;
      return SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: padding, vertical: 12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(child: Center(child: bar(width * .32, 14))),
            bar(78, 28, radius: 999),
          ]),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white, width: 2)),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              bar(width * .55, 16),
              const SizedBox(height: 14),
              bar(width * .7, 12),
              const SizedBox(height: 12),
              bar(width * .4, 12),
            ]),
          ),
          const SizedBox(height: 16),
          Row(children: [
            for (var i = 0; i < 3; i++)
              Expanded(
                  child: Column(children: [
                bar(width * .2, 10),
                const SizedBox(height: 8),
                bar(width * .24, 14),
              ])),
          ]),
          const SizedBox(height: 24),
          bar(width * .35, 16),
          const SizedBox(height: 16),
          for (var i = 0; i < 8; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 18),
              child: Row(children: [
                SizedBox(
                    width: width * (compact ? .34 : .28),
                    child: Align(
                        alignment: Alignment.centerLeft,
                        child: bar(width * .22, 12))),
                const SizedBox(width: 12),
                Expanded(child: bar(double.infinity, i == 7 ? 64 : 32)),
              ]),
            ),
        ]),
      );
    });
    return Semantics(
      label: 'Loading Status of Supplies form',
      liveRegion: true,
      child: ExcludeSemantics(
        child: IgnorePointer(
          child: MediaQuery.disableAnimationsOf(context)
              ? content
              : Shimmer.fromColors(
                  baseColor: const Color(0xffe1e4e8),
                  highlightColor: const Color(0xfff8f9fa),
                  child: content),
        ),
      ),
    );
  }
}
