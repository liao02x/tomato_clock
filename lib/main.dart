import 'dart:async';

import 'package:flutter/material.dart';
import 'package:circular_countdown_timer/circular_countdown_timer.dart';

import './notification_service.dart';


Future<void> main() async {
  var notificationService = NotificationService();

  await notificationService.init();
  notificationService.requestPermissions();

  runApp(MyApp(notificationService));
}

class MyApp extends StatelessWidget {
  final NotificationService? notificationService;
  const MyApp(this.notificationService, {Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hello Flutter',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.deepOrange,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Tomato Clock'),
        ),
        body: Center(
          child: TomatoClock(notificationService),
        ),
      ),
    );
  }
}

class TomatoClock extends StatefulWidget {
  final NotificationService? notificationService;
  const TomatoClock(this.notificationService, {Key? key}) : super(key: key);

  @override
  _TomatoClockState createState() => _TomatoClockState();
}

class _TomatoClockState extends State<TomatoClock> {
  final _workDuration = 25 * 60;
  final _breakDuration = 5 * 60;

  final _controller = CountDownController();
  var _status = "work";
  var _isPaused = false;

  String _getNextStatus(status) {
    if (status == "work") {
      return "break";
    } else {
      return "work";
    }
  }

  void _skip() {
    var _nextStatus = _getNextStatus(_status);
    var _nextDuration = _nextStatus == "work" ? _workDuration : _breakDuration;
    setState(() {
      _status = _nextStatus;
    });
    _controller.restart(duration: _nextDuration);
  }

  void _restart() {
    _controller.restart();
  }

  void _togglePause() {
    setState(() {
      _isPaused = !_isPaused;
    });
    if (_isPaused) {
      _controller.pause();
    } else {
      _controller.resume();
    }
  }

  void _notifyOnComplete(status) {
    if (status == "work") {
      () async {
        await widget.notificationService?.showNotification(
            "Tomato Clock", "work ends"
        );
      }();
    } else {
      () async {
        await widget.notificationService?.showNotification(
            "Tomato Clock", "break ends"
        );
      }();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            margin: const EdgeInsets.all(20),
            child: CircularCountDownTimer(
              width: MediaQuery.of(context).size.width * 0.9,
              height: MediaQuery.of(context).size.height - 160,
              controller: _controller,
              duration: _workDuration,
              fillColor: _status == "work" ? Colors.red : Colors.green,
              ringColor: Colors.grey[300]!,
              isReverse: true,
              // Border Thickness of the Countdown Ring.
              strokeWidth: 20.0,

              // Begin and end contours with a flat edge and no extension.
              strokeCap: StrokeCap.round,
              // Text Style for Countdown Text.
              textStyle: const TextStyle(
                fontSize: 33.0,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),

              // Format for the Countdown Text.
              textFormat: CountdownTextFormat.MM_SS,
              onComplete: () {
                _notifyOnComplete(_status);
                _skip();
              },
            ),
          ),
          Container(
            margin: const EdgeInsets.only(bottom: 10, left: 20, right: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _button(title: "skip", onPressed: _skip),
                const SizedBox(
                  width: 10,
                ),
                _button(title: "restart", onPressed: _restart),
                const SizedBox(
                  width: 10,
                ),
                _button(title: _isPaused ? "resume" : "pause", onPressed: _togglePause),
              ],
            ),
          ),
        ],
      ),
      // floatingActionButton: Row(
      //   mainAxisAlignment: MainAxisAlignment.center,
      //   children: [
      //     const SizedBox(
      //       width: 30,
      //     ),
      //     _button(title: "skip", onPressed: _skip),
      //     const SizedBox(
      //       width: 10,
      //     ),
      //     _button(title: "restart", onPressed: _restart),
      //     const SizedBox(
      //       width: 10,
      //     ),
      //     _button(title: _isPaused ? "resume" : "pause", onPressed: _togglePause),
      //   ],
      // ),
    );
  }


  Widget _button({required String title, VoidCallback? onPressed}) {
    return Expanded(
      child: ElevatedButton(
        child: Text(
          title,
          style: const TextStyle(color: Colors.white),
        ),
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(Colors.deepPurple),
        ),
        onPressed: onPressed,
      )
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final int _duration = 10;
  final CountDownController _controller = CountDownController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: CircularCountDownTimer(
        // Countdown duration in Seconds.
        duration: _duration,

        // Countdown initial elapsed Duration in Seconds.
        initialDuration: 0,

        // Controls (i.e Start, Pause, Resume, Restart) the Countdown Timer.
        controller: _controller,

        // Width of the Countdown Widget.
        width: MediaQuery.of(context).size.width / 2,

        // Height of the Countdown Widget.
        height: MediaQuery.of(context).size.height / 2,

        // Ring Color for Countdown Widget.
        ringColor: Colors.grey[300]!,

        // Ring Gradient for Countdown Widget.
        ringGradient: null,

        // Filling Color for Countdown Widget.
        fillColor: Colors.purpleAccent[100]!,

        // Filling Gradient for Countdown Widget.
        fillGradient: null,

        // Background Color for Countdown Widget.
        backgroundColor: Colors.purple[500],

        // Background Gradient for Countdown Widget.
        backgroundGradient: null,

        // Border Thickness of the Countdown Ring.
        strokeWidth: 20.0,

        // Begin and end contours with a flat edge and no extension.
        strokeCap: StrokeCap.round,

        // Text Style for Countdown Text.
        textStyle: const TextStyle(
          fontSize: 33.0,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),

        // Format for the Countdown Text.
        textFormat: CountdownTextFormat.S,

        // Handles Countdown Timer (true for Reverse Countdown (max to 0), false for Forward Countdown (0 to max)).
        isReverse: false,

        // Handles Animation Direction (true for Reverse Animation, false for Forward Animation).
        isReverseAnimation: false,

        // Handles visibility of the Countdown Text.
        isTimerTextShown: true,

        // Handles the timer start.
        autoStart: false,

        // This Callback will execute when the Countdown Starts.
        onStart: () {
          // Here, do whatever you want
          debugPrint('Countdown Started');
        },

        // This Callback will execute when the Countdown Ends.
        onComplete: () {
          // Here, do whatever you want
          debugPrint('Countdown Ended');
        },
      )),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(
            width: 30,
          ),
          _button(title: "Start", onPressed: () => _controller.start()),
          const SizedBox(
            width: 10,
          ),
          _button(title: "Pause", onPressed: () => _controller.pause()),
          const SizedBox(
            width: 10,
          ),
          _button(title: "Resume", onPressed: () => _controller.resume()),
          const SizedBox(
            width: 10,
          ),
          _button(
              title: "Restart",
              onPressed: () => _controller.restart(duration: _duration))
        ],
      ),
    );
  }

  Widget _button({required String title, VoidCallback? onPressed}) {
    return Expanded(
        child: ElevatedButton(
      child: Text(
        title,
        style: const TextStyle(color: Colors.white),
      ),
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all(Colors.purple),
      ),
      onPressed: onPressed,
    ));
  }
}
