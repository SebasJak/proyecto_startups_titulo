class StartupProject {
  final String id;
  final String name;
  final String description;
  final String videoUrl;
  final String deckUrl; // Added deckUrl for the Ver Deck button
  final String ownerPhoneNumber;
  final String? surveyUrl; // Optional survey URL
  final int likesCount;
  final bool isLikedByMe;

  StartupProject({
    required this.id,
    required this.name,
    required this.description,
    required this.videoUrl,
    required this.deckUrl,
    required this.ownerPhoneNumber,
    this.surveyUrl,
    this.likesCount = 0,
    this.isLikedByMe = false,
  });

  StartupProject copyWith({
    String? id,
    String? name,
    String? description,
    String? videoUrl,
    String? deckUrl,
    String? ownerPhoneNumber,
    String? surveyUrl,
    int? likesCount,
    bool? isLikedByMe,
  }) {
    return StartupProject(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      videoUrl: videoUrl ?? this.videoUrl,
      deckUrl: deckUrl ?? this.deckUrl,
      ownerPhoneNumber: ownerPhoneNumber ?? this.ownerPhoneNumber,
      surveyUrl: surveyUrl ?? this.surveyUrl,
      likesCount: likesCount ?? this.likesCount,
      isLikedByMe: isLikedByMe ?? this.isLikedByMe,
    );
  }
}
