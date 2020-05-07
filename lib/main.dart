import 'package:flutter/material.dart';
import 'dart:async';

void main() async {
  runApp(CalculatorApp());
}

class CalculatorApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      theme: ThemeData(primarySwatch: Colors.green),
      home: Calculator(),
    );
  }
}

class Calculator extends StatefulWidget {

  Calculator({ Key key }) : super(key: key);

  @override
  _CalculatorState createState() => _CalculatorState();
}

class _CalculatorState extends State<Calculator> {

  String _output;

  @override
  void initState() {

    KeyController.listen((event) => Processor.process(event));
    Processor.listen((data) => setState(() { _output = data; }));
    Processor.refresh();
    super.initState();
  }

  @override
  void dispose() {

    KeyController.dispose();
    Processor.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    Size screen = MediaQuery.of(context).size;

    double buttonSize = screen.width / 4;
    double displayHeight = screen.height - (buttonSize * 5) - (buttonSize);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(

          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[

            Display(value: _output, height: displayHeight),
            KeyPad()
          ]
      ),
    );
  }
}

class Display extends StatelessWidget {

  Display({ Key key, this.value, this.height }) : super(key: key);

  final String value;
  final double height;

  String get _output => value.toString();
  double get _margin => (height / 10);

  final LinearGradient _gradient = const LinearGradient(colors: [ Colors.blue, Colors.green ]);

  @override
  Widget build(BuildContext context) {

    TextStyle style = Theme.of(context).textTheme.display2
        .copyWith(color: Colors.black, fontWeight: FontWeight.w400);

    return Container(
        padding: EdgeInsets.only(top: _margin, bottom: _margin),
        constraints: BoxConstraints.expand(height: height),
        child: Container(
            padding: EdgeInsets.fromLTRB(30, 30, 30, 30),
            constraints: BoxConstraints.expand(height: height - (_margin)),
            decoration: BoxDecoration(gradient: _gradient),
            child: Text(_output, style: style, textAlign: TextAlign.center, )
        )
    );
  }
}

class KeyPad extends StatelessWidget {

  @override
  Widget build(BuildContext context) {

    return Column(

        children: [
          Row(
              children: <Widget>[
                CalculatorKey(symbol: Keys.clear),
                CalculatorKey(symbol: Keys.sign),
                CalculatorKey(symbol: Keys.percent),
                CalculatorKey(symbol: Keys.divide),
              ]
          ),
          Row(
              children: <Widget>[
                CalculatorKey(symbol: Keys.seven),
                CalculatorKey(symbol: Keys.eight),
                CalculatorKey(symbol: Keys.nine),
                CalculatorKey(symbol: Keys.multiply),
              ]
          ),
          Row(
              children: <Widget>[
                CalculatorKey(symbol: Keys.four),
                CalculatorKey(symbol: Keys.five),
                CalculatorKey(symbol: Keys.six),
                CalculatorKey(symbol: Keys.subtract),
              ]
          ),
          Row(
              children: <Widget>[
                CalculatorKey(symbol: Keys.one),
                CalculatorKey(symbol: Keys.two),
                CalculatorKey(symbol: Keys.three),
                CalculatorKey(symbol: Keys.add),
              ]
          ),
          Row(
              children: <Widget>[
                CalculatorKey(symbol: Keys.zero),
                CalculatorKey(symbol: Keys.decimal),
                CalculatorKey(symbol: Keys.equals),
              ]
          )
        ]
    );
  }
}

enum KeyType { FUNCTION, OPERATOR, INTEGER }

class KeySymbol {

  const KeySymbol(this.value);
  final String value;

  static List<KeySymbol> _functions = [ Keys.clear, Keys.sign, Keys.percent, Keys.decimal ];
  static List<KeySymbol> _operators = [ Keys.divide, Keys.multiply, Keys.subtract, Keys.add, Keys.equals ];

  @override
  String toString() => value;

  bool get isOperator => _operators.contains(this);
  bool get isFunction => _functions.contains(this);
  bool get isInteger => !isOperator && !isFunction;

  KeyType get type => isFunction ? KeyType.FUNCTION : (isOperator ? KeyType.OPERATOR : KeyType.INTEGER);
}

abstract class Keys {

  static KeySymbol clear = const KeySymbol('C');
  static KeySymbol sign = const KeySymbol('±');
  static KeySymbol percent = const KeySymbol('%');
  static KeySymbol divide = const KeySymbol('÷');
  static KeySymbol multiply = const KeySymbol('x');
  static KeySymbol subtract = const KeySymbol('-');
  static KeySymbol add = const KeySymbol('+');
  static KeySymbol equals = const KeySymbol('=');
  static KeySymbol decimal = const KeySymbol('.');

  static KeySymbol zero = const KeySymbol('0');
  static KeySymbol one = const KeySymbol('1');
  static KeySymbol two = const KeySymbol('2');
  static KeySymbol three = const KeySymbol('3');
  static KeySymbol four = const KeySymbol('4');
  static KeySymbol five = const KeySymbol('5');
  static KeySymbol six = const KeySymbol('6');
  static KeySymbol seven = const KeySymbol('7');
  static KeySymbol eight = const KeySymbol('8');
  static KeySymbol nine = const KeySymbol('9');
}

class CalculatorKey extends StatelessWidget {

  CalculatorKey({ this.symbol });

  final KeySymbol symbol;

  Color get color {

    switch (symbol.type) {

      case KeyType.FUNCTION:
        return Colors.green;

      case KeyType.OPERATOR:
        return Colors.blueAccent;

      case KeyType.INTEGER:
      default:
        return Colors.lightGreenAccent;
    }
  }

  static dynamic _fire(CalculatorKey key) => KeyController.fire(KeyEvent(key));

  @override
  Widget build(BuildContext context) {

    double size = MediaQuery.of(context).size.width / 4;
    TextStyle style = Theme.of(context).textTheme.display1.copyWith(color: Colors.black);

    return Container(

        width: (symbol == Keys.zero) ? (size * 2) : size,
        padding: EdgeInsets.all(2),
        height: size,
        child: RaisedButton(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          color: color,
          elevation: 4,
          child: Text(symbol.value, style: style),
          onPressed: () => _fire(this),
        )
    );
  }
}

class KeyEvent {

  KeyEvent(this.key);
  final CalculatorKey key;
}

abstract class KeyController {

  static StreamController _controller = StreamController();
  static Stream get _stream => _controller.stream;

  static StreamSubscription listen(Function handler) => _stream.listen(handler as dynamic);
  static void fire(KeyEvent event) => _controller.add(event);

  static dispose() => _controller.close();
}

abstract class Processor {

  static KeySymbol _operator;
  static String _valA = '0';
  static String _valB = '0';
  static String _result;

  static StreamController _controller = StreamController();
  static Stream get _stream => _controller.stream;

  static StreamSubscription listen(Function handler) => _stream.listen(handler);
  static void refresh() => _fire(_output);

  static void _fire(String data) => _controller.add(_output);

  static String get _output => _result == null ? _equation : _result;

  static String get _equation => _valA
      + (_operator != null ? ' ' + _operator.value : '')
      + (_valB != '0' ? ' ' + _valB : '');

  static dispose() => _controller.close();

  static process(dynamic event) {

    CalculatorKey key = (event as KeyEvent).key;
    switch(key.symbol.type) {

      case KeyType.FUNCTION:
        return handleFunction(key);

      case KeyType.OPERATOR:
        return handleOperator(key);

      case KeyType.INTEGER:
        return handleInteger(key);
    }
  }

  static void handleFunction(CalculatorKey key) {

    if (_valA == '0') { return; }
    if (_result != null) { _condense(); }

    Map<KeySymbol, dynamic> table = {
      Keys.clear: () => _clear(),
      Keys.sign: () => _sign(),
      Keys.percent: () => _percent(),
      Keys.decimal: () => _decimal(),
    };

    table[key.symbol]();
    refresh();
  }

  static void handleOperator(CalculatorKey key) {

    if (_valA == '0') { return; }
    if (key.symbol == Keys.equals) { return _calculate(); }
    if (_result != null) { _condense(); }

    _operator = key.symbol;
    refresh();
  }

  static void handleInteger(CalculatorKey key) {

    String val = key.symbol.value;
    if (_operator == null) { _valA = (_valA == '0') ? val : _valA + val; }
    else { _valB = (_valB == '0') ? val : _valB + val; }
    refresh();
  }

  static void _clear() {

    _valA = _valB = '0';
    _operator = _result = null;
  }

  static void _sign() {

    if (_valB != '0') { _valB = (_valB.contains('-') ? _valB.substring(1) : '-' + _valB); }
    else if (_valA != '0') { _valA = (_valA.contains('-') ? _valA.substring(1) : '-' + _valA); }
  }

  static String calcPercent(String x) => (double.parse(x) / 100).toString();

  static void _percent() {

    if (_valB != '0' && !_valB.contains('.')) { _valB = calcPercent(_valB); }
    else if (_valA != '0' && !_valA.contains('.')) { _valA = calcPercent(_valA); }
  }

  static void _decimal() {

    if (_valB != '0' && !_valB.contains('.')) { _valB = _valB + '.'; }
    else if (_valA != '0' && !_valA.contains('.')) { _valA = _valA + '.'; }
  }

  static void _calculate() {

    if (_operator == null || _valB == '0') { return; }

    Map<KeySymbol, dynamic> table = {
      Keys.divide: (a, b) => (a / b),
      Keys.multiply: (a, b) => (a * b),
      Keys.subtract: (a, b) => (a - b),
      Keys.add: (a, b) => (a + b)
    };

    double result = table[_operator](double.parse(_valA), double.parse(_valB));
    String str = result.toString();

    while ((str.contains('.') && str.endsWith('0')) || str.endsWith('.')) {
      str = str.substring(0, str.length - 1);
    }

    _result = str;
    refresh();
  }

  static void _condense() {

    _valA = _result;
    _valB = '0';
    _result = _operator = null;
  }
}