import 'package:flutter/material.dart';
import 'main.dart';
import 'dart:convert' as JSON;
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
  void initState() {
    print("called");
    streamController.stream.listen((message) {
      print("game received message");
      Map<String, dynamic> msg = JSON.jsonDecode(message);
      setState(() {});
      switch (msg["_type"]) {
        case 'actors.NotifyGameStarted':
          game.map.viewBox = null;
          game.map.territories = null;
          game.phase = 'Setup';
          List<dynamic> temp = msg["state"]["players"];
          for (dynamic obj in temp) {
            Player tempPlayer = new Player();
            tempPlayer.name = obj["name"];
            tempPlayer.unitCount = obj["unitCount"];
            game.players.add(tempPlayer);
          }
          temp = msg["state"]["map"]["territories"];
          for (dynamic obj in temp) {
            Territory tempTerritory = new Territory(
                obj["armies"], obj["ownerToken"], obj["neighbors"], obj["id"]);
            game.territories.add(tempTerritory);
          }
          break;
        case 'actors.NotifyGameState':
          List<dynamic> temp = msg["state"]["players"];
          for (dynamic obj in temp) {
            Player tempPlayer = new Player();
            tempPlayer.name = obj["name"];
            tempPlayer.unitCount = obj["unitCount"];
            game.players.add(tempPlayer);
          }
          temp = msg["state"]["map"]["territories"];
          for (dynamic obj in temp) {
            Territory tempTerritory = new Territory(
                obj["armies"], obj["ownerToken"], obj["neighbors"], obj["id"]);
            game.territories.add(tempTerritory);
          }
          print(game.territories.length);
          break;
        case 'actors.NotifyGamePhaseStart':
          game.phase = 'Realtime';
          break;
        case 'actors.SendMapResource':
          game.map.viewBox = msg["viewBox"];
          game.map.territories = msg["territories"];
          break;
        case 'actors.NotifyTurn':
          turn = msg["publicToken"];
          turnPhase = msg["turnPhase"];
          break;
        case 'actors.NotifyNewArmies':
          snackBarText = "You got $msg['newArmies'] new armies.";
          showSnackBar = true;
          break;
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('Game')),
        body: Container(
            height: MediaQuery.of(context).size.height,
            child: Column(children: <Widget>[
              Container(
                  height: MediaQuery.of(context).size.height * 0.75,
                  child: _buildTerritoryList(context)),
              Container(
                  height: MediaQuery.of(context).size.height * 0.10,
                  child: _buildActionList(context))
            ])));
  }

  ListView _buildTerritoryList(BuildContext context) {
    //TODO: fix redraw of game state
    return ListView.builder(
      itemCount: game.territories.length,
      itemBuilder: (context, index) {
        Territory t = game.territories[index];
        String owner = '';
        if (t.ownerToken == '') {
          owner = "No one";
        } else {
          if (joinedRoom.clientStatus != null) {
            for (ClientStatus player in joinedRoom.clientStatus) {
              if (t.ownerToken == player.publicToken) {
                owner = player.name;
              }
            }
          } else {
            print("Client status is null");
          }

          if (t.ownerToken == publicToken) {
            owner = "You";
          }
        }
        return Text(
            "Territory ${t.id} has ${t.armies} armies and is owned by ${owner}");
      },
    );
  }

  ListView _buildActionList(BuildContext context) {
    return ListView.builder(
        itemCount: rows.length,
        itemBuilder: (context, index) {
          final row = rows[index];
          return Container(
              height: 50,
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
                                  .map((territory) => territory.id.toString()));
                            } else if (action == "place") {
                              placeArmy(int.parse(buttonText), token, channel);
                              clear();
                            } else if (action == "attack" || action == "move") {
                              if (index == 1) {
                                fromTerritory = getTerritory(buttonText);
                                if (action == "attack") {
                                  // Show adjacent territories owned by other people
                                  rows.add(fromTerritory.neighbors
                                      .where((territory) =>
                                          territory.ownerToken != "" &&
                                          territory.ownerToken != publicToken)
                                      .map((territory) =>
                                          territory.id.toString()));
                                } else {
                                  // Show adjacent territories owned by you
                                  rows.add(fromTerritory.neighbors
                                      .where((territory) =>
                                          territory.ownerToken == publicToken)
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
        });
  }
}

Territory getTerritory(String id) {
  return game.territories
      .firstWhere((territory) => territory.id.toString() == id);
}