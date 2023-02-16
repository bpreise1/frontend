import 'package:frontend/models/custom_user.dart';

class Comment {
  const Comment({
    required this.id,
    required this.comment,
    required this.creatorUserId,
    required this.creatorUsername,
    required this.dateCreated,
    required this.likedBy,
    required this.replies,
  });

  final String id;
  final String comment;
  final String creatorUserId;
  final String creatorUsername;
  final DateTime dateCreated;
  final List<String> likedBy;
  final List<Comment> replies;

  factory Comment.fromJson(Map<String, dynamic> json) {
    List replies = json['replies'];
    List likedBy = json['likedBy'];

    return Comment(
      id: json['id'],
      comment: json['comment'],
      creatorUserId: json['creatorUserId'],
      creatorUsername: json['creatorUsername'],
      dateCreated: DateTime.parse(json['dateCreated']),
      likedBy: likedBy.map((like) => like as String).toList(),
      replies: replies.isEmpty
          ? []
          : replies.map((reply) => Comment.fromJson(reply)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'comment': comment,
      'creatorUserId': creatorUserId,
      'creatorUsername': creatorUsername,
      'dateCreated': dateCreated.toString(),
      'likedBy': likedBy,
      'replies': replies.isEmpty
          ? []
          : replies.map((reply) => reply.toJson()).toList(),
    };
  }
}
