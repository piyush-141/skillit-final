import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:printing/printing.dart';
import '../main.dart';
import '../services/resume_service.dart';
import '../services/resume_persistence_service.dart';
import 'resume_builder_screen.dart';

/// Full-screen resume viewer.
///
/// Priority:  Flutter widget layout (always works, instant, offline)
/// Secondary: "Export PDF" FAB — uses existing [ResumeGenerator] + [PdfPreview]
///
/// Can be opened two ways:
///   1. From ResumeBuilderScreen: pass [resumeData] directly (just generated).
///   2. From ProfileScreen: pass nothing — loads from [ResumePersistenceService].
class ResumePreviewScreen extends StatefulWidget {
  final ResumeData? resumeData;
  const ResumePreviewScreen({super.key, this.resumeData});

  @override
  State<ResumePreviewScreen> createState() => _ResumePreviewScreenState();
}

class _ResumePreviewScreenState extends State<ResumePreviewScreen> {
  ResumeData? _data;
  bool _loading = true;
  bool _exporting = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    if (widget.resumeData != null) {
      setState(() {
        _data = widget.resumeData;
        _loading = false;
      });
    } else {
      final loaded = await ResumePersistenceService.loadResumeData();
      if (mounted) setState(() { _data = loaded; _loading = false; });
    }
  }

  Future<void> _exportPdf() async {
    if (_data == null) return;
    setState(() => _exporting = true);
    try {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => Scaffold(
            appBar: AppBar(
              title: const Text('Export Resume'),
              backgroundColor: AppColors.surface,
              iconTheme: const IconThemeData(color: AppColors.textPrimary),
            ),
            body: PdfPreview(
              build: (fmt) async {
                final pdf = await ResumeGenerator.generateResume(_data!);
                return pdf.save();
              },
              pdfFileName:
                  '${_data!.fullName.replaceAll(' ', '_')}_Resume.pdf',
              canDebug: false,
            ),
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        title: Text(
          'Your Resume',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
        actions: [
          if (_data != null && !_loading)
            IconButton(
              tooltip: 'Export PDF',
              icon: _exporting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: AppColors.primary),
                    )
                  : const Icon(Icons.picture_as_pdf_rounded,
                      color: AppColors.primary),
              onPressed: _exporting ? null : _exportPdf,
            ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _data == null
              ? _buildEmptyState(context)
              : _buildResumeView(_data!),
      floatingActionButton: (_data != null && !_loading)
          ? FloatingActionButton.extended(
              onPressed: _exporting ? null : _exportPdf,
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.download_rounded),
              label: const Text('Export PDF'),
            )
          : null,
    );
  }

  // ── Empty state ───────────────────────────────────────────────────────────

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.description_outlined,
                  size: 44, color: AppColors.primary),
            ),
            const SizedBox(height: 24),
            Text(
              'No resume yet',
              style: GoogleFonts.inter(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary),
            ),
            const SizedBox(height: 10),
            Text(
              'Build your resume in the Resume Builder.\nIt will appear here instantly, no file needed.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                  fontSize: 14, color: AppColors.textMuted, height: 1.5),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (_) => const ResumeBuilderScreen()),
              ),
              icon: const Icon(Icons.edit_rounded),
              label: const Text('Build Resume'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                    horizontal: 28, vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Main resume widget view ───────────────────────────────────────────────

  Widget _buildResumeView(ResumeData d) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
      physics: const BouncingScrollPhysics(),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.12),
                    blurRadius: 20,
                    offset: const Offset(0, 4)),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Header ──────────────────────────────────────────────
                _header(d),
                const SizedBox(height: 16),

                // ── Summary ─────────────────────────────────────────────
                if (d.summary.isNotEmpty) ...[
                  _sectionTitle('SUMMARY'),
                  _bodyText(d.summary),
                  const SizedBox(height: 14),
                ],

                // ── Education ───────────────────────────────────────────
                _sectionTitle('EDUCATION'),
                _rowSpaced(
                  _boldText(d.college.isNotEmpty ? d.college : '—'),
                  _mutedText(d.graduationYear),
                ),
                _rowSpaced(
                  _italicText(
                      '${d.degree}${d.cgpa.isNotEmpty ? '  GPA: ${d.cgpa}' : ''}'),
                  const SizedBox.shrink(),
                ),
                const SizedBox(height: 14),

                // ── Experience ──────────────────────────────────────────
                if (d.experience.isNotEmpty) ...[
                  _sectionTitle('EXPERIENCE'),
                  ...d.experience.map((e) => _experienceBlock(e)),
                ],

                // ── Projects ────────────────────────────────────────────
                if (d.projects.isNotEmpty) ...[
                  _sectionTitle('PROJECTS'),
                  ...d.projects.map((p) => _projectBlock(p)),
                ],

                // ── Technical Skills ────────────────────────────────────
                if (d.skills.values.any((v) => v.isNotEmpty)) ...[
                  _sectionTitle('TECHNICAL SKILLS'),
                  ...d.skills.entries
                      .where((e) => e.value.isNotEmpty)
                      .map((e) => _skillRow(e.key, e.value)),
                  const SizedBox(height: 14),
                ],

                // ── Achievements ────────────────────────────────────────
                if (d.achievements.isNotEmpty) ...[
                  _sectionTitle('ACHIEVEMENTS'),
                  ...d.achievements.map((a) => _bulletItem(a)),
                  const SizedBox(height: 8),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Sub-widgets ───────────────────────────────────────────────────────────

  Widget _header(ResumeData d) {
    final contactParts = [
      if (d.email.isNotEmpty) d.email,
      if (d.phone.isNotEmpty) d.phone,
      if (d.linkedinUrl.isNotEmpty) d.linkedinUrl,
      if (d.githubUrl.isNotEmpty) d.githubUrl,
    ];
    return Column(
      children: [
        Text(
          d.fullName.toUpperCase(),
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: 'serif',
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: Color(0xFF0D0D0D),
            letterSpacing: 2.4,
          ),
        ),
        if (contactParts.isNotEmpty) ...[
          const SizedBox(height: 6),
          Text(
            contactParts.join('  |  '),
            textAlign: TextAlign.center,
            style: GoogleFonts.lato(
                fontSize: 10,
                color: const Color(0xFF444444),
                letterSpacing: 0.3),
          ),
        ],
      ],
    );
  }

  Widget _sectionTitle(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.lato(
            fontSize: 10,
            fontWeight: FontWeight.w900,
            color: const Color(0xFF1A1A1A),
            letterSpacing: 1.2,
          ),
        ),
        Container(
          height: 0.8,
          color: const Color(0xFF1A1A1A),
          margin: const EdgeInsets.only(top: 3, bottom: 8),
        ),
      ],
    );
  }

  Widget _experienceBlock(ExperienceEntry e) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _rowSpaced(_boldText(e.company), _mutedText(e.duration)),
          _italicText(e.role),
          if (e.description.isNotEmpty) ...[
            const SizedBox(height: 4),
            ...e.description
                .split('\n')
                .where((l) => l.trim().isNotEmpty)
                .map((l) => _bulletItem(l.trim())),
          ],
        ],
      ),
    );
  }

  Widget _projectBlock(ProjectEntry p) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _boldText(p.title),
              if (p.techStack.isNotEmpty) ...[
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    '| ${p.techStack}',
                    style: GoogleFonts.lato(
                        fontSize: 9,
                        color: const Color(0xFF666666),
                        fontStyle: FontStyle.italic),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ],
          ),
          if (p.description.isNotEmpty) ...[
            const SizedBox(height: 4),
            ...p.description
                .split('\n')
                .where((l) => l.trim().isNotEmpty)
                .map((l) => _bulletItem(l.trim())),
          ],
        ],
      ),
    );
  }

  Widget _skillRow(String label, List<String> values) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: '$label: ',
              style: GoogleFonts.lato(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF1A1A1A)),
            ),
            TextSpan(
              text: values.join(', '),
              style: GoogleFonts.lato(
                  fontSize: 9.5, color: const Color(0xFF333333)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _bulletItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('• ',
              style: GoogleFonts.lato(
                  fontSize: 9.5, color: const Color(0xFF1A1A1A))),
          Expanded(
            child: Text(text,
                style: GoogleFonts.lato(
                    fontSize: 9.5, color: const Color(0xFF333333))),
          ),
        ],
      ),
    );
  }

  Widget _rowSpaced(Widget left, Widget right) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(child: left),
        right,
      ],
    );
  }

  Widget _boldText(String t) => Text(t,
      style: GoogleFonts.lato(
          fontSize: 10.5,
          fontWeight: FontWeight.w800,
          color: const Color(0xFF1A1A1A)));

  Widget _italicText(String t) => Text(t,
      style: GoogleFonts.lato(
          fontSize: 9.5,
          fontStyle: FontStyle.italic,
          color: const Color(0xFF444444)));

  Widget _mutedText(String t) => Text(t,
      style: GoogleFonts.lato(
          fontSize: 9.5, color: const Color(0xFF666666)));

  Widget _bodyText(String t) => Text(t,
      style: GoogleFonts.lato(
          fontSize: 9.5, color: const Color(0xFF333333), height: 1.5));
}
