import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart';

void main() {
  runApp(CalculatorApp());
}

class CalculatorApp extends StatefulWidget {
  @override
  _CalculatorAppState createState() => _CalculatorAppState();
}

class _CalculatorAppState extends State<CalculatorApp> {
  String _input = ""; // Stores user input
  String _output = "0"; // Stores result
  bool _lastInputIsOperator = false; // Prevents consecutive operators

  void _buttonPressed(String value) {
    setState(() {
      if (value == "C") {
        _input = "";
        _output = "0";
        _lastInputIsOperator = false;
      } else if (value == "=") {
        try {
          _output = _evaluateExpression(_input);
          _input = _output; // Store result for next calculation
        } catch (e) {
          _output = "Error";
        }
        _lastInputIsOperator = false;
      } else {
        // Prevent multiple consecutive operators
        if (_isOperator(value) && _lastInputIsOperator) {
          return;
        }

        // Handle decimal input correctly
        if (value == ".") {
          List<String> parts = _input.split(RegExp(r'[\+\-\*/]')); // Split by operators
          if (parts.isNotEmpty && parts.last.contains(".")) return; // Prevent multiple decimals
        }

        _input += value;
        _lastInputIsOperator = _isOperator(value);
      }
    });
  }

  bool _isOperator(String value) {
    return ["+", "-", "*", "/"].contains(value);
  }

  String _evaluateExpression(String expression) {
    try {
      // Prevent division by zero
      if (expression.contains("/0")) {
        return "Error";
      }

      Parser p = Parser();
      Expression exp = p.parse(expression);
      ContextModel cm = ContextModel();
      double eval = exp.evaluate(EvaluationType.REAL, cm);
      return eval.toStringAsFixed(2); // Round to 2 decimal places
    } catch (e) {
      return "Error";
    }
  }

  Widget _buildButton(String text, {Color? color}) {
    return Expanded(
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.all(20),
          backgroundColor: color ?? Colors.blueGrey[200],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        onPressed: () => _buttonPressed(text),
        child: Text(text, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text("Calculator")),
        body: Column(
          children: [
            // Display Area
            Expanded(
              child: Container(
                alignment: Alignment.bottomRight,
                padding: EdgeInsets.all(24),
                child: Text(
                  _input.isEmpty ? _output : _input,
                  style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            // Buttons Grid
            Column(
              children: [
                Row(children: ["7", "8", "9", "/"].map((e) => _buildButton(e, color: Colors.orange)).toList()),
                Row(children: ["4", "5", "6", "*"].map((e) => _buildButton(e, color: Colors.orange)).toList()),
                Row(children: ["1", "2", "3", "-"].map((e) => _buildButton(e, color: Colors.orange)).toList()),
                Row(children: ["C", "0", ".", "+"].map(_buildButton).toList()),
                Row(children: ["="].map((e) => _buildButton(e, color: Colors.green)).toList()),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
