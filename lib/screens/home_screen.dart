import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/questions_provider.dart';
import '../providers/user_provider.dart';
import '../screens/questions_screen.dart';
import '../screens/splash_screen.dart';
import '../widgets/app_drawer.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final QuestionsProvider questionsProvider =
        Provider.of<QuestionsProvider>(context, listen: false);
    final Future<void> questionsFuture =
        questionsProvider.fetchAndSetQuestions(context);
    return Scaffold(
      appBar: AppBar(
        title: Consumer<UserProvider>(
          builder: (ctx, user, _) => Row(children: <Widget>[
            Expanded(child: Text(user.name),),
            Text('${user.experience} EXP'),
          ],)
        ),
      ),
      drawer: AppDrawer(),
      body: Center(
        child: FutureBuilder(
          future: questionsFuture,
          builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            } else {
              return RaisedButton(
                onPressed: () {
                  questionsProvider.loadQuestions();
                  Navigator.of(context).pushNamed(QuestionsScreen.routeName);
                },
                child: Text('Start'),
              );
            }
          },
        ),
      ),
    );
  }
}
