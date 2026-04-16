// ── Mock Roadmap Data ──────────────────────────────────────
// Each roadmap has stages, and each stage has steps with resources.

class RoadmapStep {
  final String title;
  final String description;
  final List<String> skills;
  final int durationWeeks;
  final bool isCompleted;

  const RoadmapStep({
    required this.title,
    required this.description,
    required this.skills,
    required this.durationWeeks,
    this.isCompleted = false,
  });
}

class RoadmapCourse {
  final String title;
  final String platform;
  final String url;
  final String duration;
  final String thumbnail;
  final bool isFree;

  const RoadmapCourse({
    required this.title,
    required this.platform,
    required this.url,
    required this.duration,
    this.thumbnail = '',
    this.isFree = true,
  });
}

class CareerRoadmap {
  final String id;
  final String title;
  final String description;
  final String emoji;
  final List<RoadmapStep> steps;
  final List<RoadmapCourse> courses;
  final int totalWeeks;
  final String difficulty;

  const CareerRoadmap({
    required this.id,
    required this.title,
    required this.description,
    required this.emoji,
    required this.steps,
    required this.courses,
    required this.totalWeeks,
    required this.difficulty,
  });
}

const List<CareerRoadmap> mockRoadmaps = [
  // ─── 1. Software Developer ────────────────────────────
  const CareerRoadmap(
    id: 'software-developer',
    title: 'Software Developer',
    description:
        'Build full-stack applications with modern frameworks and best practices.',
    emoji: '💻',
    difficulty: 'Intermediate',
    totalWeeks: 24,
    steps: [
      RoadmapStep(
        title: 'Programming Fundamentals',
        description:
            'Master a language like Python or JavaScript. Understand variables, loops, functions, OOP, and data structures.',
        skills: ['Python / JavaScript', 'OOP', 'Data Structures', 'Algorithms'],
        durationWeeks: 4,
      ),
      RoadmapStep(
        title: 'Version Control & Git',
        description:
            'Learn Git, GitHub workflows, branching strategies, and collaborative coding practices.',
        skills: ['Git', 'GitHub', 'Pull Requests', 'CI Basics'],
        durationWeeks: 2,
      ),
      RoadmapStep(
        title: 'Frontend Development',
        description:
            'Build responsive UIs with HTML, CSS, JavaScript, and a modern framework like React or Vue.',
        skills: [
          'HTML/CSS',
          'JavaScript ES6+',
          'React / Vue',
          'Responsive Design'
        ],
        durationWeeks: 5,
      ),
      RoadmapStep(
        title: 'Backend Development',
        description:
            'Create RESTful APIs, handle authentication, and connect to databases using Node.js or Django.',
        skills: [
          'Node.js / Django',
          'REST APIs',
          'Authentication',
          'PostgreSQL / MongoDB'
        ],
        durationWeeks: 5,
      ),
      RoadmapStep(
        title: 'Databases & DevOps',
        description:
            'Master SQL & NoSQL databases. Learn Docker, deployment, and cloud basics (AWS/GCP).',
        skills: ['SQL', 'MongoDB', 'Docker', 'AWS / GCP'],
        durationWeeks: 4,
      ),
      RoadmapStep(
        title: 'Build Real Projects',
        description:
            'Create portfolio projects — a full-stack app, open-source contributions, and deploy to production.',
        skills: ['Portfolio', 'Open Source', 'Deployment', 'System Design'],
        durationWeeks: 4,
      ),
    ],
    courses: [
      RoadmapCourse(
        title: 'CS50: Introduction to Computer Science',
        platform: 'YouTube (Harvard)',
        url: 'https://www.youtube.com/watch?v=8mAITcNt710',
        duration: '25+ hours',
        isFree: true,
      ),
      RoadmapCourse(
        title: 'The Odin Project — Full Stack Path',
        platform: 'The Odin Project',
        url: 'https://www.theodinproject.com/',
        duration: 'Self-paced',
        isFree: true,
      ),
      RoadmapCourse(
        title: 'Full Stack Open 2024',
        platform: 'University of Helsinki',
        url: 'https://fullstackopen.com/en/',
        duration: '10+ weeks',
        isFree: true,
      ),
      RoadmapCourse(
        title: 'JavaScript Mastery — MERN Stack',
        platform: 'YouTube',
        url: 'https://www.youtube.com/watch?v=VsUzmlZfYNg',
        duration: '6 hours',
        isFree: true,
      ),
      RoadmapCourse(
        title: 'Docker for Beginners — TechWorld with Nana',
        platform: 'YouTube',
        url: 'https://www.youtube.com/watch?v=3c-iBn73dDE',
        duration: '3 hours',
        isFree: true,
      ),
    ],
  ),

  // ─── 2. ML Engineer ───────────────────────────────────
  const CareerRoadmap(
    id: 'ml-engineer',
    title: 'ML Engineer',
    description:
        'Design and deploy machine learning models to solve real-world problems at scale.',
    emoji: '🤖',
    difficulty: 'Advanced',
    totalWeeks: 28,
    steps: [
      RoadmapStep(
        title: 'Mathematics for ML',
        description:
            'Build a strong foundation in linear algebra, calculus, probability, and statistics.',
        skills: ['Linear Algebra', 'Calculus', 'Probability', 'Statistics'],
        durationWeeks: 4,
      ),
      RoadmapStep(
        title: 'Python & Data Manipulation',
        description:
            'Master Python, NumPy, Pandas, and data visualization with Matplotlib and Seaborn.',
        skills: ['Python', 'NumPy', 'Pandas', 'Matplotlib'],
        durationWeeks: 3,
      ),
      RoadmapStep(
        title: 'Machine Learning Fundamentals',
        description:
            'Learn supervised & unsupervised learning, model evaluation, feature engineering, and Scikit-learn.',
        skills: ['Regression', 'Classification', 'Clustering', 'Scikit-learn'],
        durationWeeks: 5,
      ),
      RoadmapStep(
        title: 'Deep Learning & Neural Networks',
        description:
            'Dive into CNNs, RNNs, Transformers, and frameworks like TensorFlow and PyTorch.',
        skills: ['TensorFlow', 'PyTorch', 'CNNs', 'Transformers'],
        durationWeeks: 6,
      ),
      RoadmapStep(
        title: 'MLOps & Deployment',
        description:
            'Learn to deploy ML models — MLflow, FastAPI, Docker, model monitoring, and A/B testing.',
        skills: ['MLflow', 'FastAPI', 'Docker', 'Model Monitoring'],
        durationWeeks: 5,
      ),
      RoadmapStep(
        title: 'Capstone & Research',
        description:
            'Build an end-to-end ML project, contribute to Kaggle, and explore research papers.',
        skills: [
          'Kaggle',
          'Research Papers',
          'End-to-End Projects',
          'Portfolio'
        ],
        durationWeeks: 5,
      ),
    ],
    courses: [
      RoadmapCourse(
        title: 'Andrew Ng — Machine Learning Specialization',
        platform: 'Coursera / YouTube',
        url: 'https://www.youtube.com/watch?v=jGwO_UgTS7I',
        duration: '60+ hours',
        isFree: true,
      ),
      RoadmapCourse(
        title: 'Fast.ai — Practical Deep Learning',
        platform: 'fast.ai',
        url: 'https://course.fast.ai/',
        duration: '20+ hours',
        isFree: true,
      ),
      RoadmapCourse(
        title: '3Blue1Brown — Neural Networks',
        platform: 'YouTube',
        url: 'https://www.youtube.com/watch?v=aircAruvnKk',
        duration: '4 hours',
        isFree: true,
      ),
      RoadmapCourse(
        title: 'Sentdex — PyTorch Deep Learning',
        platform: 'YouTube',
        url: 'https://www.youtube.com/watch?v=BzcBsTou0C0',
        duration: '10+ hours',
        isFree: true,
      ),
      RoadmapCourse(
        title: 'Made With ML — MLOps Course',
        platform: 'Made With ML',
        url: 'https://madewithml.com/',
        duration: 'Self-paced',
        isFree: true,
      ),
    ],
  ),

  // ─── 3. Data Engineer ─────────────────────────────────
  const CareerRoadmap(
    id: 'data-engineer',
    title: 'Data Engineer',
    description:
        'Build robust data pipelines and infrastructure to power analytics and ML systems.',
    emoji: '📊',
    difficulty: 'Intermediate',
    totalWeeks: 22,
    steps: [
      RoadmapStep(
        title: 'SQL & Database Mastery',
        description:
            'Master SQL queries, joins, window functions, indexing, and database design.',
        skills: ['SQL', 'PostgreSQL', 'Database Design', 'Indexing'],
        durationWeeks: 3,
      ),
      RoadmapStep(
        title: 'Python for Data Engineering',
        description:
            'Learn Python scripting, file handling, APIs, and working with large data formats (Parquet, Avro).',
        skills: ['Python', 'APIs', 'File Formats', 'Scripting'],
        durationWeeks: 3,
      ),
      RoadmapStep(
        title: 'ETL & Data Pipelines',
        description:
            'Build ETL workflows using Apache Airflow, Luigi, or Prefect. Understand batch vs streaming.',
        skills: ['Apache Airflow', 'ETL', 'Batch Processing', 'Streaming'],
        durationWeeks: 4,
      ),
      RoadmapStep(
        title: 'Big Data Technologies',
        description:
            'Learn Apache Spark, Hadoop ecosystem, and distributed computing fundamentals.',
        skills: ['Apache Spark', 'Hadoop', 'PySpark', 'Distributed Systems'],
        durationWeeks: 5,
      ),
      RoadmapStep(
        title: 'Cloud Data Platforms',
        description:
            'Work with AWS (Redshift, Glue, S3), GCP (BigQuery), or Azure data services.',
        skills: ['AWS', 'GCP BigQuery', 'Redshift', 'Data Lakes'],
        durationWeeks: 4,
      ),
      RoadmapStep(
        title: 'Portfolio & Real Projects',
        description:
            'Build end-to-end data pipelines, contribute to data-intensive projects, and prepare for interviews.',
        skills: ['Portfolio', 'System Design', 'Data Modeling', 'Interviews'],
        durationWeeks: 3,
      ),
    ],
    courses: [
      RoadmapCourse(
        title: 'Data Engineering Zoomcamp',
        platform: 'DataTalks.Club (YouTube)',
        url: 'https://www.youtube.com/watch?v=bkJZDsrlRFo',
        duration: '10+ weeks',
        isFree: true,
      ),
      RoadmapCourse(
        title: 'SQL for Data Engineers — Danny Ma',
        platform: 'YouTube',
        url: 'https://www.youtube.com/watch?v=7mz73uXD9DA',
        duration: '8 hours',
        isFree: true,
      ),
      RoadmapCourse(
        title: 'Apache Spark Crash Course',
        platform: 'YouTube',
        url: 'https://www.youtube.com/watch?v=_C8kWso4ne4',
        duration: '5 hours',
        isFree: true,
      ),
      RoadmapCourse(
        title: 'Airflow Tutorial for Beginners',
        platform: 'YouTube',
        url: 'https://www.youtube.com/watch?v=AHMm1wfGuR8',
        duration: '3 hours',
        isFree: true,
      ),
      RoadmapCourse(
        title: 'AWS Data Engineering — Be A Better Dev',
        platform: 'YouTube',
        url: 'https://www.youtube.com/watch?v=Ia-UEYYR44s',
        duration: '4 hours',
        isFree: true,
      ),
    ],
  ),

  // ─── 4. DevOps Engineer ───────────────────────────────
  const CareerRoadmap(
    id: 'devops-engineer',
    title: 'DevOps Engineer',
    description:
        'Bridge development and operations — automate, deploy, and scale applications efficiently.',
    emoji: '⚙️',
    difficulty: 'Intermediate',
    totalWeeks: 20,
    steps: [
      RoadmapStep(
        title: 'Linux & Networking',
        description:
            'Master Linux commands, shell scripting, networking fundamentals (TCP/IP, DNS, HTTP).',
        skills: ['Linux', 'Bash', 'Networking', 'SSH'],
        durationWeeks: 3,
      ),
      RoadmapStep(
        title: 'Version Control & CI/CD',
        description:
            'Advanced Git, GitHub Actions, Jenkins, and building continuous integration pipelines.',
        skills: ['Git', 'GitHub Actions', 'Jenkins', 'CI/CD'],
        durationWeeks: 3,
      ),
      RoadmapStep(
        title: 'Containers & Orchestration',
        description:
            'Docker fundamentals, multi-stage builds, Docker Compose, and Kubernetes basics.',
        skills: ['Docker', 'Docker Compose', 'Kubernetes', 'Helm'],
        durationWeeks: 4,
      ),
      RoadmapStep(
        title: 'Infrastructure as Code',
        description:
            'Provision and manage infrastructure with Terraform, Ansible, and CloudFormation.',
        skills: ['Terraform', 'Ansible', 'CloudFormation', 'IaC'],
        durationWeeks: 4,
      ),
      RoadmapStep(
        title: 'Monitoring & Observability',
        description:
            'Set up monitoring with Prometheus, Grafana, ELK stack, and alerting systems.',
        skills: ['Prometheus', 'Grafana', 'ELK Stack', 'Alerting'],
        durationWeeks: 3,
      ),
      RoadmapStep(
        title: 'Cloud & Projects',
        description:
            'Deploy to AWS/GCP/Azure. Build CI/CD pipelines for real applications.',
        skills: ['AWS', 'GCP', 'Azure', 'Production Deployments'],
        durationWeeks: 3,
      ),
    ],
    courses: [
      RoadmapCourse(
        title: 'DevOps Roadmap — TechWorld with Nana',
        platform: 'YouTube',
        url: 'https://www.youtube.com/watch?v=9pZ2xmsSDdo',
        duration: '8 hours',
        isFree: true,
      ),
      RoadmapCourse(
        title: 'Kubernetes Course — FreeCodeCamp',
        platform: 'YouTube (FreeCodeCamp)',
        url: 'https://www.youtube.com/watch?v=d6WC5n9G_sM',
        duration: '5 hours',
        isFree: true,
      ),
      RoadmapCourse(
        title: 'Terraform in 2 Hours',
        platform: 'YouTube',
        url: 'https://www.youtube.com/watch?v=SLB_c_ayRMo',
        duration: '2.5 hours',
        isFree: true,
      ),
      RoadmapCourse(
        title: 'GitHub Actions — Full Course',
        platform: 'YouTube (TechWorld with Nana)',
        url: 'https://www.youtube.com/watch?v=R8_veQiYBjI',
        duration: '3 hours',
        isFree: true,
      ),
      RoadmapCourse(
        title: 'Linux for DevOps — Edureka',
        platform: 'YouTube',
        url: 'https://www.youtube.com/watch?v=kPylihJRG70',
        duration: '4 hours',
        isFree: true,
      ),
    ],
  ),

  // ─── 5. Cybersecurity Engineer ────────────────────────
  const CareerRoadmap(
    id: 'cybersecurity-engineer',
    title: 'Cybersecurity Engineer',
    description:
        'Protect systems, networks, and data from cyber threats with ethical hacking and defense strategies.',
    emoji: '🛡️',
    difficulty: 'Advanced',
    totalWeeks: 26,
    steps: [
      RoadmapStep(
        title: 'Networking & OS Fundamentals',
        description:
            'Understand TCP/IP, OSI model, subnetting, Linux, and Windows security internals.',
        skills: ['Networking', 'TCP/IP', 'Linux', 'Windows Security'],
        durationWeeks: 4,
      ),
      RoadmapStep(
        title: 'Security Fundamentals',
        description:
            'Learn CIA triad, encryption, hashing, PKI, firewalls, and common attack vectors.',
        skills: ['Encryption', 'PKI', 'Firewalls', 'Attack Vectors'],
        durationWeeks: 4,
      ),
      RoadmapStep(
        title: 'Ethical Hacking & Pen Testing',
        description:
            'Practice penetration testing with tools like Burp Suite, Nmap, Metasploit on platforms like HackTheBox.',
        skills: ['Burp Suite', 'Nmap', 'Metasploit', 'OWASP Top 10'],
        durationWeeks: 5,
      ),
      RoadmapStep(
        title: 'Web & Application Security',
        description:
            'Exploit and defend against XSS, SQL Injection, CSRF, and insecure APIs.',
        skills: ['XSS', 'SQL Injection', 'CSRF', 'API Security'],
        durationWeeks: 5,
      ),
      RoadmapStep(
        title: 'Cloud & SOC Operations',
        description:
            'Learn cloud security (AWS/Azure), SIEM tools, incident response, and threat hunting.',
        skills: [
          'Cloud Security',
          'SIEM',
          'Incident Response',
          'Threat Hunting'
        ],
        durationWeeks: 4,
      ),
      RoadmapStep(
        title: 'Certifications & CTFs',
        description:
            'Prepare for CompTIA Security+, CEH, or OSCP. Practice on CTF platforms.',
        skills: ['CompTIA Security+', 'CEH', 'OSCP', 'CTF'],
        durationWeeks: 4,
      ),
    ],
    courses: [
      RoadmapCourse(
        title: 'Full Ethical Hacking Course — FreeCodeCamp',
        platform: 'YouTube (FreeCodeCamp)',
        url: 'https://www.youtube.com/watch?v=3Kq1MIfTWCE',
        duration: '15+ hours',
        isFree: true,
      ),
      RoadmapCourse(
        title: 'CompTIA Security+ Full Course',
        platform: 'YouTube (Professor Messer)',
        url: 'https://www.youtube.com/watch?v=9Hd8QJmZQUc',
        duration: '12+ hours',
        isFree: true,
      ),
      RoadmapCourse(
        title: 'TryHackMe — Complete Beginner Path',
        platform: 'TryHackMe',
        url: 'https://tryhackme.com/path/outline/beginner',
        duration: 'Self-paced',
        isFree: true,
      ),
      RoadmapCourse(
        title: 'Web Security — PortSwigger Academy',
        platform: 'PortSwigger',
        url: 'https://portswigger.net/web-security',
        duration: 'Self-paced',
        isFree: true,
      ),
      RoadmapCourse(
        title: 'Networking Fundamentals — NetworkChuck',
        platform: 'YouTube',
        url: 'https://www.youtube.com/watch?v=qiQR5rTSshw',
        duration: '8 hours',
        isFree: true,
      ),
    ],
  ),
];
