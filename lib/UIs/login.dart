import 'package:flutter/services.dart';
import 'package:window_size/window_size.dart';
import 'package:layerstex/utils/google_sign_in_service.dart';
import 'package:layerstex/utils/responsive.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'home.dart';

class LoginUI extends StatefulWidget {
  const LoginUI({Key? key}) : super(key: key);

  @override
  State<LoginUI> createState() => _LoginUIState();
}

bool signingIn = false;

class _LoginUIState extends State<LoginUI> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      SystemChrome.setApplicationSwitcherDescription(ApplicationSwitcherDescription(
        label: "Đăng nhập - LayersTex",
        primaryColor: Theme.of(context).primaryColor.value,
      ));
    });
    try {
      if (Platform.isWindows) {
        setWindowTitle("LayersTex | Đăng nhập");
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            body: Stack(children: [
      Responsive.isDesktop(context)
          ? SvgPicture.asset(
              "assets/images/login_illustrate.svg",
              height: MediaQuery.of(context).size.height,
            )
          : Positioned.fill(
              child: Align(
                  alignment: Alignment.bottomCenter,
                  child: SvgPicture.asset(
                    "assets/images/login_illustrate_sideway.svg",
                    width: MediaQuery.of(context).size.width,
                  ))),
      Center(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          SvgPicture.asset("assets/images/logo.svg", width: Responsive.isMobile(context) ? 30 : 60),
          const SizedBox(width: 18),
          Text("LayersTex", style: TextStyle(fontSize: Responsive.isMobile(context) ? 24 : 28)),
        ]),
        const SizedBox(height: 20),
        SizedBox(
            height: Responsive.isDesktop(context)
                ? 500
                : Responsive.isTablet(context)
                    ? 400
                    : 375,
            width: Responsive.isDesktop(context)
                ? 700
                : Responsive.isTablet(context)
                    ? 600
                    : 400,
            child: Card(child: StatefulBuilder(builder: (context, setStateWithin) {
              return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text("Đăng nhập",
                        style: TextStyle(fontSize: Responsive.isDesktop(context) ? 35 : 22)),
                    SizedBox(height: Responsive.isDesktop(context) ? 50 : 20),
                    SizedBox(
                        width: Responsive.isDesktop(context)
                            ? 500
                            : Responsive.isTablet(context)
                                ? 400
                                : 300,
                        child: TextField(
                          decoration: InputDecoration(
                              border: const OutlineInputBorder(),
                              labelText: 'Tài khoản',
                              enabled: !signingIn),
                        )),
                    const SizedBox(height: 15),
                    SizedBox(
                        width: Responsive.isDesktop(context)
                            ? 500
                            : Responsive.isTablet(context)
                                ? 400
                                : 300,
                        child: TextField(
                          obscureText: true,
                          decoration: InputDecoration(
                              border: const OutlineInputBorder(),
                              labelText: 'Mật khẩu',
                              enabled: !signingIn),
                        )),
                    SizedBox(height: Responsive.isDesktop(context) ? 40 : 30),
                    Responsive.isMobile(context)
                        ? Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                            ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                                  backgroundColor: Theme.of(context).colorScheme.primary,
                                ).copyWith(elevation: ButtonStyleButton.allOrNull(0.0)),
                                onPressed: signingIn
                                    ? null
                                    : () {
                                        ggSignIn();
                                      },
                                child: SizedBox(
                                  width: 230,
                                  height: 40,
                                  child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: const [
                                        Icon(Icons.login),
                                        SizedBox(width: 15),
                                        Text("Đăng nhập",
                                            style: TextStyle(fontWeight: FontWeight.bold))
                                      ]),
                                )),
                            const SizedBox(height: 10),
                            ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                                  backgroundColor: Theme.of(context).colorScheme.primary,
                                ).copyWith(elevation: ButtonStyleButton.allOrNull(0.0)),
                                onPressed: signingIn
                                    ? null
                                    : () {
                                        setStateWithin(() => signingIn = true);
                                        if (signingIn) {
                                          ggSignIn().then((userObj) {
                                            signingIn = false;
                                            Navigator.pushReplacement(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        HomePageUI(userObj: userObj)));
                                          }).onError((error, stackTrace) {
                                            setStateWithin(() => signingIn = false);
                                          });
                                        }
                                      },
                                child: SizedBox(
                                    width: 230,
                                    height: 40,
                                    child:
                                        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                                      SvgPicture.asset(
                                        "assets/images/Google_G_Logo.svg",
                                        height: 20,
                                      ),
                                      const SizedBox(width: 15),
                                      const Text("Đăng nhập bằng Google",
                                          style: TextStyle(fontWeight: FontWeight.bold)),
                                      signingIn ? const SizedBox(width: 10) : Container(),
                                      signingIn
                                          ? const SizedBox(
                                              height: 15,
                                              width: 15,
                                              child: CircularProgressIndicator())
                                          : Container()
                                    ])))
                          ])
                        : Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                            ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                                  backgroundColor: Theme.of(context).colorScheme.primary,
                                ).copyWith(elevation: ButtonStyleButton.allOrNull(0.0)),
                                onPressed: signingIn
                                    ? null
                                    : () {
                                        ggSignIn();
                                      },
                                child: SizedBox(
                                  width: 230,
                                  height: 40,
                                  child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: const [
                                        Icon(Icons.login),
                                        SizedBox(width: 15),
                                        Text("Đăng nhập",
                                            style: TextStyle(fontWeight: FontWeight.bold))
                                      ]),
                                )),
                            const SizedBox(width: 20),
                            ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                                  backgroundColor: Theme.of(context).colorScheme.primary,
                                ).copyWith(elevation: ButtonStyleButton.allOrNull(0.0)),
                                onPressed: signingIn
                                    ? null
                                    : () {
                                        setStateWithin(() => signingIn = true);
                                        ggSignIn().then((userObj) {
                                          signingIn = false;
                                          Navigator.pushReplacement(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      HomePageUI(userObj: userObj)));
                                        }).onError((error, stackTrace) {
                                          setStateWithin(() => signingIn = false);
                                        });
                                      },
                                child: SizedBox(
                                    width: 230,
                                    height: 40,
                                    child:
                                        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                                      SvgPicture.asset(
                                        "assets/images/Google_G_Logo.svg",
                                        height: 20,
                                      ),
                                      const SizedBox(width: 15),
                                      const Text("Đăng nhập bằng Google",
                                          style: TextStyle(fontWeight: FontWeight.bold)),
                                      signingIn ? const SizedBox(width: 10) : Container(),
                                      signingIn
                                          ? const SizedBox(
                                              height: 15,
                                              width: 15,
                                              child: CircularProgressIndicator())
                                          : Container()
                                    ])))
                          ])
                  ]);
            })))
      ])),
      const Positioned(right: 10, top: 10, child: Text("Version: 1.20.0Alpha Windows")),
      Positioned(
          right: 10,
          bottom: 10,
          child: Tooltip(
              message: "LayersTex's Github repository",
              child: InkWell(
                  focusColor: Colors.transparent,
                  hoverColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  splashColor: Colors.transparent,
                  onTap: () async {
                    await canLaunchUrl(Uri.parse("https://github.com/Neurs12/LayersTex"))
                        ? await launchUrl(Uri.parse("https://github.com/Neurs12/LayersTex"),
                            mode: LaunchMode.externalApplication)
                        : null;
                  },
                  child: SvgPicture.asset("assets/images/github.svg", width: 30))))
    ])));
  }
}
