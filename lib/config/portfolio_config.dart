class PortfolioConfig {
  static const name = 'Jayaprakash';
  static const initials = 'JP';
  static const role = 'Mobile Application Developer';
  static const email = 'your.email@example.com';
  static const location = 'Coimbatore, Tamil Nadu, India';
  static const githubUsername = 'YOUR_GITHUB_USERNAME';
  static const githubUrl = 'https://github.com/YOUR_GITHUB_USERNAME';
  static const linkedinUrl = 'https://www.linkedin.com/in/YOUR_LINKEDIN/';
  static const resumeAssetPath = 'assets/resume.pdf';

  // Create a form at https://formspree.io/ and paste its endpoint here.
  // Example: https://formspree.io/f/abcdefgh
  static const formspreeEndpoint = '';

  static const summary =
      'I build scalable, responsive and high-performance mobile applications '
      'for Android and iOS using Flutter, Dart, Kotlin and Java. I enjoy '
      'turning product ideas into reliable applications through clean '
      'architecture, thoughtful UI and practical engineering.';

  static const skills = <String, List<String>>{
    'Mobile': ['Flutter', 'Dart', 'Android', 'Kotlin', 'Java', 'Jetpack Compose'],
    'Architecture': ['MVVM', 'MVC', 'Clean Architecture', 'GetX', 'Provider', 'Riverpod', 'BLoC'],
    'Backend & data': ['Firebase', 'Firestore', 'Realtime Database', 'Supabase', 'SQLite', 'Hive', 'Room', 'REST API'],
    'Integrations': ['Dio', 'Retrofit', 'WebSocket', 'MQTT', 'Google Maps', 'FCM', 'Stripe', 'Razorpay', 'Agora'],
    'Tools & delivery': ['Git', 'GitHub', 'Postman', 'Gradle', 'GitHub Actions', 'CI/CD', 'Play Store', 'App Store'],
  };

  static const projects = [
    Project(
      title: 'Taxi Booking Platform',
      category: 'Mobility',
      description: 'A ride-booking experience with maps, trip workflows, driver tracking and backend integration.',
      stack: ['Flutter', 'Firebase', 'Google Maps', 'REST API'],
      icon: '🚕',
      demoUrl: '',
      sourceUrl: '',
    ),
    Project(
      title: 'E-commerce Application',
      category: 'Commerce',
      description: 'A shopping experience with product discovery, cart, order flows and payment gateway integration.',
      stack: ['Flutter', 'Dart', 'Stripe', 'Razorpay'],
      icon: '🛍️',
      demoUrl: '',
      sourceUrl: '',
    ),
    Project(
      title: 'Service Booking App',
      category: 'On-demand services',
      description: 'A service marketplace concept with categories, appointment booking and status updates.',
      stack: ['Flutter', 'GetX', 'Firebase', 'REST API'],
      icon: '🧰',
      demoUrl: '',
      sourceUrl: '',
    ),
    Project(
      title: 'School Management App',
      category: 'Education',
      description: 'A mobile experience for academic information, attendance, schedules and notifications.',
      stack: ['Flutter', 'Firebase', 'SQLite'],
      icon: '🎓',
      demoUrl: '',
      sourceUrl: '',
    ),
  ];
}

class Project {
  const Project({
    required this.title,
    required this.category,
    required this.description,
    required this.stack,
    required this.icon,
    required this.demoUrl,
    required this.sourceUrl,
  });

  final String title;
  final String category;
  final String description;
  final List<String> stack;
  final String icon;
  final String demoUrl;
  final String sourceUrl;
}
