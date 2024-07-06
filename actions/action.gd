class_name Action extends Node

signal selected(_self, _is_selected)
signal set_enabled(_enabled)
signal count_updated(_count)

@export var enabled:bool = true
@export var target_self:bool = true
@export var exec_on_selected:bool = false
@export var oneshot:bool = false
@export var icon:Texture2D
@export var action_name:String = "Action"
@export var action_description:String = ""
@export var range_:float = -1
var actor:Character
var target:Character
var count:int


func _ready() -> void:
	set_enabled.connect(_on_set_enabled)


func init():
	pass


#on selected gets range
func select():
	selected.emit(self, true)  #connected to the GUI ActionButton
	if exec_on_selected: execute()


func execute():
	if oneshot:
		selected.emit(self, false)


func _on_set_enabled(_enabled):
	enabled = _enabled


func update_count(_count):
	count = _count
	count_updated.emit(_count)
