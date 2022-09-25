import 'dart:developer';
import 'dart:math' as m;

import 'package:flutter/material.dart';
import 'package:get/get.dart';

// basla butonu ile oyun baslar
// 1-100 arasi bir sayi tutar
// kullanici tahmin yapar
// girilen sayi tutulan sayi ile kiyaslanip yukari ya da asagi der
// girilen sayi tutulan sayi ise X tahmin yaparak kazandiniz der

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  final AppController app = Get.put(AppController());
  final TextEditingController textController = TextEditingController();
  FocusNode focusNode = FocusNode();
  MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GetBuilder<AppController>(builder: (ac) {
        switch (ac.gameStatus) {
          case GameStatus.none:
          case GameStatus.finished:
            return main;

          case GameStatus.started:
          case GameStatus.up:
          case GameStatus.down:
            return active(context, ac.gameStatus);
        }
      }),
    );
  }

  Widget get main => GetBuilder<AppController>(builder: (ac) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ac.gameStatus == GameStatus.finished ? congrats(ac.guessCount) : Container(),
            startButton,
            SizedBox(
              width: double.infinity,
            )
          ],
        );
      });

  Widget congrats(r) => Text(
        "Tebrikler\n$r seferde bildin",
        textAlign: TextAlign.center,
      );

  Widget get startButton => ElevatedButton(
        onPressed: app.startGame,
        child: const Text("Start"),
      );

  Widget active(context, gs) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            gs == GameStatus.up ? const Icon(Icons.arrow_upward) : Container(),
            gs == GameStatus.down ? const Icon(Icons.arrow_downward) : Container(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: TextField(
                    focusNode: focusNode,
                    keyboardType: TextInputType.number,
                    controller: textController,
                    decoration: InputDecoration(label: Text("Tahmininizi girin")),
                  ),
                ),
                IconButton(
                    onPressed: () {
                      FocusScopeNode currentFocus = FocusScope.of(context);
                      if (!currentFocus.hasPrimaryFocus) {
                        currentFocus.focusedChild?.unfocus();
                      }
                      try {
                        app.compare(guess: int.parse(textController.text));
                      } catch (e) {}

                      textController.text = "";
                      focusNode.requestFocus();
                    },
                    icon: const Icon(Icons.arrow_circle_right_outlined))
              ],
            )
          ],
        ),
      );
}

enum GameStatus { none, started, up, down, finished }

class AppController extends GetxController {
  final RxInt _randomNumber = 0.obs;
  final RxInt _guessCount = 0.obs;
  int get randomNumber => _randomNumber.value;
  int get guessCount => _guessCount.value;
  final Rx<GameStatus> _gameStatus = GameStatus.none.obs;
  GameStatus get gameStatus => _gameStatus.value;

  void startGame() {
    _randomNumber.value = 0;
    _guessCount.value = 0;
    update();
    int n = Utils.generateRandomNumber();
    _randomNumber.value = n;
    _gameStatus.value = GameStatus.started;
    update();
    log("$randomNumber");
  }

  void compare({required int guess}) {
    log("compraring $guess");
    if (guess > randomNumber) {
      //aşağı
      log("aşağı");
      _gameStatus.value = GameStatus.down;
    } else if (guess < randomNumber) {
      //yukarı
      log("yukarı");
      _gameStatus.value = GameStatus.up;
    } else {
      log("eşittir");
      _gameStatus.value = GameStatus.finished;
    }
    _guessCount.value++;
    update();
    log("Tahmin $guessCount");
  }
}

class Utils {
  static int generateRandomNumber() {
    int n = m.Random().nextInt(100);
    return n;
  }
}
