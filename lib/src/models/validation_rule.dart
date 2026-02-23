class ValidationRule {
  final String label;
  final bool Function(String) validator;

  ValidationRule({
    required this.label,
    required this.validator,
  });
}
