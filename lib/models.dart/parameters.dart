class Parameters {
  final String patientId;
  final String consciousness;
  final String heartRate;
  final String urine;
  final String spo2;
  final String temperature;
  final String respiratoryRate;
  final String bloodPressure;
  final String mews;
  final String cvp;

  Parameters({
    required this.patientId,
    required this.consciousness,
    required this.heartRate,
    required this.urine,
    required this.spo2,
    required this.temperature,
    required this.respiratoryRate,
    required this.bloodPressure,
    required this.mews,
    required this.cvp,
  });

  factory Parameters.fromJson(Map<String, dynamic> json) {
    return Parameters(
      patientId: json['patient_id'],
      consciousness: json['consciousness'],
      heartRate: json['heart_rate'],
      urine: json['urine'],
      spo2: json['spo2'],
      temperature: json['temperature'],
      respiratoryRate: json['respiratory_rate'],
      bloodPressure: json['blood_pressure'],
      mews: json['mews'],
      cvp: json['cvp'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'patient_id': patientId,
      'consciousness': consciousness,
      'heart_rate': heartRate,
      'urine': urine,
      'spo2': spo2,
      'temperature': temperature,
      'respiratory_rate': respiratoryRate,
      'blood_pressure': bloodPressure,
      'mews': mews,
      'cvp': cvp,
    };
  }
}
