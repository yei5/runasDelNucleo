extends CharacterBody2D

const SPEED = 128

func _physics_process(_delta: float) -> void:
	velocity = Input.get_vector("move_left","move-right","move_up","move_down") * SPEED
	move_and_slide()
