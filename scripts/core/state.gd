class_name State extends Node

## referencia al nodo que vamos a controlar
var controlled_node:Node # @onready var player:Player = self.owner

## referencia a la maquina de estados
var state_machine:StateMachine

#region métodos comunes

## método que se ejecuta al entrar en el estado
func start():
	pass
	
## método que se ejecuta al abandonar el estado
func end():
	pass
	
func on_process(_delta): 
	pass
	
func on_physics_process(_delta): 
	pass
	
func on_input(_event): 
	pass

#endregion
