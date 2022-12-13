import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:convert';
import 'dart:io' show Platform;
import 'package:window_size/window_size.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:layerstex/utils/track_result.dart';
import 'package:layerstex/utils/responsive.dart';
import 'package:layerstex/utils/send_code.dart';
import 'package:http/http.dart';

class ContestUI extends StatefulWidget {
  const ContestUI(
      {Key? key,
      required this.tag,
      required this.group,
      required this.contest,
      required this.groupInfo,
      required this.userObj})
      : super(key: key);
  final dynamic tag;
  final dynamic group;
  final dynamic contest;
  final dynamic groupInfo;
  final dynamic userObj;

  @override
  State<ContestUI> createState() => _ContestUIState();
}

String selectedLang = "C++ 14", selectedText = "";
Map<String, List<bool>> sent = {}, finished = {}, expandResult = {};
Map<String, List<TextEditingController>> codeInput = {};
Map<String, dynamic> cdObj = {};
Map<String, String> displayType = {};
Map<String, List<List<Widget>>> testCasesShow = {};
bool isModalClosed = true;
late Future<List<Widget>> futureTasksBuilder;
late Future<Widget> scoreboard;
PdfViewerController pdfCtrl = PdfViewerController();

void contestSignoutSignal() {
  selectedLang = "C++ 14";
  selectedText = "";
  sent = {};
  expandResult = {};
  finished = {};
  codeInput = {};
  cdObj = {};
  displayType = {};
  isModalClosed = true;
  futureTasksBuilder = [] as Future<List<Widget>>;
  testCasesShow = {};
}

class _ContestUIState extends State<ContestUI> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      SystemChrome.setApplicationSwitcherDescription(ApplicationSwitcherDescription(
        label: "${widget.contest["title"]} - ${widget.groupInfo["name"]} | LayersTex COJ",
        primaryColor: Theme.of(context).primaryColor.value,
      ));
    });
    try {
      if (Platform.isWindows) {
        setWindowTitle("LayersTex COJ | ${widget.contest["title"]} - ${widget.groupInfo["name"]}");
      }
    } catch (_) {}
    futureTasksBuilder = contestDetails(widget.group, widget.contest["id"]);
    if (displayType["${widget.group}-${widget.contest["id"]}"] == null) {
      displayType["${widget.group}-${widget.contest["id"]}"] = "Problem";
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Hero(
            tag: widget.tag,
            child: Scaffold(
                body: Column(children: [
              Padding(
                  padding: EdgeInsets.only(
                      left: Responsive.isMobile(context) ? 10 : 20,
                      right: Responsive.isMobile(context) ? 10 : 20,
                      top: Responsive.isMobile(context) ? 10 : 20),
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
                        icon: Icon(Icons.arrow_back_ios,
                            size: Responsive.isMobile(context) ? 20 : null)),
                    SizedBox(width: Responsive.isMobile(context) ? 5 : 20),
                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(children: [
                        const Icon(Icons.code, size: 15),
                        Responsive.isMobile(context)
                            ? Container()
                            : Text(" ${widget.groupInfo["name"]}",
                                style: const TextStyle(fontSize: 12)),
                        const SizedBox(width: 8),
                        const Text("|"),
                        const SizedBox(width: 8),
                        SvgPicture.asset("assets/images/logo.svg", width: 15),
                        Responsive.isMobile(context)
                            ? Container()
                            : const Text(" LayersTex COJ", style: TextStyle(fontSize: 12)),
                      ]),
                      Text(
                        widget.contest["title"],
                        style: TextStyle(fontSize: Responsive.isMobile(context) ? 22 : 28),
                      ),
                    ]),
                    Responsive.isMobile(context)
                        ? Container()
                        : Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            const SizedBox(width: 25, height: 20),
                            Card(
                              color: displayType["${widget.group}-${widget.contest["id"]}"] ==
                                      "Problem"
                                  ? Theme.of(context).colorScheme.primary
                                  : null,
                              shape: RoundedRectangleBorder(
                                  side: BorderSide(
                                    color: Theme.of(context).colorScheme.outline,
                                  ),
                                  borderRadius: BorderRadius.circular(8)),
                              child: InkWell(
                                  onTap: displayType["${widget.group}-${widget.contest["id"]}"] ==
                                          "Problem"
                                      ? null
                                      : () {
                                          setState(() {
                                            displayType["${widget.group}-${widget.contest["id"]}"] =
                                                "Problem";
                                          });
                                        },
                                  child: Padding(
                                      padding:
                                          const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                                      child: Text("Problem",
                                          style: TextStyle(
                                              fontSize: 16,
                                              color: displayType[
                                                          "${widget.group}-${widget.contest["id"]}"] ==
                                                      "Problem"
                                                  ? Theme.of(context).colorScheme.onPrimary
                                                  : null)))),
                            ),
                            Card(
                              color: displayType["${widget.group}-${widget.contest["id"]}"] ==
                                      "Scoreboard"
                                  ? Theme.of(context).colorScheme.primary
                                  : null,
                              shape: RoundedRectangleBorder(
                                  side: BorderSide(
                                    color: Theme.of(context).colorScheme.outline,
                                  ),
                                  borderRadius: BorderRadius.circular(8)),
                              child: InkWell(
                                  onTap: displayType["${widget.group}-${widget.contest["id"]}"] ==
                                          "Scoreboard"
                                      ? null
                                      : () {
                                          setState(() {
                                            scoreboard = scoreboardDetails(
                                                widget.group, widget.contest["id"]);
                                            displayType["${widget.group}-${widget.contest["id"]}"] =
                                                "Scoreboard";
                                          });
                                        },
                                  child: Padding(
                                      padding:
                                          const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                                      child: Text("Scoreboard",
                                          style: TextStyle(
                                              fontSize: 16,
                                              color: displayType[
                                                          "${widget.group}-${widget.contest["id"]}"] ==
                                                      "Scoreboard"
                                                  ? Theme.of(context).colorScheme.onPrimary
                                                  : null)))),
                            )
                          ]),
                    const Spacer(),
                    Responsive.isMobile(context)
                        ? Container()
                        : ElevatedButton(
                            onPressed: () {
                              showDialog<void>(
                                context: context,
                                barrierDismissible: false,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: const Text('Làm mới'),
                                    content:
                                        const Text('Việc làm mới sẽ xóa code lưu tạm của các bài.'),
                                    actions: <Widget>[
                                      TextButton(
                                        child: const Text('Quay lại'),
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                      ),
                                      TextButton(
                                        child: const Text('Tiếp tục'),
                                        onPressed: () {
                                          setState(() {
                                            cdObj["${widget.group}-${widget.contest["id"]}"] = {};
                                            sent["${widget.group}-${widget.contest["id"]}"] = [];
                                            codeInput["${widget.group}-${widget.contest["id"]}"] =
                                                [];
                                            testCasesShow[
                                                "${widget.group}-${widget.contest["id"]}"] = [];
                                            finished["${widget.group}-${widget.contest["id"]}"] =
                                                [];
                                            expandResult[
                                                "${widget.group}-${widget.contest["id"]}"] = [];
                                            futureTasksBuilder =
                                                contestDetails(widget.group, widget.contest["id"]);
                                          });
                                          Navigator.of(context).pop();
                                        },
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                            child: Padding(
                                padding: const EdgeInsets.all(10),
                                child: Row(children: const [
                                  Icon(Icons.refresh),
                                  SizedBox(width: 20),
                                  Text("Làm mới")
                                ])))
                  ])),
              Responsive.isMobile(context)
                  ? Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        const SizedBox(width: 15, height: 10),
                        Card(
                          color: displayType["${widget.group}-${widget.contest["id"]}"] == "Problem"
                              ? Theme.of(context).colorScheme.primary
                              : null,
                          shape: RoundedRectangleBorder(
                              side: BorderSide(
                                color: Theme.of(context).colorScheme.outline,
                              ),
                              borderRadius: BorderRadius.circular(8)),
                          child: InkWell(
                              onTap: displayType["${widget.group}-${widget.contest["id"]}"] ==
                                      "Problem"
                                  ? null
                                  : () {
                                      setState(() {
                                        displayType["${widget.group}-${widget.contest["id"]}"] =
                                            "Problem";
                                      });
                                    },
                              child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                  child: Text("Problem",
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: displayType[
                                                      "${widget.group}-${widget.contest["id"]}"] ==
                                                  "Problem"
                                              ? Theme.of(context).colorScheme.onPrimary
                                              : null)))),
                        ),
                        Card(
                          color:
                              displayType["${widget.group}-${widget.contest["id"]}"] == "Scoreboard"
                                  ? Theme.of(context).colorScheme.primary
                                  : null,
                          shape: RoundedRectangleBorder(
                              side: BorderSide(
                                color: Theme.of(context).colorScheme.outline,
                              ),
                              borderRadius: BorderRadius.circular(8)),
                          child: InkWell(
                              onTap: displayType["${widget.group}-${widget.contest["id"]}"] ==
                                      "Scoreboard"
                                  ? null
                                  : () {
                                      setState(() {
                                        scoreboard =
                                            scoreboardDetails(widget.group, widget.contest["id"]);
                                        displayType["${widget.group}-${widget.contest["id"]}"] =
                                            "Scoreboard";
                                      });
                                    },
                              child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                  child: Text("Scoreboard",
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: displayType[
                                                      "${widget.group}-${widget.contest["id"]}"] ==
                                                  "Scoreboard"
                                              ? Theme.of(context).colorScheme.onPrimary
                                              : null)))),
                        )
                      ]),
                      const SizedBox(width: 25),
                      ElevatedButton(
                          onPressed: () {
                            showDialog<void>(
                              context: context,
                              barrierDismissible: false,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text('Làm mới'),
                                  content:
                                      const Text('Việc làm mới sẽ xóa code lưu tạm của các bài.'),
                                  actions: <Widget>[
                                    TextButton(
                                      child: const Text('Quay lại'),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                    TextButton(
                                      child: const Text('Tiếp tục'),
                                      onPressed: () {
                                        setState(() {
                                          cdObj["${widget.group}-${widget.contest["id"]}"] = {};
                                          sent["${widget.group}-${widget.contest["id"]}"] = [];
                                          codeInput["${widget.group}-${widget.contest["id"]}"] = [];
                                          testCasesShow["${widget.group}-${widget.contest["id"]}"] =
                                              [];
                                          finished["${widget.group}-${widget.contest["id"]}"] = [];
                                          expandResult["${widget.group}-${widget.contest["id"]}"] =
                                              [];
                                          futureTasksBuilder =
                                              contestDetails(widget.group, widget.contest["id"]);
                                        });
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          child:
                              const Padding(padding: EdgeInsets.all(3), child: Icon(Icons.refresh)))
                    ])
                  : Container(),
              displayType["${widget.group}-${widget.contest["id"]}"] == "Problem"
                  ? SizedBox(
                      height: MediaQuery.of(context).size.height -
                          (Responsive.isMobile(context) ? 143 : 100),
                      child: SingleChildScrollView(
                          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Column(children: [
                          Responsive.isTablet(context) || Responsive.isMobile(context)
                              ? Container()
                              : const Text("* Giữ chuột và di chuyển ở phần xám để cuộn",
                                  style: TextStyle(fontSize: 12)),
                          Stack(alignment: AlignmentDirectional.topCenter, children: [
                            SizedBox(
                              height: MediaQuery.of(context).size.height - 130,
                              width: MediaQuery.of(context).size.width -
                                  (Responsive.isTablet(context) ? 500 : 600),
                              child: SfPdfViewer.network(
                                  "https://test.neurs12.repl.co/pdf-contest?groupId=${widget.group}&contestId=${widget.contest["id"]}",
                                  initialZoomLevel: 1.75,
                                  controller: pdfCtrl,
                                  onTextSelectionChanged: (PdfTextSelectionChangedDetails details) {
                                if (details.selectedText != null) {
                                  selectedText = details.selectedText!;
                                }
                              }),
                            ),
                            Card(
                                child: Padding(
                                    padding: Responsive.isMobile(context)
                                        ? const EdgeInsets.all(2)
                                        : const EdgeInsets.all(5),
                                    child: SizedBox(
                                        width: Responsive.isMobile(context) ? 200 : 250,
                                        child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                            children: [
                                              IconButton(
                                                  onPressed: () => pdfCtrl.zoomLevel += .25,
                                                  icon: const Icon(Icons.zoom_in)),
                                              IconButton(
                                                  onPressed: () => pdfCtrl.zoomLevel -= .25,
                                                  icon: const Icon(Icons.zoom_out)),
                                              IconButton(
                                                  onPressed: () {
                                                    Clipboard.setData(
                                                        ClipboardData(text: selectedText));
                                                  },
                                                  icon: const Icon(Icons.copy)),
                                              IconButton(
                                                  onPressed: () async {
                                                    await canLaunchUrl(Uri.parse(
                                                            "https://test.neurs12.repl.co/pdf-contest?groupId=${widget.group}&contestId=${widget.contest["id"]}"))
                                                        ? launchUrl(
                                                            Uri.parse(
                                                                "https://test.neurs12.repl.co/pdf-contest?groupId=${widget.group}&contestId=${widget.contest["id"]}"),
                                                            mode: LaunchMode.externalApplication)
                                                        : null;
                                                  },
                                                  icon: Icon(Responsive.isMobile(context)
                                                      ? Icons.file_download_outlined
                                                      : Icons.open_in_new))
                                            ])))),
                          ]),
                        ]),
                        const SizedBox(width: 20),
                        FutureBuilder(
                            future: futureTasksBuilder,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.done) {
                                return StatefulBuilder(builder: (context, setStateWithin) {
                                  return SizedBox(
                                      width: Responsive.isTablet(context) ? 300 : 425,
                                      height: MediaQuery.of(context).size.height - 110,
                                      child: Card(
                                          elevation: 0,
                                          shape: RoundedRectangleBorder(
                                            side: BorderSide(
                                              color: Theme.of(context).colorScheme.outline,
                                            ),
                                            borderRadius:
                                                const BorderRadius.all(Radius.circular(12)),
                                          ),
                                          child: Padding(
                                              padding: const EdgeInsets.all(10),
                                              child: Column(children: [
                                                Row(children: const [
                                                  SizedBox(width: 10),
                                                  Text(
                                                    "Tasks",
                                                    style: TextStyle(fontSize: 18),
                                                  ),
                                                ]),
                                                SingleChildScrollView(
                                                    child: Wrap(
                                                        crossAxisAlignment:
                                                            WrapCrossAlignment.center,
                                                        alignment: WrapAlignment.center,
                                                        children: snapshot.data!))
                                              ]))));
                                });
                              }
                              return SizedBox(
                                  width: Responsive.isTablet(context) ? 300 : 425,
                                  height: MediaQuery.of(context).size.height - 110,
                                  child: Card(
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        side: BorderSide(
                                          color: Theme.of(context).colorScheme.outline,
                                        ),
                                        borderRadius: const BorderRadius.all(Radius.circular(12)),
                                      ),
                                      child: Padding(
                                          padding: const EdgeInsets.all(10),
                                          child: Row(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: const [
                                                SizedBox(width: 10),
                                                Text(
                                                  "Tasks",
                                                  style: TextStyle(fontSize: 18),
                                                ),
                                                Spacer(),
                                                SizedBox(
                                                    height: 15,
                                                    width: 15,
                                                    child: CircularProgressIndicator())
                                              ]))));
                            })
                      ])))
                  : SingleChildScrollView(
                      child: Column(children: [
                      const Text("Scoreboard", style: TextStyle(fontSize: 32)),
                      const Text("Climb to the top! (If you've got balls)"),
                      FutureBuilder(
                          future: scoreboard,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.done) {
                              return SizedBox(
                                  height: MediaQuery.of(context).size.height - 146,
                                  child: snapshot.data!);
                            } else {
                              return SizedBox(
                                  height: MediaQuery.of(context).size.height - 146,
                                  child: Column(
                                      children: const [Spacer(), LinearProgressIndicator()]));
                            }
                          })
                    ])),
            ]))));
  }

  Future<Widget> scoreboardDetails(groupId, contestId) async {
    List<TableRow> boardBuilder = [];
    dynamic scores = jsonDecode(utf8.decode((await post(
            Uri.parse("https://test.neurs12.repl.co/scoreboard"),
            body: jsonEncode({"groupId": groupId, "contestId": contestId}),
            headers: {"Content-type": "application/json"}))
        .bodyBytes));
    Map<String, int> totalScores = {};

    List<Widget> tasksDisplay = [];
    for (String task in scores["details"]["tasks"]) {
      tasksDisplay.add(Center(child: Text(task, style: const TextStyle(fontSize: 20))));
    }

    boardBuilder.add(TableRow(children: [
      const SizedBox(
          height: 50, child: Center(child: Text("Standing", style: TextStyle(fontSize: 20)))),
      const Center(child: Text("Participant", style: TextStyle(fontSize: 20))),
      const Center(child: Text("Score", style: TextStyle(fontSize: 20))),
      ...tasksDisplay
    ]));
    for (String par in scores["score"].keys) {
      for (String problem in scores["score"][par]["data"].keys) {
        scores["score"][par]["data"][problem]["scores"].sort((b, a) => a.compareTo(b) as int);
        totalScores[par] =
            (totalScores[par] ?? 0) + scores["score"][par]["data"][problem]["scores"][0] as int;
      }
    }
    var standindSorted = totalScores.entries.toList()
      ..sort((e1, e2) {
        var diff = e2.value.compareTo(e1.value);
        if (diff == 0) diff = e2.key.compareTo(e1.key);
        return diff;
      });
    List<Widget> scoreDisplay = [];
    int actualCount = 1;
    int preScore = totalScores[standindSorted[0].key]!;
    for (int count = 0; count < standindSorted.length; count++) {
      if (preScore > totalScores[standindSorted[count].key]!) {
        actualCount++;
      }
      scoreDisplay = [];
      for (String task in scores["details"]["tasks"]) {
        try {
          scoreDisplay.add(Center(
              child: Text(
                  scores["score"][standindSorted[count].key]["data"][task]["scores"][0].toString(),
                  style: const TextStyle(fontSize: 18))));
        } catch (_) {
          scoreDisplay.add(const Center(child: Text("", style: TextStyle(fontSize: 18))));
        }
      }
      boardBuilder.add(TableRow(children: [
        SizedBox(
            height: 40,
            child: Center(
                child: Text((actualCount).toString(),
                    style: TextStyle(
                        fontSize: 18,
                        color: actualCount == 1
                            ? Colors.yellowAccent
                            : actualCount == 2
                                ? Colors.grey
                                : actualCount == 3
                                    ? Colors.brown
                                    : null)))),
        Center(
            child: Text(scores["score"][standindSorted[count].key]["name"],
                style: const TextStyle(fontSize: 18))),
        Center(
            child: Text(totalScores[standindSorted[count].key].toString(),
                style: const TextStyle(fontSize: 18))),
        ...scoreDisplay
      ]));
    }
    Map<int, FixedColumnWidth> widths = {
      0: const FixedColumnWidth(125),
      1: const FixedColumnWidth(300),
      2: const FixedColumnWidth(175)
    };
    double setWidth = 600;
    for (int pos = 3; pos < tasksDisplay.length + 3; pos++) {
      widths[pos] = const FixedColumnWidth(150);
      setWidth += 150;
    }
    return SizedBox(
        width: setWidth > MediaQuery.of(context).size.width
            ? MediaQuery.of(context).size.width
            : setWidth,
        height: MediaQuery.of(context).size.height,
        child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Table(
                    columnWidths: widths,
                    border: TableBorder.all(color: Theme.of(context).colorScheme.primary),
                    defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                    children: boardBuilder))));
  }

  Future<List<Widget>> contestDetails(groupId, contestId) async {
    if (cdObj["${widget.group}-${widget.contest["id"]}"] == null ||
        cdObj["${widget.group}-${widget.contest["id"]}"].isEmpty) {
      try {
        cdObj["${widget.group}-${widget.contest["id"]}"] = jsonDecode(utf8.decode((await post(
                Uri.parse("https://test.neurs12.repl.co/contestdetails"),
                body: jsonEncode({"groupId": groupId, "contestId": contestId}),
                headers: {"Content-type": "application/json"}))
            .bodyBytes));
      } catch (e) {
        return const [Text("Contest này không tạo task nào!")];
      }
      sent["${widget.group}-${widget.contest["id"]}"] = [];
      expandResult["${widget.group}-${widget.contest["id"]}"] = [];
      codeInput["${widget.group}-${widget.contest["id"]}"] = [];
      testCasesShow["${widget.group}-${widget.contest["id"]}"] = [];
      finished["${widget.group}-${widget.contest["id"]}"] = [];
      for (int i = 0; i < cdObj["${widget.group}-${widget.contest["id"]}"]["tasks"].length; i++) {
        testCasesShow["${widget.group}-${widget.contest["id"]}"]!.add([Container()]);
        finished["${widget.group}-${widget.contest["id"]}"]!.add(false);
        sent["${widget.group}-${widget.contest["id"]}"]!.add(false);
        expandResult["${widget.group}-${widget.contest["id"]}"]!.add(false);
        codeInput["${widget.group}-${widget.contest["id"]}"]!.add(TextEditingController());
      }
    }
    List<Widget> tasksDisplay = [];
    for (int i = 0; i < cdObj["${widget.group}-${widget.contest["id"]}"]["tasks"].length; i++) {
      tasksDisplay.add(Card(
          child: InkWell(
              splashFactory: NoSplash.splashFactory,
              hoverColor: Colors.transparent,
              highlightColor: Colors.transparent,
              focusColor: Colors.transparent,
              onTap: () {
                if (mounted) {
                  modalCode(i);
                }
              },
              child: SizedBox(
                  width: 360,
                  child: Padding(
                      padding: const EdgeInsets.only(top: 10, bottom: 10, left: 20),
                      child: Row(children: [
                        const Icon(Icons.description, size: 40),
                        const SizedBox(width: 20),
                        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(cdObj["${widget.group}-${widget.contest["id"]}"]["tasks"][i],
                              style: const TextStyle(fontSize: 18, fontFamily: "Source Code Pro")),
                          Row(children: [
                            Text(
                                "AC: ${cdObj["${widget.group}-${widget.contest["id"]}"]["ACs"][cdObj["${widget.group}-${widget.contest["id"]}"]["tasks"][i]]}",
                                style: const TextStyle(color: Colors.green, fontSize: 14)),
                            const Icon(Icons.person, color: Colors.green, size: 20)
                          ])
                        ])
                      ]))))));
    }
    return tasksDisplay;
  }

  void modalCode(index) {
    showModalBottomSheet<void>(
        isScrollControlled: true,
        context: context,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        builder: (context) {
          return StatefulBuilder(builder: (context, setStateModal) {
            return SizedBox(
                height: expandResult["${widget.group}-${widget.contest["id"]}"]![index]
                    ? MediaQuery.of(context).size.height
                    : MediaQuery.of(context).size.height * .75,
                child: Column(children: [
                  Stack(children: [
                    Padding(
                        padding: const EdgeInsets.all(10),
                        child: Row(children: [
                          const Spacer(),
                          InkWell(
                              splashFactory: NoSplash.splashFactory,
                              hoverColor: Colors.transparent,
                              highlightColor: Colors.transparent,
                              focusColor: Colors.transparent,
                              onTap: () {
                                Navigator.of(context).pop();
                              },
                              child:
                                  Icon(Icons.close, size: Responsive.isMobile(context) ? 25 : 30))
                        ])),
                    Padding(
                        padding: const EdgeInsets.all(10),
                        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                          IconButton(
                              onPressed: index > 0
                                  ? () {
                                      setStateModal(() {
                                        index--;
                                      });
                                    }
                                  : () {
                                      setStateModal(() {
                                        index = cdObj["${widget.group}-${widget.contest["id"]}"]
                                                    ["tasks"]
                                                .length -
                                            1;
                                      });
                                    },
                              icon: Icon(Icons.navigate_before,
                                  size: Responsive.isMobile(context) ? 20 : 25)),
                          SizedBox(
                              width: Responsive.isMobile(context) ? 150 : 250,
                              child: Center(
                                  child: Text(
                                      cdObj["${widget.group}-${widget.contest["id"]}"]["tasks"]
                                          [index],
                                      style: TextStyle(
                                          fontFamily: "Source Code Pro",
                                          fontSize: Responsive.isMobile(context) ? 22 : 28),
                                      overflow: TextOverflow.fade))),
                          IconButton(
                              onPressed: index <
                                      cdObj["${widget.group}-${widget.contest["id"]}"]["tasks"]
                                              .length -
                                          1
                                  ? () {
                                      setStateModal(() {
                                        index++;
                                      });
                                    }
                                  : () {
                                      setStateModal(() {
                                        index = 0;
                                      });
                                    },
                              icon: Icon(Icons.navigate_next,
                                  size: Responsive.isMobile(context) ? 20 : 25)),
                        ]))
                  ]),
                  StatefulBuilder(builder: (context, setStateWithin) {
                    isModalClosed = false;

                    void trackResultHelper(userId, groupId, contestId, String targetedTask) async {
                      while (!isModalClosed &&
                          !finished["${widget.group}-${widget.contest["id"]}"]![index] &&
                          sent["${widget.group}-${widget.contest["id"]}"]![index]) {
                        dynamic resultObj =
                            await trackResult(userId, groupId, contestId, targetedTask);
                        await Future.delayed(const Duration(seconds: 1));
                        if (resultObj["status"] == "sending" || resultObj["status"] == "judging") {
                          continue;
                        } else {
                          setStateWithin(() {
                            testCasesShow["${widget.group}-${widget.contest["id"]}"]![index] = [];
                            for (int count = 0; count < resultObj["details"].length; count++) {
                              String info = resultObj["details"][count][0];
                              switch (info) {
                                case "AC":
                                  {
                                    info = Responsive.isMobile(context) ? "AC" : "Accepted";
                                  }
                                  break;
                                case "WA":
                                  {
                                    info = Responsive.isMobile(context) ? "WA" : "Wrong Answer";
                                  }
                                  break;
                                case "TLE":
                                  {
                                    info = Responsive.isMobile(context)
                                        ? "TLE"
                                        : "Time Limit Exceeded";
                                  }
                                  break;
                                case "CE":
                                  {
                                    info = Responsive.isMobile(context) ? "CE" : "Compile Error";
                                  }
                                  break;
                              }
                              testCasesShow["${widget.group}-${widget.contest["id"]}"]![index]
                                  .add(SizedBox(
                                      width: 500,
                                      child: Card(
                                          child: Padding(
                                              padding: const EdgeInsets.all(10),
                                              child: Row(children: [
                                                Text("Case #${count + 1}",
                                                    style: const TextStyle(fontSize: 20)),
                                                const Spacer(),
                                                Text(
                                                    "$info | Time Executed: ${resultObj["details"][count][1]}s",
                                                    style: TextStyle(
                                                        fontFamily: "Source Code Pro",
                                                        color:
                                                            resultObj["details"][count][0] == "AC"
                                                                ? Colors.green
                                                                : Colors.red))
                                              ])))));
                            }
                            finished["${widget.group}-${widget.contest["id"]}"]![index] = true;
                          });
                          break;
                        }
                      }
                    }

                    if (sent["${widget.group}-${widget.contest["id"]}"]![index] &&
                        !finished["${widget.group}-${widget.contest["id"]}"]![index]) {
                      trackResultHelper(widget.userObj["id"], widget.group, widget.contest["id"],
                          cdObj["${widget.group}-${widget.contest["id"]}"]["tasks"][index]);
                    }

                    return Column(children: [
                      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Card(
                            color: selectedLang == "C++ 14"
                                ? Theme.of(context).colorScheme.primary
                                : null,
                            child: InkWell(
                                borderRadius: const BorderRadius.all(Radius.circular(12)),
                                onTap: selectedLang == "C++ 14"
                                    ? null
                                    : () {
                                        if (mounted) {
                                          setStateWithin(() => selectedLang = "C++ 14");
                                        }
                                      },
                                child: Padding(
                                    padding: EdgeInsets.all(Responsive.isMobile(context) ? 6 : 8),
                                    child: Row(children: [
                                      Padding(
                                          padding: const EdgeInsets.all(5),
                                          child:
                                              SvgPicture.asset("assets/images/C++.svg", width: 15)),
                                      Text("C++ 14",
                                          style: TextStyle(
                                              color: selectedLang == "C++ 14"
                                                  ? Theme.of(context).colorScheme.onPrimary
                                                  : null))
                                    ])))),
                        Card(
                            color: selectedLang == "C++ 11"
                                ? Theme.of(context).colorScheme.primary
                                : null,
                            child: InkWell(
                                borderRadius: const BorderRadius.all(Radius.circular(12)),
                                onTap: selectedLang == "C++ 11"
                                    ? null
                                    : () {
                                        if (mounted) {
                                          setStateWithin(() => selectedLang = "C++ 11");
                                        }
                                      },
                                child: Padding(
                                    padding: EdgeInsets.all(Responsive.isMobile(context) ? 6 : 8),
                                    child: Row(children: [
                                      Padding(
                                          padding: const EdgeInsets.all(5),
                                          child:
                                              SvgPicture.asset("assets/images/C++.svg", width: 15)),
                                      Text("C++ 11",
                                          style: TextStyle(
                                              color: selectedLang == "C++ 11"
                                                  ? Theme.of(context).colorScheme.onPrimary
                                                  : null))
                                    ])))),
                        Card(
                            color: selectedLang == "Python 3"
                                ? Theme.of(context).colorScheme.primary
                                : null,
                            child: InkWell(
                                borderRadius: const BorderRadius.all(Radius.circular(12)),
                                onTap: selectedLang == "Python 3"
                                    ? null
                                    : () {
                                        if (mounted) {
                                          setStateWithin(() => selectedLang = "Python 3");
                                        }
                                      },
                                child: Padding(
                                    padding: EdgeInsets.all(Responsive.isMobile(context) ? 6 : 8),
                                    child: Row(children: [
                                      Padding(
                                          padding: const EdgeInsets.all(5),
                                          child: SvgPicture.asset("assets/images/python.svg",
                                              width: 15)),
                                      Text(Responsive.isMobile(context) ? "PY3" : "Python 3",
                                          style: TextStyle(
                                              color: selectedLang == "Python 3"
                                                  ? Theme.of(context).colorScheme.onPrimary
                                                  : null))
                                    ])))),
                      ]),
                      const SizedBox(height: 15),
                      AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          height: finished["${widget.group}-${widget.contest["id"]}"]![index]
                              ? 173
                              : MediaQuery.of(context).size.height * .75 - 181,
                          child: TextField(
                              style: const TextStyle(fontFamily: "Source Code Pro"),
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.multiline,
                              minLines: 50,
                              maxLines: null,
                              controller:
                                  codeInput["${widget.group}-${widget.contest["id"]}"]![index],
                              onChanged: (value) {
                                if (mounted) {
                                  setStateWithin(() {});
                                }
                              })),
                      SizedBox(
                          height: 55,
                          child: Card(
                              child: InkWell(
                                  splashFactory: NoSplash.splashFactory,
                                  hoverColor: Colors.transparent,
                                  highlightColor: Colors.transparent,
                                  focusColor: Colors.transparent,
                                  onTap: sent["${widget.group}-${widget.contest["id"]}"]![index] ||
                                          codeInput["${widget.group}-${widget.contest["id"]}"]![
                                                      index]
                                                  .text ==
                                              ""
                                      ? null
                                      : () async {
                                          await sendCode(
                                              widget.userObj["id"],
                                              widget.group,
                                              widget.contest["id"],
                                              cdObj["${widget.group}-${widget.contest["id"]}"]
                                                  ["tasks"][index],
                                              selectedLang,
                                              codeInput["${widget.group}-${widget.contest["id"]}"]![
                                                      index]
                                                  .text);
                                          trackResultHelper(
                                              widget.userObj["id"],
                                              widget.group,
                                              widget.contest["id"],
                                              cdObj["${widget.group}-${widget.contest["id"]}"]
                                                  ["tasks"][index]);
                                          if (mounted) {
                                            setStateWithin(() =>
                                                sent["${widget.group}-${widget.contest["id"]}"]![
                                                    index] = true);
                                          }
                                        },
                                  child: Padding(
                                      padding: const EdgeInsets.only(top: 10),
                                      child: Column(children: [
                                        Row(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              sent["${widget.group}-${widget.contest["id"]}"]![
                                                      index]
                                                  ? SizedBox(
                                                      height: 20,
                                                      width: 20,
                                                      child: finished[
                                                                  "${widget.group}-${widget.contest["id"]}"]![
                                                              index]
                                                          ? InkWell(
                                                              splashFactory: NoSplash.splashFactory,
                                                              hoverColor: Colors.transparent,
                                                              highlightColor: Colors.transparent,
                                                              focusColor: Colors.transparent,
                                                              onTap: () {
                                                                setStateModal(() => expandResult[
                                                                        "${widget.group}-${widget.contest["id"]}"]![
                                                                    index] = !expandResult[
                                                                        "${widget.group}-${widget.contest["id"]}"]![
                                                                    index]);
                                                              },
                                                              child: Icon(expandResult[
                                                                          "${widget.group}-${widget.contest["id"]}"]![
                                                                      index]
                                                                  ? Icons.expand_more
                                                                  : Icons.expand_less))
                                                          : const CircularProgressIndicator(),
                                                    )
                                                  : Icon(
                                                      codeInput["${widget.group}-${widget.contest["id"]}"]![
                                                                      index]
                                                                  .text ==
                                                              ""
                                                          ? Icons.play_disabled
                                                          : Icons.play_arrow),
                                              const SizedBox(width: 15),
                                              InkWell(
                                                  splashFactory: NoSplash.splashFactory,
                                                  hoverColor: Colors.transparent,
                                                  highlightColor: Colors.transparent,
                                                  focusColor: Colors.transparent,
                                                  onTap: finished[
                                                              "${widget.group}-${widget.contest["id"]}"]![
                                                          index]
                                                      ? () async {
                                                          finished[
                                                                  "${widget.group}-${widget.contest["id"]}"]![
                                                              index] = false;
                                                          await sendCode(
                                                              widget.userObj["id"],
                                                              widget.group,
                                                              widget.contest["id"],
                                                              cdObj["${widget.group}-${widget.contest["id"]}"]
                                                                  ["tasks"][index],
                                                              selectedLang,
                                                              codeInput["${widget.group}-${widget.contest["id"]}"]![
                                                                      index]
                                                                  .text);
                                                          trackResultHelper(
                                                              widget.userObj["id"],
                                                              widget.group,
                                                              widget.contest["id"],
                                                              cdObj["${widget.group}-${widget.contest["id"]}"]
                                                                  ["tasks"][index]);
                                                          if (mounted) {
                                                            setStateWithin(() => sent[
                                                                    "${widget.group}-${widget.contest["id"]}"]![
                                                                index] = true);
                                                          }
                                                        }
                                                      : null,
                                                  child: Text(
                                                      sent["${widget.group}-${widget.contest["id"]}"]![
                                                              index]
                                                          ? finished["${widget.group}-${widget.contest["id"]}"]![
                                                                  index]
                                                              ? "Nộp lại"
                                                              : "Đang chấm..."
                                                          : "Gửi bài",
                                                      style: const TextStyle(fontSize: 18)))
                                            ]),
                                      ]))))),
                      SizedBox(
                          height: finished["${widget.group}-${widget.contest["id"]}"]![index]
                              ? expandResult["${widget.group}-${widget.contest["id"]}"]![index]
                                  ? MediaQuery.of(context).size.height - 355
                                  : MediaQuery.of(context).size.height * .75 - 355
                              : 0,
                          child: SingleChildScrollView(
                              child: Wrap(
                                  alignment: WrapAlignment.center,
                                  runAlignment: WrapAlignment.center,
                                  children: testCasesShow[
                                      "${widget.group}-${widget.contest["id"]}"]![index])))
                    ]);
                  })
                ]));
          });
        }).whenComplete(() => isModalClosed = true);
  }
}
