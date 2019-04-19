import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'dart:convert' as JSON;
import 'dart:async';

class Room {
  String roomName;
  String host;
  List<String> otherPlayers;

  Room(this.roomName, this.host, this.otherPlayers);
}

class Player {
  String name;
  int unitCount;
  // ClientWithActor client;
}

class GameState {
  List<Player> players;
  GameMap map; // GameMap is called Map in our backend
  // GamePhase gamePhase;

  GameState(this.players, this.map);
}

class GameMap {
  List<Territory> territories;
  double interval; // of FiniteDuration type in backend
  MapResource resource;

  GameMap(this.territories, this.interval, this.resource);
}

class MapResource {
  String viewBox;
  List<String> territories;

  MapResource(this.viewBox, this.territories);
}

// See also: Map, MapResource, etc.

void checkName(String name, String token, IOWebSocketChannel channel) {
  var packet = {
    "_type": "actors.CheckName",
    "token": token,
    "name": name
  };
  channel.sink.add(JSON.jsonEncode(packet));
}

void setName(String name, String token, IOWebSocketChannel channel) {
  var packet = {
    "_type": "actors.AssignName",
    "token": token,
    "name": name
  };
  channel.sink.add(JSON.jsonEncode(packet));
}

// Request to list rooms
void listRoom(String token, IOWebSocketChannel channel) {
  var packet = {
    "_type": "actors.ListRoom",
    "token": token
  };
  channel.sink.add(JSON.jsonEncode(packet));
}

class RoomStatus {
  String roomName;
  String roomId;
  String clientStatus;
}

void roomStatusUpdate(RoomStatus roomStatus, String token, IOWebSocketChannel channel) {
  var packet = {
    "_type": "actors.NotifyRoomsChanged",
    "token": token,
    "roomName": roomStatus.roomName,
    "roomId": roomStatus.roomId,
    "clientStatus": roomStatus.clientStatus
  };
  channel.sink.add(JSON.jsonEncode(packet));
}

// TODO: figure out why notifyClientResumeStatus() is in packets.js but not the backend

void createRoom(String roomName, String token, IOWebSocketChannel channel) {
  var packet = {
    "_type": "actors.CreateRoom",
    "token": token,
    "roomName": roomName
  };
  channel.sink.add(JSON.jsonEncode(packet));
}

void joinRoom(String roomId, String token, IOWebSocketChannel channel) {
  var packet = {
    "_type": "actors.CreateRoom",
    "token": token,
    "roomId": roomId
  };
  channel.sink.add(JSON.jsonEncode(packet));
}

void leaveRoom(String roomId, String token, IOWebSocketChannel channel) {
  var packet = {
    "_type": "actors.LeaveRoom",
    "token": token,
    "roomId": roomId
  };
  channel.sink.add(JSON.jsonEncode(packet));
}

void clientReady(String roomId, String token, IOWebSocketChannel channel) {
  var packet = {
    "_type": "actors.ClientReady",
    "token": token,
    "roomId": roomId
  };
  channel.sink.add(JSON.jsonEncode(packet));
}

void startGame(String roomId, String token, IOWebSocketChannel channel) {
  var packet = {
    "_type": "actors.StartGame",
    "token": token,
    "roomId": roomId
  };
  channel.sink.add(JSON.jsonEncode(packet));
}

void placeArmy(int territoryId, String token, IOWebSocketChannel channel) {
  var packet = {
    "_type": "actors.PlaceArmy",
    "token": token,
    "territoryId": territoryId
  };
  channel.sink.add(JSON.jsonEncode(packet));
}

void attackTerritory(int fromTerritoryId, int toTerritoryId, int armyCount, String token, IOWebSocketChannel channel) {
  var packet = {
    "_type": "actors.AttackTerritory",
    "token": token,
    "fromTerritoryId": fromTerritoryId,
    "toTerritoryId": toTerritoryId,
    "armyCount": armyCount
  };
  channel.sink.add(JSON.jsonEncode(packet));
}

void moveArmy(int armyCount, int territoryFrom, int territoryTo, String token, IOWebSocketChannel channel) {
  var packet = {
    "_type": "actors.MoveArmy",
    "token": token,
    "fromTerritoryId": territoryFrom,
    "toTerritoryId": territoryTo,
    "armyCount": armyCount
  };
  channel.sink.add(JSON.jsonEncode(packet));
}

// https://flutter.dev/docs/development/data-and-backend/json