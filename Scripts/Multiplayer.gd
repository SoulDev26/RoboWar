extends Node

signal PlayerConnected(id: int)
signal ServerConnected

var peer = ENetMultiplayerPeer.new()
var isServer = false
var isConnected = false

var lastConnectedClientPlayer = null
var lastConnectedServerPlayer = null

func _ready() -> void:
	pass
	
func _process(delta: float) -> void:
	pass
	
func CreateServer() -> void:
	print('CREATED SERVER')
	peer.create_server(135)
	multiplayer.multiplayer_peer = peer
	multiplayer.peer_connected.connect(OnPeerConnected)
	isServer = true

func CreateClient() -> void:
	print('CREATED CLIENT')
	peer.create_client('localhost', 135)
	multiplayer.multiplayer_peer = peer
	multiplayer.connected_to_server.connect(OnServerConnected)

func OnPeerConnected(id) -> void:
	#var enemy = preload("res://Scenes/Entities/EnemyRobot.tscn").instantiate()
	#enemy.isBot = false
	#get_tree().current_scene.get_node('Game/Test').add_child(enemy)
	PlayerConnected.emit(id)

func OnServerConnected() -> void:
	ServerConnected.emit()

@rpc("any_peer", "call_remote", "unreliable")
func SyncPlayer(id: int, otherTransform: Transform3D) -> void:
	var players = get_tree().current_scene.get_node('Game/Test/EnemyPlayers')
	print_debug(players.get_children())
	for player in players.get_children():
		print_debug(player.id, ' ', id)
		if player.id == id:
			player.transform = otherTransform
			break

@rpc("any_peer", "call_remote", "unreliable")
func SyncConnectedPeer(id: int) -> void:
	if isServer and not lastConnectedServerPlayer:
		return
	elif not isServer and not lastConnectedClientPlayer:
		return
		
	if isServer:
		lastConnectedServerPlayer.id = id
	else:
		lastConnectedClientPlayer.id = id
