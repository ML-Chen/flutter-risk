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

/*
// import 'package:json_annotation/json_annotation.dart';
// https://flutter.dev/docs/development/data-and-backend/json

abstract class AuthenticatedMsg { String token; }

// Messages for which actor
abstract class RootMsg {}
abstract class AuthenticatedRootMsg extends RootMsg with AuthenticatedMsg {}

abstract class RoomMsg extends AuthenticatedMsg {
	String roomId;
	RoomMsg(this.roomId);
}
// Client tries to join room
class JoinRoom extends RoomMsg with SerializableInEvent {
	String roomId; String token;
	JoinRoom(this.roomId, this.token);
}
// Client marks themself ready
class ClientReady extends RoomMsg with SerializableInEvent {
	String roomId; String token;
	ClientReady(this.roomId, this.token);
}
class StartGame extends RoomMsg with SerializableInEvent {
	String roomId; String token;
	StartGame(this.roomId, this.token);
}
class LeaveRoom extends RoomMsg with SerializableInEvent {
	String roomId; String token;
	LeaveRoom(this.roomId, this.token);
}

class ForwardToGame extends AuthenticatedMsg with SerializableInEvent {
	String token; String gameId; GameMsg msg;
	ForwardToGame(this.token, this.gameId, this.msg);
}
class ForwardToChat extends AuthenticatedMsg with SerializableInEvent {
	String token; ChatMsg msg;
	ForwardToChat(this.token, this.msg);
}

class UserMessage extends OutEvent {
	String senderName; String publicToken; String message; String timeStamp;
	UserMessage(this.senderName, this.publicToken, this.timeStamp);
}
class RoomMessage extends OutEvent {
	String senderName; String message; String timeStamp;
	RoomMessage(this.senderName, this.message, this.timeStamp);
}

class NotifyGameStarted extends OutEvent {
	GameState state;
	NotifyGameStarted(this.state);
}
class SendMapResource extends OutEvent {
	MapResource resource;
	SendMapResource(this.resource);
}
class NotifyGameState extends OutEvent {
	GameState state;
	NotifyGameState(this.state);
}
class NotifyGameStart extends OutEvent {
	GameState state;
	NotifyGameStart(this.state);
}
class NotifyTurn extends OutEvent {
	String publicToken;
	NotifyTurn(this.publicToken);
}

// Messages that are sent to the client
abstract class OutEvent {}

class NotifyClientsChanged extends OutEvent {
	List<ClientBrief> strings;
	NotifyClientsChanged(this.strings);
}

class NotifyRoomsChanged extends OutEvent {
	List<RoomBrief> rooms;
	NotifyRoomsChanged(this.rooms);
}

class NotifyRoomStatus extends OutEvent {
	RoomStatus roomStatus;
	NotifyRoomStatus(this.roomStatus);
}

class Token extends OutEvent {
	String token; String publicToken;
	Token(this.token, this.publicToken);
}

class CreatedRoom extends OutEvent {
	String token;
	CreatedRoom(this.token);
}

class JoinedRoom extends OutEvent {
	String token; String playerToken;
	JoinedRoom(this.token, this.playerToken);
}

class NameCheckResult extends OutEvent {
	bool available; String name;
	NameCheckResult(this.available, this.name);
}

class NameAssignResult extends OutEvent {
	bool success; String name; String message = "";
	NameAssignResult(this.success, this.name);
}

class RoomCreationResult extends OutEvent {
	bool success; String message = "";
	RoomCreationResult(this.success);
}

class Ok extends OutEvent {
	String msg;
	Ok(this.msg);
}

class Err extends OutEvent {
	String msg;
	Err(this.msg);
}

class Ping extends OutEvent {
	String msg;
	Ping(this.msg);
}

class Kill extends OutEvent {
	String msg;
	Kill(this.msg);
}

// Messages which are read (including sent from ourself to ourself
abstract class InEvent {}

// Messages which are sent from the client, and can be deserialized
abstract class SerializableInEvent extends InEvent {}

// Client first connected, store ActorRef
class RegisterClient extends InEvent with RootMsg {
	Client client; ActorRef actor;
	RegisterClient(this.client, this.actor);
}

// Client sends token to "relogin", empty for new client
class SetToken extends InEvent with RootMsg {
	String oldToken; String newToken;
	SetToken(this.oldToken, this.newToken);
}

// KeepAlive to kill dead clients
class KeepAliveTick extends InEvent with RootMsg {}

// Client request to list rooms
class ListRoom extends AuthenticatedRootMsg with SerializableInEvent {
	String token;
	ListRoom(this.token);
}

// Client request to validate a name's availability
class CheckName extends AuthenticatedRootMsg with SerializableInEvent {
	String token; String name;
	CheckName(this.token, this.name);
}

// Client response to our ping
class Pong extends AuthenticatedRootMsg with SerializableInEvent {
	String token;
	Pong(this.token);
}

// Client tries to assign name
class AssignName extends AuthenticatedRootMsg with SerializableInEvent {
	String name; String token;
	AssignName(this.name, this.token);
}

// Client tries to create room
class CreateRoom extends AuthenticatedRootMsg with SerializableInEvent {
	String roomName; String token;
	CreateRoom(this.roomName, this.token);
}
*/