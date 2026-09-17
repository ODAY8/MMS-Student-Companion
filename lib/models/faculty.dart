class Faculty {
  final String id;
  final String name;
  final String subject;
  final String? office;
  final String? email;
  final String? officeHours;

  Faculty({
    required this.id,
    required this.name,
    required this.subject,
    this.office,
    this.email,
    this.officeHours,
  });

  factory Faculty.fromMap(Map<String, dynamic> map) {
    return Faculty(
      id: map['id'],
      name: map['name'],
      subject: map['subject'],
      office: map['office'],
      email: map['email'],
      officeHours: map['office_hours'],
    );
  }

  // For randomuser.me API response
  factory Faculty.fromRandomUserApi(Map<String, dynamic> json, int index) {
    final name = json['name'];
    final fullName = 'Dr. ${name['first']} ${name['last']}';

    // Cycle through a fixed list of subjects so faculty look "assigned"
    const subjects = [
      'Mathematics',
      'Physics',
      'Computer Science',
      'Chemistry',
      'English',
      'Economics',
      'Biology',
      'History',
      'Electronics',
      'Mechanical Engineering',
    ];
    final subject = subjects[index % subjects.length];

    // Generate fake office/hours from location data
    final location = json['location'];
    final office =
        'Block ${location['street']['number'] % 5 + 1}, Room ${100 + index}';

    const hourSlots = [
      '9:00 AM - 11:00 AM',
      '11:00 AM - 1:00 PM',
      '2:00 PM - 4:00 PM',
      '4:00 PM - 6:00 PM',
    ];
    final officeHours = hourSlots[index % hourSlots.length];

    return Faculty(
      id: json['login']['uuid'],
      name: fullName,
      subject: subject,
      office: office,
      email: json['email'],
      officeHours: officeHours,
    );
  }
}
