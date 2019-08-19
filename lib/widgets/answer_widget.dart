import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/questions_provider.dart';

class Answer extends StatelessWidget {
  final String answerText;
  final int optionIndex;

  Answer(this.answerText, this.optionIndex);

  @override
  Widget build(BuildContext context) {
    final QuestionsProvider questionsProvider =
        Provider.of<QuestionsProvider>(context);
    final bool answer = questionsProvider.isCorrect;
    final int selectedOptionIndex = questionsProvider.selectedOptionIndex;
    final int correctAnswerIndex = questionsProvider.correctAnswerIndex;

    return Container(
      width: double.infinity,
      child: RaisedButton(
        color: answer == null
            ? Colors.blue
            : (correctAnswerIndex == optionIndex ? Colors.green : selectedOptionIndex == optionIndex ? Colors.red : Colors.blue),
        textColor: Colors.white,
        child: Row(
          children: <Widget>[
            Expanded(
              child: Text(
                answerText,
                textAlign: TextAlign.center,
              ),
            ),
            if(answer != null && answer && selectedOptionIndex == optionIndex) Text('+ ${questionsProvider.currentQuestion.experiencePoints}')
          ],
        ),
        onPressed: answer == null
            ? () {
                questionsProvider.checkAnswer(optionIndex);
              }
            : () {},
      ),
    );
  }
}
