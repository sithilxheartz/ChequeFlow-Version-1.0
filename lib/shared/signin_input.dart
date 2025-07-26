import 'package:flutter/material.dart';

class SignInInput extends StatefulWidget {
  final TextEditingController controller;
  final String heading;
  final String labelText;
  final String? Function(String?)? validator;
  final bool isPassword;

  const SignInInput({
    super.key,
    required this.heading,
    required this.controller,
    required this.labelText,
    this.validator,
    required this.isPassword,
  });

  @override
  State<SignInInput> createState() => _SignInInputState();
}

class _SignInInputState extends State<SignInInput> {
  bool _obscureText = true;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.isPassword;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.heading),
          const SizedBox(height: 10),
          TextFormField(
            controller: widget.controller,
            validator: widget.validator,
            obscureText: widget.isPassword ? _obscureText : false,
            decoration: InputDecoration(
              labelText: widget.labelText,
              labelStyle: const TextStyle(fontSize: 13),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
                borderRadius: BorderRadius.circular(12.0),
              ),
              filled: true,
              contentPadding: const EdgeInsets.symmetric(
                vertical: 13.0,
                horizontal: 12.0,
              ),
              suffixIcon:
                  widget.isPassword
                      ? IconButton(
                        icon: Icon(
                          _obscureText
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: Colors.grey,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureText = !_obscureText;
                          });
                        },
                      )
                      : null,
            ),
          ),
        ],
      ),
    );
  }
}
