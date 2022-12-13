import 'package:http/http.dart';
import 'dart:convert';

Future<dynamic> userInfo(userId) async {
  return jsonDecode(utf8.decode((await post(Uri.parse("https://test.neurs12.repl.co/get-user-info"),
          body: jsonEncode({"userId": userId}), headers: {"Content-type": "application/json"}))
      .bodyBytes));
}

Future<dynamic> forLoopUserInfo(answers) async {
  dynamic out = {};
  for (int aObj = 0; aObj < answers.length; aObj++) {
    out[answers[aObj]["user"]] = userInfo(answers[aObj]["user"]);
  }
  return out;
}
