extends Camera3D

@onready var playerRobot = $'../PlayerRobot'
@onready var offset = position - playerRobot.position

func _ready() -> void:
	pass


func _physics_process(delta: float) -> void:
	position = playerRobot.position + offset
