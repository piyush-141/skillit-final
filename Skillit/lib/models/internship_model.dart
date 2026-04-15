class Internship {
  final String title;
  final String company;
  final String location;
  final String type;
  final String duration;
  final String stipend;
  final String posted;
  final List<String> skills;
  final String link;

  Internship({
    required this.title,
    required this.company,
    required this.location,
    required this.type,
    required this.duration,
    required this.stipend,
    required this.posted,
    required this.skills,
    required this.link,
  });

  factory Internship.fromJson(Map<String, dynamic> json) {
    // Safely handle the skills list to prevent casting crashes
    List<String> safeSkills = [];
    if (json['skills'] != null && json['skills'] is List) {
      safeSkills = (json['skills'] as List).map((e) => e.toString()).toList();
    }

    return Internship(
      title: (json['title'] ?? 'No Title').toString(),
      company: (json['company'] ?? 'Unknown Company').toString(),
      location: (json['location'] ?? 'Remote').toString(),
      type: (json['type'] ?? 'Full-time').toString(),
      duration: (json['duration'] ?? 'Not Specified').toString(),
      stipend: (json['stipend'] ?? 'Not Specified').toString(),
      posted: (json['posted'] ?? 'Recently').toString(),
      skills: safeSkills,
      link: (json['link'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'company': company,
      'location': location,
      'type': type,
      'duration': duration,
      'stipend': stipend,
      'posted': posted,
      'skills': skills,
      'link': link,
    };
  }
}