extends CharacterBody3D

@onready var robotNode = $Robot
@onready var movementJoystickNode = $PlayerHudCanvas/PlayerHud/MovementJoystick
@onready var fireJoystickNode = $PlayerHudCanvas/PlayerHud/FireJoystick

@export var RobotModelId = 'MechRobotModel'

var movementVec: Vector3 = Vector3.ZERO

func _ready() -> void:
	robotNode.SetRobotModel(RobotModelId)
	
	fireJoystickNode.connect('Attack', OnManualAttack)
	fireJoystickNode.connect('AutoAttack', OnAutoAttack)

func _physics_process(delta: float) -> void:
	if not is_instance_valid(robotNode):
		return
	var input_dir = movementJoystickNode.joystickMoveVec
	movementVec = Vector3(input_dir.x, 0, input_dir.y)
	
	var fireJoyDir = fireJoystickNode.joystickMoveVec
	var fireVec = Vector3(fireJoyDir.x, 0, fireJoyDir.y)

	robotNode.Walk(movementVec)
	
	if fireVec != Vector3.ZERO:
		robotNode.LookAt(position + fireVec * 100)
		
	
	$Robot/AimLine.visible = fireJoystickNode.isJoystickActive

func OnManualAttack(vec: Vector2) -> void:
	robotNode.FireCurrentGun()
	
func OnAutoAttack() -> void:
	print_debug('Auto attack')
	robotNode.AutoAim()
	
	if robotNode.capturedEnemy:
		robotNode.FireCurrentGun()

