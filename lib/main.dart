import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './providers/questions_provider.dart';
import './providers/auth.dart';
import './providers/user_provider.dart';
import './screens/home_screen.dart';
import './screens/questions_screen.dart';
import './screens/auth_screen.dart';
import './screens/splash_screen.dart';
import './screens/leaderboard_screen.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(
          value: Auth(),
        ),
        ChangeNotifierProvider.value(
          value: QuestionsProvider(),
        ),
        ChangeNotifierProxyProvider<Auth, UserProvider>(
          builder: (BuildContext ctx, Auth auth, previousUser) => UserProvider(
            auth.token,
            auth.userId,
          ),
        ),
      ],
      child: Consumer2<Auth, UserProvider>(
        builder: (ctx, auth, user, _) => MaterialApp(
          title: 'QuizApp',
          theme: ThemeData(
            primarySwatch: Colors.blue,
          ),
          home: auth.isAuth
              ? FutureBuilder(
                  future: user.fetchUserData(),
                  builder: (ctx, authResultSnapshot) =>
                      authResultSnapshot.connectionState ==
                              ConnectionState.waiting
                          ? SplashScreen()
                          : HomeScreen(),
                )
              : FutureBuilder(
                  future: auth.tryAutoLogin(),
                  builder: (ctx, authResultSnapshot) =>
                      authResultSnapshot.connectionState ==
                              ConnectionState.waiting
                          ? SplashScreen()
                          : AuthScreen(),
                ),
          routes: {
            QuestionsScreen.routeName: (ctx) => QuestionsScreen(),
            LeaderBoardScreen.routeName: (ctx) => LeaderBoardScreen(),
          },
        ),
      ),
    );
  }
}
