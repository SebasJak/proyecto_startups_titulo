class SimpleUser {
  final String id;
  final String name;
  final String phoneNumber;
  final String email;

  SimpleUser({
    required this.id,
    required this.name,
    required this.phoneNumber,
    required this.email,
  });

  SimpleUser copyWith({
    String? id,
    String? name,
    String? phoneNumber,
    String? email,
  }) {
    return SimpleUser(
      id: id ?? this.id,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
    );
  }
}
