import 'package:http/http.dart';
import 'dart:convert';

Future<dynamic> trackResult(userId, groupId, contestId, String targetedTask) async {
  Response status = await post(Uri.parse("https://test.neurs12.repl.co/check-result"),
      body: jsonEncode({
        "userId": userId,
        "groupId": groupId,
        "contestId": contestId,
        "targetedTask": targetedTask
      }),
      headers: {"Content-type": "application/json"});
  return jsonDecode(status.body);
}
