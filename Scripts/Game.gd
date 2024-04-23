extends Node3D


func _ready() -> void:
	pass #Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _process(delta: float) -> void:
	pass

func LoadMap(mapPath: String):
	var mapNode = load(mapPath).instantiate()
	add_child(mapNode)
