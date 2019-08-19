import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/questions_provider.dart';
import '../providers/user_provider.dart';
import '../widgets/question_widget.dart';
import '../widgets/answer_widget.dart';
import '../widgets/counter_widget.dart';
import '../models/question.dart';

class QuestionsScreen extends StatefulWidget {
  static const routeName = '/question-screen';

  @override
  _QuestionsScreenState createState() => _QuestionsScreenState();
}

class _QuestionsScreenState extends State<QuestionsScreen> {
  int questionNumber = 1;
  int maxQuestions = 5;
  var _isLoading = false;

  void _nextQuestion(
      QuestionsProvider questionsProvider, UserProvider userProvider) {
    if (questionNumber < maxQuestions) {
      setState(() {
        questionNumber++;
      });
    } else {
      userProvider
          .addExperience(questionsProvider.tempExperience)
          .then((_) => Navigator.of(context).pop());
    }
  }

  @override
  Widget build(BuildContext context) {
    final questionProvider =
        Provider.of<QuestionsProvider>(context, listen: false);
    final Question currentQuestion = questionProvider.loadRandomQuestion();
    final userProvider = Provider.of<UserProvider>(
      context,
      listen: false,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('Quiz'),
      ),
      body: Container(
        padding: EdgeInsets.all(10.0),
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Container(
                  padding: EdgeInsets.all(10.0),
                  width: 200,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(
                      Radius.circular(10.0),
                    ),
                    color: currentQuestion.difficultyColor,
                  ),
                  child: Text(
                    currentQuestion.difficulty,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(10.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(
                      Radius.circular(10.0),
                    ),
                    color: Colors.greenAccent,
                  ),
                  child: Text('${questionNumber}/$maxQuestions'),
                ),
              ],
            ),
            QuestionText(currentQuestion.question),
            ...currentQuestion.options
                .map(
                  (String option) => Answer(
                    option,
                    currentQuestion.options.indexOf(option),
                  ),
                )
                .toList(),
            SizedBox(
              height: 10.0,
            ),
            Counter(
              () => _nextQuestion(questionProvider, userProvider),
            ),
            SizedBox(
              height: 10.0,
            ),
            if (_isLoading)
              Center(
                child: CircularProgressIndicator(),
              ),
          ],
        ),
      ),
    );
  }
}
