class_name Action extends Node

signal selected(_self)
signal set_available(is_aval)

var id:int
@export var icon:Texture2D
@export var action_name:String = "Action"
@export var action_description:String = ""
@export var range_:float = 1.5
@export var options:Array[String]
@export var is_available:bool = true
var actor:Character


func _ready() -> void:
	await owner.ready
	#actor = owner
	selected.connect(_on_action_selected)


## init() is called on the actor.selected-action setter for actions that execute immediatelly
## like Stealth for example
func init():
	##super.init() must be called after all is executed in the child class
	actor.selected_action = actor.default_action

func update():
	pass

func execute():
	actor.selected_action = actor.default_action


func _on_action_selected(_action):
	actor.selected_action = _action
