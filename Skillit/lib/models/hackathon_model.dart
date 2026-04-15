class Hackathon {
  final int id;
  final String title;
  final String organizer;
  final String prize;
  final String mode;
  final String team;
  final String duration;
  final String participants;
  final String deadline;
  final String location;
  final String logo;
  final String link;
  final List<String> tags;
  final String difficulty;
  final bool featured;
  final String registrationFee;

  Hackathon({
    required this.id,
    required this.title,
    required this.organizer,
    required this.prize,
    required this.mode,
    required this.team,
    required this.duration,
    required this.participants,
    required this.deadline,
    required this.location,
    required this.logo,
    required this.link,
    required this.tags,
    required this.difficulty,
    required this.featured,
    required this.registrationFee,
  });

  // From JSON (for API integration)
  factory Hackathon.fromJson(Map<String, dynamic> json) {
    return Hackathon(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      organizer: json['organizer'] ?? '',
      prize: json['prize'] ?? '',
      mode: json['mode'] ?? '',
      team: json['team'] ?? '',
      duration: json['duration'] ?? '',
      participants: json['participants'] ?? '',
      deadline: json['deadline'] ?? '',
      location: json['location'] ?? '',
      logo: json['logo'] ?? '',
      link: json['link'] ?? '',
      tags: List<String>.from(json['tags'] ?? []),
      difficulty: json['difficulty'] ?? '',
      featured: json['featured'] ?? false,
      registrationFee: json['registrationFee'] ?? 'Free',
    );
  }

  // To JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'organizer': organizer,
      'prize': prize,
      'mode': mode,
      'team': team,
      'duration': duration,
      'participants': participants,
      'deadline': deadline,
      'location': location,
      'logo': logo,
      'link': link,
      'tags': tags,
      'difficulty': difficulty,
      'featured': featured,
      'registrationFee': registrationFee,
    };
  }
}