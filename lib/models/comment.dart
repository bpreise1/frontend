import 'package:frontend/models/custom_user.dart';

class Comment {
  const Comment({
    required this.comment,
    required this.createdBy,
    required this.dateCreated,
    required this.likes,
    required this.replies,
  });

  final String comment;
  final CustomUser createdBy;
  final DateTime dateCreated;
  final int likes;
  final List<Comment> replies;

  factory Comment.fromJson(Map<String, dynamic> json) {
    List replies = json['replies'];

    return Comment(
      comment: json['comment'],
      createdBy: CustomUser.fromJson(json['createdBy']),
      dateCreated: DateTime.parse(json['dateCreated']),
      likes: json['likes'],
      replies: replies.isEmpty
          ? []
          : replies.map((reply) => Comment.fromJson(reply)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'comment': comment,
      'createdBy': createdBy.toJson(),
      'dateCreated': dateCreated.toString(),
      'likes': likes,
      'replies': replies.isEmpty
          ? []
          : replies.map((reply) => reply.toJson()).toList(),
    };
  }
}
