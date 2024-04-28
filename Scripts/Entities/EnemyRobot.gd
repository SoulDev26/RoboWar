extends CharacterBody3D

signal HealthChanged(health: int)

const MAX_HEALTH = 10
var health = MAX_HEALTH

const MIN_PLAYER_DISTANCE = 15

@export var ROBOT_MODEL_ID = 'MechRobotModel'

var playerNodes: Array[CharacterBody3D] = []
var moveVec = Vector3.ZERO

@onready var robotNode = $Robot
@onready var navAgentNode: NavigationAgent3D = $NavAgent

var isBot = true
var id: int

func _enter_tree() -> void:
	pass #set_multiplayer_authority(name.to_int())
	
func _ready() -> void:
	robotNode.SetRobotModel(ROBOT_MODEL_ID)
	robotNode.SPEED = 1.0
	robotNode.connect('Dead', OnDead)
	$Robot/Model.set_meta('isEnemy', true)
	
func _physics_process(delta: float) -> void:
	AttackPlayer()
	
	if robotNode.capturedEnemy:
		navAgentNode.target_position = robotNode.capturedEnemy.global_position
		
		
@rpc("any_peer", "call_remote", "unreliable")
func NetworkSync(otherTransform: Transform3D) -> void:
	transform = otherTransform
func OnDead() -> void:
	queue_free()
	
func AttackPlayer() -> void:
	if not robotNode.capturedEnemy:
		return
		
		
	var rayVec = (robotNode.capturedEnemy.global_position - global_position).normalized()
	var collidedBody = RayCastTo(global_position + rayVec * 5, robotNode.capturedEnemy.global_position)

	if collidedBody and not collidedBody.has_meta('isEnemy'):
		return
		
	var isPlayer = true
	if collidedBody and collidedBody.has_meta('isEnemy'):
		isPlayer = collidedBody.get_meta('isEnemy') != $Robot/Model.get_meta('isEnemy')
	#print_debug(collidedBody)
	if isPlayer:
		if global_position.distance_to(robotNode.capturedEnemy.global_position) >= MIN_PLAYER_DISTANCE:
			var nextPos = navAgentNode.get_next_path_position()
			robotNode.Walk(nextPos - global_position)
			robotNode.FireCurrentGun()

func RayCastTo(basePos: Vector3, targetPos: Vector3) -> Node3D:
	var spaceState = get_world_3d().direct_space_state
	var rayQuery = PhysicsRayQueryParameters3D.create(basePos, targetPos)
	var result = spaceState.intersect_ray(rayQuery)
	
	if result.is_empty():
		return null
	else:
		return result.collider

func Hit(damage: int):
	health -= damage
	
	HealthChanged.emit(health)
	if health <= 0:
		queue_free()
