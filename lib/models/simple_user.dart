class SimpleUser {
  final String id;
  final String name;
  final String phoneNumber;
  final String email;
  final String? dni;
  final String? profilePicUrl;

  SimpleUser({
    required this.id,
    required this.name,
    required this.phoneNumber,
    required this.email,
    this.dni,
    this.profilePicUrl,
  });

  SimpleUser copyWith({
    String? id,
    String? name,
    String? phoneNumber,
    String? email,
    String? dni,
    String? profilePicUrl,
  }) {
    return SimpleUser(
      id: id ?? this.id,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      dni: dni ?? this.dni,
      profilePicUrl: profilePicUrl ?? this.profilePicUrl,
    );
  }
}
