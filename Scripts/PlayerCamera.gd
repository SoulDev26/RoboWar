extends Camera3D

@onready var playerRobot = $'../PlayerRobot'
@onready var offset = position - playerRobot.position

func _ready() -> void:
	pass


func _physics_process(delta: float) -> void:
	if not is_instance_valid(playerRobot):
		return
		
	position = playerRobot.position + offset
