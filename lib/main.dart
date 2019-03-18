import 'package:flutter/material.dart';

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
                Image.asset('assets/login_icon.png'),
                SizedBox(height: 20.0),
                Text('RISC!')
              ]
            ),
            SizedBox(height: 120.0),
            TextField(
              // TODO: store the name somewhere
              decoration: InputDecoration(
                labelText: 'Enter Name'
              )
            ),
            SizedBox(height: 12.0), // spacer
            RaisedButton(
              child: Text('JOIN GAME'),
              onPressed: () {
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
  _LobbyPageState createState() => _LobbyPageState();
}

class _LobbyPageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      endDrawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            // TODO: populate drawer
            DrawerHeader(
              child: Text('People')
            ),
            ListTile(
              title: Text('What up')
            )
          ]
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
            onPressed: _createRoomDialog(context)
          )
        ]
      ),
      body: ListView.builder(
        itemBuilder: (context, position) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              // TODO: fill this with non-filler
              child: Text(position.toString(), style: TextStyle(fontSize: 22.0))
            )
          );
        }
      )
      // TODO: snackbar about connecting to server or whatever
    );
  }
}

_createRoomDialog(BuildContext context) {
  return showDialog<String>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        contentPadding: const EdgeInsets.all(16.0),
        content: Row(
          children: <Widget>[
            Expanded(
              child: TextField(
                autofocus: true
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
https://medium.com/@DakshHub/flutter-displaying-dynamic-contents-using-listview-builder-f2cedb1a19fb (haven't read yet)
*/