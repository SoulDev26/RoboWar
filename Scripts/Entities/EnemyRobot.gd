extends CharacterBody3D

signal HealthChanged(health: int)

const MAX_HEALTH = 10
var health = MAX_HEALTH

@export var ROBOT_MODEL_ID = 'MechRobotModel'

var playerNodes: Array[CharacterBody3D] = []

@onready var robotNode = $Robot
@onready var navAgentNode: NavigationAgent3D = $NavAgent

func _ready() -> void:
	robotNode.SetRobotModel(ROBOT_MODEL_ID)
	$Robot/Model.set_meta('isEnemy', true)
	
func _physics_process(delta: float) -> void:
	AttackPlayer()
	
	if robotNode.capturedEnemy:
		navAgentNode.target_position = robotNode.capturedEnemy.global_position
		
func AttackPlayer() -> void:
	if not robotNode.capturedEnemy:
		return
		
		
	var rayVec = (robotNode.capturedEnemy.global_position - global_position).normalized()
	var collidedBody = RayCastTo(global_position + rayVec * 5, robotNode.capturedEnemy.global_position)

	var isPlayer = false
	if collidedBody and collidedBody.has_meta('isEnemy'):
		isPlayer = collidedBody.get_meta('isEnemy') != $Robot/Model.get_meta('isEnemy')
	print_debug(collidedBody)
	if isPlayer:
		if global_position.distance_to(robotNode.capturedEnemy.global_position) >= 10:
			var nextPos = navAgentNode.get_next_path_position()
			robotNode.Walk(nextPos - global_position)

func RayCastTo(basePos: Vector3, targetPos: Vector3) -> Node3D:
	$AimCube.global_position = targetPos
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
