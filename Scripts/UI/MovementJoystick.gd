extends Control

signal JoystickPressed
signal JoystickReleased(deltaVec: Vector2)

@export var MAX_MOVE = 81.0
@onready var originalJoystickPos = $Joystick.position
var isJoystickActive = false
@onready var joystickMovePos = originalJoystickPos
var joystickMoveVec = Vector2.ZERO
var joystickMovePosOffset = Vector2.ZERO

func _ready() -> void:
	pass


func _process(delta: float) -> void:
	pass #print(joystickMoveVec)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		if isJoystickActive:
			joystickMovePos = event.position - joystickMovePosOffset
			joystickMoveVec = (joystickMovePos - originalJoystickPos).normalized()
			
			if originalJoystickPos.distance_to(joystickMovePos) <= MAX_MOVE:
				$Joystick.position = joystickMovePos
			else:
				$Joystick.position = originalJoystickPos + joystickMoveVec * MAX_MOVE


func _on_joystick_pressed() -> void:
	isJoystickActive = true
	joystickMovePosOffset = get_global_mouse_position() - originalJoystickPos


func _on_joystick_released() -> void:
	isJoystickActive = false
	joystickMoveVec = Vector2.ZERO
	$Joystick.position = originalJoystickPos
