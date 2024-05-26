class_name Action extends Node

signal selected(_self)
signal set_available(is_aval)

var id:int
@export var action_name:String = "Action"
@export var action_description:String = ""
@export var range_:float = 0.0
@export var options:Array[String]
@export var is_available:bool = true
var actor:Character

## init() is called on the actor.selected-action setter for actions that execute immediatelly
## like Stealth for example
func init():
	##super.init() must be called after all is executed in the child class
	actor.selected_action = actor.default_action

func update():
	pass

func execute():
	actor.selected_action = actor.default_action
