import 'package:http/http.dart';
import 'dart:convert';

Future<dynamic> getContestsPreview(groupId, page, reachedEnd) async {
  if (reachedEnd ?? true) {
    var preview = utf8.decode((await post(
            Uri.parse("https://test.neurs12.repl.co/getcontestspreview?p=$page"),
            body: jsonEncode({"groupId": groupId}),
            headers: {"Content-type": "application/json"}))
        .bodyBytes);
    try {
      return jsonDecode(preview);
    } catch (e) {
      return false;
    }
  }
}

Future<dynamic> getForumsPreview(groupId, page, reachedEnd) async {
  if (reachedEnd ?? true) {
    var preview = utf8.decode((await post(
            Uri.parse("https://test.neurs12.repl.co/getforumspreview?p=$page"),
            body: jsonEncode({"groupId": groupId}),
            headers: {"Content-type": "application/json"}))
        .bodyBytes);
    try {
      return jsonDecode(preview);
    } catch (e) {
      return false;
    }
  }
}
