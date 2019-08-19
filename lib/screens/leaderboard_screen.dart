import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/user_provider.dart';

class LeaderBoardScreen extends StatefulWidget {
  static const routeName = '/leaderboard-screen';

  @override
  _LeaderBoardScreenState createState() => _LeaderBoardScreenState();
}

class _LeaderBoardScreenState extends State<LeaderBoardScreen> {
  var _isInit = false;
  var _isLoading = false;

  @override
  void didChangeDependencies() {
    if (!_isInit) {
      _isLoading = true;
      Provider.of<UserProvider>(context).fetchLeaderBoard().then((_) {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      });
    }
    _isInit = true;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(
      context,
    );
    return Scaffold(
      appBar: AppBar(
        title: Text('Leader Board'),
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : RefreshIndicator(
              onRefresh: userProvider.fetchLeaderBoard,
              child: ListView.builder(
                itemCount: userProvider.leaderBoard.length,
                itemBuilder: (ctx, i) => Card(
                  margin: EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 4,
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(8),
                    child: ListTile(
                      leading: Text(
                        userProvider.leaderBoard[i].name,
                      ),
                      trailing: Text(
                        '${userProvider.leaderBoard[i].experience} EXP',
                      ),
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}
