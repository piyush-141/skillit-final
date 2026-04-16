import 'package:flutter/material.dart';
import 'dart:ui';
import 'dart:math' as math;
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../main.dart';
import '../data/mock_roadmaps.dart';
import '../services/api_service.dart';

class RoadmapScreen extends StatefulWidget {
  final bool hideAppBar;
  final String? initialRoadmapId;
  const RoadmapScreen(
      {Key? key, this.hideAppBar = false, this.initialRoadmapId})
      : super(key: key);

  @override
  State<RoadmapScreen> createState() => _RoadmapScreenState();
}

class _RoadmapScreenState extends State<RoadmapScreen>
    with TickerProviderStateMixin {
  late AnimationController _floatingController;
  late AnimationController _headerController;

  String? _selectedRoadmapId;
  CareerRoadmap? _selectedRoadmap;
  List<CareerRoadmap> _allRoadmaps = [];
  bool _isLoadingRoadmaps = true;

  // Progress tracking
  Set<String> _completedItems = {};
  bool _isLoadingProgress = false;

  @override
  void initState() {
    super.initState();

    _floatingController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat(reverse: true);

    _headerController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..forward();

    _loadUserProgress();
    _loadRoadmaps();
  }

  Future<void> _loadRoadmaps() async {
    setState(() => _isLoadingRoadmaps = true);
    try {
      final data = await ApiService.getRoadmaps();
      if (data != null && data['fields'] != null) {
        final List<dynamic> fields = data['fields'];
        setState(() {
          _allRoadmaps = fields
              .map((f) => CareerRoadmap(
                    id: f['id'],
                    title: f['label'],
                    description: f['tagline'] ?? "",
                    emoji:
                        "◦", // Backend doesn't have emoji yet, using placeholder
                    difficulty: "Intermediate",
                    totalWeeks: 12,
                    steps: (f['roadmap'] as List)
                        .map((s) => RoadmapStep(
                              title: s['title'] ?? "Untitled Step",
                              description: s['description'] ?? s['title'] ?? "",
                              skills: s['skills'] != null
                                  ? List<String>.from(s['skills'])
                                  : [],
                              durationWeeks: s['durationWeeks'] ?? 1,
                            ))
                        .toList(),
                    courses: (f['resources'] as List)
                        .map((r) => RoadmapCourse(
                              title: r['title'] ?? "Untitled Resource",
                              platform:
                                  r['platform'] ?? r['channel'] ?? "YouTube",
                              url: r['url'] ?? "",
                              duration: r['duration'] ?? "Varies",
                            ))
                        .toList(),
                  ))
              .toList();

          if (widget.initialRoadmapId != null) {
            _onRoadmapSelected(widget.initialRoadmapId);
          }
        });
      }
    } catch (e) {
      print("Error loading roadmaps: $e");
    } finally {
      setState(() => _isLoadingRoadmaps = false);
    }
  }

  @override
  void dispose() {
    _floatingController.dispose();
    _headerController.dispose();
    super.dispose();
  }

  Future<void> _loadUserProgress() async {
    setState(() => _isLoadingProgress = true);
    try {
      final profile = await ApiService.getUserProfile();
      if (profile != null && profile['completedNodes'] != null) {
        final List<dynamic> progress = profile['completedNodes'];
        setState(() {
          _completedItems = progress.map((id) => id.toString()).toSet();
        });
      }
    } catch (e) {
      print("Error loading progress: $e");
    } finally {
      setState(() => _isLoadingProgress = false);
    }
  }

  Future<void> _toggleProgress(String nodeId) async {
    final isCompleted = _completedItems.contains(nodeId);

    // Optimistic UI update
    setState(() {
      if (isCompleted) {
        _completedItems.remove(nodeId);
      } else {
        _completedItems.add(nodeId);
      }
    });

    try {
      final result =
          await ApiService.updateRoadmapProgress(nodeId, !isCompleted);
      if (result['error'] == true) {
        // Rollback on error
        setState(() {
          if (isCompleted) {
            _completedItems.add(nodeId);
          } else {
            _completedItems.remove(nodeId);
          }
        });
        _showErrorSnackBar("Failed to sync with database");
      }
    } catch (e) {
      _showErrorSnackBar("Network error occurred");
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _onRoadmapSelected(String? id) {
    setState(() {
      _selectedRoadmapId = id;
      _selectedRoadmap = id != null && _allRoadmaps.isNotEmpty
          ? _allRoadmaps.firstWhere((r) => r.id == id,
              orElse: () => _allRoadmaps.first)
          : null;
    });
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      _showErrorSnackBar("Could not open link");
    }
  }

  @override
  Widget build(BuildContext context) {
    final body = SafeArea(
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Header
          if (!widget.hideAppBar)
            SliverToBoxAdapter(
              child: _buildHeader(),
            ),

          // Dropdown selector
          SliverToBoxAdapter(
            child: _buildDropdownSection(),
          ),

          // Roadmap content
          if (_selectedRoadmap != null) ...[
            SliverToBoxAdapter(child: _buildRoadmapInfoCard()),
            SliverToBoxAdapter(
              child: _buildSectionHeader(
                'Learning Path',
                '${_selectedRoadmap!.steps.length} Stages',
              ),
            ),
            SliverToBoxAdapter(child: _buildTimeline()),
            SliverToBoxAdapter(
              child: _buildSectionHeader(
                'Handpicked Resources',
                '${_selectedRoadmap!.courses.length} Links',
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    return _buildCourseCard(
                        _selectedRoadmap!.courses[index], index);
                  },
                  childCount: _selectedRoadmap!.courses.length,
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 40)),
          ] else
            SliverToBoxAdapter(child: _buildEmptyState()),
        ],
      ),
    );

    if (widget.hideAppBar) {
      return Material(
        color: AppColors.background,
        child: body,
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: body,
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 24, 0),
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(-1, 0),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: _headerController,
          curve: Curves.easeOut,
        )),
        child: Row(
          children: [
            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: AppColors.shadow,
                ),
                child: const Icon(
                  Icons.arrow_back_ios_new,
                  color: AppColors.textPrimary,
                  size: 18,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Roadmaps',
                    style: GoogleFonts.inter(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.5,
                    ),
                  ),
                  Text(
                    'Step-by-step career guides',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.map_rounded,
                color: Colors.white,
                size: 24,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdownSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: AppColors.shadow,
          border: Border.all(color: AppColors.border.withOpacity(0.5)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.school_outlined,
                    color: AppColors.primary,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Career Path',
                        style: GoogleFonts.inter(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        'Select a goal to start',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                if (_isLoadingProgress)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
              ],
            ),
            const SizedBox(height: 18),
            Container(
              decoration: BoxDecoration(
                color: AppColors.background.withOpacity(0.5),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedRoadmapId,
                  hint: Text(
                    'Choose a career path...',
                    style: GoogleFonts.inter(
                        color: AppColors.textMuted, fontSize: 15),
                  ),
                  isExpanded: true,
                  dropdownColor: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  icon: const Icon(Icons.keyboard_arrow_down_rounded,
                      color: AppColors.primary),
                  style: GoogleFonts.inter(
                    color: AppColors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                  items: _allRoadmaps.map((roadmap) {
                    return DropdownMenuItem<String>(
                      value: roadmap.id,
                      child: Row(
                        children: [
                          Text(roadmap.emoji,
                              style: const TextStyle(fontSize: 20)),
                          const SizedBox(width: 12),
                          Text(roadmap.title),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: _onRoadmapSelected,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoadmapInfoCard() {
    final roadmap = _selectedRoadmap!;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF2B32B2), Color(0xFF1488CC)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1488CC).withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(roadmap.emoji, style: const TextStyle(fontSize: 40)),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        roadmap.title,
                        style: GoogleFonts.inter(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        roadmap.difficulty,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: Colors.white70,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              roadmap.description,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: Colors.white.withOpacity(0.9),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                _buildChip(Icons.calendar_today, '${roadmap.totalWeeks} Weeks',
                    Colors.white24),
                const SizedBox(width: 12),
                _buildChip(Icons.layers_outlined,
                    '${roadmap.steps.length} Stages', Colors.white24),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChip(IconData icon, String label, Color bg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.white),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.inter(
                fontSize: 12, color: Colors.white, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, String count) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              letterSpacing: -0.5,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.grayBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              count,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeline() {
    final steps = _selectedRoadmap!.steps;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: steps.length,
        itemBuilder: (context, index) {
          final step = steps[index];
          final isLast = index == steps.length - 1;
          final nodeId = "${_selectedRoadmap!.id}_step_$index";
          final isCompleted = _completedItems.contains(nodeId);

          return IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    GestureDetector(
                      onTap: () => _toggleProgress(nodeId),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: isCompleted
                              ? AppColors.success
                              : AppColors.primary,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: (isCompleted
                                      ? AppColors.success
                                      : AppColors.primary)
                                  .withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Icon(
                            isCompleted
                                ? Icons.check
                                : Icons.radio_button_unchecked,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ),
                    if (!isLast)
                      Expanded(
                        child: Container(
                          width: 2,
                          color: isCompleted
                              ? AppColors.success.withOpacity(0.5)
                              : AppColors.primary.withOpacity(0.2),
                          margin: const EdgeInsets.symmetric(vertical: 4),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.only(bottom: 24),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: AppColors.shadow,
                        border: Border.all(
                            color: isCompleted
                                ? AppColors.success.withOpacity(0.3)
                                : AppColors.border.withOpacity(0.3)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  step.title,
                                  style: GoogleFonts.inter(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: isCompleted
                                          ? AppColors.success
                                          : AppColors.textPrimary),
                                ),
                              ),
                              Text(
                                '${step.durationWeeks} Weeks',
                                style: GoogleFonts.inter(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: isCompleted
                                        ? AppColors.success
                                        : AppColors.primary),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            step.description,
                            style: GoogleFonts.inter(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                                height: 1.4),
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: step.skills.map((skill) {
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.background,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                      color: AppColors.border.withOpacity(0.5)),
                                ),
                                child: Text(
                                  skill,
                                  style: GoogleFonts.inter(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textPrimary),
                                ),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 12),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton.icon(
                              onPressed: () => _toggleProgress(nodeId),
                              icon: Icon(
                                  isCompleted ? Icons.undo : Icons.done_all,
                                  size: 16),
                              label: Text(isCompleted ? "Reset" : "Mark Done"),
                              style: TextButton.styleFrom(
                                foregroundColor: isCompleted
                                    ? AppColors.textMuted
                                    : AppColors.success,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCourseCard(RoadmapCourse course, int index) {
    final nodeId = "${_selectedRoadmap!.id}_course_$index";
    final isWatched = _completedItems.contains(nodeId);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppColors.shadow,
        border: Border.all(
            color: isWatched
                ? AppColors.success.withOpacity(0.3)
                : AppColors.border.withOpacity(0.3)),
      ),
      child: ListTile(
        onTap: () => _launchUrl(course.url),
        contentPadding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
        leading: Stack(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: (isWatched ? AppColors.success : AppColors.primary)
                    .withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                course.platform.toLowerCase().contains('youtube')
                    ? Icons.play_circle_fill
                    : Icons.school,
                color: isWatched ? AppColors.success : AppColors.primary,
              ),
            ),
            if (isWatched)
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(
                      color: AppColors.success, shape: BoxShape.circle),
                  child: const Icon(Icons.check, size: 10, color: Colors.white),
                ),
              ),
          ],
        ),
        title: Text(
          course.title,
          style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isWatched ? AppColors.success : AppColors.textPrimary),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Row(
            children: [
              Text(course.platform,
                  style: GoogleFonts.inter(
                      fontSize: 12, color: AppColors.textMuted)),
              const SizedBox(width: 8),
              const Icon(Icons.access_time,
                  size: 12, color: AppColors.textMuted),
              const SizedBox(width: 4),
              Text(course.duration,
                  style: GoogleFonts.inter(
                      fontSize: 12, color: AppColors.textMuted)),
            ],
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(
                isWatched ? Icons.visibility : Icons.visibility_outlined,
                color: isWatched ? AppColors.success : AppColors.textMuted,
              ),
              tooltip: isWatched ? "Watched" : "Mark as Watched",
              onPressed: () => _toggleProgress(nodeId),
            ),
            const Icon(Icons.arrow_forward_ios,
                size: 14, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 40),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.map_rounded, size: 64, color: AppColors.primary),
          ),
          const SizedBox(height: 24),
          Text(
            'Explore Your Future',
            style: GoogleFonts.inter(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary),
          ),
          const SizedBox(height: 12),
          Text(
            'Select a career path above to see exactly what you need to learn and where to learn it.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
                fontSize: 14, color: AppColors.textMuted, height: 1.5),
          ),
        ],
      ),
    );
  }
}
