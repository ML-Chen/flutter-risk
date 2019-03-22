abstract class AuthenticatedMsg { String token; }

// Messages for which actor
abstract class RootMsg
abstract class AuthenticatedRootMsg extends RootMsg with AuthenticatedMsg

abstract class RoomMsg extends AuthenticatedMsg { String roomId }
// Client tries to join room
class JoinRoom extends RoomMsg with SerializableInEvent {
	String roomId, String token;
	JoinRoom(this.roomId, this.token);
}
// Client marks themself ready
class ClientReady extends RoomMsg with SerializableInEvent {
	String roomId, String token;
	ClientReady(this.roomId, this.token);
}
class StartGame extends RoomMsg with SerializableInEvent {
	String roomId, String token;
	StartGame(this.roomId, this.token);
}
class LeaveRoom extends RoomMsg with SerializableInEvent {
	String roomId, String token;
	LeaveRoom(this.roomId, this.token);
}

class ForwardToGame(String token, String gameId, GameMsg msg) extends AuthenticatedMsg with SerializableInEvent
class ForwardToChat(String token, ChatMsg msg) extends AuthenticatedMsg with SerializableInEvent

class UserMessage(String senderName, String publicToken, String message, String timeStamp) extends OutEvent
class RoomMessage(String senderName, String message, String timeStamp) extends OutEvent

class NotifyGameStarted(GameState state) extends OutEvent
class SendMapResource(MapResource resource) extends OutEvent
class NotifyGameState(GameState state) extends OutEvent
class NotifyGameStart(GameState state) extends OutEvent
class NotifyTurn(String publicToken) extends OutEvent

// Messages that are sent to the client
abstract class OutEvent

class NotifyClientsChanged(List<ClientBrief> strings) extends OutEvent

class NotifyRoomsChanged(List<RoomBrief> rooms) extends OutEvent

class NotifyRoomStatus(RoomStatus roomStatus) extends OutEvent

class Token(String token, String publicToken) extends OutEvent

class CreatedRoom(String token) extends OutEvent

class JoinedRoom(String token, String playerToken) extends OutEvent

class NameCheckResult(Boolean available, String name) extends OutEvent

class NameAssignResult(Boolean success, String name, String message = "") extends OutEvent

class RoomCreationResult(Boolean success, String message = "") extends OutEvent

class Ok(String msg) extends OutEvent

class Err(String msg) extends OutEvent

class Ping(String msg) extends OutEvent

class Kill(String msg) extends OutEvent

// Messages which are read (including sent from ourself to ourself
abstract class InEvent

// Messages which are sent from the client, and can be deserialized
abstract class SerializableInEvent extends InEvent

// Client first connected, store ActorRef
class RegisterClient(Client client, ActorRef actor) extends InEvent with RootMsg

// Client sends token to "relogin", empty for new client
class SetToken(String oldToken, String newToken) extends InEvent with RootMsg

// KeepAlive to kill dead clients
class KeepAliveTick() extends InEvent with RootMsg

// Client request to list rooms
class ListRoom(String token) extends AuthenticatedRootMsg with SerializableInEvent

// Client request to validate a name's availability
class CheckName(String token, String name) extends AuthenticatedRootMsg with SerializableInEvent

// Client response to our ping
class Pong(String token) extends AuthenticatedRootMsg with SerializableInEvent

// Client tries to assign name
class AssignName(String name, String token) extends AuthenticatedRootMsg with SerializableInEvent

// Client tries to create room
class CreateRoom(String roomName, String token) extends AuthenticatedRootMsg with SerializableInEvent

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
