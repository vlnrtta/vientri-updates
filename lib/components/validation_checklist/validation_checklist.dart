import 'package:vientri/src/models/validation_rule.dart';
import 'package:flutter/material.dart';
import 'package:vientri/constants/app_colors.dart';



class ValidationChecklistComponent extends StatelessWidget {
  final String textToValidate;
  final List<ValidationRule> rules;

  const ValidationChecklistComponent({
    super.key,
    required this.textToValidate,
    required this.rules,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: rules.map((rule) {
        final isValid = rule.validator(textToValidate);
        final color = isValid ? AppColors.semantics.text.success : AppColors.semantics.text.onDisabled;

        return Padding(
          padding: const EdgeInsets.only(bottom: 4.0),
          child: Row(
            children: [
              Icon(
                isValid ? Icons.check : Icons.close,
                color: color,
                size: 20,
              ),
              const SizedBox(width: 4),
              Text(
                rule.label,
                style: TextStyle(
                  color: color,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
