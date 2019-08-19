import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:convert';
import 'dart:async';

import '../models/question.dart';

class QuestionsProvider with ChangeNotifier {
  Random _randomGenerator = Random.secure();
  List<Question> _loadedQuestions = [];
  String _contents;
  Question _currentQuestion;
  int _correctAnswerIndex;
  int _selectedOptionIndex;
  int _tempExperience = 0;
  bool _isCorrect;
  Timer _counter;
  int _timer = 10;

  int get tempExperience {
    return _tempExperience;
  }

  int get correctAnswerIndex {
    return _correctAnswerIndex;
  }

  int get timer {
    return _timer;
  }

  Question get currentQuestion {
    return _currentQuestion;
  }

  bool get isCorrect {
    return _isCorrect;
  }

  int get selectedOptionIndex {
    return _selectedOptionIndex;
  }

  /*Future<void> fetchAndSetQuestions(BuildContext context) async {
    final String contents = await DefaultAssetBundle.of(context)
        .loadString('assets/json/questions.json');
    print('hey before');
    loadedQuestions = await json.decode(contents);
    print('hey after');
  }*/

  Future<void> fetchAndSetQuestions(BuildContext context) async {
    _contents = await DefaultAssetBundle.of(context)
        .loadString('assets/json/questions.json');
  }

  void loadQuestions() {
    _tempExperience = 0;

    final List<dynamic> tempList = json.decode(_contents);
    tempList.forEach((e) {
      _loadedQuestions.add(
        Question(
          e['question'],
          [e['right'], e['wrong1'], e['wrong2']],
          e['winners'].toDouble(),
        ),
      );
    });
  }

  Question loadRandomQuestion() {
    _isCorrect = null;
    _selectedOptionIndex = null;
    _timer = 10;
    startTimer();
    final int currentQuestionIndex =
        _randomGenerator.nextInt(_loadedQuestions.length - 1);
    final Question currentQuestion = _loadedQuestions[currentQuestionIndex];
    final List<int> permutation =
        List.generate(currentQuestion.options.length, (i) => i);

    _currentQuestion = Question(
        currentQuestion.question,
        permutation.map((i) => currentQuestion.options[i]).toList(),
        currentQuestion.winnersPercentage);
    _correctAnswerIndex = permutation.indexOf(0);

    return _currentQuestion;
  }

  void checkAnswer(int index) {
    _selectedOptionIndex = index;
    _isCorrect = index == _correctAnswerIndex;
    if(_isCorrect) _tempExperience += currentQuestion.experiencePoints;
    _counter.cancel();
    notifyListeners();
  }

  void startTimer() {
    const oneSec = const Duration(seconds: 1);
    _counter = Timer.periodic(oneSec, (Timer counter) {
      if (_timer < 1) {
        checkAnswer(-1);
      } else {
        _timer = _timer - 1;
        notifyListeners();
      }
    });
  }
/*
    loadedQuestions = json
        .decode(contents)
        .map((e) => Question(
              e['question'],
              [e['right'], e['wrong1'], e['wrong2']],
              0.0,
            ))
        .toList() as List<Question>;
  }*/
}
