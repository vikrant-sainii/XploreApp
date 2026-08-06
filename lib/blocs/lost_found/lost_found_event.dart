import 'package:equatable/equatable.dart';

abstract class LostFoundEvent extends Equatable {
  const LostFoundEvent();

  @override
  List<Object?> get props => [];
}

class FetchLostFoundItems extends LostFoundEvent {}

class FetchMyLostFoundPosts extends LostFoundEvent {}

class CreateLostFoundPost extends LostFoundEvent {
  final String title;
  final String description;
  final String type; // "Lost" or "Found"
  final String? imageUrl;
  final String? imagePublicId;
  final String? whatsapp;

  const CreateLostFoundPost({
    required this.title,
    required this.description,
    required this.type,
    this.imageUrl,
    this.imagePublicId,
    this.whatsapp,
  });

  @override
  List<Object?> get props => [title, description, type, imageUrl, imagePublicId, whatsapp];
}

class ReuniteItem extends LostFoundEvent {
  final String itemId;

  const ReuniteItem(this.itemId);

  @override
  List<Object?> get props => [itemId];
}

class ReportLostFoundPost extends LostFoundEvent {
  final String itemId;
  final String reason;

  const ReportLostFoundPost({required this.itemId, required this.reason});

  @override
  List<Object?> get props => [itemId, reason];
}

class ClaimLostFoundItem extends LostFoundEvent {
  final String itemId;

  const ClaimLostFoundItem(this.itemId);

  @override
  List<Object?> get props => [itemId];
}
