import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:stallion/utils/responsive.dart';
import 'package:lottie/lottie.dart';

//loader when some method or function calling or processing
class CustomLoading {
  String title = "";

  /// Skeleton type constants
  static const String skeletonDefault = 'default';
  static const String skeletonVerifyOtp = 'verify_otp';
  static const String skeletonProjectList = 'project_list';
  static const String skeletonPermissionList = 'permission_list';
  static const String skeletonTrackPermission = 'track_permission';
  static const String skeletonTaskManager = 'task_manager';
  static const String skeletonTaskDetails = 'task_details';
  static const String skeletonMeetingDetails = 'meeting_details';
  static const String skeletonAddTask = 'add_task';
  static const String skeletonCreateMeeting = 'create_meeting';
  static const String skeletonAssignMeeting = 'assign_meeting';
  static const String skeletonExtendDeadline = 'extend_deadline';
  static const String skeletonTaskRemarks = 'task_remarks';
  static const String skeletonTaskCount = 'task_count';

  static progressDialog(
      {required bool isLoading,
      required BuildContext context,
      title,
      noNeedOfLoading = false,
      double bgOpacity = 0,
      String skeletonType = skeletonDefault,
      bool isDark = false}) {
    if (noNeedOfLoading) return;
    if (!isLoading) {
      Navigator.of(context, rootNavigator: true).pop();
    } else {
      showDialog(
        barrierDismissible: false,
        context: context,
        useSafeArea: true,
        barrierColor: isDark ? Colors.black.withOpacity(0.95) : Colors.white.withOpacity(0.95),
        builder: (BuildContext context) {
          return WillPopScope(
              onWillPop: () async => false,
              child: _buildSkeleton(context, skeletonType, isDark: isDark));
        },
        useRootNavigator: true,
      );
    }
  }

  static Widget wrapWithHorseLoader(Widget skeleton, {bool isDark = false}) {
    return Stack(
      children: [
        skeleton,
        Center(
          child: SizedBox(
            height: 64,
            child: OverflowBox(
              minHeight: 100,
              maxHeight: 100,
              child: Lottie.asset(
                isDark ? 'assets/animation/running3.json' : 'assets/animation/running2.json',
                repeat: true,
              ),
            ),
          ),
        ),
      ],
    );
  }

  static Widget _buildSkeleton(BuildContext context, String skeletonType, {bool isDark = false}) {
    Widget skeleton;
    switch (skeletonType) {
      case skeletonVerifyOtp:
        skeleton = _buildVerifyOtpSkeleton(context, isDark: isDark);
        break;
      case skeletonProjectList:
        skeleton = _buildProjectListSkeleton(context);
        break;
      case skeletonPermissionList:
        skeleton = _buildPermissionListSkeleton(context);
        break;
      case skeletonTrackPermission:
        skeleton = _buildTrackPermissionSkeleton(context);
        break;
      case skeletonTaskManager:
        skeleton = buildTaskManagerSkeletonInline(context);
        break;
      case skeletonTaskDetails:
        skeleton = buildTaskDetailsSkeletonInline(context);
        break;
      case skeletonMeetingDetails:
        skeleton = buildMeetingDetailsSkeletonInline(context);
        break;
      case skeletonAddTask:
        skeleton = buildAddTaskSkeletonInline(context);
        break;
      case skeletonCreateMeeting:
        skeleton = buildCreateMeetingSkeletonInline(context);
        break;
      case skeletonAssignMeeting:
        skeleton = buildAssignMeetingSkeletonInline(context);
        break;
      case skeletonExtendDeadline:
        skeleton = buildExtendDeadlineSkeletonInline(context);
        break;
      case skeletonTaskRemarks:
        skeleton = buildTaskRemarksSkeletonInline(context);
        break;
      case skeletonTaskCount:
        skeleton = buildTaskCountSkeletonInline(context);
        break;
      default:
        skeleton = _buildDefaultSkeleton();
        break;
    }
    return wrapWithHorseLoader(skeleton, isDark: isDark);
  }

  /// Generic compact skeleton for general use
  static Widget _buildDefaultSkeleton() {
    return Center(
      child: Shimmer.fromColors(
        baseColor: const Color(0xFFF0F0F0),
        highlightColor: const Color(0xFFF9F9F9),
        period: const Duration(milliseconds: 1500),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              width: 120,
              height: 14,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// OTP form skeleton content (used by both mobile and desktop)
  static Widget _buildOtpFormContent({bool isDark = false}) {
    return Shimmer.fromColors(
        baseColor: isDark ? const Color(0xFF1C1C1E) : const Color(0xFFF0F0F0),
        highlightColor: isDark ? const Color(0xFF2C2C2E) : const Color(0xFFF9F9F9),
      period: const Duration(milliseconds: 1500),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Logo placeholder
          Container(
            width: 170,
            height: 170,
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[850] : Colors.white,
              borderRadius: BorderRadius.circular(24),
            ),
          ),
          const SizedBox(height: 16),

          // Title placeholder ("Verification Code")
          Container(
            width: 200,
            height: 28,
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[850] : Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const SizedBox(height: 8),

          // Subtitle placeholder
          Container(
            width: 260,
            height: 16,
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[850] : Colors.white,
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          const SizedBox(height: 32),

          // PIN code fields placeholder (4 boxes)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                  4,
                  (index) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: isDark ? Colors.grey[850] : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      )),
            ),
          ),
          const SizedBox(height: 16),

          // Resend text placeholder
          Container(
            width: 220,
            height: 14,
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[850] : Colors.white,
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          const SizedBox(height: 32),

          // Verify button placeholder
          Container(
            width: double.infinity,
            height: 52,
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[850] : Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          const SizedBox(height: 16),

          // Back button placeholder
          Container(
            width: double.infinity,
            height: 52,
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[850] : Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ],
      ),
    );
  }

  /// Carousel skeleton for desktop right panel
  static Widget _buildCarouselSkeleton({bool isDark = false}) {
    return Shimmer.fromColors(
      baseColor: isDark ? const Color(0xFF1C1C1E) : const Color(0xFFF0F0F0),
      highlightColor: isDark ? const Color(0xFF2C2C2E) : const Color(0xFFF9F9F9),
      period: const Duration(milliseconds: 1500),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Image placeholder
          Container(
            margin: const EdgeInsets.fromLTRB(50, 0, 50, 0),
            height: 400,
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[850] : Colors.white,
              borderRadius: BorderRadius.circular(5),
            ),
          ),
          const SizedBox(height: 16),
          // Header placeholder
          Container(
            width: 220,
            height: 16,
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[850] : Colors.white,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 12),
          // Subheader placeholders
          Container(
            width: 180,
            height: 13,
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[850] : Colors.white,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 6),
          Container(
            width: 160,
            height: 13,
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[850] : Colors.white,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 6),
          Container(
            width: 170,
            height: 13,
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[850] : Colors.white,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ),
    );
  }

  /// Full-screen skeleton matching the verify OTP screen layout
  /// Responsive: mobile shows just the form, desktop shows split layout with carousel
  static Widget _buildVerifyOtpSkeleton(BuildContext context, {bool isDark = false}) {
    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final isDesktop = width > 1024;

          if (isDesktop) {
            // Desktop: split layout matching TutorialScreen
            return Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Left: OTP form skeleton (flex: 7)
                Expanded(
                  flex: 7,
                  child: Container(
                    color: isDark ? Colors.black : Colors.white,
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 460),
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 40.0, vertical: 24.0),
                          child: _buildOtpFormContent(isDark: isDark),
                        ),
                      ),
                    ),
                  ),
                ),
                // Right: Carousel skeleton (flex: 13)
                Expanded(
                  flex: 13,
                  child: Container(
                    color: isDark ? const Color(0xff121212) : const Color(0xfff7f7f7),
                    child: Center(
                      child: _buildCarouselSkeleton(isDark: isDark),
                    ),
                  ),
                ),
              ],
            );
          }
          // Mobile/Tablet: just the OTP form centered
          return SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24.0, vertical: 24.0),
                  child: _buildOtpFormContent(isDark: isDark),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  /// Skeleton matching the project list screen (My Projects page)
  /// Shows the AppBar skeleton + grid of project card skeletons
  static Widget _buildProjectListSkeleton(BuildContext context) {
    final isMobile = context.isMobile;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: Shimmer.fromColors(
          baseColor: const Color(0xFFF0F0F0),
          highlightColor: const Color(0xFFF9F9F9),
          child: Container(
            margin: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
        centerTitle: true,
        title: Shimmer.fromColors(
          baseColor: const Color(0xFFE0E0E0),
          highlightColor: const Color(0xFFF5F5F5),
          child: Container(
            width: 80,
            height: 20,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(isMobile ? 16.0 : 24.0),
          child: Shimmer.fromColors(
            baseColor: const Color(0xFFF0F0F0),
            highlightColor: const Color(0xFFF9F9F9),
            period: const Duration(milliseconds: 1500),
            child: isMobile
                ? GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 0.68,
                    ),
                    itemCount: 6,
                    itemBuilder: (context, index) => _buildProjectCardSkeleton(),
                  )
                : Wrap(
                    direction: Axis.horizontal,
                    alignment: WrapAlignment.start,
                    children: List.generate(6, (index) {
                      return Padding(
                        padding: const EdgeInsets.only(
                            left: 12.0, top: 12.0, bottom: 20.0),
                        child: Container(
                          margin: const EdgeInsets.only(
                            left: 20.0,
                            top: 20.0,
                            bottom: 20.0,
                            right: 30.0,
                          ),
                          width: 145,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                height: 185,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              const SizedBox(height: 10),
                              Container(
                                width: 100,
                                height: 14,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Container(
                                width: 70,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ),
          ),
        ),
      ),
    );
  }

  /// Single project card skeleton
  static Widget _buildProjectCardSkeleton() {
    return Container(
      color: Colors.transparent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: double.infinity,
            height: 170,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
            child: Column(
              children: [
                Container(
                  width: 100,
                  height: 13,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 5),
                Container(
                  width: 70,
                  height: 10,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Skeleton matching the permission list screen layout
  /// Shows a mock AppBar + title/filter row + search bar + list of permission card skeletons + bottom tabs
  static Widget _buildPermissionListSkeleton(BuildContext context) {
    final bool isMobile = context.isMobile;
    final double horizontalPadding = isMobile ? 16.0 : 40.0;

    Widget skeletonContent = Shimmer.fromColors(
      baseColor: const Color(0xFFF0F0F0),
      highlightColor: const Color(0xFFF9F9F9),
      period: const Duration(milliseconds: 1500),
      child: Column(
        children: [
          // Header Row (Toolbar: filter & title)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                const Spacer(),
                Container(
                  width: 100,
                  height: 15,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const Spacer(),
                const SizedBox(width: 36),
              ],
            ),
          ),
          const Divider(color: Color(0xfff0f0f0), height: 1.0),

          // Search bar skeleton
          Padding(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 12),
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),

          // Permission card skeletons
          ...List.generate(4, (index) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Row 1: Name + checkmark + status badge
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 15,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Checkmark circle
                      Container(
                        width: 16,
                        height: 16,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Status badge pill (fixed width 120)
                      Container(
                        width: 120,
                        height: 22,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Row 2: Expiry Date + Upload button
                  Row(
                    children: [
                      Container(
                        width: 120,
                        height: 24,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 70,
                        height: 24,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Row 3: Remark + LOD link
                  Row(
                    children: [
                      Container(
                        width: 160,
                        height: 12,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const Spacer(),
                      Container(
                        width: 30,
                        height: 12,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          )),
        ],
      ),
    );

    Widget scaffoldContent = Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
        centerTitle: true,
        title: Shimmer.fromColors(
          baseColor: const Color(0xFFF0F0F0),
          highlightColor: const Color(0xFFF9F9F9),
          child: Container(
            width: 150,
            height: 18,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
            child: Shimmer.fromColors(
              baseColor: const Color(0xFFF0F0F0),
              highlightColor: const Color(0xFFF9F9F9),
              child: Container(
                width: 60,
                height: 28,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(child: skeletonContent),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(color: Color(0xfff0f0f0), width: 1.0),
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
        child: SafeArea(
          child: Container(
            height: 52,
            decoration: BoxDecoration(
              color: const Color(0xfff8f9fa),
              borderRadius: BorderRadius.circular(16.0),
              border: Border.all(color: const Color(0xffe9ecef), width: 1.0),
            ),
            child: Shimmer.fromColors(
              baseColor: const Color(0xFFF0F0F0),
              highlightColor: const Color(0xFFF9F9F9),
              child: Row(
                children: List.generate(4, (index) => Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: Center(
                        child: Container(
                          width: 40,
                          height: 12,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),
                  ),
                )),
              ),
            ),
          ),
        ),
      ),
    );

    return scaffoldContent;
  }

  /// Skeleton matching the track permissions dashboard layout
  /// Shows mock AppBar + "TRACK PERMISSIONS" title + Table Header card + 5 employee row cards
  static Widget _buildTrackPermissionSkeleton(BuildContext context) {
    final bool isMobile = context.isMobile;
    final double horizontalPadding = isMobile ? 16.0 : 40.0;

    Widget skeletonContent = Shimmer.fromColors(
      baseColor: const Color(0xFFF0F0F0),
      highlightColor: const Color(0xFFF9F9F9),
      period: const Duration(milliseconds: 1500),
      child: Column(
        children: [
          // Section Title
          Container(
            padding: const EdgeInsets.only(top: 16, bottom: 12),
            width: double.maxFinite,
            child: Center(
              child: Container(
                width: 160,
                height: 16,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
          
          // Mock Table Header Card
          Container(
            margin: EdgeInsets.fromLTRB(horizontalPadding, 16.0, horizontalPadding, 8.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.0),
            ),
            padding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 16.0),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Container(
                    height: 14,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Center(
                    child: Container(
                      width: 80,
                      height: 14,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Center(
                    child: Container(
                      width: 50,
                      height: 14,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Scrollable list of employee rows
          ...List.generate(5, (index) => Container(
            margin: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 5.0),
            padding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 16.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Container(
                    height: 15,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Center(
                    child: Container(
                      width: 40,
                      height: 15,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Center(
                    child: Container(
                      width: 60,
                      height: 30,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );

    Widget scaffoldContent = Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
        centerTitle: true,
        title: Shimmer.fromColors(
          baseColor: const Color(0xFFF0F0F0),
          highlightColor: const Color(0xFFF9F9F9),
          child: Container(
            width: 150,
            height: 18,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(child: skeletonContent),
    );

    return scaffoldContent;
  }

  static Widget buildPermissionListSkeletonInline(BuildContext context) {
    return wrapWithHorseLoader(
      Shimmer.fromColors(
        baseColor: const Color(0xFFF0F0F0),
        highlightColor: const Color(0xFFF9F9F9),
        period: const Duration(milliseconds: 1500),
        child: SingleChildScrollView(
          child: Column(
            children: List.generate(4, (index) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xfff0f0f0), width: 1.0),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Row 1: Name + checkmark + status badge
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 15,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Checkmark circle
                        Container(
                          width: 16,
                          height: 16,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Status badge pill (fixed width 100)
                        Container(
                          width: 100,
                          height: 22,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Row 2: Expiry Date + Upload button
                    Row(
                      children: [
                        Container(
                          width: 120,
                          height: 24,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          width: 70,
                          height: 24,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Row 3: Remark + LOD link
                    Row(
                      children: [
                        Container(
                          width: 160,
                          height: 12,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const Spacer(),
                        Container(
                          width: 30,
                          height: 12,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            )),
          ),
        ),
      ),
    );
  }

  static Widget buildLegalListSkeletonInline(BuildContext context) {
    final bool isMobile = context.isMobile;

    return wrapWithHorseLoader(
      Shimmer.fromColors(
        baseColor: const Color(0xFFF0F0F0),
        highlightColor: const Color(0xFFF9F9F9),
        period: const Duration(milliseconds: 1500),
        child: SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          child: Column(
            children: List.generate(4, (index) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 2.0),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                padding: EdgeInsets.all(isMobile ? 12.0 : 16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14.0),
                  border: Border.all(color: const Color(0xfff0f0f0), width: 1.0),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 140,
                          height: 16,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Container(
                          width: 18,
                          height: 18,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const Spacer(),
                        // Status Badge Capsule
                        Container(
                          width: 90,
                          height: 24,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Row 2: Notify date button, View documents button
                    Row(
                      children: [
                        Container(
                          width: 130,
                          height: 24,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        const Spacer(),
                        Container(
                          width: 130,
                          height: 24,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Row 3: Initiated date text, Upload button
                    Row(
                      children: [
                        Container(
                          width: 160,
                          height: 14,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const Spacer(),
                        Container(
                          width: 80,
                          height: 24,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Row 4: Remark
                    Row(
                      children: [
                        Container(
                          width: 200,
                          height: 14,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const Spacer(),
                        Container(
                          width: 80,
                          height: 14,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            )),
          ),
        ),
      ),
    );
  }

  static Widget buildLegalDocsSkeletonInline(BuildContext context) {
    final bool isMobile = context.isMobile;

    return wrapWithHorseLoader(
      Shimmer.fromColors(
        baseColor: const Color(0xFFF0F0F0),
        highlightColor: const Color(0xFFF9F9F9),
        period: const Duration(milliseconds: 1500),
        child: SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          child: Column(
            children: List.generate(4, (index) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 2.0),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                padding: EdgeInsets.all(isMobile ? 12.0 : 16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14.0),
                  border: Border.all(color: const Color(0xfff0f0f0), width: 1.0),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Row 1: subLegalName + uploadFlag checkmark
                    Row(
                      children: [
                        Container(
                          width: 180,
                          height: 16,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Container(
                          width: 18,
                          height: 18,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Row 2: Notify date button + Upload button
                    Row(
                      children: [
                        Container(
                          width: 150,
                          height: 24,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        const Spacer(),
                        Container(
                          width: 80,
                          height: 24,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Row 3: Initiated On date text
                    Row(
                      children: [
                        Container(
                          width: 160,
                          height: 14,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            )),
          ),
        ),
      ),
    );
  }

  static Widget buildCategorySkeletonInline(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: const Color(0xFFE9ECEF),
      highlightColor: const Color(0xFFF8F9FA),
      period: const Duration(milliseconds: 1500),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(4, (index) => Container(
            width: 70,
            height: 34,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10.0),
            ),
          )),
        ),
      ),
    );
  }

  static Widget buildSopListSkeletonInline(BuildContext context) {
    final bool isMobile = context.isMobile;
    return wrapWithHorseLoader(
      Shimmer.fromColors(
        baseColor: const Color(0xFFF0F0F0),
        highlightColor: const Color(0xFFF9F9F9),
        period: const Duration(milliseconds: 1500),
        child: SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          child: Column(
            children: List.generate(
              6,
              (index) => Container(
                padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 80, vertical: 12),
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: Colors.black12)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 16,
                        margin: const EdgeInsets.only(right: 10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Center(
                        child: Container(
                          width: isMobile ? 60 : 80,
                          height: 16,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Container(
                          width: isMobile ? 85 : 110,
                          height: 28,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  static Widget buildSopDetailsSkeletonInline(BuildContext context) {
    final bool isMobile = context.isMobile;
    return wrapWithHorseLoader(
      Shimmer.fromColors(
        baseColor: const Color(0xFFF0F0F0),
        highlightColor: const Color(0xFFF9F9F9),
        period: const Duration(milliseconds: 1500),
        child: SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          child: Column(
            children: List.generate(
              4,
              (index) => Container(
                margin: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 60, vertical: 6),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xfff0f0f0)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 150,
                          height: 18,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const Spacer(),
                        Container(
                          width: 20,
                          height: 20,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  static Widget buildSopDocsSkeletonInline(BuildContext context) {
    final bool isMobile = context.isMobile;
    return wrapWithHorseLoader(
      Shimmer.fromColors(
        baseColor: const Color(0xFFF0F0F0),
        highlightColor: const Color(0xFFF9F9F9),
        period: const Duration(milliseconds: 1500),
        child: SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          child: Column(
            children: List.generate(
              3,
              (index) => Container(
                padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 80, vertical: 12),
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: Colors.black12)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: isMobile ? 100 : 150,
                          height: 16,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Container(
                            height: 16,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Container(
                          width: isMobile ? 100 : 150,
                          height: 16,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Container(
                            height: 16,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Container(
                          width: isMobile ? 100 : 150,
                          height: 16,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Container(
                          width: 100,
                          height: 16,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const Spacer(),
                        Container(
                          width: 80,
                          height: 30,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  static Widget buildSopTrackSkeletonInline(BuildContext context) {
    final bool isMobile = context.isMobile;
    return wrapWithHorseLoader(
      Shimmer.fromColors(
        baseColor: const Color(0xFFF0F0F0),
        highlightColor: const Color(0xFFF9F9F9),
        period: const Duration(milliseconds: 1500),
        child: SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          child: Column(
            children: List.generate(
              5,
              (index) => Container(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                margin: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 40, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xfff0f0f0)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Container(
                        height: 16,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 3,
                      child: Container(
                        height: 16,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: Container(
                        height: 28,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Skeleton loader matching TaskManagerScreen layout
  static Widget buildTaskManagerSkeletonInline(BuildContext context) {
    final bool isMobile = context.isMobile;
    final double padding = isMobile ? 16.0 : 32.0;

    return wrapWithHorseLoader(
      Shimmer.fromColors(
        baseColor: const Color(0xFFF0F0F0),
        highlightColor: const Color(0xFFF9F9F9),
        period: const Duration(milliseconds: 1500),
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: padding, vertical: 16),
          child: Column(
            children: [
              // Search & Filter Capsule Bar
              Container(
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              const SizedBox(height: 16),
              // Segment toggle capsule bar
              Container(
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                ),
              ),
              const SizedBox(height: 20),
              // List of Task Cards
              ...List.generate(
                4,
                (index) => Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFF0F0F0)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 18,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            width: 80,
                            height: 24,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Container(
                            width: 120,
                            height: 14,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const Spacer(),
                          Container(
                            width: 90,
                            height: 14,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Skeleton loader matching TaskDetailsScreen layout
  static Widget buildTaskDetailsSkeletonInline(BuildContext context) {
    final bool isMobile = context.isMobile;
    final double padding = isMobile ? 16.0 : 32.0;

    return wrapWithHorseLoader(
      Shimmer.fromColors(
        baseColor: const Color(0xFFF0F0F0),
        highlightColor: const Color(0xFFF9F9F9),
        period: const Duration(milliseconds: 1500),
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: padding, vertical: 20),
          child: Column(
            children: [
              // Header title card
              Container(
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              const SizedBox(height: 16),
              // Task details info card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: List.generate(
                    4,
                    (index) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        children: [
                          Container(
                            width: 100,
                            height: 14,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const Spacer(),
                          Container(
                            width: 140,
                            height: 14,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Bottom capsule action buttons
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Skeleton loader matching MeetingDetailsScreen layout
  static Widget buildMeetingDetailsSkeletonInline(BuildContext context) {
    final bool isMobile = context.isMobile;
    final double padding = isMobile ? 16.0 : 32.0;

    return wrapWithHorseLoader(
      Shimmer.fromColors(
        baseColor: const Color(0xFFF0F0F0),
        highlightColor: const Color(0xFFF9F9F9),
        period: const Duration(milliseconds: 1500),
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: padding, vertical: 20),
          child: Column(
            children: [
              // Meeting header card
              Container(
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              const SizedBox(height: 16),
              // Participants avatar row
              Row(
                children: List.generate(
                  4,
                  (index) => Container(
                    margin: const EdgeInsets.only(right: 8),
                    width: 36,
                    height: 36,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Linked task cards
              ...List.generate(
                3,
                (index) => Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  height: 70,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Skeleton loader matching AddTaskScreen & CreateNewMeetingScreen layout
  static Widget buildAddTaskSkeletonInline(BuildContext context) {
    final bool isMobile = context.isMobile;
    final double padding = isMobile ? 16.0 : 32.0;

    return wrapWithHorseLoader(
      Shimmer.fromColors(
        baseColor: const Color(0xFFF0F0F0),
        highlightColor: const Color(0xFFF9F9F9),
        period: const Duration(milliseconds: 1500),
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: padding, vertical: 20),
          child: Column(
            children: [
              ...List.generate(
                4,
                (index) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Container(
                    height: 52,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                height: 50,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget buildCreateMeetingSkeletonInline(BuildContext context) {
    return buildAddTaskSkeletonInline(context);
  }

  /// Skeleton loader matching AssignMeeting & ExtendDeadlinePage layout
  static Widget buildAssignMeetingSkeletonInline(BuildContext context) {
    return buildAddTaskSkeletonInline(context);
  }

  static Widget buildExtendDeadlineSkeletonInline(BuildContext context) {
    return buildAddTaskSkeletonInline(context);
  }

  /// Skeleton loader matching TaskRemarks layout
  static Widget buildTaskRemarksSkeletonInline(BuildContext context) {
    final bool isMobile = context.isMobile;
    final double padding = isMobile ? 16.0 : 32.0;

    return wrapWithHorseLoader(
      Shimmer.fromColors(
        baseColor: const Color(0xFFF0F0F0),
        highlightColor: const Color(0xFFF9F9F9),
        period: const Duration(milliseconds: 1500),
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: padding, vertical: 20),
          child: Column(
            children: List.generate(
              3,
              (index) => Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 140,
                      height: 14,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      height: 30,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Skeleton loader matching TaskCountScreen layout
  static Widget buildTaskCountSkeletonInline(BuildContext context) {
    final bool isMobile = context.isMobile;
    final double padding = isMobile ? 16.0 : 32.0;

    return wrapWithHorseLoader(
      Shimmer.fromColors(
        baseColor: const Color(0xFFF0F0F0),
        highlightColor: const Color(0xFFF9F9F9),
        period: const Duration(milliseconds: 1500),
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: padding, vertical: 20),
          child: Column(
            children: [
              // User header card
              Container(
                height: 90,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              const SizedBox(height: 16),
              // Summary Stat Cards Grid
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: isMobile ? 2 : 4,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.4,
                children: List.generate(
                  4,
                  (index) => Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Skeleton loader matching RCC TaskListScreen layout
  static Widget buildRccTaskListSkeletonInline(BuildContext context) {
    final bool isMobile = context.isMobile;
    final double padding = isMobile ? 12.0 : 24.0;

    return wrapWithHorseLoader(
      Shimmer.fromColors(
        baseColor: const Color(0xFFF0F0F0),
        highlightColor: const Color(0xFFF9F9F9),
        period: const Duration(milliseconds: 1500),
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: padding, vertical: 12),
          child: Column(
            children: [
              // Search Capsule Bar
              Container(
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                ),
              ),
              const SizedBox(height: 12),
              // Segment toggle capsule bar
              Container(
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                ),
              ),
              const SizedBox(height: 16),
              // List of RCC Task Cards
              ...List.generate(
                4,
                (index) => Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFF0F0F0)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 18,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            width: 24,
                            height: 24,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Divider(height: 1, color: Color(0xFFF0F0F0)),
                      const SizedBox(height: 10),
                      ...List.generate(
                        4,
                        (r) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              Container(
                                width: 100,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                              const Spacer(),
                              Container(
                                width: 120,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Skeleton loader matching RccTaskDetails layout
  static Widget buildRccTaskDetailsSkeletonInline(BuildContext context) {
    final bool isMobile = context.isMobile;
    final double padding = isMobile ? 12.0 : 24.0;

    return wrapWithHorseLoader(
      Shimmer.fromColors(
        baseColor: const Color(0xFFF0F0F0),
        highlightColor: const Color(0xFFF9F9F9),
        period: const Duration(milliseconds: 1500),
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: padding, vertical: 16),
          child: Column(
            children: [
              // Header title card
              Container(
                height: 90,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              const SizedBox(height: 14),
              // Task details info card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: List.generate(
                    5,
                    (index) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        children: [
                          Container(
                            width: 90,
                            height: 13,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const Spacer(),
                          Container(
                            width: 130,
                            height: 13,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              // Remarks Box Card
              Container(
                height: 90,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              const SizedBox(height: 16),
              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 46,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(23),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      height: 46,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(23),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Skeleton loader matching RccTaskRemarks layout
  static Widget buildRccTaskRemarksSkeletonInline(BuildContext context) {
    final bool isMobile = context.isMobile;
    final double padding = isMobile ? 12.0 : 24.0;

    return wrapWithHorseLoader(
      Shimmer.fromColors(
        baseColor: const Color(0xFFF0F0F0),
        highlightColor: const Color(0xFFF9F9F9),
        period: const Duration(milliseconds: 1500),
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: padding, vertical: 16),
          child: Column(
            children: List.generate(
              3,
              (index) => Container(
                margin: const EdgeInsets.only(bottom: 14),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFF0F0F0)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 110,
                          height: 16,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const Spacer(),
                        Container(
                          width: 80,
                          height: 14,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Divider(height: 1, color: Color(0xFFF0F0F0)),
                    const SizedBox(height: 10),
                    ...List.generate(
                      3,
                      (r) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            Container(
                              width: 90,
                              height: 12,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            const Spacer(),
                            Container(
                              width: 120,
                              height: 12,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}


