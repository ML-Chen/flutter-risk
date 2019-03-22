abstract class ChatMsg {}

class MessageToUser extends ChatMsg {
  String recipientPublic; String message;
  MessageToUser(this.recipientPublic, this.message);
}

class MessageToRoom extends ChatMsg {
  String roomId; String message;
  MessageToRoom(this.roomId, this.message);
}