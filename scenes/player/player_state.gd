class_name PlayerState extends State

var player: Player:
	set (value):
		controlled_node = value
	get:
		return controlled_node
