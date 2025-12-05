import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:octagon/utils/constants.dart';

class FirebasePostService {
  static final FirebasePostService _instance = FirebasePostService._internal();
  factory FirebasePostService() => _instance;
  FirebasePostService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final storage = GetStorage();

  /// Save post data to Firestore with Cloudinary URLs
  Future<String?> savePost({
    required String title,
    required String content,
    required List<String> imageUrls,
    List<String>? videoUrls,
    String? location,
    bool isCommentEnabled = true,
    String type = 'post',
  }) async {
    try {
      final userId = storage.read("current_uid");
      final userName = storage.read("user_name");
      final userPhoto = storage.read("image_url");

      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final postData = {
        'userId': userId,
        'userName': userName ?? 'Anonymous',
        'userPhoto': userPhoto,
        'title': title,
        'content': content,
        'imageUrls': imageUrls,
        'videoUrls': videoUrls ?? [],
        'location': location,
        'isCommentEnabled': isCommentEnabled,
        'type': type,
        'likes': 0,
        'comments': [],
        'isLikedByMe': false,
        'isUserFollowedByMe': false,
        'isSaveByMe': false,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      final docRef = await _firestore.collection('posts').add(postData);
      print('Post saved to Firestore with ID: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      print('Error saving post to Firestore: $e');
      return null;
    }
  }

  /// Get posts from Firestore
  Stream<QuerySnapshot> getPosts({int limit = 20}) {
    return _firestore
        .collection('posts')
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots();
  }

  /// Like/Unlike a post
  Future<void> toggleLike(String postId, bool isLiked) async {
    try {
      final userId = storage.read("current_uid");
      if (userId == null) return;

      final postRef = _firestore.collection('posts').doc(postId);

      if (isLiked) {
        // Add like
        await postRef.update({
          'likes': FieldValue.increment(1),
          'likedBy': FieldValue.arrayUnion([userId]),
        });
      } else {
        // Remove like
        await postRef.update({
          'likes': FieldValue.increment(-1),
          'likedBy': FieldValue.arrayRemove([userId]),
        });
      }
    } catch (e) {
      print('Error toggling like: $e');
    }
  }

  /// Add comment to a post
  Future<void> addComment(String postId, String comment) async {
    try {
      final userId = storage.read("current_uid");
      final userName = storage.read("user_name");
      final userPhoto = storage.read("image_url");

      if (userId == null) return;

      final commentData = {
        'userId': userId,
        'userName': userName ?? 'Anonymous',
        'userPhoto': userPhoto,
        'comment': comment,
        'createdAt': FieldValue.serverTimestamp(),
      };

      await _firestore
          .collection('posts')
          .doc(postId)
          .collection('comments')
          .add(commentData);

      // Update comment count
      await _firestore.collection('posts').doc(postId).update({
        'commentCount': FieldValue.increment(1),
      });
    } catch (e) {
      print('Error adding comment: $e');
    }
  }

  /// Save/Unsave a post
  Future<void> toggleSave(String postId, bool isSaved) async {
    try {
      final userId = storage.read("current_uid");
      if (userId == null) return;

      final userRef = _firestore.collection('users').doc(userId);

      if (isSaved) {
        // Add to saved posts
        await userRef.update({
          'savedPosts': FieldValue.arrayUnion([postId]),
        });
      } else {
        // Remove from saved posts
        await userRef.update({
          'savedPosts': FieldValue.arrayRemove([postId]),
        });
      }
    } catch (e) {
      print('Error toggling save: $e');
    }
  }

  /// Follow/Unfollow a user
  Future<void> toggleFollow(String targetUserId, bool isFollowing) async {
    try {
      final userId = storage.read("current_uid");
      if (userId == null) return;

      final userRef = _firestore.collection('users').doc(userId);
      final targetUserRef = _firestore.collection('users').doc(targetUserId);

      if (isFollowing) {
        // Follow user
        await userRef.update({
          'following': FieldValue.arrayUnion([targetUserId]),
        });
        await targetUserRef.update({
          'followers': FieldValue.arrayUnion([userId]),
        });
      } else {
        // Unfollow user
        await userRef.update({
          'following': FieldValue.arrayRemove([targetUserId]),
        });
        await targetUserRef.update({
          'followers': FieldValue.arrayRemove([userId]),
        });
      }
    } catch (e) {
      print('Error toggling follow: $e');
    }
  }

  /// Delete a post
  Future<void> deletePost(String postId) async {
    try {
      final userId = storage.read("current_uid");
      if (userId == null) return;

      // Check if user owns the post
      final postDoc = await _firestore.collection('posts').doc(postId).get();
      if (postDoc.data()?['userId'] != userId) {
        throw Exception('User not authorized to delete this post');
      }

      // Delete comments first
      final commentsSnapshot = await _firestore
          .collection('posts')
          .doc(postId)
          .collection('comments')
          .get();

      for (var doc in commentsSnapshot.docs) {
        await doc.reference.delete();
      }

      // Delete the post
      await _firestore.collection('posts').doc(postId).delete();
      print('Post deleted successfully');
    } catch (e) {
      print('Error deleting post: $e');
      rethrow;
    }
  }

  /// Get user's saved posts
  Stream<QuerySnapshot> getSavedPosts(String userId) {
    return _firestore
        .collection('posts')
        .where('savedBy', arrayContains: userId)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  /// Get user's posts
  Stream<QuerySnapshot> getUserPosts(String userId) {
    return _firestore
        .collection('posts')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }
}
