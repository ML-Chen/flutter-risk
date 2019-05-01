enum Status { Waiting, Ready, Idk }

class Room {
  String name;
  String hostName;
  String roomId;
  List<ClientStatus> clientStatus;

  Room(this.name, this.hostName, this.roomId, this.clientStatus);
}

class RoomBrief {
  String name;
  String hostToken;
  String roomId;
  int numClients;

  RoomBrief(this.name, this.hostToken, this.roomId, this.numClients);
  String toString() {
    return "Room name=${this.name} hostToken=${this.hostToken} roomId=${this.roomId} numClients=${this.numClients.toString()}";
  }
}

class RoomStatus {
  String roomName;
  String roomId;
  String clientStatus;
}

class ClientStatus {
  String name;
  Status status;
  String publicToken;

  ClientStatus(this.name, this.publicToken);
}

class Player {
  String name;
  int unitCount;
  // ClientWithActor client;
}

// This class specification is based on game.js, not the backend
class Game {
  MapResource map = MapResource(null, null);
  String phase = "Setup";
  List<Player> players = [];
  List<Territory> territories = [Territory(0, null, [], 0)];
  String turn;
  String turnPhase;

  Game(this.map, this.phase, this.players, this.territories, this.turn,
      this.turnPhase);
}

class Territory {
  int armies;
  String ownerToken;
  List neighbours; // called neighbours in backend and frontend
  int id;

  Territory(this.armies, this.ownerToken, this.neighbours, this.id);
  String toString() {
    return "Territory armies=${this.armies} ownerToken=${this.ownerToken} neighbours=${this.neighbours} id=${this.id}";
  }
}

/*class GameState {
  List<Player> players;
  GameMap map; // GameMap is called Map in our backend
  // GamePhase gamePhase;
  GameState(this.players, this.map);
}*/

// class GameMap {
//   List<Territory> territories;
//   double interval; // of FiniteDuration type in backend
//   MapResource resource;

//   GameMap(this.territories, this.interval, this.resource);
// }

class MapResource {
  String viewBox;
  List<String> territories;

  MapResource(this.viewBox, this.territories);
}

// See also: Map, MapResource, etc.
