import 'package:flutter/material.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
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
// As of right now we're not really using joinedRoom for anything that we couldn't with joinedRoomBrief
Room joinedRoom;
var isReady = false;
Game game = Game(MapResource("", []), "", [], [], "", "");
var turn = ""; // the publicToken of whose turn it is
var turnPhase = "";

void main() async {
  // To find the IP of your server, type ipconfig in Command Prompt and look at Wireless LAN adapter Wi-Fi
  try {
    channel = IOWebSocketChannel.connect('ws://128.61.116.219:9000/ws');
    print("Connected to server");
  } catch (e) {
    print("Exception when connecting to server: " + e);
  }

  var subscription = channel.stream.listen((message) {
    print("Message received: " + message);
    Map<String, dynamic> msg = JSON.jsonDecode(message);
    switch (msg["_type"]) {
      case 'actors.Token':
        token = msg["token"];
        publicToken = msg["publicToken"];
        snackBarText = "Connected to server";
        showSnackBar = true;
        break;
      case 'actors.Ping':
        var pong = {
          "_type": "actors.Pong",
          "token": token
        };
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
          rooms.add(RoomBrief(room["name"], room["hostToken"], room["roomId"], room["numClients"]));
        }
        break;
      case 'actors.JoinedRoom':
        if (msg["playerToken"] == publicToken) {
          joinedRoom = Room(
            msg["name"],
            msg["hostToken"],
            msg["roomId"],
            msg["clientStatus"].map((clientStatus) => ClientStatus(clientStatus["name"], clientStatus["token"], clientStatus["publicToken"])));
          joinedRoomBrief = RoomBrief(msg["name"], msg["hostToken"], msg["roomId"], msg["clientStatus"].length);
        }
        break;
      case 'actors.NotifyClientsChanged':
        players = msg["players"];
        break;
      // TODO: not sure what NotifyRoomStatus is
      case 'actors.NotifyRoomStatus':
        // if (joinedRoom.roomId == msg["roomId"]) {
          joinedRoom.name = msg["roomName"];
          joinedRoom.clientStatus = msg["clientStatus"];
          joinedRoomBrief.name = msg["roomName"];
        // }
        break;
      case 'actors.NotifyGameStarted':
        game.map.viewBox = null;
        game.map.territories = null;
        game.phase = 'Setup';
        game.players = msg["players"];
        game.territories = msg["map"]["territories"];
        break;
      case 'actors.NotifyGameState':
        game.players = msg["players"];
        game.territories = msg["map"]["territories"];
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
      case 'actors.NotifyClientResumeStatus':
        if (msg["name"])
          yourName = msg["name"];
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
    return MaterialApp(
      title: "RISC!",
      theme: kDefaultTheme,
      home: HomePage()
    );
  }
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
  var snackBar = SnackBar(
    content: Text(snackBarText)
  );

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
              decoration: InputDecoration(
                labelText: 'Enter Name'
              ),
              onChanged: (text) {
                yourName = text;
                checkName(yourName, token, channel);
                // TODO: check whether snackBar is showing up correctly
                if (showSnackBar)  {
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
                if (nameIsValid == Maybe.Idk || nameIsValid == Maybe.False) return null;
                setName(yourName, token, channel);
                listRoom(token, channel);
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
    if (game.phase != "") {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => GamePage())
      );
    }

    return Scaffold(
      endDrawer: Drawer(
        child: ListView.builder(
          itemCount: players.length,
          itemBuilder: (context, index) {
            final item = players[index];
            if (item == yourName)
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
        itemCount: rooms.length,
        itemBuilder: (context, index) {
          final room = rooms[index];
          return ListTile(
            title: Text(room.name),
            subtitle: Text(room.numClients.toString() + " players"), 
            // ? Text("👑" + room.host) : Text("👑" + room.host + ", " + room.otherPlayers.join(", ")),
            trailing: Opacity(
              opacity: (joinedRoom == null || joinedRoomBrief == room) ? 1.0 : 0.0,
              child: FlatButton(
                // TODO: if you are the host, show START
                child: joinedRoomBrief == null || joinedRoomBrief.roomId != room.roomId ? const Text('JOIN') : const Text('READY'),
                onPressed: () {
                  if (joinedRoomBrief.roomId != room.roomId) { // Button shows JOIN
                    if (joinedRoomBrief != null)
                      leaveRoom(joinedRoomBrief.roomId, token, channel);
                    joinedRoomBrief = room;
                    print('requested join room $room.roomId $token $channel');
                    joinRoom(room.roomId, token, channel);
                  } else if (!isReady && room.numClients >= 3 && room.numClients < 6) { // Button shows READY
                  // TODO: READY button looks enabled even when there aren't enough players
                    clientReady(room.roomId, token, channel);
                    isReady = true;
                  } else {
                    return null;
                  }
                }
              )
            )
          );
        }
      )
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
                createRoom(tec.text, token, channel);
                // TODO: join room
                Navigator.pop(context);
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
https://www.didierboelens.com/2018/06/web-sockets---build-a-real-time-game/
https://medium.com/flutter-community/reactive-programming-streams-bloc-6f0d2bd2d248
*/