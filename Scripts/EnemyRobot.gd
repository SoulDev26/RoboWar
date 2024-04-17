extends CharacterBody3D

signal HealthChanged(health: int)

const MAX_HEALTH = 10
var health = MAX_HEALTH

func Hit(damage: int):
	health -= damage
	
	HealthChanged.emit(health)
	print('health '+ str(health))
	if health <= 0:
		queue_free()
