import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;

GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId:
        kIsWeb ? "949984522577-tag5js0053u3s70ntk8ogrvajmp6jq93.apps.googleusercontent.com" : null,
    serverClientId:
        kIsWeb ? null : "949984522577-ht0o1alannk4nmlj8a2236m4pagpemis.apps.googleusercontent.com",
    scopes: ["email"]);

Future<dynamic> ggSignInSilent() async {
  if (!await _googleSignIn.isSignedIn()) {
    return false;
  }
  GoogleSignInAccount? account =
      kIsWeb ? await _googleSignIn.signInSilently() : await _googleSignIn.signIn();
  if (account == null) {
    return false;
  } else {
    dynamic getData =
        jsonDecode(utf8.decode((await post(Uri.parse("https://test.neurs12.repl.co/login_google"),
                body: jsonEncode({
                  "id": account.id,
                  "photoUrl": account.photoUrl ?? "no_img",
                  "displayName": account.displayName ?? "LayersTex's User"
                }),
                headers: {"Content-Type": "application/json"}))
            .bodyBytes));
    if (getData != "") {
      getData["id"] = account.id;
      return getData;
    }
  }
  return false;
}

Future<dynamic> ggSignIn() async {
  GoogleSignInAccount? account = await _googleSignIn.signIn();
  if (account == null) {
    return false;
  } else {
    dynamic getData =
        jsonDecode(utf8.decode((await post(Uri.parse("https://test.neurs12.repl.co/login_google"),
                body: jsonEncode({
                  "id": account.id,
                  "photoUrl": account.photoUrl ?? "no_img",
                  "displayName": account.displayName ?? "LayersTex's User"
                }),
                headers: {"Content-type": "application/json"}))
            .bodyBytes));
    if (getData != "") {
      getData["id"] = account.id;
      return getData;
    }
  }
  return false;
}

Future<bool> ggSignOut() async {
  try {
    await _googleSignIn.signOut();
  } catch (_) {}
  try {
    await _googleSignIn.disconnect();
  } catch (_) {}
  return true;
}
