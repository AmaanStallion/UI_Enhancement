import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class SkeletonBox extends StatefulWidget {
  final double? width;
  final double height;
  final double borderRadius;

  const SkeletonBox({
    Key? key,
    this.width,
    required this.height,
    this.borderRadius = 4.0,
  }) : super(key: key);

  @override
  State<SkeletonBox> createState() => _SkeletonBoxState();
}

class _SkeletonBoxState extends State<SkeletonBox>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: Color.lerp(
              Colors.grey.shade200,
              Colors.grey.shade300,
              _animation.value,
            ),
            borderRadius: BorderRadius.circular(widget.borderRadius),
          ),
        );
      },
    );
  }
}

class RccSkeletonScreen extends StatelessWidget {
  final bool isMobile;
  final int itemCount;

  const RccSkeletonScreen({
    Key? key,
    required this.isMobile,
    this.itemCount = 4,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Stack(
        children: [
          ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 8.0 : 16.0,
              vertical: isMobile ? 4.0 : 8.0,
            ),
            itemCount: itemCount,
            itemBuilder: (context, index) {
              return RccSkeletonCard(isMobile: isMobile);
            },
          ),
          Center(
            child: SizedBox(
              height: 64,
              child: OverflowBox(
                minHeight: 100,
                maxHeight: 100,
                child: Lottie.asset(
                  'assets/animation/running2.json',
                  repeat: true,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class RccSkeletonCard extends StatelessWidget {
  final bool isMobile;

  const RccSkeletonCard({Key? key, required this.isMobile}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double btnWidth = isMobile ? 136.0 : 175.0;
    final double btnHeight = isMobile ? 25.0 : 31.0;

    return Card(
      color: Colors.white,
      margin: EdgeInsets.only(bottom: isMobile ? 12.0 : 16.0),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Colors.black12),
      ),
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 12.0 : 16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left Column (Slab Title & Metadata)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SkeletonBox(
                    width: isMobile ? 120.0 : 160.0,
                    height: isMobile ? 16.0 : 20.0,
                    borderRadius: 4.0,
                  ),
                  SizedBox(height: isMobile ? 8 : 12),
                  SkeletonBox(
                    width: isMobile ? 140.0 : 180.0,
                    height: isMobile ? 12.0 : 14.0,
                    borderRadius: 3.0,
                  ),
                  SizedBox(height: isMobile ? 4 : 6),
                  SkeletonBox(
                    width: isMobile ? 130.0 : 165.0,
                    height: isMobile ? 12.0 : 14.0,
                    borderRadius: 3.0,
                  ),
                  SizedBox(height: isMobile ? 6 : 8),
                  SkeletonBox(
                    width: isMobile ? 100.0 : 130.0,
                    height: isMobile ? 20.0 : 24.0,
                    borderRadius: 6.0,
                  ),
                ],
              ),
            ),
            SizedBox(width: isMobile ? 8 : 12),
            // Right Column (3 Buttons + Status Circle)
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                SkeletonBox(
                  width: isMobile ? 18.0 : 22.0,
                  height: isMobile ? 18.0 : 22.0,
                  borderRadius: 11.0,
                ),
                SizedBox(height: isMobile ? 4 : 8),
                SkeletonBox(
                    width: btnWidth, height: btnHeight, borderRadius: 7.0),
                SizedBox(height: isMobile ? 3 : 6),
                SkeletonBox(
                    width: btnWidth, height: btnHeight, borderRadius: 7.0),
                SizedBox(height: isMobile ? 3 : 6),
                SkeletonBox(
                    width: btnWidth, height: btnHeight, borderRadius: 7.0),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class RevisionSkeletonScreen extends StatelessWidget {
  final bool isMobile;
  final int itemCount;

  const RevisionSkeletonScreen({
    Key? key,
    required this.isMobile,
    this.itemCount = 3,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xfff8f9fa),
      child: Stack(
        children: [
          ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 12.0 : 24.0,
              vertical: isMobile ? 8.0 : 16.0,
            ),
            itemCount: itemCount,
            itemBuilder: (context, index) {
              return RevisionSkeletonCard(isMobile: isMobile);
            },
          ),
          Center(
            child: SizedBox(
              height: 64,
              child: OverflowBox(
                minHeight: 100,
                maxHeight: 100,
                child: Lottie.asset(
                  'assets/animation/running2.json',
                  repeat: true,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class RevisionSkeletonCard extends StatelessWidget {
  final bool isMobile;

  const RevisionSkeletonCard({Key? key, required this.isMobile}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: isMobile ? 10.0 : 16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xffe9ecef)),
      ),
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 12.0 : 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SkeletonBox(
                  width: isMobile ? 75.0 : 100.0,
                  height: isMobile ? 22.0 : 26.0,
                  borderRadius: 12.0,
                ),
                SkeletonBox(
                  width: isMobile ? 16.0 : 20.0,
                  height: isMobile ? 16.0 : 20.0,
                  borderRadius: 10.0,
                ),
              ],
            ),
            SizedBox(height: isMobile ? 10 : 14),
            SkeletonBox(
              width: isMobile ? 220.0 : 340.0,
              height: isMobile ? 13.0 : 15.0,
              borderRadius: 4.0,
            ),
            SizedBox(height: isMobile ? 6 : 8),
            SkeletonBox(
              width: isMobile ? 160.0 : 260.0,
              height: isMobile ? 13.0 : 15.0,
              borderRadius: 4.0,
            ),
          ],
        ),
      ),
    );
  }
}


class IssueReportSkeletonScreen extends StatelessWidget {
  final bool isMobile;
  final int itemCount;

  const IssueReportSkeletonScreen({
    Key? key,
    required this.isMobile,
    this.itemCount = 2,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xfff8f9fa),
      child: Stack(
        children: [
          ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 12.0 : 24.0,
              vertical: isMobile ? 8.0 : 16.0,
            ),
            itemCount: itemCount,
            itemBuilder: (context, index) {
              return IssueReportSkeletonCard(isMobile: isMobile);
            },
          ),
          Center(
            child: SizedBox(
              height: 64,
              child: OverflowBox(
                minHeight: 100,
                maxHeight: 100,
                child: Lottie.asset(
                  'assets/animation/running2.json',
                  repeat: true,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class IssueReportSkeletonCard extends StatelessWidget {
  final bool isMobile;

  const IssueReportSkeletonCard({Key? key, required this.isMobile}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: isMobile ? 10.0 : 14.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xffe9ecef)),
      ),
      padding: EdgeInsets.all(isMobile ? 12.0 : 16.0),
      child: isMobile
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Mobile Top Section: Image on left, Status & Action button column on right
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SkeletonBox(
                      width: 90.0,
                      height: 90.0,
                      borderRadius: 10.0,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          SkeletonBox(
                            width: 95.0,
                            height: 22.0,
                            borderRadius: 16.0,
                          ),
                          const SizedBox(height: 10),
                          SkeletonBox(
                            width: 105.0,
                            height: 26.0,
                            borderRadius: 16.0,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(height: 1, color: Color(0xffe9ecef)),
                const SizedBox(height: 10),

                // Mobile Bottom Section: Left-aligned metadata placeholders
                SkeletonBox(
                  width: 220.0,
                  height: 13.0,
                  borderRadius: 4.0,
                ),
                const SizedBox(height: 7),
                SkeletonBox(
                  width: 160.0,
                  height: 13.0,
                  borderRadius: 4.0,
                ),
                const SizedBox(height: 7),
                SkeletonBox(
                  width: 240.0,
                  height: 13.0,
                  borderRadius: 4.0,
                ),
                const SizedBox(height: 7),
                SkeletonBox(
                  width: 190.0,
                  height: 13.0,
                  borderRadius: 4.0,
                ),
                const SizedBox(height: 7),
                SkeletonBox(
                  width: double.infinity,
                  height: 13.0,
                  borderRadius: 4.0,
                ),
              ],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Desktop Image
                SkeletonBox(
                  width: 130.0,
                  height: 130.0,
                  borderRadius: 10.0,
                ),
                const SizedBox(width: 18),
                // Desktop Details Column
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SkeletonBox(
                        width: 240.0,
                        height: 15.0,
                        borderRadius: 4.0,
                      ),
                      const SizedBox(height: 8),
                      SkeletonBox(
                        width: 320.0,
                        height: 14.0,
                        borderRadius: 4.0,
                      ),
                      const SizedBox(height: 8),
                      SkeletonBox(
                        width: 280.0,
                        height: 14.0,
                        borderRadius: 4.0,
                      ),
                      const SizedBox(height: 8),
                      SkeletonBox(
                        width: 180.0,
                        height: 14.0,
                        borderRadius: 4.0,
                      ),
                      const SizedBox(height: 8),
                      SkeletonBox(
                        width: double.infinity,
                        height: 14.0,
                        borderRadius: 4.0,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                // Desktop Status & Button Column
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    SkeletonBox(
                      width: 110.0,
                      height: 26.0,
                      borderRadius: 16.0,
                    ),
                    const SizedBox(height: 12),
                    SkeletonBox(
                      width: 115.0,
                      height: 30.0,
                      borderRadius: 16.0,
                    ),
                  ],
                ),
              ],
            ),
    );
  }
}

class SlabStatusSkeletonScreen extends StatelessWidget {
  final bool isMobile;

  const SlabStatusSkeletonScreen({
    Key? key,
    required this.isMobile,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xfff8f9fa),
      child: Stack(
        children: [
          SingleChildScrollView(
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 12.0 : 24.0,
              vertical: isMobile ? 10.0 : 16.0,
            ),
            child: Column(
              children: [
                SlabStatusSkeletonCard(isMobile: isMobile),
                const SizedBox(height: 12),
                SlabStatusSkeletonCard(isMobile: isMobile),
              ],
            ),
          ),
          Center(
            child: SizedBox(
              height: 64,
              child: OverflowBox(
                minHeight: 100,
                maxHeight: 100,
                child: Lottie.asset(
                  'assets/animation/running2.json',
                  repeat: true,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SlabStatusSkeletonCard extends StatelessWidget {
  final bool isMobile;

  const SlabStatusSkeletonCard({Key? key, required this.isMobile}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: isMobile ? 10.0 : 14.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xffe9ecef)),
      ),
      padding: EdgeInsets.all(isMobile ? 12.0 : 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SkeletonBox(
            width: isMobile ? 160.0 : 240.0,
            height: isMobile ? 15.0 : 18.0,
            borderRadius: 4.0,
          ),
          const SizedBox(height: 10),
          SkeletonBox(
            width: isMobile ? 220.0 : 340.0,
            height: isMobile ? 13.0 : 15.0,
            borderRadius: 4.0,
          ),
          const SizedBox(height: 8),
          SkeletonBox(
            width: isMobile ? 180.0 : 260.0,
            height: isMobile ? 13.0 : 15.0,
            borderRadius: 4.0,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              SkeletonBox(
                width: isMobile ? 70.0 : 90.0,
                height: isMobile ? 70.0 : 90.0,
                borderRadius: 8.0,
              ),
              const SizedBox(width: 10),
              SkeletonBox(
                width: isMobile ? 70.0 : 90.0,
                height: isMobile ? 70.0 : 90.0,
                borderRadius: 8.0,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class ExcavationSkeletonScreen extends StatelessWidget {
  final bool isMobile;

  const ExcavationSkeletonScreen({
    Key? key,
    required this.isMobile,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xfff8f9fa),
      child: Stack(
        children: [
          SingleChildScrollView(
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 12.0 : 24.0,
              vertical: isMobile ? 10.0 : 16.0,
            ),
            child: Column(
              children: [
                ExcavationSkeletonCard(isMobile: isMobile),
                const SizedBox(height: 12),
                ExcavationSkeletonCard(isMobile: isMobile),
                const SizedBox(height: 12),
                ExcavationSkeletonCard(isMobile: isMobile),
              ],
            ),
          ),
          Center(
            child: SizedBox(
              height: 64,
              child: OverflowBox(
                minHeight: 100,
                maxHeight: 100,
                child: Lottie.asset(
                  'assets/animation/running2.json',
                  repeat: true,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ExcavationSkeletonCard extends StatelessWidget {
  final bool isMobile;

  const ExcavationSkeletonCard({Key? key, required this.isMobile}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: isMobile ? 10.0 : 14.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xffe9ecef)),
      ),
      padding: EdgeInsets.all(isMobile ? 12.0 : 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SkeletonBox(
                width: isMobile ? 140.0 : 220.0,
                height: isMobile ? 15.0 : 18.0,
                borderRadius: 4.0,
              ),
              SkeletonBox(
                width: isMobile ? 70.0 : 100.0,
                height: isMobile ? 14.0 : 16.0,
                borderRadius: 4.0,
              ),
            ],
          ),
          const SizedBox(height: 10),
          SkeletonBox(
            width: isMobile ? 200.0 : 300.0,
            height: isMobile ? 13.0 : 15.0,
            borderRadius: 4.0,
          ),
          const SizedBox(height: 8),
          SkeletonBox(
            width: isMobile ? 160.0 : 240.0,
            height: isMobile ? 13.0 : 15.0,
            borderRadius: 4.0,
          ),
          const SizedBox(height: 8),
          SkeletonBox(
            width: isMobile ? 180.0 : 280.0,
            height: isMobile ? 13.0 : 15.0,
            borderRadius: 4.0,
          ),
        ],
      ),
    );
  }
}

class ExcavationDetailSkeletonScreen extends StatelessWidget {
  final bool isMobile;

  const ExcavationDetailSkeletonScreen({Key? key, required this.isMobile}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xfff8f9fa),
      child: Stack(
        children: [
          SingleChildScrollView(
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 12.0 : 24.0,
              vertical: isMobile ? 12.0 : 16.0,
            ),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xffe9ecef)),
              ),
              padding: EdgeInsets.all(isMobile ? 16.0 : 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SkeletonBox(width: isMobile ? 160 : 240, height: 20, borderRadius: 4),
                      SkeletonBox(width: isMobile ? 80 : 120, height: 24, borderRadius: 12),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SkeletonBox(width: double.infinity, height: 1, borderRadius: 0),
                  const SizedBox(height: 16),
                  for (int i = 0; i < 8; i++) ...[
                    Row(
                      children: [
                        SkeletonBox(width: isMobile ? 120 : 180, height: 16, borderRadius: 4),
                        const SizedBox(width: 16),
                        SkeletonBox(width: isMobile ? 140 : 220, height: 16, borderRadius: 4),
                      ],
                    ),
                    const SizedBox(height: 12),
                  ],
                ],
              ),
            ),
          ),
          Center(
            child: SizedBox(
              height: 64,
              child: OverflowBox(
                minHeight: 100,
                maxHeight: 100,
                child: Lottie.asset(
                  'assets/animation/running2.json',
                  repeat: true,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AddVehicleSkeletonScreen extends StatelessWidget {
  final bool isMobile;

  const AddVehicleSkeletonScreen({Key? key, required this.isMobile}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xfff8f9fa),
      child: Stack(
        children: [
          SingleChildScrollView(
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 12.0 : 24.0,
              vertical: isMobile ? 12.0 : 16.0,
            ),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xffe9ecef)),
              ),
              padding: EdgeInsets.all(isMobile ? 16.0 : 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (int i = 0; i < 6; i++) ...[
                    SkeletonBox(width: isMobile ? 120 : 160, height: 16, borderRadius: 4),
                    const SizedBox(height: 8),
                    SkeletonBox(width: double.infinity, height: 44, borderRadius: 8),
                    const SizedBox(height: 16),
                  ],
                ],
              ),
            ),
          ),
          Center(
            child: SizedBox(
              height: 64,
              child: OverflowBox(
                minHeight: 100,
                maxHeight: 100,
                child: Lottie.asset(
                  'assets/animation/running2.json',
                  repeat: true,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ChecklistSkeletonScreen extends StatelessWidget {
  final bool isMobile;
  final int itemCount;

  const ChecklistSkeletonScreen({
    Key? key,
    required this.isMobile,
    this.itemCount = 3,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xfff8f9fa),
      child: Stack(
        children: [
          ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 12.0 : 20.0,
              vertical: isMobile ? 12.0 : 16.0,
            ),
            itemCount: itemCount,
            itemBuilder: (context, index) {
              return ChecklistCardSkeleton(isMobile: isMobile);
            },
          ),
          Center(
            child: SizedBox(
              height: 64,
              child: OverflowBox(
                minHeight: 100,
                maxHeight: 100,
                child: Lottie.asset(
                  'assets/animation/running2.json',
                  repeat: true,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ChecklistCardSkeleton extends StatelessWidget {
  final bool isMobile;

  const ChecklistCardSkeleton({Key? key, required this.isMobile}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      margin: EdgeInsets.only(bottom: isMobile ? 12.0 : 16.0),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xffe9ecef)),
      ),
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 14.0 : 18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SkeletonBox(
                  width: isMobile ? 160.0 : 220.0,
                  height: isMobile ? 16.0 : 18.0,
                  borderRadius: 4.0,
                ),
                SkeletonBox(
                  width: isMobile ? 80.0 : 100.0,
                  height: isMobile ? 22.0 : 26.0,
                  borderRadius: 14.0,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SkeletonBox(
                  width: isMobile ? 120.0 : 180.0,
                  height: isMobile ? 14.0 : 16.0,
                  borderRadius: 4.0,
                ),
                SkeletonBox(
                  width: isMobile ? 80.0 : 95.0,
                  height: isMobile ? 28.0 : 32.0,
                  borderRadius: 16.0,
                ),
              ],
            ),
            const SizedBox(height: 10),
            SkeletonBox(
              width: isMobile ? 140.0 : 200.0,
              height: isMobile ? 14.0 : 16.0,
              borderRadius: 4.0,
            ),
            const SizedBox(height: 10),
            SkeletonBox(
              width: double.infinity,
              height: isMobile ? 14.0 : 16.0,
              borderRadius: 4.0,
            ),
          ],
        ),
      ),
    );
  }
}

class DprSkeletonScreen extends StatelessWidget {
  final bool isMobile;
  final int itemCount;

  const DprSkeletonScreen({
    Key? key,
    required this.isMobile,
    this.itemCount = 4,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xfff8f9fa),
      child: Stack(
        children: [
          ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 12.0 : 20.0,
              vertical: isMobile ? 12.0 : 16.0,
            ),
            itemCount: itemCount,
            itemBuilder: (context, index) {
              return DprCardSkeleton(isMobile: isMobile);
            },
          ),
          Center(
            child: SizedBox(
              height: 64,
              child: OverflowBox(
                minHeight: 100,
                maxHeight: 100,
                child: Lottie.asset(
                  'assets/animation/running2.json',
                  repeat: true,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DprCardSkeleton extends StatelessWidget {
  final bool isMobile;

  const DprCardSkeleton({Key? key, required this.isMobile}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      margin: EdgeInsets.only(bottom: isMobile ? 12.0 : 16.0),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xffe9ecef)),
      ),
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 14.0 : 18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SkeletonBox(
                  width: isMobile ? 120.0 : 160.0,
                  height: isMobile ? 16.0 : 18.0,
                  borderRadius: 4.0,
                ),
                SkeletonBox(
                  width: isMobile ? 70.0 : 90.0,
                  height: isMobile ? 24.0 : 28.0,
                  borderRadius: 14.0,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SkeletonBox(
                  width: isMobile ? 150.0 : 200.0,
                  height: isMobile ? 14.0 : 16.0,
                  borderRadius: 4.0,
                ),
                SkeletonBox(
                  width: isMobile ? 80.0 : 100.0,
                  height: isMobile ? 14.0 : 16.0,
                  borderRadius: 4.0,
                ),
              ],
            ),
            const SizedBox(height: 10),
            SkeletonBox(
              width: isMobile ? 130.0 : 180.0,
              height: isMobile ? 14.0 : 16.0,
              borderRadius: 4.0,
            ),
            const SizedBox(height: 10),
            SkeletonBox(
              width: isMobile ? 180.0 : 240.0,
              height: isMobile ? 14.0 : 16.0,
              borderRadius: 4.0,
            ),
          ],
        ),
      ),
    );
  }
}
