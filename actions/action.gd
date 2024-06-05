class_name Action extends Node

signal selected(_self)
signal executed(_self)
signal set_enabled(_enabled)

@export var enabled:bool = true
@export var exec_on_selected:bool = false
@export var oneshot:bool = false
@export var icon:Texture2D
@export var action_name:String = "Action"
@export var action_description:String = ""
@export var range_:float = 1.5
var actor:Character


func _ready() -> void:
	await  owner.ready
	actor = owner
	
	set_enabled.connect(_on_set_enabled)


func select():
	actor.selected_action = self
	selected.emit(self)  #connected to the GUI ActionButton
	if exec_on_selected:
		execute()


func execute():
	if oneshot:
		actor.selected_action = null


func _on_set_enabled(_enabled):
	enabled = _enabled
