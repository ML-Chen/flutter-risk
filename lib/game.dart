import 'package:flutter/material.dart';
import 'main.dart';
import 'packets.dart';
import 'classes.dart';

class GamePage extends StatefulWidget {
  @override
  _GamePageState createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  // TODO: show place only when you have armies to place
  var rows = [
    ["place", "attack", "move"]
  ]; // list of rows of text of buttons
  var selectedButtons = [
    "",
    "",
    "",
    ""
  ]; // text corresponding to buttons in each row that have been pressed
  String action = "";
  Territory fromTerritory;
  Territory toTerritory;
  int armyCount;

  var snackBar = SnackBar(content: Text(""));

  void clear() {
    rows = [
      ["place", "attack", "move"]
    ];
    selectedButtons = ["", "", "", ""];
    action = "";
    fromTerritory = null;
    toTerritory = null;
    armyCount = 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('Game')),
        body: ListView.builder(
            itemCount: rows.length,
            itemBuilder: (context, index) {
              final row = rows[index];
              return Container(
                  height: 500,
                  child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: row.length,
                      itemBuilder: (context, index) {
                        final buttonText = row[index];
                        if (buttonText == selectedButtons[index]) {
                          // TODO: return a selected-looking FlatButton
                        } else {
                          return FlatButton(
                              child: Text(buttonText),
                              onPressed: () {
                                selectedButtons[index] = buttonText;
                                // TODO: possibly clear the later indices too
                                rows = rows.sublist(0, index + 1);
                                if (index == 0) {
                                  action = buttonText;
                                  // Add a row of ids of territories you own
                                  rows.add(game.territories
                                      .where((territory) =>
                                          territory.ownerToken == publicToken)
                                      .map((territory) =>
                                          territory.id.toString()));
                                } else if (action == "place") {
                                  placeArmy(
                                      int.parse(buttonText), token, channel);
                                  clear();
                                } else if (action == "attack" ||
                                    action == "move") {
                                  if (index == 1) {
                                    fromTerritory = getTerritory(buttonText);
                                    if (action == "attack") {
                                      // Show adjacent territories owned by other people
                                      rows.add(fromTerritory.neighbors
                                          .where((territory) =>
                                              territory.ownerToken != "" &&
                                              territory.ownerToken !=
                                                  publicToken)
                                          .map((territory) =>
                                              territory.id.toString()));
                                    } else {
                                      // Show adjacent territories owned by you
                                      rows.add(fromTerritory.neighbors
                                          .where((territory) =>
                                              territory.ownerToken ==
                                              publicToken)
                                          .map((territory) =>
                                              territory.id.toString()));
                                    }
                                  }
                                  if (index == 2) {
                                    toTerritory = getTerritory(buttonText);
                                    // Show possible armyCounts
                                    rows.add(new List<int>.generate(
                                            fromTerritory.armies, (i) => i + 1)
                                        .map((num) => num.toString()));
                                  } else {
                                    armyCount = int.parse(buttonText);
                                    if (action == "attack")
                                      attackTerritory(
                                          fromTerritory.id,
                                          toTerritory.id,
                                          armyCount,
                                          token,
                                          channel);
                                    else
                                      moveArmy(fromTerritory.id, toTerritory.id,
                                          armyCount, token, channel);
                                    clear();
                                  }
                                }
                              });
                        }
                      }));
            }));
  }
}

Territory getTerritory(String id) {
  return game.territories
      .firstWhere((territory) => territory.id.toString() == id);
}
