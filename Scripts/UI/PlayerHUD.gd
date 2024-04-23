extends Control

@onready var playerNode = $'../..'

func _ready() -> void:
	playerNode.connect('EnergyChanged', _OnAmmoChanged)


func _process(delta: float) -> void:
	var text = ''
	for enemy in playerNode.capturableEnemies:
		text += enemy.name + '\n'
		
	$CapturedEnemies.text = text


func _OnAmmoChanged(ammo: int) -> void:
	$AmmoBar.value = ammo / (playerNode.MAX_ENERGY / 100.0)
