extends RigidBody3D

var maxDistance = 100.0
var speed = 20.0
var startPos: Vector3
var damage: int = 1

func _ready() -> void:
	pass # Replace with function body.


func _physics_process(delta: float) -> void:
	if position.distance_to(startPos) >= maxDistance:
		queue_free()

func launch(launchSpeed: Vector3):
	linear_velocity = launchSpeed * speed

func _on_body_entered(body: Node) -> void:
	if body.has_meta('isEnemy'):
		body.get_parent().Hit(damage)
		queue_free()
