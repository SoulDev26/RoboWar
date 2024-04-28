extends CharacterBody3D

var modelNode = null

signal EnergyChanged(energy: int)

var isEnemy = false

@export var FIRE_DISTANCE = 20.0
@export var BULLET_SPEED = 10.0
@export var SPEED = 4.0
@export var Arr: Array[Marker3D]

@export var AMMO_REFILL_COOLDOWN = 2000 # 2 seconds
@export var AMMO_REFILL_DELAY = 500 # 0.5 seconds

var bulletScene = preload("res://Scenes/Entities/Bullet.tscn")
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

@export var MAX_HEALTH = 10
var health = MAX_HEALTH

@export var MAX_ENERGY = 20
var energy = MAX_ENERGY


var fireTime: int
var bulletRefillTime: int
var energyRefillAllowed = false

var capturableEnemies: Array[Node3D] = []
var capturedEnemy = null

@onready var parentNode: CharacterBody3D = get_parent()
@onready var animationPlayerNode: AnimationPlayer

func _ready() -> void:
	pass

func _physics_process(delta: float) -> void:
	CheckEnergy()
	AutoAimCheck()
	
	parentNode.move_and_slide()
	parentNode.velocity = Vector3.ZERO
	
func Hit(damage: int) -> void:
	health -= damage
	
	if health <= 0:
		queue_free()

func Walk(dir: Vector3, speed: float = SPEED) -> void:
	parentNode.velocity = speed * dir

	if dir == Vector3.ZERO:
		if animationPlayerNode.current_animation == 'MechaWalk':
			animationPlayerNode.play('MechaAction')
			
		return

	if animationPlayerNode.current_animation != 'MechaWalk':
		animationPlayerNode.play('MechaWalk')
		
	var rotateVec = global_position + (dir * 100)
	parentNode.look_at(rotateVec)
	parentNode.rotation_degrees.x = 0
	
func LookAt(pos: Vector3):
	parentNode.look_at(pos)

func SetRobotModel(assetId: String):
	if has_node('Model'):
		$Model.queue_free()
		await $Model.tree_exited

	var asset = Assets.GetAsset(assetId)
	modelNode = asset.instantiate()
	modelNode.name = 'Model'

	add_child(modelNode)
	animationPlayerNode = $Model/Model/AnimationPlayer
	
	$Model.set_meta('isEnemy', false)
	$Model/AutoAimZone.connect('body_entered', OnAutoAimZoneBodyEntered)
	$Model/AutoAimZone.connect('body_exited', OnAutoAimZoneBodyExited)
	$Model/AmmoRefillTimer.connect('timeout', OnAmmoRefillTimerTimeout)
	$Model/AmmoRefillDelayTimer.connect('timeout', OnAmmoRefillDelayTimerTimeout)

func FireCurrentGun() -> void:
	if energy <= 0:
		return
		
	if not $Model/FireDelayTimer.is_stopped():
		return
	
	var bulletSpawnMarkers = $Model/BulletSpawnMarkers.get_children()
	var bulletGuidingMarkers = $Model/BulletGuidingMarkers.get_children()
	for i in bulletSpawnMarkers.size():
		var spawnMarker = bulletSpawnMarkers[i]
		var guidingMarker = bulletGuidingMarkers[i]
		
		var bullet = bulletScene.instantiate()
		bullet.position = spawnMarker.global_position
		bullet.startPos = bullet.position
		bullet.maxDistance = FIRE_DISTANCE
		bullet.speed = BULLET_SPEED
		bullet.launch(GetBulletMovementVec(spawnMarker.global_position, guidingMarker.global_position))
		$'../..'.add_child(bullet)
	
	IncreaseAmmo(-1)
	energyRefillAllowed = false
	$Model/AmmoRefillTimer.start()
	$Model/FireDelayTimer.start()
	
func GetBulletMovementVec(bulletSpawnPos: Vector3, bulletGuidingPos: Vector3) -> Vector3:
	var vec = bulletSpawnPos - bulletGuidingPos
	vec.y = 0
	
	return vec

#func CheckAim() -> void:
	#$AimLine.visible = fireJoystickNode.IsAttackManual
	#
	#if fireJoystickNode.isJoystickActive:
		#var joystickMoveVec3 = Vector3(fireJoystickNode.joystickMoveVec.x, 0, fireJoystickNode.joystickMoveVec.y)
		#look_at(position + joystickMoveVec3 * 10)
		#rotation_degrees.x = 0
	#elif movementJoystickNode.isJoystickActive:
		#var joystickMoveVec3 = Vector3(movementJoystickNode.joystickMoveVec.x, 0, movementJoystickNode.joystickMoveVec.y)
		#look_at(position + joystickMoveVec3 * 10)
		#rotation_degrees.x = 0

	
func CheckEnergy() -> void:
	return
	
	if energy == 0 and $Model/AmmoRefillTimer.is_stopped():
		$Model/AmmoRefillTimer.start()
		return
		
func IncreaseAmmo(delta: int) -> void:
	energy += delta
	EnergyChanged.emit(energy)


func OnAmmoRefillTimerTimeout() -> void:
	energyRefillAllowed = true
	IncreaseAmmo(1)
	$Model/AmmoRefillTimer.stop()
	
	$Model/AmmoRefillDelayTimer.start()


func OnAmmoRefillDelayTimerTimeout() -> void:
	if not energyRefillAllowed:
		return
		
	if energy < MAX_ENERGY:
		IncreaseAmmo(1)
		
	if energy < MAX_ENERGY:
		$Model/AmmoRefillDelayTimer.start() 
	else:
		energyRefillAllowed = false

func AutoAim() -> void:
	if not capturedEnemy:
		return

	parentNode.look_at(capturedEnemy.global_position)
	parentNode.rotation_degrees.x = 0

func AutoAimCheck() -> void:
	if not capturedEnemy:
		if capturableEnemies.is_empty():
			return
			
		capturedEnemy = capturableEnemies[0]
		
	var capturedEnemyDist = parentNode.position.distance_to(capturedEnemy.position)
	
	for enemy in capturableEnemies:
		var enemyDist = parentNode.position.distance_to(enemy.position)
		if enemyDist < capturedEnemyDist:
			capturedEnemy = enemy

func OnAutoAimZoneBodyEntered(body: Node3D) -> void:
	if not body.has_meta('isEnemy') or body.get_meta('isEnemy') == modelNode.get_meta('isEnemy'):
			return
			
	capturableEnemies.append(body)
	
	if not capturedEnemy:
		capturedEnemy = body

func OnAutoAimZoneBodyExited(body: Node3D) -> void:
	capturableEnemies.erase(body)
	
	if capturedEnemy and body == capturedEnemy:
		capturedEnemy = null
