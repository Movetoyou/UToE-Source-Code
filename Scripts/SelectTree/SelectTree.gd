extends Node2D

@onready var BaseTree = $BaseTree

func _ready() -> void:
	BaseTree.pressed.connect(_on_pressed)

func _on_pressed():
	get_tree().change_scene_to_file("res://Scenes/BaseTree.tscn")
