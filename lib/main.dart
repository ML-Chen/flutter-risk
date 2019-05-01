import 'dart:async';

import 'package:flutter/material.dart';
import 'package:web_socket_channel/io.dart';
import 'dart:convert' as JSON;
import 'packets.dart';
import 'classes.dart';
import 'game.dart';

enum Maybe { True, False, Idk }

IOWebSocketChannel channel;
var token = "";
var publicToken = "";
var snackBarText = "";
var showSnackBar = true;
var yourName = "";
var nameIsValid = Maybe.Idk;
var nameAssignResult = Maybe.Idk;
var players = [];
List<RoomBrief> rooms = [];
RoomBrief joinedRoomBrief;
Room joinedRoom;
var isReady = false;
Game game = Game(MapResource("", []), "", [], [], "", "");
var turn = ""; // the publicToken of whose turn it is
var turnPhase = "";

final StreamController<String> streamController =
    new StreamController<String>.broadcast();

void main() async {
  // To find the IP of your server, type ipconfig in Command Prompt and look at Wireless LAN adapter Wi-Fi IPv4 Address
  try {
    channel = IOWebSocketChannel.connect('ws://128.61.122.96:9000/ws');
    print("Connected to server");
  } catch (e) {
    print("Exception when connecting to server: " + e);
  }

  var subscription = channel.stream.listen((message) {
    print("Message received: " + message);
    streamController.add(message);
    Map<String, dynamic> msg = JSON.jsonDecode(message);
    switch (msg["_type"]) {
      case 'actors.Token':
        token = msg["token"];
        publicToken = msg["publicToken"];
        snackBarText = "Connected to server";
        showSnackBar = true;
        break;
      case 'actors.NotifyGameStarted':
        game.phase = 'Setup';
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
              obj["armies"], obj["ownerToken"], obj["neighbours"], obj["id"]);
          game.territories.add(tempTerritory);
        }
        break;
      case 'actors.Ping':
        var pong = {"_type": "actors.Pong", "token": token};
        channel.sink.add(JSON.jsonEncode(pong));
        break;
      case 'actors.NameCheckResult':
        if (msg["name"] == yourName) {
          nameIsValid = (msg["available"]) ? Maybe.True : Maybe.False;
        }
        break;
      case 'actors.NameAssignResult':
        if (msg["name"] == yourName)
          nameAssignResult = (msg["success"]) ? Maybe.True : Maybe.False;
        break;
      case 'actors.NotifyClientsChanged':
        players = [];
        for (var clientBrief in msg["strings"]) {
          players.add(clientBrief["name"]);
        }
        break;
      case 'actors.JoinedRoom':
        if (msg["playerToken"] == publicToken) {
          joinedRoom = Room('', '', msg["token"], []);
          joinedRoomBrief = RoomBrief('', '', msg["token"], 0);
        }
        break;
      case 'actors.NotifyClientsChanged':
        players = msg["players"];
        break;
      case 'actors.NotifyRoomStatus':
        List<ClientStatus> temp;
        msg["roomStatus"]["clientStatus"].map((clientStatus) => temp.add(
            ClientStatus(clientStatus["name"], clientStatus["publicToken"])));
        joinedRoom = Room(msg["roomStatus"]["name"],
            msg["roomStatus"]["hostName"], msg["roomStatus"]["roomId"], temp);
        //Not essential on mobile
        break;
      case 'actors.NotifyClientResumeStatus':
        if (msg["name"]) yourName = msg["name"];
        // TODO: consider refactoring yourName to displayName: { name: '', valid: null, committed: false }
        if (msg["room"]) {
          if (joinedRoom == null) {
            // TODO: I'm pretty unsure about what exactly the msg here should be
            joinedRoom = Room(null, null, msg["room"], null);
          } else {
            joinedRoom.roomId = msg["room"];
          }
        }
        break;
      case 'actors.Err':
        snackBarText = "Error from server";
        showSnackBar = true;
        break;
      default:
        print("Default case message: " + message);
    }
  });

  runApp(new RiskApp());
}

class RiskApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(title: "RISC!", theme: kDefaultTheme, home: HomePage());
  }
}

final ThemeData kDefaultTheme = new ThemeData(
    primarySwatch: Colors.blue,
    accentColor: Colors.purpleAccent[400],
    brightness: Brightness.dark);

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var snackBar = SnackBar(content: Text(snackBarText));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
            child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                children: <Widget>[
          SizedBox(height: 40.0),
          Column(children: <Widget>[
            // Image.asset('assets/login_icon.png'),
            SizedBox(height: 40.0),
            Text(
                'RISC!',
                style: DefaultTextStyle.of(context).style.apply(fontSizeFactor: 2)
            )
          ]),
          SizedBox(height: 40.0),
          TextField(
            decoration: InputDecoration(labelText: 'Enter Name'),
            onChanged: (text) {
              yourName = text;
              checkName(yourName, token, channel);
              // TODO: check whether snackBar is showing up correctly
              if (showSnackBar) {
                showSnackBar = false;
                // Scaffold.of(context).showSnackBar(snackBar);
              }
            },
            // See https://flutter.dev/docs/cookbook/forms/validation – we'd need to change this from a TextField to a TextFormField
            // validator: (value) {
            //   if (value.isEmpty) {
            //     return 'Please enter some text';
            //   } else if (nameIsValid == Maybe.False) {
            //     return 'That name is already taken';
            //   }
            // }
          ),
          SizedBox(height: 12.0), // spacer
          RaisedButton(
              child: Text('START'),
              onPressed: () {
                if (nameIsValid == Maybe.Idk || nameIsValid == Maybe.False)
                  return null;
                setName(yourName, token, channel);
                listRoom(token, channel);
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => LobbyPage()));
              })
        ])));
  }
}

class LobbyPage extends StatefulWidget {
  @override
  State createState() => _LobbyPageState();
}

class _LobbyPageState extends State<LobbyPage> {
  @override
  void initState() {
    streamController.stream.listen((message) {
      Map<String, dynamic> msg = JSON.jsonDecode(message);
      setState(() {});
      switch (msg["_type"]) {
        case 'actors.CreatedRoom':
          snackBarText = "Room created";
          showSnackBar = true;
          break;
        case 'actors.RoomCreationResult':
          snackBarText = "Room creation failed";
          showSnackBar = true;
          break;
        case 'actors.NotifyRoomsChanged':
          rooms = [];
          for (var room in msg["rooms"]) {
            rooms.add(RoomBrief(room["name"], room["hostToken"], room["roomId"],
                room["numClients"]));
          }
          break;
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return game.phase == ""
        ? Scaffold(
            endDrawer: Drawer(
                child: ListView.builder(
                    itemCount: players.length,
                    itemBuilder: (context, index) {
                      final item = players[index];
                      if (item == yourName)
                        return ListTile(
                            title: Text(item), subtitle: Text("(me)"));
                      else
                        return ListTile(title: Text(item));
                    })),
            appBar: AppBar(title: Text('Rooms'), actions: <Widget>[
              Builder(
                  builder: (context) => IconButton(
                      icon: Icon(Icons.people),
                      onPressed: () => Scaffold.of(context).openEndDrawer(),
                      tooltip: 'Players')),
              IconButton(
                  icon: Icon(Icons.add),
                  tooltip: 'Create Room',
                  onPressed: () => _createRoomDialog(context))
            ]),
            body: ListView.builder(
                itemCount: rooms.length,
                itemBuilder: (context, index) {
                  final room = rooms[index];
                  return ListTile(
                      title: Text(room.name),
                      subtitle: Text(room.numClients.toString() + " players"),
                      // ? Text("👑" + room.host) : Text("👑" + room.host + ", " + room.otherPlayers.join(", ")),
                      trailing: Opacity(
                          opacity: 1.0,
                          child: FlatButton(
                              // TODO: if you are the host, show START
                              child: joinedRoomBrief == null ||
                                      joinedRoomBrief.roomId != room.roomId
                                  ? const Text('JOIN')
                                  : ((!isReady)
                                      ? const Text('READY')
                                      : const Text('Waiting')),
                              onPressed: () {
                                if (joinedRoomBrief == null ||
                                    joinedRoomBrief.roomId != room.roomId) {
                                  if (joinedRoomBrief != null)
                                    leaveRoom(
                                        joinedRoomBrief.roomId, token, channel);
                                  joinedRoomBrief = room;
                                  print(
                                      'requested join room $room.roomId $token $channel');
                                  joinRoom(room.roomId, token, channel);
                                } else if (!isReady) {
                                  // TODO: READY button looks enabled even when there aren't enough players
                                  clientReady(room.roomId, token, channel);
                                  isReady = true;
                                } else {
                                  return null;
                                }
                              })));
                }))
        : GamePage();
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
                        decoration: InputDecoration(hintText: 'Room name')))
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
                    createRoom(tec.text, token, channel);
                    // TODO: join room
                    Navigator.pop(context);
                  })
            ]);
      });
}

class GamePage extends StatefulWidget {
  @override
  _GamePageState createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  // TODO: show place only when you have armies to place
  /*var rows = [
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
  }*/

  final _tec = TextEditingController();
  bool _commandSeemsValid = false;

  @override
  void initState() {
    print("game.dart initState() called");
    streamController.stream.listen((message) {
      print("game received message: " + message);
      Map<String, dynamic> msg = JSON.jsonDecode(message);
      setState(() {});
      switch (msg["_type"]) {
        case 'actors.Ping':
          var pong = {"_type": "actors.Pong", "token": token};
          channel.sink.add(JSON.jsonEncode(pong));
          break;
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
                obj["armies"], obj["ownerToken"], obj["neighbours"], obj["id"]);
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
                obj["armies"], obj["ownerToken"], obj["neighbours"], obj["id"]);
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
            child: ListView(children: <Widget>[
              Container(
                  height: MediaQuery.of(context).size.height * 0.1,
                  child: _buildCommandPrompt(context)),
              Container(
                  height: MediaQuery.of(context).size.height * 0.3,
                  child: _buildTerritoryList(context)),
              // Container(
              //     height: MediaQuery.of(context).size.height * 0.4,
              //     child: Image.asset('assets/map.png'),
              // )
              // Container(
              //     height: MediaQuery.of(context).size.height * 0.35,
              //     child: _buildActionList(context)),
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
            "Territory ${t.id}: ${t.armies} armies, owned by ${owner}",
            style: DefaultTextStyle.of(context).style.apply(fontSizeFactor: 1.2)
        );
      },
    );
  }

  /*ListView _buildActionList(BuildContext context) {
    return ListView.builder(
        itemCount: rows.length,
        itemBuilder: (context, index) {
          final row = rows[index];
          return Container(
              height: 50,
              child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: row.length,
                  itemBuilder: (context, j) {
                    final buttonText = row[j];
                    if (buttonText == selectedButtons[index]) {
                      // TODO: return a selected-looking FlatButton
                    } else {
                      return FlatButton(
                          child: Text(buttonText),
                          onPressed: () {
                            selectedButtons[index] = buttonText;
                            // TODO: rows is literally not changing, even though buttons are disappearing
                            print("rows: " + rows.toString());
                            print("All territories: " + game.territories.toString());
                            // TODO: possibly clear the later indices too
                            // rows = rows.sublist(0, index + 1);
                            if (action == "place") {
                              if (index == 0) {
                                if (game.phase == "Setup") {
                                  // Show all territories not already occupied
                                  rows.add(game.territories
                                    .where((territory) =>
                                        territory.ownerToken == "")
                                    .map((territory) => territory.id.toString()));
                                } else {
                                  // Show territories you own
                                  rows.add(game.territories
                                    .where((territory) =>
                                        territory.ownerToken == "")
                                    .map((territory) => territory.id.toString()));
                                }
                              } else {
                                placeArmy(int.parse(buttonText), token, channel);
                                clear();
                              }
                            } else if (action == "attack" || action == "move") {
                              if (index == 0) {
                                // Show territories you own
                                rows.add(game.territories
                                    .where((territory) =>
                                        territory.ownerToken == publicToken)
                                    .map((territory) => territory.id.toString()));
                              } else if (index == 1) {
                                fromTerritory = getTerritory(buttonText);
                                if (action == "attack") {
                                  // Show adjacent territories owned by other people
                                  rows.add(fromTerritory.neighbours
                                      .where((territory) =>
                                          territory.ownerToken != "" &&
                                          territory.ownerToken != publicToken)
                                      .map((territory) =>
                                          territory.id.toString()));
                                } else {
                                  // Show adjacent territories owned by you
                                  rows.add(fromTerritory.neighbours
                                      .where((territory) =>
                                          territory.ownerToken == publicToken)
                                      .map((territory) =>
                                          territory.id.toString()));
                                }
                              } else if (index == 2) {
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
  }*/

  Row _buildCommandPrompt(BuildContext context) {
    return Row(children: <Widget>[
      Flexible(
        child: TextField(
          autofocus: true,
          controller: _tec,
          onChanged: (text) {
            setState(() {
              _commandSeemsValid = _tec.text.contains("place") || _tec.text.contains("Place") || _tec.text.contains("move") || _tec.text.contains("Move") || _tec.text.contains("attack") || _tec.text.contains("Attack");
            });
          },
          decoration: InputDecoration(labelText: 'e.g., "place 2", "move 2 3 2", "attack 4 5 3"'),
        )
      ),
      Container(
        margin: EdgeInsets.symmetric(horizontal: 4.0),
        child: IconButton(
          icon: Icon(Icons.send),
          onPressed: () => _commandSeemsValid ? _handleCommand(_tec.text) : null
        )
      )
    ]);
  }

  void _handleCommand(String command) {
    final args = command.split(" ");
    print(args);
    if (args[0] == "place" || args[0] == "Place") {
      int territoryId = int.parse(args[1]);
      placeArmy(territoryId, joinedRoomBrief.roomId, token, channel);
    } else if (args[0] == "move" || args[0] == "Move") {
      int territoryFrom = int.parse(args[1]);
      int territoryTo = int.parse(args[2]);
      int armyCount = int.parse(args[3]);
      moveArmy(territoryFrom, territoryTo, armyCount, joinedRoomBrief.roomId, token, channel);
    } else if (args[0] == "attack" || args[0] == "Attack") {
      int territoryFrom = int.parse(args[1]);
      int territoryTo = int.parse(args[2]);
      int armyCount = int.parse(args[3]);
      attackTerritory(territoryFrom, territoryTo, armyCount, joinedRoomBrief.roomId, token, channel);
    }
    _tec.clear();
  }
}

Territory getTerritory(String id) {
  return game.territories
      .firstWhere((territory) => territory.id.toString() == id);
}

/* References
https://github.com/flutter/flutter/issues/19606
https://stackoverflow.com/questions/51957960/how-to-change-the-enddrawer-icon-in-flutter
https://flutter.dev/docs/cookbook/design/drawer
https://flutter.dev/docs/cookbook/lists/mixed-list
https://flutter.dev/docs/cookbook/forms/retrieve-input
https://flutter.dev/docs/cookbook/networking/web-sockets
https://www.didierboelens.com/2018/06/web-sockets---build-a-real-time-game/
https://medium.com/flutter-community/reactive-programming-streams-bloc-6f0d2bd2d248
*/