import 'dart:convert';
import 'package:flutter_client_sse/constants/sse_request_type_enum.dart';
import 'package:flutter_client_sse/flutter_client_sse.dart';

import 'dart:convert';
import 'package:flutter_client_sse/flutter_client_sse.dart';

class FirestoreSSEService {
  final String baseUrl;

  FirestoreSSEService({required this.baseUrl});

  Stream<List<Map<String, dynamic>>> listenToPatients() {
    return SSEClient.subscribeToSSE(
      method: SSERequestType.GET,
      url: "$baseUrl/stream_patients",
      header: {"Accept": "text/event-stream", "Cache-Control": "no-cache"},
    ).map((SSEModel sseEvent) {
      if (sseEvent.data != null) {
        final decoded = jsonDecode(sseEvent.data!);
        return List<Map<String, dynamic>>.from(decoded["patients"]);
      }
      return [];
    });
  }
}
