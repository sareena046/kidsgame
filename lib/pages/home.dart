import 'dart:async';
import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final Map<String, bool> score = {};
  final Map<String, Color> choices = {
    '🍎': Colors.red,
    '🥒': Colors.green,
    '🔵': Colors.blue,
    '🍍': Colors.yellow,
    '🍊': Colors.orange,
    '🍇': Colors.purple,
    '🥥': Colors.brown,
    '🖤': Colors.black,
  };
  int index = 0;
  final play = AudioPlayer();
  int countdownSeconds = 30;
  Timer? timer;
  int correctAnswers = 0;
  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  void startTimer() {
    timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (countdownSeconds > 0) {
          countdownSeconds--;
        } else {
          timer.cancel();
          endGame();
        }
      });
    });
  }

  void endGame() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('good game'),
        content: Text('Your score: $correctAnswers out of ${choices.length}'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Countdown: $countdownSeconds seconds'),
        ),
        body: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: choices.keys.map((element) {
                return Expanded(
                  child: Draggable<String>(
                    data: element,
                    child: Movable(element),
                    feedback: Movable(element),
                    childWhenDragging: Movable('🤪'),
                  ),
                );
              }).toList(),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: choices.keys.map((element) {
                return buildTarget(element);
              }).toList()
                ..shuffle(Random(index)),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
            child: Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                score.clear();
                index++;
                countdownSeconds = 30; // รีเซ็ตค่าเวลา
                startTimer(); // เริ่มต้นการนับเวลาใหม่
              });
            }));
  }

  Widget buildTarget(emoji) {
    return DragTarget<String>(
      builder: (context, incoming, rejects) {
        if (score[emoji] == true) {
          return Container(
            color: Colors.white,
            child: Text('Congratulations'),
            alignment: Alignment.center,
            height: 80,
            width: 200,
          );
        } else {
          return Container(
            color: choices[emoji],
            height: 80,
            width: 200,
          );
        }
      },
      onWillAccept: (data) => data == emoji,
      onAccept: (data) {
        setState(() {
          score[emoji] = true;
          play.play(AssetSource('clap1.mp3'));
          correctAnswers++; // เพิ่มจำนวนคำถามที่ตอบถูก
          int totalQuestions = choices.length;
          if (correctAnswers == totalQuestions) {
            // ตรวจสอบว่าตอบครบทุกคำถามหรือไม่
            endGame();
          } else {
            // showDialog(
            //   context: context,
            //   builder: (_) => AlertDialog(
            //     title: Text('Correct!'),
            //     content: Text('You have answered $correctAnswers out of $totalQuestions questions correctly.'),
            //     actions: [
            //       TextButton(
            //         onPressed: () {
            //           Navigator.pop(context);
            //         },
            //         child: Text('OK'),
            //       ),
            //     ],
            //   ),
            // );
          }
        });
      },
      onLeave: (data) {},
    );
  }
}

class Movable extends StatelessWidget {
  final String emoji;
  Movable(this.emoji);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        alignment: Alignment.center,
        height: 150,
        padding: EdgeInsets.all(15),
        child: Text(
          emoji,
          style: TextStyle(color: Colors.black, fontSize: 60),
        ),
      ),
    );
  }
}
