import '../models/post.dart';
import '../models/comment.dart';
import '../models/topic.dart';
import '../models/report.dart';

/// Community service (mock data; replace with real API in production).
class CommunityService {
  static final CommunityService _instance = CommunityService._internal();
  factory CommunityService() => _instance;
  CommunityService._internal();

  final Map<String, Post> _posts = {};
  final Map<String, Comment> _comments = {};
  final Map<String, Topic> _topics = {};
  final Map<String, Report> _reports = {};
  final Set<String> _blockedUsers = {};
  final Set<String> _blacklistedUsers = {};
  final Set<String> _likedPosts = {};
  final Set<String> _collectedPosts = {};
  final Set<String> _followedTopics = {};

  String _currentUserId = 'current_user';

  void _initSampleData() {
    if (_posts.isEmpty) {
      final samplePosts = [
        Post(
          id: 'post_1',
          userId: 'user_1',
          username: 'Jay_Conditioning',
          content:
              'Speed & agility day: shuttles, box jumps, core stability. Soaked but felt sharp! 🏃 #conditioning #agility',
          tags: ['conditioning', 'agility'],
          likes: 128,
          comments: 32,
          createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        ),
        Post(
          id: 'post_2',
          userId: 'user_2',
          username: 'Coach_Wang',
          content:
              'Abs finisher:\n1. Crunch 3x15\n2. Plank 3x60s\n3. Leg raise 3x12\n4. Russian twist 3x20\nStay consistent for a month! 💪',
          tags: ['fitness', 'training'],
          likes: 256,
          comments: 45,
          createdAt: DateTime.now().subtract(const Duration(hours: 4)),
        ),
        Post(
          id: 'post_3',
          userId: 'user_3',
          username: 'AI_Coach_Watch',
          content:
              '🔥 Challenge: 4 rounds — squat, push-up, plank, jumping jack. 45s rest between rounds. How many can you finish?',
          tags: ['challenge', 'home workout'],
          likes: 512,
          comments: 128,
          createdAt: DateTime.now().subtract(const Duration(hours: 6)),
        ),
        Post(
          id: 'post_4',
          userId: 'user_4',
          username: 'Morning_Runner',
          content: '5K PR this morning — perfect weather! 🌅 #running #morning',
          tags: ['running', 'morning'],
          likes: 89,
          comments: 12,
          createdAt: DateTime.now().subtract(const Duration(hours: 8)),
        ),
      ];

      for (var post in samplePosts) {
        _posts[post.id] = post;
      }

      final sampleTopics = [
        Topic(id: 'topic_1', name: '#SoccerNight', description: 'For soccer fans', postsCount: 2500, discussionsCount: 1800),
        Topic(id: 'topic_2', name: '#TrainingChallenge', description: 'Weekly challenges', postsCount: 1800, discussionsCount: 1200),
        Topic(id: 'topic_3', name: '#RunningLog', description: 'Daily running posts', postsCount: 1200, discussionsCount: 800),
        Topic(id: 'topic_4', name: '#GymLife', description: 'Training stories', postsCount: 980, discussionsCount: 650),
        Topic(id: 'topic_5', name: '#SwimClub', description: 'Swim tips', postsCount: 650, discussionsCount: 420),
        Topic(id: 'topic_6', name: '#Tennis101', description: 'Beginner to advanced', postsCount: 420, discussionsCount: 280),
      ];

      for (var topic in sampleTopics) {
        _topics[topic.id] = topic;
      }
    }
  }

  // --- Posts ---

  /// Feed list
  List<Post> getFeed({int page = 1, int pageSize = 20}) {
    _initSampleData();

    final visiblePosts = _posts.values
        .where((post) => !_blacklistedUsers.contains(post.userId))
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    final start = (page - 1) * pageSize;
    if (start >= visiblePosts.length) return [];
    
    final end = (start + pageSize).clamp(0, visiblePosts.length);
    return visiblePosts.sublist(start, end).map((post) {
      return post.copyWith(
        isLiked: _likedPosts.contains(post.id),
        isCollected: _collectedPosts.contains(post.id),
      );
    }).toList();
  }

  /// Like a post
  Future<bool> likePost(String postId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    
    if (_likedPosts.contains(postId)) {
      // Unlike
      _likedPosts.remove(postId);
      if (_posts.containsKey(postId)) {
        final post = _posts[postId]!;
        _posts[postId] = post.copyWith(likes: post.likes - 1, isLiked: false);
      }
      return false;
    } else {
      // Like
      _likedPosts.add(postId);
      if (_posts.containsKey(postId)) {
        final post = _posts[postId]!;
        _posts[postId] = post.copyWith(likes: post.likes + 1, isLiked: true);
      }
      return true;
    }
  }

  /// Collect / bookmark post
  Future<bool> collectPost(String postId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    
    if (_collectedPosts.contains(postId)) {
      _collectedPosts.remove(postId);
      if (_posts.containsKey(postId)) {
        final post = _posts[postId]!;
        _posts[postId] = post.copyWith(isCollected: false);
      }
      return false;
    } else {
      _collectedPosts.add(postId);
      if (_posts.containsKey(postId)) {
        final post = _posts[postId]!;
        _posts[postId] = post.copyWith(isCollected: true);
      }
      return true;
    }
  }

  /// Create post
  Future<Post> createPost({
    required String content,
    List<String> images = const [],
    List<String> tags = const [],
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    final post = Post(
      id: 'post_${DateTime.now().millisecondsSinceEpoch}',
      userId: _currentUserId,
      username: 'Me',
      content: content,
      images: images,
      tags: tags,
      createdAt: DateTime.now(),
    );
    
    _posts[post.id] = post;
    return post;
  }

  /// Delete post
  Future<bool> deletePost(String postId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    
    if (_posts.containsKey(postId)) {
      final post = _posts[postId]!;
      if (post.userId == _currentUserId) {
        _posts.remove(postId);
        return true;
      }
    }
    return false;
  }

  // --- Comments ---

  /// List comments for a post
  List<Comment> getComments(String postId) {
    return _comments.values
        .where((comment) => comment.postId == postId && comment.parentId == null)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  /// Add comment
  Future<Comment> addComment({
    required String postId,
    required String content,
    String? parentId,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    final comment = Comment(
      id: 'comment_${DateTime.now().millisecondsSinceEpoch}',
      postId: postId,
      userId: _currentUserId,
      username: 'Me',
      content: content,
      parentId: parentId,
      createdAt: DateTime.now(),
    );
    
    _comments[comment.id] = comment;
    
    // Bump comment count
    if (_posts.containsKey(postId)) {
      final post = _posts[postId]!;
      _posts[postId] = post.copyWith(comments: post.comments + 1);
    }
    
    return comment;
  }

  /// Delete comment
  Future<bool> deleteComment(String commentId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    
    if (_comments.containsKey(commentId)) {
      final comment = _comments[commentId]!;
      if (comment.userId == _currentUserId) {
        _comments.remove(commentId);
        
        // Bump comment count
        if (_posts.containsKey(comment.postId)) {
          final post = _posts[comment.postId]!;
          _posts[comment.postId] = post.copyWith(comments: post.comments - 1);
        }
        return true;
      }
    }
    return false;
  }

  // --- Topics ---

  /// All topics
  List<Topic> getTopics() {
    _initSampleData();
    return _topics.values.map((topic) {
      return topic.copyWith(isFollowing: _followedTopics.contains(topic.id));
    }).toList();
  }

  /// Follow / unfollow topic
  Future<bool> followTopic(String topicId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    
    if (_followedTopics.contains(topicId)) {
      _followedTopics.remove(topicId);
      if (_topics.containsKey(topicId)) {
        final topic = _topics[topicId]!;
        _topics[topicId] = topic.copyWith(
          isFollowing: false,
          discussionsCount: topic.discussionsCount - 1,
        );
      }
      return false;
    } else {
      _followedTopics.add(topicId);
      if (_topics.containsKey(topicId)) {
        final topic = _topics[topicId]!;
        _topics[topicId] = topic.copyWith(
          isFollowing: true,
          discussionsCount: topic.discussionsCount + 1,
        );
      }
      return true;
    }
  }

  /// Create topic
  Future<Topic> createTopic({
    required String name,
    String? description,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    final topic = Topic(
      id: 'topic_${DateTime.now().millisecondsSinceEpoch}',
      name: name.startsWith('#') ? name : '#$name',
      description: description,
      postsCount: 0,
      discussionsCount: 1,
      isFollowing: true,
    );
    
    _topics[topic.id] = topic;
    _followedTopics.add(topic.id);
    return topic;
  }

  // --- Users ---

  /// Block user (hide content)
  Future<bool> blockUser(String userId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    
    if (_blockedUsers.contains(userId)) {
      _blockedUsers.remove(userId);
      return false;
    } else {
      _blockedUsers.add(userId);
      return true;
    }
  }

  /// Blacklist user
  Future<bool> blacklistUser(String userId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    
    if (_blacklistedUsers.contains(userId)) {
      _blacklistedUsers.remove(userId);
      return false;
    } else {
      _blacklistedUsers.add(userId);
      return true;
    }
  }

  /// Whether user is blacklisted
  bool isUserBlacklisted(String userId) {
    return _blacklistedUsers.contains(userId);
  }

  /// Blacklisted user count
  int get blacklistedCount => _blacklistedUsers.length;

  // --- Reports ---

  /// Submit report
  Future<Report> reportContent({
    required String targetType,
    required String targetId,
    required ReportType type,
    String? description,
    String? evidence,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    final report = Report(
      id: 'report_${DateTime.now().millisecondsSinceEpoch}',
      reporterId: _currentUserId,
      targetType: targetType,
      targetId: targetId,
      type: type,
      description: description,
      evidence: evidence,
    );
    
    _reports[report.id] = report;
    return report;
  }

  /// My reports
  List<Report> getMyReports() {
    return _reports.values
        .where((report) => report.reporterId == _currentUserId)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  // --- Me ---

  /// My posts
  List<Post> getMyPosts() {
    return _posts.values
        .where((post) => post.userId == _currentUserId)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  /// Saved posts
  List<Post> getCollectedPosts() {
    return _collectedPosts
        .where((postId) => _posts.containsKey(postId))
        .map((postId) => _posts[postId]!.copyWith(isCollected: true))
        .toList();
  }

  /// Followed topics
  List<Topic> getFollowedTopics() {
    return _followedTopics
        .where((topicId) => _topics.containsKey(topicId))
        .map((topicId) => _topics[topicId]!.copyWith(isFollowing: true))
        .toList();
  }

  // --- Search ---

  /// Search posts
  List<Post> searchPosts(String keyword) {
    if (keyword.isEmpty) return [];
    
    return _posts.values
        .where((post) =>
            post.content.contains(keyword) ||
            post.tags.any((tag) => tag.contains(keyword)))
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  /// Search topics
  List<Topic> searchTopics(String keyword) {
    if (keyword.isEmpty) return [];
    
    return _topics.values
        .where((topic) =>
            topic.name.contains(keyword) ||
            (topic.description?.contains(keyword) ?? false))
        .toList();
  }
}