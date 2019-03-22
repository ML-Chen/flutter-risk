import 'package:json_annotation/json_annotation.dart';
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
	Boolean available; String name;
	NameCheckResult(this.available, this.name);
}

class NameAssignResult extends OutEvent {
	Boolean success; String name; String message = "";
	NameAssignResult(this.success, this.name);
}

class RoomCreationResult extends OutEvent {
	Boolean success; String message = "";
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

/*
class SerializableInEvent {
  static final SerializableInEvent _singleton = new MyClass._internal();

  factory SerializableInEvent() {
    return _singleton;
  }

	var assignNameRead = Json.reads[AssignName];
  var joinRoomRead = Json.reads[JoinRoom];
  var createRoomRead = Json.reads[CreateRoom];
  var readyRead = Json.reads[ClientReady];
  var startGameRead = Json.reads[StartGame];
  var pongRead = Json.reads[Pong];
  var listRoomRead = Json.reads[ListRoom];
  var checkNameRead = Json.reads[CheckName];
  var leaveRoomRead = Json.reads[LeaveRoom];
  var gameMsgRead = SerializableGameMsg.gameMsgRead;
  var chatMsgRead = SerializableChatMsg.chatMsgRead;
  var forwardToGameRead = Json.reads[ForwardToGame];
  var forwardToChatRead = Json.reads[ForwardToChat];
  var serializableInEventRead = Json.reads[SerializableInEvent];
}

object OutEvent {
  var notifyClientsChangedWrite = Json.writes[NotifyClientsChanged]
  var notifyRoomsChangedWrite = Json.writes[NotifyRoomsChanged]
  var notifyRoomStatusWrite = Json.writes[NotifyRoomStatus]
  var tokenWrite = Json.writes[Token]
  var okWrite = Json.writes[Ok]
  var createdRoomWrite = Json.writes[CreatedRoom]
  var joinedRoomWrite = Json.writes[JoinedRoom]
  var pingWrite = Json.writes[Ping]
  var errWrite = Json.writes[Err]
  var killWrite = Json.writes[Kill]
  var userMessageWrite = Json.writes[UserMessage]
  var roomMessageWrite = Json.writes[RoomMessage]
  var nameCheckResultWrite = Json.writes[NameCheckResult]
  var nameAssignResultWrite = Json.writes[NameAssignResult]
  var roomCreationResult = Json.writes[RoomCreationResult]
  var sendMapResourceWrite = Json.writes[SendMapResource]

  var notifyGameStateWrite = Json.writes[NotifyGameState]
  var notifyGameStartedWrite = Json.writes[NotifyGameStarted]
  var notifyGameStartWrite = Json.writes[NotifyGameStart]
  var notifyTurnWrite = Json.writes[NotifyTurn]

  var outEventFormat = Json.writes[OutEvent]
  var messageFlowTransformer = MessageFlowTransformer.jsonMessageFlowTransformer[SerializableInEvent, OutEvent]
}
*/