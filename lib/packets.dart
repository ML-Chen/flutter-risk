import 'dart:convert';

final jsonEncoder = JsonEncoder();

class Token {
	var token, publictoken;

  Token(this.token, this.publictoken);
	Token.fromOther(other) {
		this.token = other.token;
    this.publictoken = other.publictoken;
	}
}

class Ping {
	var msg;

	Ping(this.msg);
	Ping.fromOther(other) {
		this.msg = other.msg;
	}
}

class ListRoom {
	var token, _type;

	ListRoom(token) {
		this.token = token;
		this._type = 'ListRoom';
	}
}

class NotifyRoomsChanged {
	var rooms;

	NotifyRoomsChanged(this.rooms);
	NotifyRoomsChanged.fromOther(other) {
		this.rooms = other.rooms;
	}
}

class NotifyClientsChanged {
	var players;

	NotifyClientsChanged(this.players);
}

class RoomStatusUpdate {
	var roomName, roomId, clientStatus;

	RoomStatusUpdate(this.roomName, this.roomId, this.clientStatus);
	RoomStatusUpdate.fromOther(other) {
		this.roomName = other.roomStatus.name;
		this.roomId = other.roomStatus.roomId;
		this.clientStatus = other.roomStatus.clientStatus;
	}
}

class NameAssignResult {
	var success, name, message;

	NameAssignResult(this.success, this.name, this.message);
	NameAssignResult.fromOther(other) {
		this.success = other.success;
		this.name = other.name;
		this.message = other.message;
	}
}

class NameCheckResult {
	var available, name;

	NameCheckResult(this.available, this.name);
	NameCheckResult.fromOther(other) {
		this.available = other.available;
		this.name = other.name;
	}
}

class RoomCreationResult {
	var success, message;
	
	RoomCreationResult(this.success, this.message);
	RoomCreationResult.fromOther(other) {
		this.success = other.success;
		this.message = other.message;
	}
}

class CreatedRoom {
	var token;

	CreatedRoom(this.token);
	CreatedRoom.fromOther(other) {
		this.token = other.token;
	}
}

class JoinedRoom {
	var roomId;

	JoinedRoom(this.roomId);
	JoinedRoom.fromOther(other) {
		this.roomId = other.token;
		this.playerToken = other.playerToken;
	}
}

class GameState {
	var players, map;

	GameState(this.players, this.map);
	GameState.fromOther(other) {
		this.players = other.state.players;
		this.map = other.state.map;
	}
}

class MapResource {
	var viewBox, territories;

	MapResource(this.viewBox, this.territories);
	MapResource.fromOther(other) {
		print(jsonEncoder.convert(other));
		this.viewBox = other.resource.viewBox;
		this.territories = other.resource.territories;
	}
}

class NotifyTurn {
	var publicToken;

	NotifyTurn(this.publicToken);
	NotifyTurn.fromOther(other) {
		print(jsonEncoder.convert(other));
		this.publicToken = other.publicToken;
	}
}

class Message {
	var _type, token, territoryId;

	Message(this._type, this.token, this.territoryId);
}

class PlaceArmy {
	var token, gameId, msg, _type;

	PlaceArmy(token, gameId, territoryId) {
		this.token = token;
		this.gameId = gameId;
		this.msg = Message('actors.PlaceArmy', token, territoryId);
		this._type = 'actors.ForwardToGame';
	}
}

class Err {
	var message;

	Err(this.message);
	Err.fromOther(other) {
		this.message = other.message;
	}
}

class ClientReady {
	var token, roomId, _type;

	ClientReady(token, roomId) {
		this.token = token;
		this.roomId = roomId;
		this._type = 'actors.ClientReady';
	}
}

class StartGame {
	var token, roomId, _type;

	StartGame(token, roomId) {
		this.token = token;
		this.roomId = roomId;
		this._type = 'actors.StartGame';
	}
}

class CreateRoom {
	var token, roomId, _type;

	CreateRoom(token, roomName) {
		this.token = token;
		this.roomName = roomName;
		this._type = 'actors.CreateRoom';
	}
}

class JoinRoom {
	var token, roomId, _type;

	JoinRoom(token, roomId) {
		this.token = token;
		this.roomId = roomId;
		this._type = 'actors.JoinRoom';
	}
}

class CheckName {
	var token, roomId, _type;

	CheckName(token, name) {
		this.token = token;
		this.name = name;
		this._type = 'actors.CheckName';
	}
}

class AssignName {
	var token, roomId, _type;

	AssignName(token, name) {
		this.token = token;
		this.name = name;
		this._type = 'actors.AssignName';
	}
}

class Pong {
	var token, _type;
	
	Pong(token) {
		this.token = token;
		this._type = 'actors.Pong';
	}
}

processMessage(store, socket, toastr, message) {
	switch (message._type) {
		case 'actors.Token':
			const packet = new Token(message);
			store.commit(types.SET_TOKEN, packet);
			store.dispatch('gameListRoom', socket);
			break;
		case 'actors.Ping':
			socket.sendObj(new Pong(store.state.game.token));
			break;
		case 'actors.NotifyRoomsChanged':
			const roomsChanged = new NotifyRoomsChanged(message);
			store.commit(types.GAME_ROOMS_CHANGED, roomsChanged);
			break;
		case 'actors.NameCheckResult':
			const nameCheckResult = new NameCheckResult(message);
			if (store.state.game.displayName.name === nameCheckResult.name) {
				store.commit(types.VALIDATE_GAME_NAME, nameCheckResult.available ? 'true' : 'false');
			}
			break;
		case 'actors.CreatedRoom':
			store.commit(types.GAME_ROOM_CREATED, new CreatedRoom(message));
			break;
		case 'actors.JoinedRoom':
			store.commit(types.GAME_ROOM_JOIN, new JoinedRoom(message));
			break;
		case 'actors.RoomCreationResult':
			store.commit(types.GAME_ROOM_CREATION_RESULT_OCCURRED, new RoomCreationResult(message));
			break;
		case 'actors.NotifyClientsChanged':
			store.commit(types.GAME_PLAYER_LIST_CHANGED, new NotifyClientsChanged(message));
			break;
		case 'actors.NotifyRoomStatus':
			store.commit(types.GAME_ROOM_STATUS_CHANGED, new RoomStatusUpdate(message));
			break;
		case 'actors.NameAssignResult':
			const nameAssignmentResult = new NameAssignResult(message);
			if (store.state.game.displayName.name == nameAssignmentResult.name) {
				store.commit(types.COMMIT_GAME_NAME, nameAssignmentResult);
			}
			break;
		case 'actors.NotifyGameStarted':
			store.commit(types.GAME_STARTED, new GameState(message));
			break;
		case 'actors.NotifyGameState':
			store.commit(types.GAME_STATE, new GameState(message));
			break;
		case 'actors.SendMapResource':
			store.commit(types.MAP_RESOURCE, new MapResource(message));
			break;
		case 'actors.NotifyTurn':
			store.commit(types.NOTIFY_TURN, new NotifyTurn(message));
			break;
		case 'actors.Err':
			print('error', new Err(message).message, 'Error from Server');
			break;
		default:
			print('info', jsonEncoder.convert(message), 'Un-parsed Socket Message:');
			print(jsonEncoder.convert(message));
	}
}
