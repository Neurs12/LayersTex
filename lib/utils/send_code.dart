import 'dart:convert';
import 'package:http/http.dart';

Future<dynamic> sendCode(userId, groupId, contestId, String targetedTask, String codeLanguage,
    String codeSnippet) async {
  await post(Uri.parse("https://test.neurs12.repl.co/send-code"),
      body: jsonEncode({
        "userId": userId,
        "groupId": groupId,
        "contestId": contestId,
        "targetedTask": targetedTask,
        "codeLanguage": codeLanguage,
        "codeSnippet": codeSnippet
      }),
      headers: {"Content-type": "application/json"});
}
