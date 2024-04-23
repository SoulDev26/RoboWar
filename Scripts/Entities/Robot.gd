extends CharacterBody3D

signal EnergyChanged(energy: int)

@export var FIRE_DISTANCE = 20.0
@export var BULLET_SPEED = 10.0
@export var SPEED = 10.0
@export var Arr: Array[Marker3D]
const JUMP_VELOCITY = 10.0
const MOUSE_CONTROL_SENSITIVITY = 100

@export var AMMO_REFILL_COOLDOWN = 2000 # 2 seconds
@export var AMMO_REFILL_DELAY = 500 # 0.5 seconds

var bulletScene = preload("res://Scenes/Entities/Bullet.tscn")
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

@export var MAX_ENERGY = 20
var energy = MAX_ENERGY

var movementVec: Vector3 = Vector3.ZERO

var fireTime: int
var bulletRefillTime: int
var energyRefillAllowed = false

var capturableEnemies: Array[Node3D] = []
var capturedEnemy = null

@onready var movementJoystickNode = $PlayerHudCanvas/PlayerHud/MovementJoystick
@onready var fireJoystickNode = $PlayerHudCanvas/PlayerHud/FireJoystick

func _ready() -> void:
	fireJoystickNode.connect('Attack', OnManualAttack)
	fireJoystickNode.connect('AutoAttack', OnAutoAttack)

func _physics_process(delta: float) -> void:
	CheckEnergy()
	CheckAim()
	AutoAimCheck()
	#AutoAim()
	
	if not is_on_floor():
		velocity.y -= gravity * delta

	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		
	#if Input.is_action_just_pressed("attack"):
		#FireCurrentGun()

	var input_dir: Vector2 = movementJoystickNode.joystickMoveVec #Input.get_vector("left", "right", "up", "down")
	movementVec = Vector3(input_dir.x, 0, input_dir.y)
	#var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	#var direction = Vector3(input_dir.x, 0, input_dir.y)
	#if direction:
		#velocity.x = direction.x * SPEED
		#velocity.z = direction.z * SPEED
	#else:
		#velocity.x = move_toward(velocity.x, 0, SPEED)
		#velocity.z = move_toward(velocity.z, 0, SPEED)
	velocity = SPEED * movementVec
	


	move_and_slide()
	
func _input(event: InputEvent) -> void:
	return
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x / 100)
	

func OnManualAttack(vec: Vector2) -> void:
	FireCurrentGun()
	
func OnAutoAttack() -> void:
	AutoAim()
	FireCurrentGun()

func FireCurrentGun() -> void:
	if energy <= 0:
		return
	
	var bullet = bulletScene.instantiate()
	bullet.position = $BulletSpawnMarker.global_position
	bullet.startPos = bullet.position
	bullet.maxDistance = FIRE_DISTANCE
	bullet.speed = BULLET_SPEED
	bullet.launch(GetBulletMovementVec())
	get_parent().add_child(bullet)
	
	IncreaseAmmo(-1)
	energyRefillAllowed = false
	$AmmoRefillTimer.start()
	
func GetBulletMovementVec() -> Vector3:
	var vec = $BulletSpawnMarker.global_position - position
	vec.y = 0
	
	return vec

func CheckAim() -> void:
	$AimLine.visible = fireJoystickNode.IsAttackManual
	
	if fireJoystickNode.isJoystickActive:
		var joystickMoveVec3 = Vector3(fireJoystickNode.joystickMoveVec.x, 0, fireJoystickNode.joystickMoveVec.y)
		look_at(position + joystickMoveVec3 * 10)
		rotation_degrees.x = 0
	elif movementJoystickNode.isJoystickActive:
		var joystickMoveVec3 = Vector3(movementJoystickNode.joystickMoveVec.x, 0, movementJoystickNode.joystickMoveVec.y)
		look_at(position + joystickMoveVec3 * 10)
		rotation_degrees.x = 0

	
func CheckEnergy() -> void:
	return
	
	if energy == 0 and $AmmoRefillTimer.is_stopped():
		$AmmoRefillTimer.start()
		return
		
func IncreaseAmmo(delta: int) -> void:
	energy += delta
	EnergyChanged.emit(energy)


func _on_ammo_refill_timer_timeout() -> void:
	energyRefillAllowed = true
	IncreaseAmmo(1)
	$AmmoRefillTimer.stop()
	
	$AmmoRefillDelayTimer.start()


func _on_ammo_refill_delay_timer_timeout() -> void:
	if not energyRefillAllowed:
		return
		
	if energy < MAX_ENERGY:
		IncreaseAmmo(1)
		
	if energy < MAX_ENERGY:
		$AmmoRefillDelayTimer.start() 
	else:
		energyRefillAllowed = false

func AutoAim() -> void:
	if not capturedEnemy:
		return

	look_at(capturedEnemy.position)
	rotation_degrees.x = 0

func AutoAimCheck() -> void:
	if not capturedEnemy:
		if capturableEnemies.is_empty():
			return
			
		capturedEnemy = capturableEnemies[0]
		
	var capturedEnemyDist = position.distance_to(capturedEnemy.position)
	
	for enemy in capturableEnemies:
		var enemyDist = position.distance_to(enemy.position)
		if enemyDist < capturedEnemyDist:
			capturedEnemy = enemy

func _on_auto_aim_zone_body_entered(body: Node3D) -> void:
	if 'EnemyRobot' not in body.name:
		return
		
	capturableEnemies.append(body)
	
	if not capturedEnemy:
		capturedEnemy = body
		

func _on_auto_aim_zone_body_exited(body: Node3D) -> void:
	capturableEnemies.erase(body)
	
	if capturedEnemy and body == capturedEnemy:
		capturedEnemy = null
