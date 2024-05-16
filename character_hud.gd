extends Control

@onready var log = %Log
@onready var charName = %CharacterName
@onready var actionBar = %ActionBar


func _process(delta: float) -> void:
	actionBar.visible = actionBar.value > actionBar.min_value and actionBar.value < actionBar.max_value


func set_charname(name_:String):
	charName.text = name_.to_upper()


func create_msg(text):
	var label = Label.new()
	label.text = text
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	
	if log.get_child_count() >= 10:
		log.get_child(log.get_child_count()-1).queue_free()
	
	log.add_child(label)


func update_actionbar(val, max_val):
	actionBar.value = val
	actionBar.max_value = max_val
