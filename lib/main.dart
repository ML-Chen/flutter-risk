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
                                } else {
                                  if (room.hostToken == publicToken)
                                    startGame(room.roomId, token, channel);
                                  if (!isReady) {
                                    // TODO: READY button looks enabled even when there aren't enough players
                                    clientReady(room.roomId, token, channel);
                                    isReady = true;
                                  }
                                }
                              })));
                }))
        : GamePage();
  }
}

void _createRoomDialog(BuildContext context) {
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
