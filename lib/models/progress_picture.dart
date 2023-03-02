import 'dart:typed_data';

import 'package:frontend/models/comment.dart';

class ProgressPicture {
  const ProgressPicture(
      {required this.id,
      required this.image,
      required this.creatorUserId,
      required this.dateCreated,
      this.likedBy = const [],
      this.comments = const [],
      this.totalComments = 0});

  final String id;
  final Uint8List image;
  final String creatorUserId;
  final DateTime dateCreated;
  final List<String> likedBy;
  final List<Comment> comments;
  final int totalComments;

  factory ProgressPicture.fromJson(
      Map<String, dynamic> json, Uint8List progressPicture) {
    List likedBy = json['likedBy'];
    List comments = json['comments'];

    return ProgressPicture(
      id: json['id'],
      image: progressPicture,
      creatorUserId: json['creatorUserId'],
      dateCreated: DateTime.parse(json['timeCreated']),
      likedBy: likedBy.map((like) => like as String).toList(),
      comments: comments.map((comment) => Comment.fromJson(comment)).toList(),
      totalComments: json['totalComments'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'creatorUserId': creatorUserId,
      'timeCreated': dateCreated.toString(),
      'likedBy': likedBy,
      'comments': comments.map((comment) => comment.toJson()).toList(),
      'totalComments': totalComments,
    };
  }
}
