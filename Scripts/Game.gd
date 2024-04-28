extends Node3D

var playerRobotScene = preload('res://Scenes/Entities/PlayerRobot.tscn')
var enemyRobotScene = preload('res://Scenes/Entities/EnemyRobot.tscn')

func _ready() -> void:
	Multiplayer.connect('PlayerConnected', OnPeerConnected)
	Multiplayer.connect('ServerConnected', OnServerConnected)


func _process(delta: float) -> void:
	pass

func LoadMap(mapPath: String) -> void:
	var mapNode = load(mapPath).instantiate()
	add_child(mapNode)
	
	if Multiplayer.isServer:
		await Multiplayer.OnPeerConnected
	else:
		await Multiplayer.OnServerConnected

func OnPeerConnected(id) -> void:
	Multiplayer.isConnected = true
	var map = get_children()[0]
	print("PEER CONNECTED")
	
	var robot = enemyRobotScene.instantiate()
	#robot.id = map.get_node('PlayerRobot').id
	robot.isBot = false
	robot.position = map.get_node('PlayerRobot').position
	robot.position.x -= 20
	Multiplayer.lastConnectedClientPlayer = robot
	map.get_node('EnemyPlayers').add_child(robot)

func OnServerConnected() -> void:
	Multiplayer.isConnected = true
	var map = get_children()[0]

	var robot = enemyRobotScene.instantiate()
	#robot.id = map.get_node('PlayerRobot').id
	robot.isBot = false
	robot.position = map.get_node('PlayerRobot').position
	robot.position.x -= 20
	Multiplayer.lastConnectedClientPlayer = robot
	
	
	map.get_node('EnemyPlayers').add_child(robot)
	print('PLAYER ADDED')
	pass
