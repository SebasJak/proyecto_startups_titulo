import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:faker/faker.dart';
import '../models/startup_project.dart';

final mockProjectsProvider = Provider<List<StartupProject>>((ref) {
  final faker = Faker();
  
  final videoUrls = [
    'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4',
    'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4',
    'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4',
    'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4',
    'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4',
  ];

  return List.generate(10, (index) {
    return StartupProject(
      id: faker.guid.guid(),
      name: faker.company.name(),
      description: faker.company.position(),
      videoUrl: videoUrls[index % videoUrls.length],
      // Hardcoded single team leader number per user's MVP clarification
      ownerPhoneNumber: '+51904275799', 
      likesCount: faker.randomGenerator.integer(500, min: 10),
      isLikedByMe: false,
    );
  });
});
