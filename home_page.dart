import 'dart:math' as math;
import 'package:expressions/expressions.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'history.dart';
import 'dark_theme.dart';
import 'light_theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String _input = '';
  String _result = '';
  List<String> _history = [];

  void _onButtonPressed(String value) {
    setState(() {
      if (value == '=') {
        _calculateResult();
      } else if (['sin', 'cos', 'tan', 'log'].contains(value)) {
        _input += '$value(';
      } else if (value == '!') {
        if (_input.isNotEmpty && RegExp(r'\d$').hasMatch(_input)) {
          _input += '!';
        }
      } else {
        _input += value;
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('calculations')
          .orderBy('timestamp', descending: true)
          .limit(50)
          .get();

      setState(() {
        _history = snapshot.docs
            .map((doc) => '${doc['expression']} = ${doc['result']}')
            .toList();
      });
    } catch (e) {
      print('Error loading history: $e');
    }
  }

  Future<void> _saveCalculation(String expression, String result) async {
    try {
      await _firestore.collection('calculations').add({
        'expression': expression,
        'result': result,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error saving calculation: $e');
    }
  }

  void _calculateResult() {
    try {
      String balancedInput = _balanceBrackets(_input);
      String processedInput = _preProcessFunctions(balancedInput);
      final expression = processedInput
          .replaceAll('x', '*')
          .replaceAll('÷', '/');

      final exp = Expression.parse(expression);
      final evaluator = const ExpressionEvaluator();
      final result = evaluator.eval(exp, {});
      setState(() {
        _result = result.toStringAsFixed(6);
        _history.insert(0, '$balancedInput = $_result');
        _saveCalculation(balancedInput, _result);
      });
    } catch (e) {
      setState(() {
        _result = 'Error: ${e.toString()}';
      });
    }
  }

  String _balanceBrackets(String input) {
    int openBrackets = input.split('(').length - 1;
    int closeBrackets = input.split(')').length - 1;
    String balanced = input;
    for (int i = 0; i < openBrackets - closeBrackets; i++) {
      balanced += ')';
    }
    return balanced;
  }

  String _preProcessFunctions(String input) {
    input = _handleFactorial(input);
    RegExp regExp = RegExp(r'(sin|cos|tan|log)\(([^)]+)\)');
    return input.replaceAllMapped(regExp, (match) {
      String func = match.group(1)!;
      String arg = match.group(2)!;
      double value = double.parse(arg);
      switch (func) {
        case 'sin':
          return math.sin(_degreesToRadians(value)).toString();
        case 'cos':
          return math.cos(_degreesToRadians(value)).toString();
        case 'tan':
          return math.tan(_degreesToRadians(value)).toString();
        case 'log':
          return (math.log(value) / math.ln10).toString();
        default:
          return match.group(0)!;
      }
    });
  }

  String _handleFactorial(String input) {
    RegExp factorialRegExp = RegExp(r'(\d+)!');
    return input.replaceAllMapped(factorialRegExp, (match) {
      int n = int.parse(match.group(1)!);
      return _factorial(n).toString();
    });
  }

  double _degreesToRadians(num degrees) {
    return degrees * (math.pi / 180);
  }

  int _factorial(int n) {
    if (n < 0) throw Exception('Invalid input for factorial');
    if (n == 0 || n == 1) return 1;
    return List.generate(n, (i) => i + 1).reduce((a, b) => a * b);
  }

  void _clearInput() {
    setState(() {
      _input = '';
      _result = '';
    });
  }

  void _navigateToHistory(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => HistoryPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const Icon(
          Icons.calculate_outlined,
          color: Colors.black87,
          size: 40.0,
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Expanded(
              child: Text(
                'Calculator',
                style: TextStyle(
                  color: Colors.deepOrange,
                  fontSize: 30.0,
                  fontFamily: 'ProtestRiot',
                ),
              ),
            ),
            SizedBox(width: 40.0),
            InkWell(
              onTap: () => _navigateToHistory(context),
              child: Icon(
                Icons.history,
                color: Theme.of(context).colorScheme.primary,
                size: 35.0,
              ),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              child: Container(
                child: TextField(
                  readOnly: true,
                  controller: TextEditingController(text: _input),
                  decoration: InputDecoration(
                    hintText: 'enter expression',
                    hintStyle: TextStyle(color: Theme.of(context).colorScheme.primary),
                    filled: true,
                    fillColor: Colors.transparent,
                  ),
                ),
              ),
            ),
            SizedBox(height: 16.0),
            Expanded(
              child: Container(
                alignment: Alignment.centerRight,
                child: Text(
                  _result,
                  style: TextStyle(
                    fontSize: 30.0,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            ),
            SizedBox(height: 16.0),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildButton('AC', _clearInput),
                        SizedBox(height: 4.0),
                        _buildButton('7', () => _onButtonPressed('7')),
                        SizedBox(height: 4.0),
                        _buildButton('4', () => _onButtonPressed('4')),
                        SizedBox(height: 4.0),
                        _buildButton('1', () => _onButtonPressed('1')),
                        SizedBox(height: 4.0),
                        _buildButton('00', () => _onButtonPressed('00')),
                      ],
                    ),
                  ),
                  SizedBox(width: 4.0),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildButton('%', () => _onButtonPressed('%')),
                        SizedBox(height: 4.0),
                        _buildButton('8', () => _onButtonPressed('8')),
                        SizedBox(height: 4.0),
                        _buildButton('5', () => _onButtonPressed('5')),
                        SizedBox(height: 4.0),
                        _buildButton('2', () => _onButtonPressed('2')),
                        SizedBox(height: 4.0),
                        _buildButton('0', () => _onButtonPressed('0')),
                      ],
                    ),
                  ),
                  SizedBox(width: 4.0),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildButtonIcon(Icons.backspace_outlined, () {
                          setState(() {
                            if (_input.isNotEmpty) {
                              _input = _input.substring(0, _input.length - 1);
                            }
                          });
                        }),
                        SizedBox(height: 4.0),
                        _buildButton('9', () => _onButtonPressed('9')),
                        SizedBox(height: 4.0),
                        _buildButton('6', () => _onButtonPressed('6')),
                        SizedBox(height: 4.0),
                        _buildButton('3', () => _onButtonPressed('3')),
                        SizedBox(height: 4.0),
                        _buildButton('.', () => _onButtonPressed('.')),
                      ],
                    ),
                  ),
                  SizedBox(width: 4.0),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildButtonIcon(CupertinoIcons.divide, () => _onButtonPressed('÷')),
                        SizedBox(height: 4.0),
                        _buildButtonIcon(CupertinoIcons.multiply, () => _onButtonPressed('x')),
                        SizedBox(height: 4.0),
                        _buildButtonIcon(CupertinoIcons.minus, () => _onButtonPressed('-')),
                        SizedBox(height: 4.0),
                        _buildButtonIcon(CupertinoIcons.plus, () => _onButtonPressed('+')),
                        SizedBox(height: 4.0),
                        _buildButtonIcon(CupertinoIcons.equal, () => _onButtonPressed('='), Colors.deepOrangeAccent),
                      ],
                    ),
                  ),
                  SizedBox(width: 4.0),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildButton('sin', () => _onButtonPressed('sin')),
                        SizedBox(height: 4.0),
                        _buildButton('cos', () => _onButtonPressed('cos')),
                        SizedBox(height: 4.0),
                        _buildButton('tan', () => _onButtonPressed('tan')),
                        SizedBox(height: 4.0),
                        _buildButton('log', () => _onButtonPressed('log')),
                        SizedBox(height: 4.0),
                        _buildButton('!', () => _onButtonPressed('!')),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButton(String text, Function onTap) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Theme.of(context).colorScheme.secondary,
        ),
        child: InkWell(
          onTap: onTap as void Function()?,
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 30.0,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildButtonIcon(IconData icon, Function onTap, [Color color = Colors.white24]) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
        ),
        child: InkWell(
          onTap: onTap as void Function()?,
          child: Center(
            child: Icon(icon, color: color == Colors.deepOrangeAccent ? Theme.of(context).colorScheme.background : Theme.of(context).colorScheme.primary),
          ),
        ),
      ),
    );
  }
}
