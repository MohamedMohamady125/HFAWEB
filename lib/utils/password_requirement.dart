class PasswordRequirement {
  final String text;
  final bool Function(String) validator;
  bool isMet = false;

  PasswordRequirement({required this.text, required this.validator});
}
