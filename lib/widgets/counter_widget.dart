import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/questions_provider.dart';

class Counter extends StatelessWidget {
  final Function _nextQuestion;

  Counter(this._nextQuestion);

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<QuestionsProvider>(context);
    return Container(
      width: 50,
      height: 50,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.yellow,
        borderRadius: BorderRadius.all(
          Radius.circular(10.0),
        ),
      ),
      child: Consumer<QuestionsProvider>(
        builder: (ctx, provider, _) {
          if (provider.timer > 0 && provider.isCorrect == null) {
            return Text(
              '${provider.timer}',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20.0,
              ),
            );
          } else {
            return IconButton(
              icon: IconButton(
                color: Colors.white,
                icon: Icon(
                  Icons.forward,
                ),
                onPressed: _nextQuestion,
              ),
            );
          }
        },
      ),
    );
  }
}
