extends PlayerState

func on_physics_process(_delta):	
	controlled_node.velocity = Input.get_vector("move_left","move_right","move_up","move_down") * controlled_node.running_speed
	controlled_node.move_and_slide()

func on_input(_event):
	var dir = Input.get_vector("move_left","move_right","move_up","move_down")
	if dir == Vector2.ZERO : 
		state_machine.change_to(player.states.Idle)
