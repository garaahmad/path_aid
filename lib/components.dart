import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Input extends StatefulWidget {
  final String label;
  final String hint;
  final int maxLine;
  final size;
  final padding;
  final Function(String)? onChanged;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;

  const Input({
    super.key,
    required this.label,
    required this.hint,
    required this.maxLine,
    this.onChanged,
    this.controller,
    this.keyboardType,
    this.inputFormatters,
    this.size,
    this.padding,
  });

  @override
  State<Input> createState() => _InputState();
}

class _InputState extends State<Input> {
  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      onChanged: widget.onChanged,
      keyboardType: widget.keyboardType,
      inputFormatters: widget.inputFormatters,
      maxLines: widget.maxLine,
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: widget.hint,
        labelStyle: TextStyle(fontSize: widget.size),
        hintStyle: TextStyle(fontSize: widget.size),
        enabled: true,
        contentPadding: EdgeInsets.all(widget.padding ?? 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(widget.padding ?? 20),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(widget.padding ?? 20),
          borderSide: BorderSide(
            color: Color.fromARGB(255, 4, 113, 214),
            width: 3,
          ),
        ),
      ),
    );
  }
}

class Sans extends StatefulWidget {
  final text;
  final size;
  const Sans({super.key, @required this.text, @required this.size});

  @override
  State<Sans> createState() => _SansState();
}

class _SansState extends State<Sans> {
  @override
  Widget build(BuildContext context) {
    return Text(widget.text, style: TextStyle(fontSize: widget.size));
  }
}

class SansBold extends StatefulWidget {
  final text;
  final size;
  const SansBold({super.key, @required this.text, @required this.size});

  @override
  State<SansBold> createState() => _SansBoldState();
}

class _SansBoldState extends State<SansBold> {
  @override
  Widget build(BuildContext context) {
    return Text(
      widget.text,
      style: TextStyle(fontSize: widget.size, fontWeight: FontWeight.bold),
    );
  }
}
