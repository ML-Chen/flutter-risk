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

void createRoom(String roomId) {

}

// import 'package:json_annotation/json_annotation.dart';
// https://flutter.dev/docs/development/data-and-backend/json