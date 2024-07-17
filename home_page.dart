import 'package:expressions/expressions.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'history.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _input = '';
  String _result = '';
  List<String> _history = [];

  void _onButtonPressed(String value) {
    setState(() {
      if (value == '=') {
        _calculateResult();
      } else {
        _input += value;
      }
    });
  }

  void _calculateResult() {
    try {
      final expression = _input.replaceAll('x', '*').replaceAll('÷', '/');
      final exp = Expression.parse(expression);
      final evaluator = const ExpressionEvaluator();
      final result = evaluator.eval(exp, {});
      setState(() {
        _result = result.toString();
        _history.add('$_input = $_result');
      });
    } catch (e) {
      setState(() {
        _result = 'Error';
      });
    }
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
        builder: (context) => HistoryPage(history: _history),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
                color: Colors.black87,
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
                    hintStyle: TextStyle(color: Colors.black45),
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
                    color: Colors.black,
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
          color: Colors.white54,
        ),
        child: InkWell(
          onTap: onTap as void Function()?,
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 30.0,
                fontWeight: FontWeight.bold,
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
            child: Icon(icon, color: color == Colors.deepOrangeAccent ? Colors.white : Colors.black),
          ),
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: HomePage(),
  ));
}
