import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class ResumeData {
  final String fullName;
  final String email;
  final String phone;
  final String summary;
  final String college;
  final String degree;
  final String cgpa;
  final String graduationYear;
  final String githubUrl;
  final String linkedinUrl;
  final String portfolioUrl;
  final Map<String, List<String>> skills;
  final List<ProjectEntry> projects;
  final List<ExperienceEntry> experience;
  final List<String> achievements;

  ResumeData({
    required this.fullName,
    required this.email,
    required this.phone,
    required this.summary,
    required this.college,
    required this.degree,
    required this.cgpa,
    required this.graduationYear,
    required this.githubUrl,
    required this.linkedinUrl,
    required this.portfolioUrl,
    required this.skills,
    required this.projects,
    required this.experience,
    required this.achievements,
  });

  Map<String, dynamic> toJson() => {
        'fullName': fullName,
        'email': email,
        'phone': phone,
        'summary': summary,
        'college': college,
        'degree': degree,
        'cgpa': cgpa,
        'graduationYear': graduationYear,
        'githubUrl': githubUrl,
        'linkedinUrl': linkedinUrl,
        'portfolioUrl': portfolioUrl,
        'skills': skills,
        'projects': projects.map((p) => p.toJson()).toList(),
        'experience': experience.map((e) => e.toJson()).toList(),
        'achievements': achievements,
      };

  factory ResumeData.fromJson(Map<String, dynamic> j) => ResumeData(
        fullName: j['fullName'] as String? ?? '',
        email: j['email'] as String? ?? '',
        phone: j['phone'] as String? ?? '',
        summary: j['summary'] as String? ?? '',
        college: j['college'] as String? ?? '',
        degree: j['degree'] as String? ?? '',
        cgpa: j['cgpa'] as String? ?? '',
        graduationYear: j['graduationYear'] as String? ?? '',
        githubUrl: j['githubUrl'] as String? ?? '',
        linkedinUrl: j['linkedinUrl'] as String? ?? '',
        portfolioUrl: j['portfolioUrl'] as String? ?? '',
        skills: (j['skills'] as Map<String, dynamic>? ?? {}).map(
          (k, v) => MapEntry(k, List<String>.from(v as List)),
        ),
        projects: (j['projects'] as List<dynamic>? ?? [])
            .map((e) => ProjectEntry.fromJson(e as Map<String, dynamic>))
            .toList(),
        experience: (j['experience'] as List<dynamic>? ?? [])
            .map((e) => ExperienceEntry.fromJson(e as Map<String, dynamic>))
            .toList(),
        achievements: List<String>.from(j['achievements'] as List? ?? []),
      );
}

class ProjectEntry {
  final String title;
  final String description;
  final String techStack;
  final String link;

  ProjectEntry({
    required this.title,
    required this.description,
    required this.techStack,
    required this.link,
  });

  Map<String, dynamic> toJson() => {
        'title': title,
        'description': description,
        'techStack': techStack,
        'link': link,
      };

  factory ProjectEntry.fromJson(Map<String, dynamic> j) => ProjectEntry(
        title: j['title'] as String? ?? '',
        description: j['description'] as String? ?? '',
        techStack: j['techStack'] as String? ?? '',
        link: j['link'] as String? ?? '',
      );
}

class ExperienceEntry {
  final String role;
  final String company;
  final String duration;
  final String description;

  ExperienceEntry({
    required this.role,
    required this.company,
    required this.duration,
    required this.description,
  });

  Map<String, dynamic> toJson() => {
        'role': role,
        'company': company,
        'duration': duration,
        'description': description,
      };

  factory ExperienceEntry.fromJson(Map<String, dynamic> j) => ExperienceEntry(
        role: j['role'] as String? ?? '',
        company: j['company'] as String? ?? '',
        duration: j['duration'] as String? ?? '',
        description: j['description'] as String? ?? '',
      );
}

class ResumeGenerator {
  static Future<pw.Document> generateResume(ResumeData data) async {
    final pdf = pw.Document();

    pw.Font mainFont;
    pw.Font boldFont;

    try {
      mainFont = await PdfGoogleFonts.notoSerifRegular();
      boldFont = await PdfGoogleFonts.notoSerifBold();
    } catch (e) {
      mainFont = pw.Font.times();
      boldFont = pw.Font.timesBold();
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.symmetric(horizontal: 32, vertical: 28),
        build: (context) {
          // Inner helper for sections
          pw.Widget section(String title, List<pw.Widget> children) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  title.toUpperCase(),
                  style: pw.TextStyle(
                    font: boldFont,
                    fontSize: 10,
                    letterSpacing: 0.5,
                  ),
                ),
                pw.Container(height: 0.5, color: PdfColors.black),
                pw.SizedBox(height: 6),
                ...children,
                pw.SizedBox(height: 10),
              ],
            );
          }

          return [
            // ===== HEADER =====
            pw.Center(
              child: pw.Text(
                data.fullName.toUpperCase(),
                style: pw.TextStyle(
                  font: boldFont,
                  fontSize: 18,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            pw.Center(
              child: pw.Text(
                '${data.email} | ${data.phone} ${data.linkedinUrl.isNotEmpty ? "| " + data.linkedinUrl : ""} ${data.githubUrl.isNotEmpty ? "| " + data.githubUrl : ""}',
                style: pw.TextStyle(font: mainFont, fontSize: 9),
              ),
            ),
            pw.SizedBox(height: 12),

            // ===== SUMMARY =====
            if (data.summary.isNotEmpty)
              section('SUMMARY', [
                pw.Text(
                  data.summary,
                  style: pw.TextStyle(font: mainFont, fontSize: 9),
                )
              ]),

            // ===== EDUCATION =====
            section('EDUCATION', [
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    data.college,
                    style: pw.TextStyle(font: boldFont, fontSize: 10),
                  ),
                  pw.Text(
                    data.graduationYear, // "Aug 2020 – May 2024"
                    style: pw.TextStyle(font: mainFont, fontSize: 9),
                  ),
                ],
              ),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    '${data.degree}  GPA: ${data.cgpa}',
                    style: pw.TextStyle(
                        font: mainFont, fontSize: 9, fontStyle: pw.FontStyle.italic),
                  ),
                  pw.Text(
                    'Berkeley, CA',
                    style: pw.TextStyle(font: mainFont, fontSize: 9),
                  ),
                ],
              ),
            ]),

            // ===== EXPERIENCE =====
            if (data.experience.isNotEmpty)
              section('EXPERIENCE', data.experience.map((exp) {
                return pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text(
                          exp.company,
                          style: pw.TextStyle(font: boldFont, fontSize: 10),
                        ),
                        pw.Text(
                          exp.duration,
                          style: pw.TextStyle(font: mainFont, fontSize: 9),
                        ),
                      ],
                    ),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text(
                          exp.role,
                          style: pw.TextStyle(
                            font: mainFont,
                            fontSize: 9,
                            fontStyle: pw.FontStyle.italic,
                          ),
                        ),
                        pw.Text(
                          'San Francisco, CA', // Default location as placeholder/data
                          style: pw.TextStyle(font: mainFont, fontSize: 9),
                        ),
                      ],
                    ),
                    pw.SizedBox(height: 2),
                    ..._bulletList(exp.description, mainFont),
                    pw.SizedBox(height: 6),
                  ],
                );
              }).toList()),

            // ===== PROJECTS =====
            if (data.projects.isNotEmpty)
              section('PROJECTS', data.projects.map((proj) {
                return pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.RichText(
                      text: pw.TextSpan(
                        text: proj.title,
                        style: pw.TextStyle(font: boldFont, fontSize: 10),
                        children: [
                          if (proj.link.isNotEmpty) ...[
                            pw.TextSpan(text: '  '),
                            pw.TextSpan(
                              text: proj.link,
                              style: pw.TextStyle(
                                font: mainFont,
                                fontSize: 9,
                                decoration: pw.TextDecoration.underline,
                              ),
                            ),
                          ],
                          pw.TextSpan(
                            text: ' | ${proj.techStack}',
                            style: pw.TextStyle(
                              font: mainFont,
                              fontSize: 9,
                              color: PdfColors.grey700,
                              fontStyle: pw.FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ),
                    pw.SizedBox(height: 2),
                    ..._bulletList(proj.description, mainFont),
                    pw.SizedBox(height: 6),
                  ],
                );
              }).toList()),

            // ===== SKILLS =====
            if (data.skills.isNotEmpty)
              section('TECHNICAL SKILLS', data.skills.entries.map((entry) {
                if (entry.value.isEmpty) return pw.SizedBox();
                return pw.Padding(
                  padding: const pw.EdgeInsets.only(bottom: 2),
                  child: pw.RichText(
                    text: pw.TextSpan(
                      text: '${entry.key}: ',
                      style: pw.TextStyle(font: boldFont, fontSize: 9),
                      children: [
                        pw.TextSpan(
                          text: entry.value.join(', '),
                          style: pw.TextStyle(font: mainFont, fontSize: 9),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList()),

            // ===== ACHIEVEMENTS =====
            if (data.achievements.isNotEmpty)
              section('ACHIEVEMENTS',
                data.achievements.map((a) => pw.Padding(
                  padding: const pw.EdgeInsets.only(bottom: 2),
                  child: pw.Text('• $a', style: pw.TextStyle(font: mainFont, fontSize: 9)),
                )).toList()
              ),
          ];
        },
      ),
    );

    return pdf;
  }

  static List<pw.Widget> _bulletList(String text, pw.Font font) {
    if (text.isEmpty) return [];
    final lines = text.split('\n');
    return lines.map((line) {
      if (line.trim().isEmpty) return pw.SizedBox();
      return pw.Padding(
        padding: const pw.EdgeInsets.only(left: 6, bottom: 2),
        child: pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('• ', style: pw.TextStyle(font: font, fontSize: 9)),
            pw.Expanded(
              child: pw.Text(
                line.trim(),
                style: pw.TextStyle(font: font, fontSize: 9),
              ),
            ),
          ],
        ),
      );
    }).toList();
  }
}
