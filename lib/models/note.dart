class Note {
  final String text;
  final String auditorID;

  Note({required this.text, required this.auditorID});

  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(text: json['text'], auditorID: json['audit_by']);
  }

  Map<String, dynamic> toJson() {
    return {'text': text, 'audit_by': auditorID};
  }
}
