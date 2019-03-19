import 'package:flutter/material.dart';
// import 'package:web_socket_channel/io.dart';
// import 'package:web_socket_channel/web_socket_channel.dart';

var _yourName = "Mic";
var _players = ["Mic", "Alice", "Bob", "Carol", "Dan", "Eve"];
List<Room> _rooms = [Room("Room1", "mwahaha", ["hehe", "lol", "jk"]), Room("Room2", "ya", ["whoa", "uh huh"])];
// final channel = IOWebSocketChannel.connect('ws://localhost:9000/ws');

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
  String roomName;
  String host;
  List<String> otherPlayers;

  Room(this.roomName, this.host, this.otherPlayers);
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
  final tecYourName = TextEditingController();

  @override
  void dispose() {
    tecYourName.dispose();
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
              controller: tecYourName,
              decoration: InputDecoration(
                labelText: 'Enter Name'
              )
            ),
            SizedBox(height: 12.0), // spacer
            // TODO: enable button only when name exists
            RaisedButton(
              child: Text('JOIN GAME'),
              onPressed: () {
                _yourName = tecYourName.text;
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
            onPressed: () => _createRoomDialog(context)
          )
        ]
      ),
      body: ListView.builder(
        itemCount: _rooms.length,
        itemBuilder: (context, index) {
          final room = _rooms[index];
          return ListTile(
            title: Text(room.roomName),
            subtitle: (room.otherPlayers.isEmpty) ? Text("👑" + room.host) : Text("👑" + room.host + ", " + room.otherPlayers.join(", ")),
            // TODO: join room logic
            trailing: FlatButton(
              child: const Text('JOIN'),
            )
          );
        }
      )
      // TODO: snackbar about connecting to server or whatever
    );
  }
}

void _createRoomDialog(BuildContext context) {
  String newRoomName;
  final tec = TextEditingController();

  showDialog<String>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Create Room'),
        content: Row(
          children: <Widget>[
            Expanded(
              child: TextField(
                autofocus: true,
                controller: tec,
                decoration: InputDecoration(
                  hintText: 'Room name'
                )
              )
            )
          ],
        ),
        actions: <Widget>[
          FlatButton(
              child: const Text('CANCEL'),
              onPressed: () {
                Navigator.pop(context);
              }),
          FlatButton(
              child: const Text('CREATE'),
              onPressed: () {
                _rooms.add(Room(tec.text, _yourName, <String>[]));
                Navigator.pop(context);
                // TODO: handle creating room
              })
        ]
      );
    }
  );
}

/* References
https://github.com/flutter/flutter/issues/19606
https://stackoverflow.com/questions/51957960/how-to-change-the-enddrawer-icon-in-flutter
https://flutter.dev/docs/cookbook/design/drawer
https://flutter.dev/docs/cookbook/lists/mixed-list
https://flutter.dev/docs/cookbook/forms/retrieve-input
https://flutter.dev/docs/cookbook/networking/web-sockets
*/