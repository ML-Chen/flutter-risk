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
          padding: EdgeInsets.symmetric(horizontal: 24.0),
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
                  MaterialPageRoute(builder: (context) => LoginPage())
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
      appBar: AppBar(
        title: Text('Rooms'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.add),
            tooltip: 'Add room',
            onPressed: () {
              
            }
          )
        ]
      )
    );
    // Title bar: Rooms with add button
    // List
      // if no rooms: No rooms yet. Create one!
      // Lonely users with no room
    // Dialog: Create room
  }
}