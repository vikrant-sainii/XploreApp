import 'package:equatable/equatable.dart';
import 'user_model.dart';

class LostFoundModel extends Equatable {
  final String id;
  final String title;
  final String description;
  final String type; // "LOST" or "FOUND"
  final String? imageUrl;
  final String? imagePublicId;
  final String? whatsapp;
  final String userId;
  final DateTime? createdAt;
  final UserModel? user;

  const LostFoundModel({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    this.imageUrl,
    this.imagePublicId,
    this.whatsapp,
    required this.userId,
    this.createdAt,
    this.user,
  });

  factory LostFoundModel.fromJson(Map<String, dynamic> json) {
    return LostFoundModel(
      id: json['id'] ?? json['_id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      type: json['type'] ?? 'LOST',
      imageUrl: json['imageUrl'] ?? json['image_url'],
      imagePublicId: json['imagePublicId'] ?? json['image_public_id'],
      whatsapp: json['whatsapp'],
      userId: json['userId'] ?? '',
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt']) : null,
      user: json['user'] != null ? UserModel.fromJson(json['user']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type,
      'imageUrl': imageUrl,
      'imagePublicId': imagePublicId,
      'whatsapp': whatsapp,
      'userId': userId,
      'createdAt': createdAt?.toIso8601String(),
      'user': user?.toJson(),
    };
  }

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        type,
        imageUrl,
        imagePublicId,
        whatsapp,
        userId,
        createdAt,
        user,
      ];
}
