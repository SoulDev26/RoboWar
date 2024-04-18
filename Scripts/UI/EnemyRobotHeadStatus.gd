extends Control

@onready var robot = $'../..'

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	robot.connect('HealthChanged', _OnHealthChanged)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _OnHealthChanged(health: int) -> void:
	$HealthBar.value = health / (robot.MAX_HEALTH / 100.0)
