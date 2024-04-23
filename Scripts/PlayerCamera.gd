extends Camera3D

@onready var player = $'../PlayerRobot'
@onready var offset = position - player.position

func _ready() -> void:
	pass


func _physics_process(delta: float) -> void:
	position = player.position + offset
