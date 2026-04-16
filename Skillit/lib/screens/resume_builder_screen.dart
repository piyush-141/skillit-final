import 'package:flutter/material.dart';
import 'dart:ui';
import 'dart:math' as math;
import 'package:google_fonts/google_fonts.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import '../main.dart';
import '../services/resume_service.dart';

class ResumeBuilderScreen extends StatefulWidget {
  const ResumeBuilderScreen({Key? key}) : super(key: key);

  @override
  State<ResumeBuilderScreen> createState() => _ResumeBuilderScreenState();
}

class _ResumeBuilderScreenState extends State<ResumeBuilderScreen>
    with TickerProviderStateMixin {
  late AnimationController _floatingController;
  late AnimationController _headerController;

  final _formKey = GlobalKey<FormState>();
  int _currentStep = 0;
  bool _isGenerating = false;

  // ── Personal Info Controllers ──
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _summaryController = TextEditingController();

  // ── Education Controllers ──
  final _collegeController = TextEditingController();
  final _degreeController = TextEditingController();
  final _cgpaController = TextEditingController();
  final _gradYearController = TextEditingController();

  // ── Links Controllers ──
  final _githubController = TextEditingController();
  final _linkedinController = TextEditingController();
  final _portfolioController = TextEditingController();

  // ── Skills ──
  final _languagesController = TextEditingController();
  final _frameworksController = TextEditingController();
  final _toolsController = TextEditingController();
  final _othersController = TextEditingController();

  // ── Projects ──
  List<ProjectEntry> _projects = [];
  final _projTitleController = TextEditingController();
  final _projDescController = TextEditingController();
  final _projTechController = TextEditingController();
  final _projLinkController = TextEditingController();

  // ── Experience ──
  List<ExperienceEntry> _experience = [];
  final _expRoleController = TextEditingController();
  final _expCompanyController = TextEditingController();
  final _expDurationController = TextEditingController();
  final _expDescController = TextEditingController();

  // ── Achievements ──
  final _achievementController = TextEditingController();
  List<String> _achievements = [];

  final List<Map<String, dynamic>> _steps = [
    {
      'title': 'Personal',
      'icon': Icons.person_outline,
      'color': AppColors.primary
    },
    {'title': 'Education', 'icon': Icons.school_outlined, 'color': Colors.pink},
    {'title': 'Skills', 'icon': Icons.code_outlined, 'color': Colors.cyan},
    {'title': 'Projects', 'icon': Icons.build_outlined, 'color': Colors.orange},
    {
      'title': 'Experience',
      'icon': Icons.work_outline,
      'color': AppColors.success
    },
    {
      'title': 'Achievements',
      'icon': Icons.emoji_events_outlined,
      'color': const Color(0xFF667EEA)
    },
  ];

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
  }

  @override
  void dispose() {
    _floatingController.dispose();
    _headerController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _summaryController.dispose();
    _collegeController.dispose();
    _degreeController.dispose();
    _cgpaController.dispose();
    _gradYearController.dispose();
    _githubController.dispose();
    _linkedinController.dispose();
    _portfolioController.dispose();
    _languagesController.dispose();
    _frameworksController.dispose();
    _toolsController.dispose();
    _othersController.dispose();
    _projTitleController.dispose();
    _projDescController.dispose();
    _projTechController.dispose();
    _projLinkController.dispose();
    _expRoleController.dispose();
    _expCompanyController.dispose();
    _expDurationController.dispose();
    _expDescController.dispose();
    _achievementController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                _buildStepIndicator(),
                Expanded(
                  child: Form(
                    key: _formKey,
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                      child: _buildCurrentStep(),
                    ),
                  ),
                ),
                _buildBottomButtons(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 24, 0),
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(-1, 0),
          end: Offset.zero,
        ).animate(
            CurvedAnimation(parent: _headerController, curve: Curves.easeOut)),
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
                child: const Icon(Icons.arrow_back_ios_new,
                    color: AppColors.textPrimary, size: 18),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Resume Builder',
                      style: GoogleFonts.inter(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.5,
                      )),
                ],
              ),
            ),
            IconButton(
              onPressed: _autofillSampleData,
              tooltip: 'Autofill with Sample Data',
              icon: Icon(Icons.auto_fix_high_rounded,
                  color: AppColors.textMuted.withOpacity(0.3), size: 18),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4)),
                ],
              ),
              child: const Icon(Icons.description_rounded,
                  color: Colors.white, size: 24),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Container(
      height: 75,
      margin: const EdgeInsets.only(top: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _steps.length,
        itemBuilder: (context, index) {
          final step = _steps[index];
          final isActive = index == _currentStep;
          final isCompleted = index < _currentStep;
          final color = step['color'] as Color;

          return GestureDetector(
            onTap: () => setState(() => _currentStep = index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 6),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: isActive ? color.withOpacity(0.1) : AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isActive ? color : Colors.transparent,
                  width: 1.5,
                ),
                boxShadow: isActive ? [] : AppColors.shadow,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isCompleted ? Icons.check_circle : step['icon'],
                    color:
                        isActive || isCompleted ? color : AppColors.textMuted,
                    size: 20,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    step['title'],
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                      color: isActive ? color : AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case 0:
        return _buildPersonalInfoStep();
      case 1:
        return _buildEducationStep();
      case 2:
        return _buildSkillsLinksStep();
      case 3:
        return _buildProjectsStep();
      case 4:
        return _buildExperienceStep();
      case 5:
        return _buildAchievementsStep();
      default:
        return const SizedBox();
    }
  }

  Widget _buildPersonalInfoStep() {
    return _buildStepCard(
      color: AppColors.primary,
      emoji: '👤',
      title: 'Personal Info',
      subtitle: 'Contact details & summary',
      children: [
        _buildTextField(
            controller: _nameController,
            label: 'Full Name',
            hint: 'Rahul Sharma',
            icon: Icons.person_outline,
            isRequired: true),
        _buildTextField(
            controller: _emailController,
            label: 'Email Address',
            hint: 'rahul@email.com',
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            isRequired: true),
        _buildTextField(
            controller: _phoneController,
            label: 'Phone Number',
            hint: '+91 9876543210',
            icon: Icons.phone_outlined,
            keyboardType: TextInputType.phone),
        _buildTextField(
            controller: _summaryController,
            label: 'Bio / Summary',
            hint: 'Passionate Flutter developer...',
            icon: Icons.notes_outlined,
            maxLines: 3),
      ],
    );
  }

  Widget _buildEducationStep() {
    return _buildStepCard(
      color: Colors.pink,
      emoji: '🎓',
      title: 'Education',
      subtitle: 'Where did you study?',
      children: [
        _buildTextField(
            controller: _collegeController,
            label: 'College',
            hint: 'IIT Delhi',
            icon: Icons.account_balance_outlined,
            isRequired: true),
        _buildTextField(
            controller: _degreeController,
            label: 'Degree',
            hint: 'B.Tech CS',
            icon: Icons.school_outlined,
            isRequired: true),
        Row(
          children: [
            Expanded(
                child: _buildTextField(
                    controller: _cgpaController,
                    label: 'CGPA',
                    hint: '8.5',
                    icon: Icons.star_outline,
                    keyboardType: TextInputType.number,
                    isRequired: true)),
            const SizedBox(width: 14),
            Expanded(
                child: _buildTextField(
                    controller: _gradYearController,
                    label: 'Grad Year',
                    hint: '2026',
                    icon: Icons.calendar_today_outlined,
                    keyboardType: TextInputType.number,
                    isRequired: true)),
          ],
        ),
      ],
    );
  }

  Widget _buildSkillsLinksStep() {
    return _buildStepCard(
      color: Colors.cyan,
      emoji: '💡',
      title: 'Skills & Links',
      subtitle: 'What do you know?',
      children: [
        _buildTextField(
            controller: _languagesController,
            label: 'Programming Languages',
            hint: 'JavaScript, Python, C++...',
            icon: Icons.code),
        _buildTextField(
            controller: _frameworksController,
            label: 'Frameworks & Libraries',
            hint: 'React, Flutter, Node.js...',
            icon: Icons.layers_outlined),
        _buildTextField(
            controller: _toolsController,
            label: 'Developer Tools',
            hint: 'Git, Docker, AWS, Firebase...',
            icon: Icons.handyman_outlined),
        _buildTextField(
            controller: _othersController,
            label: 'Other Skills',
            hint: 'System Design, Agile, UI/UX...',
            icon: Icons.psychology_outlined),
        const SizedBox(height: 20),
        _buildTextField(
            controller: _githubController,
            label: 'GitHub',
            hint: 'github.com/user',
            icon: Icons.code),
        _buildTextField(
            controller: _linkedinController,
            label: 'LinkedIn',
            hint: 'linkedin.com/in/user',
            icon: Icons.link),
      ],
    );
  }

  Widget _buildProjectsStep() {
    return _buildStepCard(
      color: Colors.orange,
      emoji: '🛠️',
      title: 'Projects',
      subtitle: 'Your best work',
      children: [
        if (_projects.isNotEmpty) ...[
          ..._projects.map((p) => Card(
                child: ListTile(
                  title: Text(p.title),
                  subtitle: Text(p.techStack),
                  trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => setState(() => _projects.remove(p))),
                ),
              )),
          const SizedBox(height: 16),
        ],
        _buildTextField(
            controller: _projTitleController,
            label: 'Title',
            hint: 'SkillIt App',
            icon: Icons.title),
        _buildTextField(
            controller: _projTechController,
            label: 'Tech Stack',
            hint: 'Flutter, Firebase',
            icon: Icons.layers),
        _buildTextField(
            controller: _projDescController,
            label: 'Description',
            hint: 'Built a cool app...',
            icon: Icons.notes,
            maxLines: 2),
        const SizedBox(height: 10),
        _buildAddButton('Add Project', Colors.orange, _addProject),
      ],
    );
  }

  Widget _buildExperienceStep() {
    return _buildStepCard(
      color: AppColors.success,
      emoji: '💼',
      title: 'Experience',
      subtitle: 'Internships & Jobs',
      children: [
        if (_experience.isNotEmpty) ...[
          ..._experience.map((e) => Card(
                child: ListTile(
                  title: Text(e.role),
                  subtitle: Text(e.company),
                  trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => setState(() => _experience.remove(e))),
                ),
              )),
          const SizedBox(height: 16),
        ],
        _buildTextField(
            controller: _expRoleController,
            label: 'Role',
            hint: 'Flutter Intern',
            icon: Icons.badge),
        _buildTextField(
            controller: _expCompanyController,
            label: 'Company',
            hint: 'Google',
            icon: Icons.business),
        _buildTextField(
            controller: _expDurationController,
            label: 'Duration',
            hint: '3 Months',
            icon: Icons.date_range),
        const SizedBox(height: 10),
        _buildAddButton('Add Experience', AppColors.success, _addExperience),
      ],
    );
  }

  Widget _buildAchievementsStep() {
    return _buildStepCard(
      color: const Color(0xFF667EEA),
      emoji: '🏆',
      title: 'Achievements',
      subtitle: 'Your wins',
      children: [
        if (_achievements.isNotEmpty) ...[
          ..._achievements.map((a) => Card(
                child: ListTile(
                  title: Text(a),
                  trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => setState(() => _achievements.remove(a))),
                ),
              )),
          const SizedBox(height: 16),
        ],
        Row(
          children: [
            Expanded(
                child: _buildTextField(
                    controller: _achievementController,
                    label: 'Achievement',
                    hint: 'Won Hackathon...',
                    icon: Icons.military_tech)),
            IconButton(
                onPressed: _addAchievement,
                icon: const Icon(Icons.add_circle),
                color: const Color(0xFF667EEA),
                iconSize: 40),
          ],
        ),
      ],
    );
  }

  Widget _buildStepCard(
      {required Color color,
      required String emoji,
      required String title,
      required String subtitle,
      required List<Widget> children}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color.withOpacity(0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withOpacity(0.2)),
          ),
          child: Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 28)),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                  Text(subtitle,
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.textMuted)),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        ...children,
      ],
    );
  }

  Widget _buildTextField(
      {required TextEditingController controller,
      required String label,
      required String hint,
      required IconData icon,
      TextInputType keyboardType = TextInputType.text,
      int maxLines = 1,
      bool isRequired = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary)),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            maxLines: maxLines,
            validator:
                isRequired ? (v) => v!.isEmpty ? 'Required' : null : null,
            decoration: InputDecoration(
              hintText: hint,
              prefixIcon: Icon(icon, color: AppColors.textMuted, size: 20),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.border)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddButton(String label, Color color, VoidCallback onTap) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: const Icon(Icons.add),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: color,
        side: BorderSide(color: color),
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildBottomButtons() {
    final isLastStep = _currentStep == _steps.length - 1;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration:
          BoxDecoration(color: AppColors.surface, boxShadow: AppColors.shadow),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
                child: OutlinedButton(
                    onPressed: () => setState(() => _currentStep--),
                    child: const Text('Back'))),
          if (_currentStep > 0) const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: isLastStep
                  ? _generateResume
                  : () {
                      if (_formKey.currentState!.validate()) {
                        _autoSaveCurrentStep();
                        setState(() => _currentStep++);
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    isLastStep ? AppColors.success : AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: _isGenerating
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2))
                  : Text(isLastStep ? 'Generate PDF' : 'Next'),
            ),
          ),
        ],
      ),
    );
  }

  void _autoSaveCurrentStep() {
    switch (_currentStep) {
      case 3: // Projects
        if (_projTitleController.text.trim().isNotEmpty) _addProject();
        break;
      case 4: // Experience
        if (_expRoleController.text.trim().isNotEmpty) _addExperience();
        break;
      case 5: // Achievements
        if (_achievementController.text.trim().isNotEmpty) _addAchievement();
        break;
    }
  }


  void _addProject() {
    if (_projTitleController.text.isNotEmpty) {
      setState(() {
        _projects.add(ProjectEntry(
            title: _projTitleController.text.trim(),
            techStack: _projTechController.text.trim(),
            description: _projDescController.text.trim(),
            link: ''));
        _projTitleController.clear();
        _projTechController.clear();
        _projDescController.clear();
      });
    }
  }

  void _addExperience() {
    if (_expRoleController.text.isNotEmpty) {
      setState(() {
        _experience.add(ExperienceEntry(
            role: _expRoleController.text.trim(),
            company: _expCompanyController.text.trim(),
            duration: _expDurationController.text.trim(),
            description: ''));
        _expRoleController.clear();
        _expCompanyController.clear();
        _expDurationController.clear();
      });
    }
  }

  void _addAchievement() {
    if (_achievementController.text.isNotEmpty) {
      setState(() {
        _achievements.add(_achievementController.text.trim());
        _achievementController.clear();
      });
    }
  }

  Future<void> _generateResume() async {
    _autoSaveCurrentStep();
    if (!_formKey.currentState!.validate()) {
      _showSnackbar('Please fill all required fields');
      return;
    }

    setState(() => _isGenerating = true);
    try {
      final data = ResumeData(
        fullName: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        summary: _summaryController.text.trim(),
        college: _collegeController.text.trim(),
        degree: _degreeController.text.trim(),
        cgpa: _cgpaController.text.trim(),
        graduationYear: _gradYearController.text.trim(),
        githubUrl: _githubController.text.trim(),
        linkedinUrl: _linkedinController.text.trim(),
        portfolioUrl: _portfolioController.text.trim(),
        skills: {
          'Programming Languages': _languagesController.text
              .split(',')
              .map((e) => e.trim())
              .where((e) => e.isNotEmpty)
              .toList(),
          'Frameworks & Libraries': _frameworksController.text
              .split(',')
              .map((e) => e.trim())
              .where((e) => e.isNotEmpty)
              .toList(),
          'Developer Tools': _toolsController.text
              .split(',')
              .map((e) => e.trim())
              .where((e) => e.isNotEmpty)
              .toList(),
          'Other Skills': _othersController.text
              .split(',')
              .map((e) => e.trim())
              .where((e) => e.isNotEmpty)
              .toList(),
        },
        projects: _projects,
        experience: _experience,
        achievements: _achievements,
      );

      // We go directly to the preview screen and let IT handle the generation
      // using the captured 'data' object.
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Scaffold(
            appBar: AppBar(
              title: const Text('Export Resume'),
              backgroundColor: AppColors.surface,
              iconTheme: const IconThemeData(color: AppColors.textPrimary),
            ),
            body: PdfPreview(
              build: (format) async {
                final pdf = await ResumeGenerator.generateResume(data);
                return pdf.save();
              },
              pdfFileName: '${data.fullName.replaceAll(' ', '_')}_Resume.pdf',
              canDebug: false,
            ),
          ),
        ),
      );
    } catch (e) {
      _showSnackbar('Error: $e');
    } finally {
      if (mounted) setState(() => _isGenerating = false);
    }
  }

  void _autofillSampleData() {
    setState(() {
      // Personal
      _nameController.text = "Nitesh Singh";
      _emailController.text = "nitesh@jobfound.org";
      _phoneController.text = "9999999999";
      _summaryController.text = "";

      // Education
      _collegeController.text = "University of California, Berkeley";
      _degreeController.text = "Bachelor of Science in Computer Science";
      _cgpaController.text = "3.85";
      _gradYearController.text = "Aug 2020 – May 2024";

      // Links
      _githubController.text = "github.com/Nitesh-Singh-5";
      _linkedinController.text = "linkedin.com/in/nitesh-singh-2001";
      _portfolioController.text = "";

      // Skills
      _languagesController.text = "JavaScript, TypeScript, Python, Java, SQL, Go";
      _frameworksController.text = "React, Next.js, Node.js, Express, Django, TailwindCSS";
      _toolsController.text = "Git, Docker, AWS, PostgreSQL, MongoDB, Redis, GitHub Actions";
      _othersController.text = "System Design, Agile/Scrum, Technical Writing";

      // Projects
      _projects = [
        ProjectEntry(
          title: "AI-Powered Study Assistant",
          techStack: "Python, OpenAI API, React, PostgreSQL",
          description:
              "Built a GPT-4 study assistant that summarizes documents and generates quizzes; reduced average study time ~40% based on user feedback + analytics.\nCut LLM spend ~60% via prompt optimization, caching, and output-length controls while maintaining answer quality.\nScaled to 500+ active users in month 1; shipped a hosted demo and instrumented events to reach ~25 min avg session duration.",
          link: "github.com/Nitesh-Singh-5/",
        ),
        ProjectEntry(
          title: "Real-time Collaboration Tool",
          techStack: "Next.js, Socket.io, MongoDB, Docker",
          description:
              "Built real-time collaborative editing with Socket.io + operational transformation; supported 50+ concurrent editors without conflicts.\nImplemented OAuth2 + RBAC for team workspaces; secured APIs and improved auditability with role-scoped permissions.\nDeployed Docker services to GKE; achieved 99.9% uptime with health checks, autoscaling, and automated restarts for failures.",
          link: "github.com/Nitesh-Singh-5/",
        ),
      ];

      // Experience
      _experience = [
        ExperienceEntry(
          role: "Software Engineering Intern",
          company: "Tech Startup Inc.",
          duration: "May 2023 – Aug 2023",
          description:
              "Shipped 15+ Node.js/Express REST APIs and Redis caching; cut p95 latency ~40% and improved DB query performance via indexing + query tuning.\nBuilt React dashboard UI for 10,000+ DAU; improved usability by streamlining key workflows and reducing UI regressions with component reuse.\nAutomated CI/CD with GitHub Actions; reduced deploy time 45—15 mins and eliminated manual release errors with checks + rollback-friendly steps.",
        ),
        ExperienceEntry(
          role: "Full Stack Developer",
          company: "Innovation Labs",
          duration: "Jan 2024 – Present",
          description:
              "Architected a multi-tenant SaaS on Next.js 14 + PostgreSQL; supported 5,000+ concurrent users with optimized pooling, caching, and observability.\nIntegrated Stripe subscriptions (checkout, webhooks, retries) and improved payment reliability with idempotency + clear failure handling.\nLed 3 engineers with weekly reviews and mentorship; raised code quality via TypeScript standards, docs, and scalable system-design patterns.",
        ),
      ];

      // Achievements
      _achievements = [
        "Dean's List — All semesters (Top 5% of class)",
        "1st Place — University Hackathon 2023 (500+ participants)",
        "Published research paper on ML optimization at an IEEE conference",
        "Built and scaled production systems serving 10,000+ users with 99.9% uptime",
        "Reduced API + infrastructure costs by 60% via performance tuning and caching"
      ];

      _currentStep = 0;
    });

    _showSnackbar('Form populated with sample data');
  }

  void _showSnackbar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.primary,
      ),
    );
  }
}
