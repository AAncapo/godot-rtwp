extends Control

@onready var _log = %Log
@onready var charName = %CharacterName
@onready var actionBar = %ActionBar
var actor


func _ready() -> void:
	await owner.ready
	actor = owner
	set_charname(actor.name)


func _process(delta: float) -> void:
	actionBar.visible = actionBar.value > actionBar.min_value and actionBar.value < actionBar.max_value
	
	if actor:
		update_actionbar(actor.ttimer.time_left, actor.next_action)


func set_charname(name_:String):
	charName.text = name_.to_upper()


func create_msg(text):
	var label:Label = Label.new()
	label.text = text
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	label.set("theme_override_font_sizes/font_size",12)
	
	if _log.get_child_count() >= 10:
		_log.get_child(_log.get_child_count()-1).queue_free()
	
	var timer = Timer.new()
	timer.wait_time = 6
	timer.autostart = true
	timer.timeout.connect(_on_label_timer_timeout.bind(label))
	_log.add_child(label)
	label.add_child(timer)


func update_actionbar(val, max_val):
	actionBar.value = val
	actionBar.max_value = max_val


func _on_label_timer_timeout(label) -> void:
	label.queue_free()
