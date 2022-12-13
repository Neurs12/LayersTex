import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'dart:io' show Platform;
import 'package:window_size/window_size.dart';

class ForumUI extends StatefulWidget {
  const ForumUI(
      {Key? key,
      required this.tag,
      required this.group,
      required this.groupInfo,
      required this.forum,
      required this.userObj})
      : super(key: key);
  final dynamic tag;
  final dynamic group;
  final dynamic groupInfo;
  final dynamic forum;
  final dynamic userObj;

  @override
  State<ForumUI> createState() => _ForumUIState();
}

class _ForumUIState extends State<ForumUI> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      SystemChrome.setApplicationSwitcherDescription(ApplicationSwitcherDescription(
        label: "${widget.forum["question"]} - ${widget.groupInfo["name"]} | LayersTex Forum",
        primaryColor: Theme.of(context).primaryColor.value,
      ));
    });
    try {
      if (Platform.isWindows) {
        setWindowTitle(
            "LayersTex Forum | ${widget.forum["question"]} - ${widget.groupInfo["name"]}");
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Hero(
            tag: widget.tag,
            child: Scaffold(
                body: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  child: Row(children: [
                    IconButton(
                        focusColor: Colors.transparent,
                        hoverColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        splashColor: Colors.transparent,
                        onPressed: () {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            SystemChrome.setApplicationSwitcherDescription(
                                ApplicationSwitcherDescription(
                              label: "Trang chủ - LayersTex",
                              primaryColor: Theme.of(context).primaryColor.value,
                            ));
                          });
                          try {
                            if (Platform.isWindows) {
                              setWindowTitle("LayersTex | Trang chủ");
                            }
                          } catch (_) {}
                          Navigator.pop(context);
                        },
                        icon: const Icon(Icons.arrow_back_ios)),
                    const SizedBox(width: 20),
                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(children: [
                        SvgPicture.asset("assets/images/logo.svg", width: 15),
                        const SizedBox(width: 5),
                        const Text("LayersTex Forum", style: TextStyle(fontSize: 12)),
                      ]),
                      Row(children: [
                        const Icon(Icons.code, size: 30),
                        const SizedBox(width: 15),
                        Text("${widget.groupInfo["name"]}", style: const TextStyle(fontSize: 28))
                      ])
                    ]),
                  ])),
              const Divider(thickness: 1),
              Padding(
                  padding: const EdgeInsets.only(left: 100, right: 100, top: 20),
                  child: SingleChildScrollView(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child:
                            Text(widget.forum["question"], style: const TextStyle(fontSize: 26))),
                    const SizedBox(height: 5),
                    Opacity(
                        opacity: 0.7,
                        child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 25),
                            child: Text(
                                "Đã hỏi vào: ${DateFormat('HH:mm dd/mm/yyyy').format(DateTime.fromMillisecondsSinceEpoch(widget.forum["asked_at"] * 1000))}"))),
                    const SizedBox(height: 10),
                    const Divider(thickness: 1),
                    const SizedBox(height: 20),
                  ])))
            ]))));
  }
}
