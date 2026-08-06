import 'package:equatable/equatable.dart';
import '../../models/lost_found_model.dart';

abstract class LostFoundState extends Equatable {
  const LostFoundState();

  @override
  List<Object?> get props => [];
}

class LostFoundInitial extends LostFoundState {}

class LostFoundLoading extends LostFoundState {}

class LostFoundItemsLoaded extends LostFoundState {
  final List<LostFoundModel> items;

  const LostFoundItemsLoaded(this.items);

  @override
  List<Object?> get props => [items];
}

class MyLostFoundPostsLoaded extends LostFoundState {
  final List<LostFoundModel> posts;

  const MyLostFoundPostsLoaded(this.posts);

  @override
  List<Object?> get props => [posts];
}

class LostFoundPostCreated extends LostFoundState {
  final LostFoundModel post;
  final String message;

  const LostFoundPostCreated({required this.post, required this.message});

  @override
  List<Object?> get props => [post, message];
}

class LostFoundActionSuccess extends LostFoundState {
  final String message;

  const LostFoundActionSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class LostFoundClaimSuccess extends LostFoundState {
  final String message;
  final Map<String, dynamic>? contact;

  const LostFoundClaimSuccess({required this.message, this.contact});

  @override
  List<Object?> get props => [message, contact];
}

class LostFoundError extends LostFoundState {
  final String message;

  const LostFoundError(this.message);

  @override
  List<Object?> get props => [message];
}
