class StartupProject {
  final String id;
  final String name;
  final String description;
  final String videoUrl;
  final String ownerPhoneNumber;
  final int likesCount;
  final bool isLikedByMe;

  StartupProject({
    required this.id,
    required this.name,
    required this.description,
    required this.videoUrl,
    required this.ownerPhoneNumber,
    this.likesCount = 0,
    this.isLikedByMe = false,
  });

  StartupProject copyWith({
    String? id,
    String? name,
    String? description,
    String? videoUrl,
    String? ownerPhoneNumber,
    int? likesCount,
    bool? isLikedByMe,
  }) {
    return StartupProject(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      videoUrl: videoUrl ?? this.videoUrl,
      ownerPhoneNumber: ownerPhoneNumber ?? this.ownerPhoneNumber,
      likesCount: likesCount ?? this.likesCount,
      isLikedByMe: isLikedByMe ?? this.isLikedByMe,
    );
  }
}
