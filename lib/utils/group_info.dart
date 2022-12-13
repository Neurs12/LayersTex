import 'package:http/http.dart';
import 'dart:convert';

Future<dynamic> groupInfo(groupId) async {
  String groupInf = utf8.decode((await post(Uri.parse("https://test.neurs12.repl.co/group-info"),
          body: jsonEncode({"groupId": groupId}), headers: {"Content-type": "application/json"}))
      .bodyBytes);
  try {
    return jsonDecode(groupInf);
  } catch (e) {
    return false;
  }
}
