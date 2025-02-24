class Patient {
  final String pId;
  final String name;
  final String surname;
  final int age;
  final String gender;
  final int MEWs;
  final DateTime lastUpdate;
  final String bedNumber;
  final String hn;
  final String ward;
  final List<String> note;

  Patient({
    required this.pId,
    required this.name,
    required this.surname,
    required this.age,
    required this.gender,
    required this.MEWs,
    required this.lastUpdate,
    required this.bedNumber,
    required this.hn,
    required this.ward,
    this.note = const [],
  });
}
