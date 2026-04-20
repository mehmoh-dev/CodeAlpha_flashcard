import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/flashcard.dart';
import 'package:uuid/uuid.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FlashcardProvider with ChangeNotifier {
  static const String _storageKey = 'flashcards_data';
  
  List<Flashcard> _cards = [];
  int _currentIndex = 0;
  bool _isLoading = true;

  FlashcardProvider() {
    _loadFromDisk();
  }

  List<Flashcard> get cards => [..._cards];
  int get currentIndex => _currentIndex;
  bool get isLoading => _isLoading;

  Flashcard? get currentCard => _cards.isNotEmpty ? _cards[_currentIndex] : null;

  Future<void> _loadFromDisk() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? encodedData = prefs.getString(_storageKey);
      
      if (encodedData != null && encodedData.isNotEmpty) {
        final List<dynamic> decodedList = json.decode(encodedData);
        _cards = decodedList.map((item) => Flashcard.fromMap(item)).toList();
      } else {
        // Prepopulate with sample data on first run or if empty
        _cards = [
          Flashcard(id: '1', question: 'What is Flutter?', answer: 'An open-source UI kit by Google for building apps.'),
          Flashcard(id: '2', question: 'What is the capital of Japan?', answer: 'Tokyo.'),
          Flashcard(id: '3', question: 'Who painted the Mona Lisa?', answer: 'Leonardo da Vinci.'),
          Flashcard(id: '4', question: 'What does DNA stand for?', answer: 'Deoxyribonucleic Acid.'),
          Flashcard(id: '5', question: 'What is the largest planet in our solar system?', answer: 'Jupiter.'),
          Flashcard(id: '6', question: 'What is the boiling point of water?', answer: '100°C or 212°F.'),
          Flashcard(id: '7', question: 'Who is known as the father of computers?', answer: 'Charles Babbage.'),
          Flashcard(id: '8', question: 'What is the fastest land animal?', answer: 'The Cheetah.'),
          Flashcard(id: '9', question: 'Which element has the symbol "O"?', answer: 'Oxygen.'),
          Flashcard(id: '10', question: 'What is the square root of 64?', answer: '8.'),
        ];
        await _saveToDisk();
      }
    } catch (e) {
      debugPrint('Error loading cards: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _saveToDisk() async {
    final prefs = await SharedPreferences.getInstance();
    final String encodedData = json.encode(_cards.map((card) => card.toMap()).toList());
    await prefs.setString(_storageKey, encodedData);
  }

  void addCard(String question, String answer) {
    final newCard = Flashcard(
      id: const Uuid().v4(),
      question: question,
      answer: answer,
    );
    _cards.add(newCard);
    _saveToDisk();
    notifyListeners();
  }

  void updateCard(String id, String question, String answer) {
    final index = _cards.indexWhere((card) => card.id == id);
    if (index != -1) {
      _cards[index].question = question;
      _cards[index].answer = answer;
      _saveToDisk();
      notifyListeners();
    }
  }

  void deleteCard(String id) {
    final index = _cards.indexWhere((card) => card.id == id);
    if (index != -1) {
      _cards.removeAt(index);
      if (_currentIndex >= _cards.length && _cards.isNotEmpty) {
        _currentIndex = _cards.length - 1;
      } else if (_cards.isEmpty) {
        _currentIndex = 0;
      }
      _saveToDisk();
      notifyListeners();
    }
  }

  void nextCard() {
    if (_cards.isEmpty) return;
    _currentIndex = (_currentIndex + 1) % _cards.length;
    notifyListeners();
  }

  void previousCard() {
    if (_cards.isEmpty) return;
    _currentIndex = (_currentIndex - 1 + _cards.length) % _cards.length;
    notifyListeners();
  }

  void resetIndex() {
    _currentIndex = 0;
    notifyListeners();
  }

  void setIndex(int index) {
    if (index >= 0 && index < _cards.length) {
      _currentIndex = index;
      notifyListeners();
    }
  }
}
