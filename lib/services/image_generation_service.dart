import 'dart:math';

/// Placeholder / avatar image URLs (Unsplash).
class ImageGenerationService {
  static final ImageGenerationService _instance = ImageGenerationService._internal();
  factory ImageGenerationService() => _instance;
  ImageGenerationService._internal();

  final Random _random = Random();

  // Athlete avatars — soccer
  static const List<String> _soccerAvatars = [
    'https://images.unsplash.com/photo-1575361204480-aadea25e6e68?w=200&h=200&fit=crop',
    'https://images.unsplash.com/photo-1517466787929-bc90951d0974?w=200&h=200&fit=crop',
    'https://images.unsplash.com/photo-1504279903053-0fc609b9c60e?w=200&h=200&fit=crop',
  ];

  // Basketball
  static const List<String> _basketballAvatars = [
    'https://images.unsplash.com/photo-1546519638-68e109498ffc?w=200&h=200&fit=crop',
    'https://images.unsplash.com/photo-1593784991095-a205069470b6?w=200&h=200&fit=crop',
    'https://images.unsplash.com/photo-1612872087720-bb876e2e67d1?w=200&h=200&fit=crop',
  ];

  // Tennis
  static const List<String> _tennisAvatars = [
    'https://images.unsplash.com/photo-1595435934249-5df7ed86e1c0?w=200&h=200&fit=crop',
    'https://images.unsplash.com/photo-1622279457486-62dcc4a431d6?w=200&h=200&fit=crop',
    'https://images.unsplash.com/photo-1554068865-24cecd4e34b8?w=200&h=200&fit=crop',
  ];

  // Swimming
  static const List<String> _swimmingAvatars = [
    'https://images.unsplash.com/photo-1519315901367-f34ff9154487?w=200&h=200&fit=crop',
    'https://images.unsplash.com/photo-1530549387789-4c1017266635?w=200&h=200&fit=crop',
    'https://images.unsplash.com/photo-1526670017774-c7a3b5602d0a?w=200&h=200&fit=crop',
  ];

  // Track
  static const List<String> _athleticsAvatars = [
    'https://images.unsplash.com/photo-1552674605-db6ffd4facb5?w=200&h=200&fit=crop',
    'https://images.unsplash.com/photo-1461896836934-ffe607ba8211?w=200&h=200&fit=crop',
    'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?w=200&h=200&fit=crop',
  ];

  // Badminton
  static const List<String> _badmintonAvatars = [
    'https://images.unsplash.com/photo-1617083934551-ac1f1b6a50f7?w=200&h=200&fit=crop',
    'https://images.unsplash.com/photo-1596379698480-6a4f8e5c9c0a?w=200&h=200&fit=crop',
    'https://images.unsplash.com/photo-1626245027672-b3dc2b6c9f9e?w=200&h=200&fit=crop',
  ];

  // Generic user avatars
  static const List<String> _maleAvatars = [
    'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=100&h=100&fit=crop',
    'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=100&h=100&fit=crop',
    'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=100&h=100&fit=crop',
    'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=100&h=100&fit=crop',
  ];

  static const List<String> _femaleAvatars = [
    'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=100&h=100&fit=crop',
    'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=100&h=100&fit=crop',
    'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=100&h=100&fit=crop',
    'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=100&h=100&fit=crop',
  ];

  // Stadiums / venues
  static const List<String> _stadiumImages = [
    'https://images.unsplash.com/photo-1508098682722-e99c43a406b2?w=400&h=300&fit=crop',
    'https://images.unsplash.com/photo-1540747913346-19e32dc3e97e?w=400&h=300&fit=crop',
    'https://images.unsplash.com/photo-1574629810360-7efbbe195018?w=400&h=300&fit=crop',
    'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?w=400&h=300&fit=crop',
  ];

  // Post images
  static const List<String> _postImages = [
    'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=400&h=300&fit=crop',
    'https://images.unsplash.com/photo-1517836357463-d25dfeac3438?w=400&h=300&fit=crop',
    'https://images.unsplash.com/photo-1583454110551-21f2fa2afe35?w=400&h=300&fit=crop',
    'https://images.unsplash.com/photo-1534258936925-c58bed479fcb?w=400&h=300&fit=crop',
    'https://images.unsplash.com/photo-1518611012118-696072aa579a?w=400&h=300&fit=crop',
    'https://images.unsplash.com/photo-1601422407692-ec4eeec1d9b3?w=400&h=300&fit=crop',
  ];

  static final Map<String, List<String>> _sportAvatarMap = <String, List<String>>{
    'Soccer': _soccerAvatars,
    'Basketball': _basketballAvatars,
    'Tennis': _tennisAvatars,
    'Swimming': _swimmingAvatars,
    'Track': _athleticsAvatars,
    'Badminton': _badmintonAvatars,
  };

  String getAthleteAvatar({String? sportType}) {
    final String sport = sportType ?? 'Soccer';
    final List<String> avatars = _sportAvatarMap[sport] ?? _soccerAvatars;
    return avatars[_random.nextInt(avatars.length)];
  }

  List<String> getSportAvatars(String sport) {
    return _sportAvatarMap[sport] ?? _soccerAvatars;
  }

  String getUserAvatar({bool? isMale}) {
    if (isMale == true) {
      return _maleAvatars[_random.nextInt(_maleAvatars.length)];
    } else if (isMale == false) {
      return _femaleAvatars[_random.nextInt(_femaleAvatars.length)];
    }
    final all = [..._maleAvatars, ..._femaleAvatars];
    return all[_random.nextInt(all.length)];
  }

  String getStadiumImage() {
    return _stadiumImages[_random.nextInt(_stadiumImages.length)];
  }

  String getPostImage() {
    return _postImages[_random.nextInt(_postImages.length)];
  }

  List<String> getPostImages({int count = 1}) {
    final images = List<String>.from(_postImages)..shuffle(_random);
    return images.take(count).toList();
  }

  String getPlaceholderImage({
    int width = 400,
    int height = 300,
    String? seed,
  }) {
    final s = seed ?? DateTime.now().millisecondsSinceEpoch.toString();
    return 'https://picsum.photos/seed/$s/$width/$height';
  }

  String getAvatarPlaceholder({required String userId}) {
    final all = [..._maleAvatars, ..._femaleAvatars];
    final index = userId.hashCode.abs() % all.length;
    return all[index];
  }

  /// Stub AI image generation (replace with real API if needed).
  Future<String?> generateImage({
    required String prompt,
    String style = 'realistic',
  }) async {
    await Future.delayed(Duration(milliseconds: 500 + _random.nextInt(1500)));

    final sportsImages = [
      'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=400&h=300&fit=crop',
      'https://images.unsplash.com/photo-1517836357463-d25dfeac3438?w=400&h=300&fit=crop',
      'https://images.unsplash.com/photo-1583454110551-21f2fa2afe35?w=400&h=300&fit=crop',
    ];
    return sportsImages[_random.nextInt(sportsImages.length)];
  }

  Future<List<String>> generateImages({
    required String prompt,
    int count = 1,
    String style = 'realistic',
  }) async {
    await Future.delayed(Duration(milliseconds: 800 + _random.nextInt(2000)));
    
    final images = List<String>.from(_postImages)..shuffle(_random);
    return images.take(count).toList();
  }
}
