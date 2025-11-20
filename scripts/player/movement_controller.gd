extends Node2D

@onready var player: CharacterBody2D = $".."

const SPEED = 128

func _physics_process(_delta: float) -> void:
	print("inside controller process")
	player.velocity = Input.get_vector("move_left","move-right","move_up","move_down") * SPEED
	player.move_and_slide()
