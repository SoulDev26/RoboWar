extends Control

@onready var playerNode = $'../../Map/PlayerRobot'

func _ready() -> void:
	playerNode.connect('AmmoChanged', _OnAmmoChanged)


func _process(delta: float) -> void:
	pass


func _OnAmmoChanged(ammo: int) -> void:
	$AmmoBar.value = ammo / (playerNode.MAX_AMMO / 100.0)
