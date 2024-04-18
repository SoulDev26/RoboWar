extends CharacterBody3D

signal AmmoChanged(ammo: int)

const SPEED = 10.0
const JUMP_VELOCITY = 10.0
const MOUSE_CONTROL_SENSITIVITY = 100

const AMMO_REFILL_COOLDOWN = 2000 # 2 seconds
const AMMO_REFILL_DELAY = 500 # 0.5 seconds

var bulletScene = preload("res://Scenes/Entities/Bullet.tscn")
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

const MAX_AMMO = 20
var ammo = MAX_AMMO

var fireTime: int
var bulletRefillTime: int
var ammoRefillAllowed = false


func _init() -> void:
	pass

func _physics_process(delta: float) -> void:
	CheckAmmo()
	
	if not is_on_floor():
		velocity.y -= gravity * delta

	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		
	if Input.is_action_just_pressed("attack"):
		FireCurrentGun()

	var input_dir := Input.get_vector("left", "right", "up", "down")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
	
func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x / 100)
		
func FireCurrentGun() -> void:
	if ammo <= 0:
		return
	
	var bullet = bulletScene.instantiate()
	bullet.position = $BulletSpawnMarker.global_position
	bullet.startPos = bullet.position
	bullet.launch(GetBulletMovementVec())
	get_parent().add_child(bullet)
	
	IncreaseAmmo(-1)
	ammoRefillAllowed = false
	$AmmoRefillTimer.start()
	
func GetBulletMovementVec() -> Vector3:
	var vec = $BulletSpawnMarker.global_position - position
	vec.y = 0
	
	return vec

func CheckAmmo() -> void:
	return
	
	if ammo == 0 and $AmmoRefillTimer.is_stopped():
		$AmmoRefillTimer.start()
		return
		
func IncreaseAmmo(delta: int) -> void:
	ammo += delta
	AmmoChanged.emit(ammo)


func _on_ammo_refill_timer_timeout() -> void:
	ammoRefillAllowed = true
	IncreaseAmmo(1)
	$AmmoRefillTimer.stop()
	
	$AmmoRefillDelayTimer.start()


func _on_ammo_refill_delay_timer_timeout() -> void:
	if not ammoRefillAllowed:
		return
		
	if ammo < MAX_AMMO:
		IncreaseAmmo(1)
		
	if ammo < MAX_AMMO:
		$AmmoRefillDelayTimer.start() 
	else:
		ammoRefillAllowed = false
