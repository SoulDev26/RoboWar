extends Control

var gameScene = preload('res://Scenes/Game.tscn')

func _ready() -> void:
	pass # Replace with function body.


func _process(delta: float) -> void:
	pass


func _on_start_button_pressed() -> void:
	self.visible = false
	var gameNode = gameScene.instantiate()
	gameNode.LoadMap('res://Scenes/Maps/Test.tscn')
	get_parent().add_child(gameNode)
