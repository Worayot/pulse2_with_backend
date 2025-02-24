int calculateMEWs({
  required String consciousness,
  int? heartRate,
  double? temperature,
  int? systolicBp,
  int? spo2,
  int? respiratoryRate,
  int? urine,
}) {
  int score = 0;
  // Consciousness scoring
  Map<String, int> consciousnessScoreMap = {
    "Unresponsive": 3,
    "Pain": 2,
    "verbalStimuli": 1,
    "Alert": 2,
    "Conscious": 0,
    "-": 0,
    " ": 0
  };

  score += consciousnessScoreMap[consciousness] ??
      0; // Default to 0 if consciousness is unknown

  // Heart Rate scoring
  if (heartRate != null) {
    if (heartRate > 130) {
      score += 3;
    } else if ((heartRate < 40) || (heartRate >= 111 && heartRate <= 130)) {
      score += 2;
    } else if ((heartRate >= 40 && heartRate <= 50) ||
        (heartRate >= 101 && heartRate <= 110)) {
      score += 1;
    }
  }

  // Respiratory Rate scoring
  if (respiratoryRate != null) {
    if (respiratoryRate < 8 || respiratoryRate > 30) {
      score += 3;
    } else if (respiratoryRate >= 21 && respiratoryRate <= 30) {
      score += 1;
    }
  }

  // Systolic Blood Pressure scoring
  if (systolicBp != null) {
    if (systolicBp < 70 || systolicBp > 220) {
      score += 3;
    } else if ((systolicBp >= 71 && systolicBp <= 80) ||
        (systolicBp >= 201 && systolicBp <= 220)) {
      score += 2;
    } else if ((systolicBp >= 81 && systolicBp <= 100) ||
        (systolicBp >= 181 && systolicBp <= 200)) {
      score += 1;
    }
  }

  // Temperature scoring
  if (temperature != null) {
    if (temperature < 34 || temperature > 40) {
      score += 3;
    } else if ((temperature >= 34 && temperature <= 35) ||
        (temperature >= 38.6 && temperature <= 40)) {
      score += 2;
    } else if (temperature >= 35.1 && temperature <= 37.5) {
      score += 0;
    } else if (temperature >= 37.6 && temperature <= 38.5) {
      score += 1;
    }
  }

  // Oxygen Saturation (Spo2) scoring
  if (spo2 != null) {
    if (spo2 <= 90) {
      score += 3;
    } else if (spo2 >= 91 && spo2 <= 93) {
      score += 2;
    }
  }

  // Urine Output scoring
  if (urine != null) {
    if (urine < 30) {
      score += 3;
    }
  }

  return score;
}
