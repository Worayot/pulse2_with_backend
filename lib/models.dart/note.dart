class Note {
  final String text;
  final String auditor;

  Note({required this.text, required this.auditor});

  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(text: json['text'], auditor: json['audit_by']);
  }

  Map<String, dynamic> toJson() {
    return {'text': text, 'audit_by': auditor};
  }
}
