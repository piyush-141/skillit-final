import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import 'package:google_fonts/google_fonts.dart';
import '../main.dart';

class ColdOutreachScreen extends StatefulWidget {
  const ColdOutreachScreen({Key? key}) : super(key: key);

  @override
  State<ColdOutreachScreen> createState() => _ColdOutreachScreenState();
}

class _ColdOutreachScreenState extends State<ColdOutreachScreen> {
  final _nameController = TextEditingController();
  final _skillsController = TextEditingController();
  final _companyController = TextEditingController();
  final _roleController = TextEditingController();
  final _hrNameController = TextEditingController();
  final _portfolioController = TextEditingController();

  String _selectedTemplate = 'Introduction';
  String _generatedMessage = '';
  bool _isEmailMode = true; // true = Email, false = LinkedIn Message

  final List<String> _templates = [
    'Introduction',
    'Internship Request',
    'Job Application',
    'Follow-up',
    'Referral Request',
    'Informational Interview',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _skillsController.dispose();
    _companyController.dispose();
    _roleController.dispose();
    _hrNameController.dispose();
    _portfolioController.dispose();
    super.dispose();
  }

  String _generateMessage() {
    final name = _nameController.text.trim().isEmpty ? '[Your Name]' : _nameController.text.trim();
    final skills = _skillsController.text.trim().isEmpty ? '[Your Skills]' : _skillsController.text.trim();
    final company = _companyController.text.trim().isEmpty ? '[Company Name]' : _companyController.text.trim();
    final role = _roleController.text.trim().isEmpty ? '[Position/Role]' : _roleController.text.trim();
    final hrName = _hrNameController.text.trim().isEmpty ? 'Hiring Manager' : _hrNameController.text.trim();
    final portfolio = _portfolioController.text.trim();

    final portfolioLine = portfolio.isNotEmpty ? '\n\nYou can view my portfolio/work here: $portfolio' : '';

    if (_isEmailMode) {
      switch (_selectedTemplate) {
        case 'Introduction':
          return 'Subject: Enthusiastic $role – Eager to Contribute at $company\n\nDear $hrName,\n\nI hope this email finds you well. My name is $name, and I am writing to express my keen interest in opportunities at $company.\n\nI have developed strong proficiency in $skills through academic projects and personal endeavors. I am particularly drawn to $company\'s innovative approach and would love the opportunity to contribute to your team.\n\nI am confident that my technical skills and enthusiasm for continuous learning would make me a valuable addition to your organization.$portfolioLine\n\nI would greatly appreciate the opportunity to discuss how I can contribute to $company\'s success. Please let me know if there is a convenient time for a brief conversation.\n\nThank you for your time and consideration.\n\nBest regards,\n$name';
        case 'Internship Request':
          return 'Subject: Application for $role Internship at $company\n\nDear $hrName,\n\nI hope this message finds you well. My name is $name, and I am a passionate and driven student actively seeking internship opportunities in the field of $role.\n\nI have hands-on experience with $skills, which I have honed through coursework, personal projects, and self-directed learning. I am deeply impressed by $company\'s work and culture, and I believe an internship with your team would provide invaluable industry exposure.\n\nKey highlights:\n• Strong foundation in $skills\n• Proven ability to learn and adapt quickly\n• Passionate about building real-world solutions\n• Excellent team collaboration and communication skills$portfolioLine\n\nI am available to start at your earliest convenience and would be happy to discuss my qualifications further. I have attached my resume for your review.\n\nThank you for considering my application. I look forward to hearing from you.\n\nWarm regards,\n$name';
        case 'Job Application':
          return 'Subject: Application for $role Position at $company\n\nDear $hrName,\n\nI am writing to express my strong interest in the $role position at $company. With a solid background in $skills, I am confident in my ability to make meaningful contributions to your team.\n\nThroughout my career journey, I have:\n• Developed expertise in $skills through hands-on projects and continuous learning\n• Successfully delivered impactful solutions under tight deadlines\n• Demonstrated strong problem-solving abilities and attention to detail\n• Collaborated effectively in cross-functional team environments\n\nI am particularly excited about $company\'s mission and the opportunity to apply my skills to drive innovation within your organization.$portfolioLine\n\nI would welcome the chance to discuss how my background aligns with your team\'s needs. Please find my resume attached for your consideration.\n\nThank you for your time. I look forward to the possibility of contributing to $company.\n\nSincerely,\n$name';
        case 'Follow-up':
          return 'Subject: Follow-up on $role Application – $name\n\nDear $hrName,\n\nI hope you are doing well. I am writing to follow up on my recent application for the $role position at $company.\n\nI remain very enthusiastic about the opportunity to join your team and contribute my skills in $skills. I understand you may have a busy schedule, and I appreciate you taking the time to review my application.\n\nSince my initial application, I have continued to enhance my expertise in $skills and would love the chance to share how my growth aligns with your team\'s goals.$portfolioLine\n\nIf there are any additional materials or information I can provide, please don\'t hesitate to let me know. I would be grateful for any updates regarding the status of my application.\n\nThank you for your time and consideration.\n\nBest regards,\n$name';
        case 'Referral Request':
          return 'Subject: Seeking Guidance – $role Opportunity at $company\n\nDear $hrName,\n\nI hope this email finds you well. My name is $name, and I recently came across the $role opportunity at $company. I am very interested in this position and wanted to reach out to learn more.\n\nI have built a strong skill set in $skills and am eager to bring this expertise to a dynamic team like yours at $company.\n\nI would be incredibly grateful if you could:\n• Share any insights about the team or role\n• Advise me on how to strengthen my application\n• Consider referring me if you believe I could be a good fit$portfolioLine\n\nI completely understand if you are unable to assist, and I appreciate your time regardless.\n\nThank you for your consideration.\n\nWith gratitude,\n$name';
        case 'Informational Interview':
          return 'Subject: Request for Informational Interview – Aspiring $role\n\nDear $hrName,\n\nMy name is $name, and I am an aspiring $role with experience in $skills. I have been following $company\'s remarkable work and am truly inspired by the impact your team is making.\n\nI would love to learn more about:\n• Your experience at $company and your career journey\n• The skills and qualities that make someone successful in this field\n• Any advice for someone at the start of their career in $role\n\nI would be honored if you could spare 15-20 minutes for a brief conversation at your convenience. I promise to be respectful of your time.$portfolioLine\n\nThank you so much for considering my request. I look forward to the possibility of connecting with you.\n\nRespectfully,\n$name';
        default:
          return '';
      }
    } else {
      switch (_selectedTemplate) {
        case 'Introduction':
          return 'Hi $hrName,\n\nI\'m $name, skilled in $skills. I\'m really impressed by $company\'s work and would love to connect and explore potential opportunities to contribute as a $role.\n\nI\'d appreciate a brief chat at your convenience!$portfolioLine\n\nBest,\n$name';
        case 'Internship Request':
          return 'Hi $hrName,\n\nI\'m $name, a passionate student with experience in $skills. I\'m actively seeking internship opportunities in $role at $company.\n\nI\'d love to discuss how I could contribute to your team. Would you be open to a brief conversation?$portfolioLine\n\nThank you!\n$name';
        case 'Job Application':
          return 'Hi $hrName,\n\nI recently came across the $role opening at $company and I\'m very interested! I have strong experience in $skills and believe I\'d be a great fit.\n\nI\'d love to connect and learn more about the role.$portfolioLine\n\nLooking forward to hearing from you!\n$name';
        case 'Follow-up':
          return 'Hi $hrName,\n\nI hope you\'re doing well! I wanted to follow up on my interest in the $role position at $company. I continue to sharpen my skills in $skills and remain very excited about this opportunity.\n\nAny updates would be greatly appreciated!$portfolioLine\n\nThanks,\n$name';
        case 'Referral Request':
          return 'Hi $hrName,\n\nI\'m $name, and I\'m interested in the $role position at $company. I have experience in $skills and would be grateful for any guidance or referral you could provide.\n\nThank you for your time!$portfolioLine\n\nBest,\n$name';
        case 'Informational Interview':
          return 'Hi $hrName,\n\nI\'m $name, an aspiring $role with skills in $skills. I admire $company\'s work and would love 15 minutes of your time to learn about your experience and get career advice.\n\nI\'d truly appreciate it!$portfolioLine\n\nThank you,\n$name';
        default:
          return '';
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Cold Outreach Writer'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildIntroduction(),
            const SizedBox(height: 32),
            _buildModeToggle(),
            const SizedBox(height: 24),
            _buildTemplateSelector(),
            const SizedBox(height: 32),
            _buildInputForm(),
            const SizedBox(height: 32),
            _buildGenerateButton(),
            if (_generatedMessage.isNotEmpty) ...[
              const SizedBox(height: 32),
              _buildGeneratedMessage(),
            ],
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }

  Widget _buildIntroduction() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Generate professional hooks",
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "Get higher response rates with personalized messages for HRs and founders.",
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildModeToggle() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.grayBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _buildToggleButton(true, 'Email', Icons.email_outlined),
          _buildToggleButton(false, 'LinkedIn', Icons.chat_bubble_outline_rounded),
        ],
      ),
    );
  }

  Widget _buildToggleButton(bool mode, String label, IconData icon) {
    bool isSelected = _isEmailMode == mode;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _isEmailMode = mode),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.surface : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: isSelected ? AppColors.shadow : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: isSelected ? AppColors.primary : AppColors.textMuted, size: 18),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? AppColors.textPrimary : AppColors.textMuted,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTemplateSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text("Select Template", style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 18)),
        ),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: _templates.map((t) {
            bool isSelected = _selectedTemplate == t;
            return ChoiceChip(
              label: Text(t),
              selected: isSelected,
              onSelected: (val) => setState(() => _selectedTemplate = t),
              backgroundColor: AppColors.surface,
              selectedColor: AppColors.primary,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : AppColors.textPrimary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(color: isSelected ? Colors.transparent : AppColors.border),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              showCheckmark: false,
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildInputForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 16),
          child: Text("Personalization Details", style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 18)),
        ),
        _buildTextField(_nameController, "Your Name", "e.g. Piyush", Icons.person_outline),
        const SizedBox(height: 16),
        _buildTextField(_skillsController, "Your Core Skills", "e.g. Flutter, React, Firebase", Icons.bolt_outlined),
        const SizedBox(height: 16),
        _buildTextField(_companyController, "Company Name", "e.g. Google", Icons.business_outlined),
        const SizedBox(height: 16),
        _buildTextField(_roleController, "Target Role", "e.g. SDE Intern", Icons.work_outline),
        const SizedBox(height: 16),
        _buildTextField(_hrNameController, "Recruiter Name", "e.g. Jane (Optional)", Icons.badge_outlined),
        const SizedBox(height: 16),
        _buildTextField(_portfolioController, "Portfolio/GitHub Link", "e.g. github.com/piyush", Icons.link_rounded),
      ],
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, String hint, IconData icon) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: TextField(
        controller: controller,
        style: const TextStyle(fontSize: 16),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
          filled: true,
          fillColor: Colors.transparent,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
          contentPadding: const EdgeInsets.all(20),
        ),
      ),
    );
  }

  Widget _buildGenerateButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          setState(() => _generatedMessage = _generateMessage());
        },
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 18),
          backgroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 0,
        ),
        child: const Text('Craft Message', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.white)),
      ),
    );
  }

  Widget _buildGeneratedMessage() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.primary.withOpacity(0.1), width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_awesome_rounded, color: AppColors.primary, size: 24),
              const SizedBox(width: 12),
              Text('Your Hook:', style: Theme.of(context).textTheme.titleLarge),
              const Spacer(),
              IconButton(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: _generatedMessage));
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Copied to clipboard!")));
                },
                icon: const Icon(Icons.copy_rounded, color: AppColors.primary, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 16),
          SelectableText(
            _generatedMessage,
            style: const TextStyle(fontSize: 15, height: 1.6, color: AppColors.textPrimary),
          ),
        ],
      ),
    );
  }
}
