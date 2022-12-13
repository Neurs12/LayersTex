import 'package:flutter/services.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/material.dart';
import 'package:layerstex/utils/responsive.dart';
import 'package:layerstex/utils/preview_helper.dart';
import 'contest.dart';
import 'forum.dart';
import 'login.dart';
import 'dart:io' show Platform;
import 'package:window_size/window_size.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import 'package:layerstex/utils/google_sign_in_service.dart';
import 'package:layerstex/utils/group_info.dart';

class HomePageUI extends StatefulWidget {
  const HomePageUI({Key? key, required this.userObj}) : super(key: key);
  final dynamic userObj;

  @override
  State<HomePageUI> createState() => _HomePageUIState();
}

int selectedIndex = 0, preSelectedIndex = 0;
bool launched = false, groupSelected = false;
String displayType = "Contests";
List<Widget> body = [];
Map<int, List<Widget>> contestCards = {}, forumCards = {};
Map<String, List<Widget>> groupsMenu = {"expanded": [], "minimized": []};
dynamic futureContestsCardBuilder, futureForumsCardBuilder, futureMenuBuilder;

class _HomePageUIState extends State<HomePageUI> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      SystemChrome.setApplicationSwitcherDescription(ApplicationSwitcherDescription(
        label: "Trang chủ - LayersTex",
        primaryColor: Theme.of(context).primaryColor.value,
      ));
    });
    try {
      if (Platform.isWindows) {
        setWindowTitle("LayersTex | Trang chủ");
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    if (!launched) {
      futureMenuBuilder = dataBuilder(Theme.of(context).colorScheme);
      launched = true;
    } else {
      menuSetState(preSelectedIndex, selectedIndex, Theme.of(context).colorScheme);
      bodySetState();
    }
    return SafeArea(
        child: Scaffold(
            floatingActionButton: groupSelected
                ? null
                : FloatingActionButton.extended(
                    onPressed: () {},
                    label: const Text("Create forum"),
                    icon: const Icon(Icons.add)),
            body: Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: Responsive.isDesktop(context) ? 10 : 5,
                    vertical: Responsive.isDesktop(context) ? 10 : 5),
                child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  FutureBuilder(
                      future: futureMenuBuilder,
                      builder: (ctx, snapshot) {
                        return Responsive.isDesktop(context)
                            ? menuExpanded(widget.userObj, Theme.of(context).colorScheme)
                            : menuMini(widget.userObj, Theme.of(context).colorScheme);
                      }),
                  Expanded(
                      child: Column(children: [
                    groupSelected ? body[selectedIndex] : homeWelcome(),
                    const SizedBox(height: 50),
                  ]))
                ]))));
  }

  Widget homeWelcome() {
    String greetType = "";
    int hour = DateTime.now().hour;
    if (hour <= 12) {
      greetType = "Chào buổi sáng!";
    } else if (hour <= 18) {
      greetType = "Chào buổi chiều!";
    } else {
      greetType = "Chào buổi tối!";
    }
    return Expanded(child: Center(child: Column(children: [Text(greetType)])));
  }

  void menuSetState(int oldIndex, int newIndex, ColorScheme color) {
    if (groupSelected) {
      groupsMenu["expanded"]![oldIndex] = Padding(
          padding: const EdgeInsets.symmetric(vertical: 3),
          child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 210,
              child: Card(
                  color: color.onSecondary,
                  child: InkWell(
                      borderRadius: const BorderRadius.all(Radius.circular(12)),
                      onTap: () {
                        setState(() {
                          groupSelected = true;
                          preSelectedIndex = selectedIndex;
                          selectedIndex = oldIndex;
                        });
                      },
                      child: SizedBox(
                          height: 50,
                          child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              child: Row(children: [
                                const Icon(Icons.code, size: 24),
                                const SizedBox(width: 5),
                                Expanded(
                                    child: Text(widget.userObj["groupsInfo"][oldIndex]["name"],
                                        softWrap: false, overflow: TextOverflow.fade))
                              ])))))));
      groupsMenu["expanded"]![newIndex] = Padding(
          padding: const EdgeInsets.symmetric(vertical: 3),
          child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 230,
              child: Card(
                  color: color.onPrimary,
                  child: InkWell(
                      borderRadius: const BorderRadius.all(Radius.circular(12)),
                      onTap: null,
                      child: SizedBox(
                          height: 50,
                          child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              child: Row(children: [
                                const Icon(Icons.code, size: 24),
                                const SizedBox(width: 5),
                                Expanded(
                                    child: Text(widget.userObj["groupsInfo"][newIndex]["name"],
                                        softWrap: false, overflow: TextOverflow.fade)),
                                const Icon(Icons.navigate_next)
                              ])))))));
      groupsMenu["minimized"]![oldIndex] = Padding(
          padding: const EdgeInsets.symmetric(vertical: 3),
          child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 50,
              child: Card(
                  color: color.onSecondary,
                  child: InkWell(
                      borderRadius: const BorderRadius.all(Radius.circular(12)),
                      onTap: () {
                        setState(() {
                          groupSelected = true;
                          preSelectedIndex = selectedIndex;
                          selectedIndex = oldIndex;
                        });
                      },
                      child: const SizedBox(
                          height: 40, child: Center(child: Icon(Icons.code, size: 20)))))));
      groupsMenu["minimized"]![newIndex] = Padding(
          padding: const EdgeInsets.symmetric(vertical: 3),
          child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 50,
              child: Card(
                  color: color.onPrimary,
                  child: const SizedBox(height: 40, child: Icon(Icons.code, size: 20)))));
    }
  }

  void bodySetState() {
    try {
      body[selectedIndex] = AnimationLimiter(
          child: Column(
              children: AnimationConfiguration.toStaggeredList(
        duration: const Duration(milliseconds: 375),
        childAnimationBuilder: (widget) => SlideAnimation(
          horizontalOffset: 50,
          child: FadeInAnimation(
            child: widget,
          ),
        ),
        children: [
          Row(mainAxisSize: MainAxisSize.min, children: [
            SizedBox(
                width: Responsive.isDesktop(context) ? 30 : 20,
                height: Responsive.isDesktop(context) ? 60 : 40),
            Icon(Icons.code, size: Responsive.isDesktop(context) ? 40 : 30),
            const SizedBox(width: 20),
            Text(widget.userObj["groupsInfo"][selectedIndex]["name"],
                style: TextStyle(fontSize: Responsive.isDesktop(context) ? 30 : 20)),
            const Spacer(),
            ElevatedButton(
                onPressed: () {
                  setState(() {
                    contestCards[selectedIndex] = [];
                    forumCards[selectedIndex] = [];
                    futureContestsCardBuilder = contestView();
                    futureForumsCardBuilder = forumsView();
                  });
                },
                child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Row(children: const [
                      Icon(Icons.refresh),
                      SizedBox(width: 20),
                      Text("Làm mới")
                    ])))
          ]),
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            SizedBox(
                width: Responsive.isDesktop(context) ? 25 : 15,
                height: Responsive.isDesktop(context) ? 20 : 10),
            Card(
              color: displayType == "Contests" ? Theme.of(context).colorScheme.primary : null,
              shape: RoundedRectangleBorder(
                  side: BorderSide(
                    color: Theme.of(context).colorScheme.outline,
                  ),
                  borderRadius: BorderRadius.circular(8)),
              child: InkWell(
                  onTap: displayType == "Contests"
                      ? null
                      : () {
                          setState(() {
                            displayType = "Contests";
                          });
                        },
                  child: Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: Responsive.isDesktop(context) ? 15 : 10,
                          vertical: Responsive.isDesktop(context) ? 8 : 5),
                      child: Row(children: [
                        displayType == "Contests"
                            ? Padding(
                                padding:
                                    EdgeInsets.only(right: Responsive.isDesktop(context) ? 10 : 7),
                                child: Icon(Icons.check,
                                    size: Responsive.isDesktop(context) ? 20 : 15,
                                    color: displayType == "Contests"
                                        ? Theme.of(context).colorScheme.onPrimary
                                        : null))
                            : Container(),
                        Text("Contests",
                            style: TextStyle(
                                fontSize: Responsive.isDesktop(context) ? 16 : 12,
                                color: displayType == "Contests"
                                    ? Theme.of(context).colorScheme.onPrimary
                                    : null))
                      ]))),
            ),
            Card(
              color: displayType == "Forums" ? Theme.of(context).colorScheme.primary : null,
              shape: RoundedRectangleBorder(
                  side: BorderSide(
                    color: Theme.of(context).colorScheme.outline,
                  ),
                  borderRadius: BorderRadius.circular(8)),
              child: InkWell(
                  onTap: displayType == "Forums"
                      ? null
                      : () {
                          setState(() {
                            displayType = "Forums";
                          });
                        },
                  child: Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: Responsive.isDesktop(context) ? 15 : 10,
                          vertical: Responsive.isDesktop(context) ? 8 : 5),
                      child: Row(children: [
                        displayType == "Forums"
                            ? Padding(
                                padding:
                                    EdgeInsets.only(right: Responsive.isDesktop(context) ? 10 : 7),
                                child: Icon(Icons.check,
                                    size: Responsive.isDesktop(context) ? 20 : 15,
                                    color: displayType == "Forums"
                                        ? Theme.of(context).colorScheme.onPrimary
                                        : null))
                            : Container(),
                        Text("Forums",
                            style: TextStyle(
                                fontSize: Responsive.isDesktop(context) ? 16 : 12,
                                color: displayType == "Forums"
                                    ? Theme.of(context).colorScheme.onPrimary
                                    : null))
                      ]))),
            )
          ]),
          displayType == "Contests"
              ? FutureBuilder(
                  future: futureContestsCardBuilder,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      try {
                        return SizedBox(
                            height: Responsive.isDesktop(context)
                                ? MediaQuery.of(context).size.height - 124
                                : MediaQuery.of(context).size.height - 100,
                            child: SingleChildScrollView(
                              child: AnimationLimiter(
                                  child: Column(
                                      children: AnimationConfiguration.toStaggeredList(
                                duration: const Duration(milliseconds: 375),
                                childAnimationBuilder: (widget) => SlideAnimation(
                                  verticalOffset: 50,
                                  child: FadeInAnimation(
                                    child: widget,
                                  ),
                                ),
                                children: contestCards[selectedIndex]!,
                              ))),
                            ));
                      } catch (e) {
                        return const Text("Nhóm này không tạo bất kì contest nào :(");
                      }
                    }
                    if (snapshot.hasError) {
                      return const Text("Nhóm này không tạo bất kì contest nào :(");
                    }
                    return SizedBox(
                        height: Responsive.isDesktop(context)
                            ? MediaQuery.of(context).size.height - 124
                            : MediaQuery.of(context).size.height - 100,
                        child: Column(children: const [Spacer(), LinearProgressIndicator()]));
                  })
              : FutureBuilder(
                  future: futureForumsCardBuilder,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      try {
                        return SizedBox(
                            height: Responsive.isDesktop(context)
                                ? MediaQuery.of(context).size.height - 124
                                : MediaQuery.of(context).size.height - 100,
                            child: SingleChildScrollView(
                              child: AnimationLimiter(
                                  child: Column(
                                      children: AnimationConfiguration.toStaggeredList(
                                duration: const Duration(milliseconds: 375),
                                childAnimationBuilder: (widget) => SlideAnimation(
                                  verticalOffset: 50,
                                  child: FadeInAnimation(
                                    child: widget,
                                  ),
                                ),
                                children: forumCards[selectedIndex]!,
                              ))),
                            ));
                      } catch (e) {
                        return const Text("Nhóm này không tạo bất kì forum nào :(");
                      }
                    }
                    if (snapshot.hasError) {
                      return const Text("Nhóm này không tạo bất kì forum nào :(");
                    }
                    return SizedBox(
                        height: Responsive.isDesktop(context)
                            ? MediaQuery.of(context).size.height - 124
                            : MediaQuery.of(context).size.height - 100,
                        child: Column(children: const [Spacer(), LinearProgressIndicator()]));
                  })
        ],
      )));
    } catch (_) {}
  }

  Future contestView() async {
    if (contestCards[selectedIndex] == null || contestCards[selectedIndex]!.isEmpty) {
      dynamic cardsRaw =
          await getContestsPreview(widget.userObj["joined_groups"][selectedIndex], 0, null);
      if (cardsRaw.runtimeType != bool) {
        contestCards[selectedIndex] = [];
        for (int raw = 0; raw < cardsRaw.length; raw++) {
          contestCards[selectedIndex]!.add(Hero(
              tag: "contest-${cardsRaw[raw]["id"]}",
              child: Card(
                  child: InkWell(
                      borderRadius: const BorderRadius.all(Radius.circular(12)),
                      splashFactory: NoSplash.splashFactory,
                      hoverColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      focusColor: Colors.transparent,
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ContestUI(
                                    tag: "contest-${cardsRaw[raw]["id"]}",
                                    group: widget.userObj["joined_groups"][selectedIndex],
                                    groupInfo: widget.userObj["groupsInfo"][selectedIndex],
                                    contest: cardsRaw[raw],
                                    userObj: widget.userObj)));
                      },
                      child: SizedBox(
                          width: 1100,
                          height: 200,
                          child: Padding(
                              padding: const EdgeInsets.all(20),
                              child:
                                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                Text(cardsRaw[raw]["title"], style: const TextStyle(fontSize: 20)),
                                const SizedBox(height: 10),
                                Expanded(
                                    child: Text(cardsRaw[raw]["description"],
                                        overflow: TextOverflow.fade,
                                        style: const TextStyle(fontSize: 14))),
                                Opacity(
                                    opacity: 0.7,
                                    child: Text(
                                      "Python 3 / C++ 11 / C++ 14 / FPC\nHết hạn: ${DateFormat('HH:mm dd/MM/yyyy').format(DateTime.fromMillisecondsSinceEpoch(cardsRaw[raw]["end"] * 1000))} | Đã tham gia vào 0:00 16/10/2022",
                                      style: const TextStyle(fontSize: 12),
                                    )),
                              ])))))));
        }
      }
    }
  }

  Future forumsView() async {
    if (forumCards[selectedIndex] == null || forumCards[selectedIndex]!.isEmpty) {
      dynamic cardsRaw =
          await getForumsPreview(widget.userObj["joined_groups"][selectedIndex], 0, null);
      if (cardsRaw.runtimeType != bool) {
        forumCards[selectedIndex] = [];
        for (int raw = 0; raw < cardsRaw.length; raw++) {
          var hero = Hero(
              tag: "forum-${cardsRaw[raw]["id"]}",
              child: Card(
                  child: InkWell(
                      borderRadius: const BorderRadius.all(Radius.circular(12)),
                      splashFactory: NoSplash.splashFactory,
                      hoverColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      focusColor: Colors.transparent,
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ForumUI(
                                    tag: "forum-${cardsRaw[raw]["id"]}",
                                    group: widget.userObj["joined_groups"][selectedIndex],
                                    groupInfo: widget.userObj["groupsInfo"][selectedIndex],
                                    forum: cardsRaw[raw],
                                    userObj: widget.userObj)));
                      },
                      child: SizedBox(
                          width: 1100,
                          height: 200,
                          child: Padding(
                              padding: const EdgeInsets.all(20),
                              child:
                                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                Text(cardsRaw[raw]["question"],
                                    style: const TextStyle(fontSize: 20)),
                                const SizedBox(height: 10),
                                Expanded(
                                    child: Text(cardsRaw[raw]["description"],
                                        overflow: TextOverflow.fade,
                                        style: const TextStyle(fontSize: 14))),
                                Opacity(
                                    opacity: 0.7,
                                    child: Text(
                                      "Đã hỏi vào ${DateFormat('HH:mm dd/MM/yyyy').format(DateTime.fromMillisecondsSinceEpoch(cardsRaw[raw]["asked_at"] * 1000))}",
                                      style: const TextStyle(fontSize: 12),
                                    )),
                              ]))))));
          var hero2 = hero;
          forumCards[selectedIndex]!.add(hero2);
        }
      }
    }
  }

  Future dataBuilder(ColorScheme color) async {
    widget.userObj["groupsInfo"] = [];
    for (int group = 0; group < widget.userObj["joined_groups"].length; ++group) {
      widget.userObj["groupsInfo"]!.add(await groupInfo(widget.userObj["joined_groups"][group]));
      groupsMenu["expanded"]!.add(Padding(
          padding: const EdgeInsets.symmetric(vertical: 3),
          child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 210,
              child: Card(
                  color: color.onSecondary,
                  child: InkWell(
                      borderRadius: const BorderRadius.all(Radius.circular(12)),
                      onTap: () {
                        setState(() {
                          groupSelected = true;
                          preSelectedIndex = selectedIndex;
                          selectedIndex = group;
                          futureContestsCardBuilder = contestView();
                          futureForumsCardBuilder = forumsView();
                        });
                      },
                      child: SizedBox(
                          height: 50,
                          child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              child: Row(children: [
                                const Icon(Icons.code, size: 24),
                                const SizedBox(width: 5),
                                Expanded(
                                    child: Text(widget.userObj["groupsInfo"][selectedIndex]["name"],
                                        softWrap: false, overflow: TextOverflow.fade))
                              ]))))))));
      groupsMenu["minimized"]!.add(Padding(
          padding: const EdgeInsets.symmetric(vertical: 3),
          child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 50,
              child: Card(
                  color: color.onSecondary,
                  child: InkWell(
                      borderRadius: const BorderRadius.all(Radius.circular(12)),
                      onTap: () {
                        setState(() {
                          groupSelected = true;
                          preSelectedIndex = selectedIndex;
                          selectedIndex = group;
                          futureContestsCardBuilder = contestView();
                          futureForumsCardBuilder = forumsView();
                        });
                      },
                      child: const SizedBox(
                          height: 40,
                          child: Center(
                            child: Icon(Icons.code, size: 20),
                          )))))));
      body.add(Container());
    }
    if (groupsMenu["expanded"]!.isEmpty && groupsMenu["minimized"]!.isEmpty) {
      groupsMenu["expanded"] = [const Center(child: Text("Bạn không vào nhóm nào :("))];
      groupsMenu["minimized"] = [const Center(child: Text("Bạn không vào nhóm nào :("))];
    }
  }

  Widget menuExpanded(dynamic userObj, ColorScheme color) {
    return Card(
      child: SizedBox(
          height: double.infinity,
          width: 250,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const SizedBox(height: 10),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              SvgPicture.asset("assets/images/logo.svg", width: 40),
              const SizedBox(width: 10),
              const Text(
                "LayersTex",
                style: TextStyle(fontSize: 18),
              )
            ]),
            const SizedBox(height: 10),
            Center(
                child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 3),
                    child: SizedBox(
                        width: 225,
                        child: Card(
                            color: color.primary,
                            child: SizedBox(
                                height: 50,
                                child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 10),
                                    child: Row(children: [
                                      Icon(Icons.people, color: color.onPrimary),
                                      const SizedBox(width: 5),
                                      Expanded(
                                          child: Text("Diễn đàn chung",
                                              softWrap: false,
                                              overflow: TextOverflow.fade,
                                              style: TextStyle(color: color.onPrimary)))
                                    ]))))))),
            const SizedBox(height: 40),
            const Center(child: Text("Nhóm", style: TextStyle(fontSize: 18))),
            const SizedBox(height: 17),
            Expanded(
                child: SingleChildScrollView(
              child: Row(children: [
                const SizedBox(width: 10),
                AnimationLimiter(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: AnimationConfiguration.toStaggeredList(
                            duration: const Duration(milliseconds: 375),
                            childAnimationBuilder: (widget) => SlideAnimation(
                                  verticalOffset: 50,
                                  child: FadeInAnimation(
                                    child: widget,
                                  ),
                                ),
                            // menu variable made from menuSetState
                            children: groupsMenu["expanded"] == null
                                ? const [SizedBox(width: 225, child: LinearProgressIndicator())]
                                : groupsMenu["expanded"]!.isEmpty
                                    ? const [SizedBox(width: 225, child: LinearProgressIndicator())]
                                    : groupsMenu["expanded"]!))),
              ]),
            )),
            Row(children: [
              Tooltip(
                  message: "Đăng xuất",
                  child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: InkWell(
                          focusColor: Colors.transparent,
                          hoverColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          splashColor: Colors.transparent,
                          onTap: () {
                            showDialog<void>(
                              context: context,
                              barrierDismissible: false,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text('Đăng xuất'),
                                  content: const Text('Bạn có muốn đăng xuất?'),
                                  actions: <Widget>[
                                    TextButton(
                                      child: const Text('Không'),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                    TextButton(
                                      child: const Text('Đăng xuất'),
                                      onPressed: () {
                                        selectedIndex = 0;
                                        preSelectedIndex = 0;
                                        launched = false;
                                        groupSelected = false;
                                        displayType = "Contests";
                                        body = [];
                                        contestCards = {};
                                        forumCards = {};
                                        groupsMenu = {"expanded": [], "minimized": []};
                                        futureContestsCardBuilder = null;
                                        futureForumsCardBuilder = null;
                                        futureMenuBuilder = null;
                                        try {
                                          contestSignoutSignal();
                                        } catch (_) {}
                                        ggSignOut().then((signal) {
                                          if (signal) {
                                            Navigator.pushReplacement(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) => const LoginUI()));
                                          }
                                        });
                                      },
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          child: const Icon(Icons.logout)))),
              Tooltip(
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
                      child: SvgPicture.asset("assets/images/github.svg", width: 30))),
            ])
          ])),
    );
  }

  Widget menuMini(dynamic userObj, ColorScheme color) {
    return Card(
      child: SizedBox(
          height: double.infinity,
          width: 55,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const SizedBox(height: 10),
            Center(child: SvgPicture.asset("assets/images/logo.svg", width: 35)),
            const SizedBox(height: 10),
            Center(
                child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 3),
                    child: SizedBox(
                        width: 50,
                        child: Card(
                            color: color.primary,
                            child: SizedBox(
                                height: 40,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 8),
                                  child: Icon(Icons.people, color: color.onPrimary),
                                )))))),
            const SizedBox(height: 20),
            const Center(child: Text("Nhóm", style: TextStyle(fontSize: 15))),
            const SizedBox(height: 5),
            Expanded(
                child: SingleChildScrollView(
                    child: AnimationLimiter(
                        child: Center(
                            child: Column(
                                children: AnimationConfiguration.toStaggeredList(
              duration: const Duration(milliseconds: 375),
              childAnimationBuilder: (widget) => SlideAnimation(
                verticalOffset: 50,
                child: FadeInAnimation(
                  child: widget,
                ),
              ),
              // menu variable made from menuSetState
              children: groupsMenu["minimized"] == null
                  ? const [SizedBox(width: 20, height: 20, child: CircularProgressIndicator())]
                  : groupsMenu["minimized"]!.isEmpty
                      ? const [SizedBox(width: 20, height: 20, child: CircularProgressIndicator())]
                      : groupsMenu["minimized"]!,
            )))))),
            Padding(
                padding: const EdgeInsets.all(10),
                child: InkWell(
                    focusColor: Colors.transparent,
                    hoverColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    splashColor: Colors.transparent,
                    onTap: () {
                      showDialog<void>(
                        context: context,
                        barrierDismissible: false,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text('Đăng xuất'),
                            content: const Text('Bạn có muốn đăng xuất?'),
                            actions: <Widget>[
                              TextButton(
                                child: const Text('Không'),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                              TextButton(
                                child: const Text('Đăng xuất'),
                                onPressed: () {
                                  selectedIndex = 0;
                                  preSelectedIndex = 0;
                                  launched = false;
                                  groupSelected = false;
                                  displayType = "Contests";
                                  body = [];
                                  contestCards = {};
                                  forumCards = {};
                                  groupsMenu = {"expanded": [], "minimized": []};
                                  futureContestsCardBuilder = null;
                                  futureForumsCardBuilder = null;
                                  futureMenuBuilder = null;
                                  try {
                                    contestSignoutSignal();
                                  } catch (_) {}
                                  ggSignOut().then((signal) {
                                    if (signal) {
                                      Navigator.pushReplacement(context,
                                          MaterialPageRoute(builder: (context) => const LoginUI()));
                                    }
                                  });
                                },
                              ),
                            ],
                          );
                        },
                      );
                    },
                    child: const Icon(Icons.logout)))
          ])),
    );
  }
}
