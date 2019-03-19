import 'package:flutter/material.dart';

var _yourName = "Mic";
var _players = ["Mic", "Alice", "Bob", "Carol", "Dan", "Eve"];
List<Room> _rooms = [Room("mwahaha", ["hehe", "lol", "jk"]), Room("ya", ["whoa", "uh huh"])];

void main() {
  runApp(new RiskApp());
}

class RiskApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "RISC!",
      theme: kDefaultTheme,
      home: HomePage()
    );
  }
}

class Room {
  String host;
  List<String> otherPlayers;

  Room(this.host, this.otherPlayers);
}

final ThemeData kDefaultTheme = new ThemeData(
  primarySwatch: Colors.blue,
  accentColor: Colors.purpleAccent[400],
  brightness: Brightness.dark
);

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final tec = TextEditingController();

  @override
  void dispose() {
    tec.dispose();
    super.dispose();
  }

  @override                               
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          children: <Widget>[
            SizedBox(height: 80.0),
            Column(
              children: <Widget>[
                // Image.asset('assets/login_icon.png'),
                SizedBox(height: 20.0),
                Text('RISC!')
              ]
            ),
            SizedBox(height: 120.0),
            TextField(
              controller: tec,
              decoration: InputDecoration(
                labelText: 'Enter Name'
              )
            ),
            SizedBox(height: 12.0), // spacer
            RaisedButton(
              child: Text('JOIN GAME'),
              onPressed: () {
                // _yourName = tec.text;
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LobbyPage())
                );
              }
            )
          ]
        )
      )
    );
  }
}

class LobbyPage extends StatefulWidget {
  @override
  State createState() => _LobbyPageState();
}

class _LobbyPageState extends State<LobbyPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      endDrawer: Drawer(
        child: ListView.builder(
          itemCount: _players.length,
          itemBuilder: (context, index) {
            final item = _players[index];
            if (item == _yourName)
              return ListTile(
                title: Text(item),
                subtitle: Text("(me)")
              );
            else
              return ListTile(
                title: Text(item)
              );
          }
        )
      ),
      appBar: AppBar(
        title: Text('Rooms'),
        actions: <Widget>[
          Builder(
            builder: (context) => IconButton(
              icon: Icon(Icons.people),
              onPressed: () => Scaffold.of(context).openEndDrawer(),
              tooltip: 'Players'
            )
          ),
          IconButton(
            icon: Icon(Icons.add),
            tooltip: 'Create Room',
            // onPressed: _createRoomDialog(context)
          )
        ]
      ),
      body: ListView.builder(
        itemCount: _rooms.length,
        itemBuilder: (context, index) {
          final item = _players[index];
            if (item == _yourName)
              return ListTile(
                title: Text(item),
                subtitle: Text("(me)")
              );
        }
      )
      // TODO: snackbar about connecting to server or whatever
    );
  }
}

// _createRoomDialog(BuildContext context) {
//   return showDialog<String>(
//     context: context,
//     builder: (BuildContext context) {
//       return AlertDialog(
//         contentPadding: const EdgeInsets.all(16.0),
//         content: Row(
//           children: <Widget>[
//             Expanded(
//               child: TextField(
//                 autofocus: true
//               )
//             )
//           ],
//         ),
//         actions: <Widget>[
//           FlatButton(
//               child: const Text('CANCEL'),
//               onPressed: () {
//                 Navigator.pop(context);
//               }),
//           FlatButton(
//               child: const Text('CREATE'),
//               onPressed: () {
//                 Navigator.pop(context);
//                 // TODO: handle creating room
//               })
//         ]
//       );
//     }
//   );
// }

/* References
https://github.com/flutter/flutter/issues/19606
https://stackoverflow.com/questions/51957960/how-to-change-the-enddrawer-icon-in-flutter
https://flutter.dev/docs/cookbook/design/drawer
https://flutter.dev/docs/cookbook/lists/mixed-list
https://flutter.dev/docs/cookbook/forms/retrieve-input
*/