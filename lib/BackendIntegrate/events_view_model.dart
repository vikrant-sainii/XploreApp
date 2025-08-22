import 'package:flutter/material.dart';
import 'api_service.dart';
import 'models.dart';

enum EventsState { initial, loading, loaded, error }

class EventsViewModel extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  EventsState _state = EventsState.initial;
  List<Event> _events = [];
  String? _errorMessage;
  bool _isCreatingEvent = false;
  bool _isParticipating = false;

  EventsState get state => _state;
  List<Event> get events => _events;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _state == EventsState.loading;
  bool get isCreatingEvent => _isCreatingEvent;
  bool get isParticipating => _isParticipating;

  void _setState(EventsState newState) {
    _state = newState;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    _setState(EventsState.error);
  }

  Future<void> loadEvents() async {
    try {
      _setState(EventsState.loading);
      _errorMessage = null;

      _events = await _apiService.getEvents();
      _setState(EventsState.loaded);
    } catch (e) {
      _setError(e.toString());
    }
  }

  Future<void> createEvent({
    required String name,
    required DateTime eventDate,
    required String description,
  }) async {
    try {
      _isCreatingEvent = true;
      notifyListeners();
      _errorMessage = null;

      final newEvent = await _apiService.createEvent(
        name: name,
        eventDate: eventDate,
        description: description,
      );

      _events.insert(0, newEvent);
      _isCreatingEvent = false;
      notifyListeners();
    } catch (e) {
      _isCreatingEvent = false;
      _setError(e.toString());
    }
  }

  Future<void> participateInEvent(String eventId) async {
    try {
      _isParticipating = true;
      notifyListeners();
      _errorMessage = null;

      await _apiService.participateInEvent(eventId);
      
      // Refresh events to get updated participant list
      await loadEvents();
      
      _isParticipating = false;
      notifyListeners();
    } catch (e) {
      _isParticipating = false;
      _setError(e.toString());
    }
  }

  Future<void> leaveEvent(String eventId) async {
    try {
      _isParticipating = true;
      notifyListeners();
      _errorMessage = null;

      await _apiService.leaveEvent(eventId);
      
      // Refresh events to get updated participant list
      await loadEvents();
      
      _isParticipating = false;
      notifyListeners();
    } catch (e) {
      _isParticipating = false;
      _setError(e.toString());
    }
  }

  void clearError() {
    _errorMessage = null;
    if (_state == EventsState.error) {
      _setState(_events.isNotEmpty ? EventsState.loaded : EventsState.initial);
    }
  }

  Event? getEventById(String eventId) {
    try {
      return _events.firstWhere((event) => event.id == eventId);
    } catch (e) {
      return null;
    }
  }

  bool isUserParticipating(String eventId, String userId) {
    final event = getEventById(eventId);
    return event?.participants.contains(userId) ?? false;
  }
}