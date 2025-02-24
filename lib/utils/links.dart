import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthLink {
  Uri getSignUpUrl() {
    return Uri.parse('http://0.0.0.0:8000/authenticate/signup');
  }

  Uri getLoginUrl() {
    return Uri.parse('http://0.0.0.0:8000/authenticate/login');
  }

  Uri getLogoutUrl() {
    return Uri.parse('http://0.0.0.0:8000/authenticate/logout');
  }

  Uri getCreateCookieUrl() {
    return Uri.parse(
      'http://127.0.0.1:8000/authenticate/create-session-cookie',
    );
  }

  Uri getVerifyCookieUrl() {
    return Uri.parse(
      'http://127.0.0.1:8000/authenticate/verify_session_cookie',
    );
  }
}

class ExportLink {
  final List<String> patientsList;

  ExportLink({required this.patientsList});

  Uri fetchAllPatientsUrl() {
    return Uri.parse(
      'http://0.0.0.0:8000/get_report_excel/{"patient_ids": $patientsList}',
    );
  }
}

class PatientLink {
  var fetchAllPatientsUrl = Uri.parse('http://0.0.0.0:8000/patient_load');

  Uri getPatientsUrl() {
    return fetchAllPatientsUrl;
  }
}

class HomeLink {
  Uri getHomeFetch() {
    return Uri.parse('http://0.0.0.0:8000/home-fetch');
  }
}
