class Holiday {
  final String id;
  final String name;
  final DateTime date;
  final String? description;

  Holiday({
    required this.id,
    required this.name,
    required this.date,
    this.description,
  });

  // For Supabase rows
  factory Holiday.fromMap(Map<String, dynamic> map) {
    return Holiday(
      id: map['id'],
      name: map['name'],
      date: DateTime.parse(map['date']),
      description: map['description'],
    );
  }

  // For date.nager.at API response
  factory Holiday.fromNagerApi(Map<String, dynamic> json) {
    return Holiday(
      id: json['date'] + '_' + json['name'], // synthetic id
      name: json['localName'] ?? json['name'],
      date: DateTime.parse(json['date']),
      description: json['name'],
    );
  }

  bool get isUpcoming => date.isAfter(DateTime.now());
}
