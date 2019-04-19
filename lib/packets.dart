import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'packets.dart';
import 'dart:convert' as JSON;
import 'main.dart';
import 'dart:async';

class Room {
  String roomName;
  String host;
  List<String> otherPlayers;

  Room(this.roomName, this.host, this.otherPlayers);
}

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

void leaveRoom(String roomId, String token, IOWebSocketChannel channel) {
  var packet = {
    "_type": "actors.LeaveRoom",
    "token": token,
    "roomId": roomId
  };
  channel.sink.add(JSON.jsonEncode(packet));
}

// import 'package:json_annotation/json_annotation.dart';
// https://flutter.dev/docs/development/data-and-backend/json