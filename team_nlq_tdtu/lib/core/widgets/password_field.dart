import 'package:flutter/material.dart';
import 'package:team_nlq_tdtu/core/widgets/custom_text_field.dart';

class PasswordField extends StatefulWidget {
  final TextEditingController controller;
  final String labelText;
  final String? hintText;
  final String? Function(String?)? validator;
  final bool autoFocus;
  final Widget? prefixIcon;
  final Function(String)? onChanged;

  const PasswordField({
    super.key,
    required this.controller,
    required this.labelText,
    this.hintText,
    this.validator,
    this.autoFocus = false,
    this.prefixIcon,
    this.onChanged,
  });

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      controller: widget.controller,
      labelText: widget.labelText,
      hintText: widget.hintText,
      obscureText: _obscureText,
      prefixIcon: widget.prefixIcon ?? const Icon(Icons.lock_outline),
      suffixIcon: GestureDetector(
        onTap: () {
          setState(() {
            _obscureText = !_obscureText;
          });
        },
        child: Icon(
          _obscureText
              ? Icons.visibility_outlined
              : Icons.visibility_off_outlined,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
      validator: widget.validator,
      onChanged: widget.onChanged,
      autofocus: widget.autoFocus,
    );
  }
}
