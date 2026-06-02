class Token {
  final String token;
  final String role;
  final bool active;

  Token({
    required this.token,
    required this.role,
    required this.active,
  });

  factory Token.fromJson(Map<String, dynamic> json) {
    return Token(
      token: json['token'] as String,
      role: json['role'] as String,
      active: json['active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'role': role,
      'active': active,
    };
  }
}
