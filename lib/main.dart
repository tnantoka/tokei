import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

enum _DialogAction {
  retry,
  next,
}

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final Random _rand = Random();
  TimeOfDay _time = TimeOfDay.now();
  final List<int> _hours = List<int>.generate(12, (int i) => i + 1);
  int _hour = 1;
  int _minute = 1;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  void _refresh() {
    setState(() {
      _time = TimeOfDay(
        hour: _rand.nextInt(11),
        minute: _rand.nextInt(59),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Column(
        children: <Widget>[
          AspectRatio(
            aspectRatio: 1.3,
            child: ClipRect(
              child: Container(
                color: Colors.grey[300],
                child: CustomPaint(
                  painter: _MyPainter(
                    time: _time,
                  ),
                ),
              ),
            ),
          ),
          DropdownButtonHideUnderline(
            child: Container(
              padding: const EdgeInsets.all(16.0),
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'なんじ？',
                  contentPadding: EdgeInsets.zero,
                ),
                child: DropdownButton<int>(
                  value: _hour,
                  onChanged: (int newValue) {
                    setState(() {
                      _hour = newValue;
                    });
                  },
                  items: _hours.map<DropdownMenuItem<int>>((int value) {
                    return DropdownMenuItem<int>(
                      value: value,
                      child: Text('$valueじ'),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
          Container(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        'なんぷん？',
                        style: TextStyle(color: Colors.grey[500], fontSize: 13),
                      ),
                      Text(
                        '$_minuteふん',
                        style: TextStyle(color: Colors.black, fontSize: 13),
                      ),
                    ],
                  ),
                ],
              )),
          Slider(
            value: _minute.toDouble(),
            min: 0,
            max: 59,
            divisions: 60,
            label: '$_minuteふん',
            onChanged: (double value) {
              setState(() {
                _minute = value.toInt();
              });
            },
          ),
          const SizedBox(height: 8.0),
          RaisedButton(
            child: const Text('これでいい'),
            onPressed: () {
              final bool isCorrect =
                  _hour == _time.hour && _minute == _time.minute;
              print(isCorrect);

              showDialog<_DialogAction>(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    content: Text(
                      isCorrect ? 'せいかい！！' : 'おしい！',
                    ),
                    actions: <Widget>[
                      FlatButton(
                        child: Text(isCorrect ? 'つぎのもんだい' : 'もういちどこたえる'),
                        onPressed: () {
                          Navigator.pop(
                            context,
                            isCorrect
                                ? _DialogAction.next
                                : _DialogAction.retry,
                          );
                        },
                      ),
                    ],
                  );
                },
              ).then<void>((_DialogAction value) {
                switch (value) {
                  case _DialogAction.next:
                    _refresh();
                    break;
                  case _DialogAction.retry:
                    break;
                }
              });
            },
          ),
        ],
      ),
    );
  }
}

class _MyPainter extends CustomPainter {
  _MyPainter({this.time}) : super();

  TimeOfDay time;

  @override
  bool shouldRepaint(_MyPainter oldDelegate) {
    return oldDelegate.time != time;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final double radius = size.height * 0.35;

    final Offset center = Offset(size.width * 0.5, size.height * 0.5);
    canvas.drawCircle(center, radius, Paint()..color = Colors.white);

    for (int i = 0; i < 360; i += 6) {
      final double x1 = center.dx +
          radius * (i % 30 == 0 ? 0.9 : 0.95) * cos(radians(i.toDouble()));
      final double y1 = center.dy +
          radius * (i % 30 == 0 ? 0.9 : 0.95) * sin(radians(i.toDouble()));

      final double x2 = center.dx + radius * cos(radians(i.toDouble()));
      final double y2 = center.dy + radius * sin(radians(i.toDouble()));

      canvas.drawLine(
          Offset(x1, y1), Offset(x2, y2), Paint()..color = Colors.black);
    }

    const double fontSize = 20;
    for (int i = 1; i <= 12; i++) {
      final ui.ParagraphStyle style =
          ui.ParagraphStyle(textAlign: TextAlign.center, fontSize: fontSize);
      final ui.ParagraphBuilder builder = ui.ParagraphBuilder(style)
        ..pushStyle(ui.TextStyle(color: Colors.black))
        ..addText(i.toString());
      final ui.Paragraph paragraph = builder.build()
        ..layout(const ui.ParagraphConstraints(width: fontSize * 2));

      final double x = center.dx +
          radius * 1.15 * cos(radians(30 * i.toDouble() - 90)) -
          paragraph.width * 0.5;
      final double y = center.dy +
          radius * 1.15 * sin(radians(30 * i.toDouble() - 90)) -
          paragraph.height * 0.5;

      canvas.drawParagraph(paragraph, Offset(x, y));
    }

    canvas.save();
    canvas.translate(center.dx, center.dy);

    canvas.save();
    canvas.rotate(
        radians(-180 + (time.hour * 30 + 30 * time.minute / 60).toDouble()));
    canvas.drawRect(
        Rect.fromLTWH(-7, 0, 14, radius * 0.6),
        Paint()
          ..color = Colors.lightBlue
          ..style = PaintingStyle.fill);
    canvas.restore();

    canvas.save();
    canvas.rotate(radians(-180 + time.minute.toDouble() * 6));
    canvas.drawRect(
        Rect.fromLTWH(-5, 0, 10, radius * 0.85),
        Paint()
          ..color = Colors.grey
          ..style = PaintingStyle.fill);
    canvas.restore();

    canvas.restore();

    canvas.drawCircle(center, radius * 0.1, Paint()..color = Colors.orange);
  }
}

double radians(double degree) {
  return degree * pi / 180;
}
