import 'package:web_socket_channel/io.dart';
import 'dart:convert' as JSON;
import 'classes.dart';

void checkName(String name, String token, IOWebSocketChannel channel) {
  var packet = {"_type": "actors.CheckName", "token": token, "name": name};
  channel.sink.add(JSON.jsonEncode(packet));
}

void setName(String name, String token, IOWebSocketChannel channel) {
  var packet = {"_type": "actors.AssignName", "token": token, "name": name};
  channel.sink.add(JSON.jsonEncode(packet));
}

// Request to list rooms
void listRoom(String token, IOWebSocketChannel channel) {
  var packet = {"_type": "actors.ListRoom", "token": token};
  channel.sink.add(JSON.jsonEncode(packet));
}

void roomStatusUpdate(
    RoomStatus roomStatus, String token, IOWebSocketChannel channel) {
  var packet = {
    "_type": "actors.RoomStatusUpdate",
    "token": token,
    "roomName": roomStatus.roomName,
    "roomId": roomStatus.roomId,
    "clientStatus": roomStatus.clientStatus
  };
  channel.sink.add(JSON.jsonEncode(packet));
}

void createRoom(String roomName, String token, IOWebSocketChannel channel) {
  var packet = {
    "_type": "actors.CreateRoom",
    "token": token,
    "roomName": roomName
  };
  channel.sink.add(JSON.jsonEncode(packet));
}

void joinRoom(String roomId, String token, IOWebSocketChannel channel) {
  var packet = {"_type": "actors.JoinRoom", "token": token, "roomId": roomId};
  channel.sink.add(JSON.jsonEncode(packet));
}

void leaveRoom(String roomId, String token, IOWebSocketChannel channel) {
  var packet = {"_type": "actors.LeaveRoom", "token": token, "roomId": roomId};
  channel.sink.add(JSON.jsonEncode(packet));
}

void clientReady(String roomId, String token, IOWebSocketChannel channel) {
  var packet = {
    "_type": "actors.ClientReady",
    "token": token,
    "roomId": roomId,
    "ready": true
  };
  channel.sink.add(JSON.jsonEncode(packet));
}

void startGame(String roomId, String token, IOWebSocketChannel channel) {
  var packet = {"_type": "actors.StartGame", "token": token, "roomId": roomId};
  channel.sink.add(JSON.jsonEncode(packet));
}

void placeArmy(int territoryId, String gameId, String token, IOWebSocketChannel channel) {
  var packet = {
    "_type": "actors.ForwardToGame",
    "token": token,
    "gameId": gameId, // room id of joined room
    "msg": {
      "_type": "actors.PlaceArmy",
      "token": token,
      "territoryId": territoryId
    }
  };
  channel.sink.add(JSON.jsonEncode(packet));
}

void attackTerritory(int fromTerritoryId, int toTerritoryId, int armyCount, String gameId,
    String token, IOWebSocketChannel channel) {
  var packet = {
    "_type": "actors.ForwardToGame",
    "token": token,
    "gameId": gameId,
    "msg": {
      "_type": "actors.AttackTerritory",
      "token": token,
      "fromTerritoryId": fromTerritoryId,
      "toTerritoryId": toTerritoryId,
      "armyCount": armyCount
    }
  };
  channel.sink.add(JSON.jsonEncode(packet));
}

void moveArmy(int fromTerritoryId, int toTerritoryId, int armyCount, String gameId, String token,
    IOWebSocketChannel channel) {
  var packet = {
    "_type": "actors.ForwardToGame",
    "token": token,
    "gameId": gameId,
    "msg": {
      "_type": "actors.MoveArmy",
      "token": token,
      "fromTerritoryId": fromTerritoryId,
      "toTerritoryId": toTerritoryId,
      "armyCount": armyCount
    }
  };
  channel.sink.add(JSON.jsonEncode(packet));
}

// https://flutter.dev/docs/development/data-and-backend/json