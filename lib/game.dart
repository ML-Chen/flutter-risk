import 'package:flutter/material.dart';
import 'main.dart';
import 'dart:convert' as JSON;
import 'packets.dart';
import 'classes.dart';

// class GamePage extends StatefulWidget {
//   @override
//   _GamePageState createState() => _GamePageState();
// }

// class _GamePageState extends State<GamePage> {
//   // TODO: show place only when you have armies to place
//   /*var rows = [
//     ["place", "attack", "move"]
//   ]; // list of rows of text of buttons
//   var selectedButtons = [
//     "",
//     "",
//     "",
//     ""
//   ]; // text corresponding to buttons in each row that have been pressed
//   String action = "";
//   Territory fromTerritory;
//   Territory toTerritory;
//   int armyCount;

//   var snackBar = SnackBar(content: Text(""));

//   void clear() {
//     rows = [
//       ["place", "attack", "move"]
//     ];
//     selectedButtons = ["", "", "", ""];
//     action = "";
//     fromTerritory = null;
//     toTerritory = null;
//     armyCount = 0;
//   }*/

//   final _tec = TextEditingController();
//   bool _commandSeemsValid = false;

//   @override
//   void initState() {
//     print("game.dart initState() called");
//     streamController.stream.listen((message) {
//       print("game received message: " + message);
//       Map<String, dynamic> msg = JSON.jsonDecode(message);
//       setState(() {});
//       switch (msg["_type"]) {
//         case 'actors.Ping':
//           var pong = {"_type": "actors.Pong", "token": token};
//           channel.sink.add(JSON.jsonEncode(pong));
//           break;
//         case 'actors.NotifyGameStarted':
//           game.map.viewBox = null;
//           game.map.territories = null;
//           game.phase = 'Setup';
//           List<dynamic> temp = msg["state"]["players"];
//           for (dynamic obj in temp) {
//             Player tempPlayer = new Player();
//             tempPlayer.name = obj["name"];
//             tempPlayer.unitCount = obj["unitCount"];
//             game.players.add(tempPlayer);
//           }
//           temp = msg["state"]["map"]["territories"];
//           for (dynamic obj in temp) {
//             Territory tempTerritory = new Territory(
//                 obj["armies"], obj["ownerToken"], obj["neighbours"], obj["id"]);
//             game.territories.add(tempTerritory);
//           }
//           break;
//         case 'actors.NotifyGameState':
//           List<dynamic> temp = msg["state"]["players"];
//           for (dynamic obj in temp) {
//             Player tempPlayer = new Player();
//             tempPlayer.name = obj["name"];
//             tempPlayer.unitCount = obj["unitCount"];
//             game.players.add(tempPlayer);
//           }
//           temp = msg["state"]["map"]["territories"];
//           for (dynamic obj in temp) {
//             Territory tempTerritory = new Territory(
//                 obj["armies"], obj["ownerToken"], obj["neighbours"], obj["id"]);
//             game.territories.add(tempTerritory);
//           }
//           print(game.territories.length);
//           break;
//         case 'actors.NotifyGamePhaseStart':
//           game.phase = 'Realtime';
//           break;
//         case 'actors.SendMapResource':
//           game.map.viewBox = msg["viewBox"];
//           game.map.territories = msg["territories"];
//           break;
//         case 'actors.NotifyTurn':
//           turn = msg["publicToken"];
//           turnPhase = msg["turnPhase"];
//           break;
//         case 'actors.NotifyNewArmies':
//           snackBarText = "You got $msg['newArmies'] new armies.";
//           showSnackBar = true;
//           break;
//       }
//     });
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         appBar: AppBar(title: Text('Game')),
//         body: Container(
//             height: MediaQuery.of(context).size.height,
//             child: Column(children: <Widget>[
//               Container(
//                   height: MediaQuery.of(context).size.height * 0.15,
//                   child: _buildCommandPrompt(context)),
//               Container(
//                   height: MediaQuery.of(context).size.height * 0.3,
//                   child: _buildTerritoryList(context)),
//               // Image.asset('assets/map.png'),
//               // Container(
//               //     height: MediaQuery.of(context).size.height * 0.35,
//               //     child: _buildActionList(context)),
//             ])));
//   }

//   ListView _buildTerritoryList(BuildContext context) {
//     //TODO: fix redraw of game state
//     return ListView.builder(
//       itemCount: game.territories.length,
//       itemBuilder: (context, index) {
//         Territory t = game.territories[index];
//         String owner = '';
//         if (t.ownerToken == '') {
//           owner = "No one";
//         } else {
//           if (joinedRoom.clientStatus != null) {
//             for (ClientStatus player in joinedRoom.clientStatus) {
//               if (t.ownerToken == player.publicToken) {
//                 owner = player.name;
//               }
//             }
//           } else {
//             print("Client status is null");
//           }

//           if (t.ownerToken == publicToken) {
//             owner = "You";
//           }
//         }
//         return Text(
//             "Territory ${t.id}: ${t.armies} armies, owned by ${owner}",
//             style: DefaultTextStyle.of(context).style.apply(fontSizeFactor: 1.2)
//         );
//       },
//     );
//   }

//   /*ListView _buildActionList(BuildContext context) {
//     return ListView.builder(
//         itemCount: rows.length,
//         itemBuilder: (context, index) {
//           final row = rows[index];
//           return Container(
//               height: 50,
//               child: ListView.builder(
//                   scrollDirection: Axis.horizontal,
//                   itemCount: row.length,
//                   itemBuilder: (context, j) {
//                     final buttonText = row[j];
//                     if (buttonText == selectedButtons[index]) {
//                       // TODO: return a selected-looking FlatButton
//                     } else {
//                       return FlatButton(
//                           child: Text(buttonText),
//                           onPressed: () {
//                             selectedButtons[index] = buttonText;
//                             // TODO: rows is literally not changing, even though buttons are disappearing
//                             print("rows: " + rows.toString());
//                             print("All territories: " + game.territories.toString());
//                             // TODO: possibly clear the later indices too
//                             // rows = rows.sublist(0, index + 1);
//                             if (action == "place") {
//                               if (index == 0) {
//                                 if (game.phase == "Setup") {
//                                   // Show all territories not already occupied
//                                   rows.add(game.territories
//                                     .where((territory) =>
//                                         territory.ownerToken == "")
//                                     .map((territory) => territory.id.toString()));
//                                 } else {
//                                   // Show territories you own
//                                   rows.add(game.territories
//                                     .where((territory) =>
//                                         territory.ownerToken == "")
//                                     .map((territory) => territory.id.toString()));
//                                 }
//                               } else {
//                                 placeArmy(int.parse(buttonText), token, channel);
//                                 clear();
//                               }
//                             } else if (action == "attack" || action == "move") {
//                               if (index == 0) {
//                                 // Show territories you own
//                                 rows.add(game.territories
//                                     .where((territory) =>
//                                         territory.ownerToken == publicToken)
//                                     .map((territory) => territory.id.toString()));
//                               } else if (index == 1) {
//                                 fromTerritory = getTerritory(buttonText);
//                                 if (action == "attack") {
//                                   // Show adjacent territories owned by other people
//                                   rows.add(fromTerritory.neighbours
//                                       .where((territory) =>
//                                           territory.ownerToken != "" &&
//                                           territory.ownerToken != publicToken)
//                                       .map((territory) =>
//                                           territory.id.toString()));
//                                 } else {
//                                   // Show adjacent territories owned by you
//                                   rows.add(fromTerritory.neighbours
//                                       .where((territory) =>
//                                           territory.ownerToken == publicToken)
//                                       .map((territory) =>
//                                           territory.id.toString()));
//                                 }
//                               } else if (index == 2) {
//                                 toTerritory = getTerritory(buttonText);
//                                 // Show possible armyCounts
//                                 rows.add(new List<int>.generate(
//                                         fromTerritory.armies, (i) => i + 1)
//                                     .map((num) => num.toString()));
//                               } else {
//                                 armyCount = int.parse(buttonText);
//                                 if (action == "attack")
//                                   attackTerritory(
//                                       fromTerritory.id,
//                                       toTerritory.id,
//                                       armyCount,
//                                       token,
//                                       channel);
//                                 else
//                                   moveArmy(fromTerritory.id, toTerritory.id,
//                                       armyCount, token, channel);
//                                 clear();
//                               }
//                             }
//                           });
//                     }
//                   }));
//         });
//   }*/

//   Row _buildCommandPrompt(BuildContext context) {
//     return Row(children: <Widget>[
//       Flexible(
//         child: TextField(
//           autofocus: true,
//           controller: _tec,
//           onChanged: (text) {
//             setState(() {
//               _commandSeemsValid = _tec.text.contains("place") || _tec.text.contains("Place") || _tec.text.contains("move") || _tec.text.contains("Move") || _tec.text.contains("attack") || _tec.text.contains("Attack");
//             });
//           },
//           decoration: InputDecoration(labelText: 'e.g., "place 2", "move 2 3 2", "attack 4 5 3"'),
//         )
//       ),
//       Container(
//         margin: EdgeInsets.symmetric(horizontal: 4.0),
//         child: IconButton(
//           icon: Icon(Icons.send),
//           onPressed: () => _commandSeemsValid ? _handleCommand(_tec.text) : null
//         )
//       )
//     ]);
//   }

//   void _handleCommand(String command) {
//     final args = command.split(" ");
//     print(args);
//     if (args[0] == "place" || args[0] == "Place") {
//       int territoryId = int.parse(args[1]);
//       placeArmy(territoryId, token, channel);
//       for (int i = 1; i <= 11; i++) {
//         placeArmy(i, token, channel);
//       }
//       checkName("checking a name", token, channel);
//     } else if (args[0] == "move" || args[0] == "Move") {
//       int territoryFrom = int.parse(args[1]);
//       int territoryTo = int.parse(args[2]);
//       int armyCount = int.parse(args[3]);
//       moveArmy(territoryFrom, territoryTo, armyCount, token, channel);
//     } else if (args[0] == "attack" || args[0] == "Attack") {
//       int territoryFrom = int.parse(args[1]);
//       int territoryTo = int.parse(args[2]);
//       int armyCount = int.parse(args[3]);
//       attackTerritory(territoryFrom, territoryTo, armyCount, token, channel);
//     }
//     _tec.clear();
//   }
// }

// Territory getTerritory(String id) {
//   return game.territories
//       .firstWhere((territory) => territory.id.toString() == id);
// }