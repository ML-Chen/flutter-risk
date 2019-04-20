import 'package:flutter/material.dart';
import 'packets.dart';
import 'classes.dart';

var rows = [["place", "attack", "move"]]; // list of rows of text of buttons

class GamePage extends StatefulWidget {
  @override
  _GamePageState createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  var snackBar = SnackBar(
    content: Text("")
  );

  @override                               
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemCount: rows.length,
        itemBuilder: (context, index) {
          final row = rows[index];
          return ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: row.length,
            itemBuilder: (context, index) {
              final buttonText = row[index];
              return FlatButton( 
                child: Text(buttonText),
                onPressed: () {
                  switch (buttonText) {
                    case "place":
                      break;
                    case "attack":
                      break;
                    case "move":
                      break;
                  }
                }
              );
            }
          );
        }
      )
    );
}