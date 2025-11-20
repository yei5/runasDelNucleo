class_name Player extends CharacterBody2D

const running_speed = 128

var states:PlayerStates = PlayerStates.new()

func _enter_tree():
	print("ENTER TREE")
	
func _ready() -> void:
	print("READY")
