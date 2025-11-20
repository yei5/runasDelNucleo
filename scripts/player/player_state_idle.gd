extends PlayerState

func on_physics_process(_delta):	
	player.velocity = Vector2.ZERO
	controlled_node.move_and_slide()
	
	
func on_input(_event):
	# seria mejor usar el parametro _event para obtener la información del evento
	var dir = Input.get_vector("move_left","move_right","move_up","move_down")
	if dir != Vector2.ZERO : 
		state_machine.change_to(player.states.Running)
