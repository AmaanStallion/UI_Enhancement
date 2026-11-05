import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../custom_loading/custom_loading.dart';
import 'account_management_layout.dart';

class AccountSkeleton extends StatelessWidget {
  const AccountSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    Widget bar(double width, double height) => Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(8)));
    final content = LayoutBuilder(
        builder: (context, constraints) => ListView(
                padding: EdgeInsets.all(context.accountCompact ? 12 : 24),
                children: [
                  bar(constraints.maxWidth, 44),
                  const SizedBox(height: 16),
                  for (var i = 0; i < 3; i++) ...[
                    Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: Colors.white, width: 2)),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              bar(constraints.maxWidth * 0.48, 16),
                              const SizedBox(height: 18),
                              bar(constraints.maxWidth * 0.75, 12),
                              const SizedBox(height: 12),
                              bar(constraints.maxWidth * 0.60, 12),
                              const SizedBox(height: 18),
                              bar(100, 32),
                            ])),
                    const SizedBox(height: 16),
                  ],
                ]));
    return Semantics(
        label: 'Loading Account Management',
        child: IgnorePointer(
            child: MediaQuery.disableAnimationsOf(context)
                ? content
                : Shimmer.fromColors(
                    baseColor: const Color(0xffe1e4e8),
                    highlightColor: const Color(0xfff8f9fa),
                    child: content)));
  }
}

/// Mirrors the main screen's status sections and bottom payment rows.
class AccountMainSkeleton extends StatelessWidget {
  const AccountMainSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final compact = context.accountCompact;
    Widget block(double width, double height, {double radius = 6}) => Container(
      width: width, height: height,
      decoration: BoxDecoration(color: Colors.white,
          borderRadius: BorderRadius.circular(radius)),
    );
    final content = Column(children: [
      Expanded(child: ListView(
        padding: EdgeInsets.symmetric(horizontal: compact ? 12 : 40, vertical: 12),
        children: [
          Center(child: block(170, 14)),
          const SizedBox(height: 20),
          Center(child: block(100, 20)),
          const SizedBox(height: 16),
          for (final count in [3, 3, 2]) ...[
            Stack(children: [
              Padding(padding: const EdgeInsets.only(top: 14),
                child: Container(
                  padding: const EdgeInsets.fromLTRB(8, 28, 8, 14),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white, width: 2),
                    borderRadius: BorderRadius.circular(14)),
                  child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      for (var i = 0; i < count; i++)
                        block(compact ? (MediaQuery.sizeOf(context).width - 96) / 3 : 150,
                            compact ? 56 : 88, radius: 12),
                    ]),
                )),
              Positioned(top: 0, left: 16,
                  child: block(compact ? 150 : 190, 28, radius: 20)),
            ]),
            const SizedBox(height: 16),
          ],
        ],
      )),
      for (var i = 0; i < 2; i++)
        Padding(padding: EdgeInsets.symmetric(horizontal: compact ? 12 : 40, vertical: 12),
          child: Row(children: [
            block(24, 24), const SizedBox(width: 12), block(110, 14),
            const Spacer(), block(compact ? 70 : 110, 16),
            const SizedBox(width: 12), block(10, 16),
          ])),
    ]);
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final skeleton = reduceMotion ? content : Shimmer.fromColors(
      baseColor: const Color(0xfff0f0f0),
      highlightColor: const Color(0xfff9f9f9),
      period: const Duration(milliseconds: 1500), child: content);
    return Semantics(label: 'Loading Account Management',
      child: IgnorePointer(child: reduceMotion
          ? skeleton : CustomLoading.wrapWithHorseLoader(skeleton)));
  }
}

/// Retains the existing loading call sites, with an account-specific skeleton.
class AccountLoading {
  static void progressDialog(
      {required bool isLoading,
      required BuildContext context,
      dynamic title,
      bool noNeedOfLoading = false,
      double bgOpacity = 0,
      String skeletonType = 'default',
      bool isDark = false}) {
    if (noNeedOfLoading) {
      return;
    }
    if (!isLoading) {
      Navigator.of(context, rootNavigator: true).pop();
      return;
    }
    showDialog<void>(
        context: context,
        barrierDismissible: false,
        barrierColor: const Color(0xf2ffffff),
        builder: (_) => const PopScope(
            canPop: false,
            child: Material(
                color: Color(0xfff8f9fa),
                child: SafeArea(child: AccountSkeleton()))));
  }
}
