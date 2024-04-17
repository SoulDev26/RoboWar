extends RigidBody3D

const MAX_DISTANCE = 100.0
const SPEED = 20.0
var startPos: Vector3
var damage: int = 1

func _ready() -> void:
	pass # Replace with function body.


func _physics_process(delta: float) -> void:
	if position.distance_to(startPos) >= MAX_DISTANCE:
		queue_free()

func launch(speed: Vector3):
	linear_velocity = speed * SPEED

func _on_body_entered(body: Node) -> void:
	if 'EnemyRobot' in body.name:
		body.Hit(damage)
		queue_free()
