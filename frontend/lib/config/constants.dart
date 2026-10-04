class AppConstants {
  static const String appName = 'Careerly';
  static const String appTagline = 'Your career, your next step.';

  static const String defaultApiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8000',
  );

  static const List<String> degrees = [
    'B.Tech',
    'B.E.',
    'B.Sc Computer Science',
    'B.C.A.',
    'M.Tech',
    'M.C.A.',
    'M.Sc Data Science',
    'Other'
  ];

  static const List<String> departments = [
    'Computer Science Engineering',
    'Information Technology',
    'Artificial Intelligence & Data Science',
    'Electronics & Communication Engineering',
    'Electrical & Electronics Engineering',
    'Mechanical Engineering',
    'Civil Engineering',
    'Other'
  ];

  static const List<String> suggestedTechSkills = [
    'Python',
    'Java',
    'C++',
    'C',
    'JavaScript',
    'TypeScript',
    'HTML',
    'CSS',
    'SQL',
    'Machine Learning',
    'Deep Learning',
    'Data Structures',
    'Algorithms',
    'React',
    'Flutter',
    'Node.js',
    'Git & GitHub',
    'Docker',
    'Cloud Computing',
    'Cybersecurity'
  ];

  static const List<String> suggestedSoftSkills = [
    'Problem Solving',
    'Critical Thinking',
    'Communication',
    'Teamwork',
    'Time Management',
    'Leadership',
    'Adaptability',
    'Presentation Skills'
  ];

  static const List<String> suggestedInterests = [
    'Artificial Intelligence',
    'Web Development',
    'Mobile App Development',
    'Data Science & Analytics',
    'Cybersecurity',
    'Cloud Computing',
    'Software Architecture',
    'DevOps',
    'Game Development',
    'Open Source'
  ];

  static const List<String> suggestedCareerGoals = [
    'Software Engineer',
    'AI / ML Engineer',
    'Data Scientist',
    'Data Analyst',
    'Full Stack Developer',
    'Frontend Developer',
    'Backend Engineer',
    'Mobile App Developer',
    'Cloud Solutions Engineer',
    'Cybersecurity Analyst',
    'DevOps Engineer'
  ];
}
