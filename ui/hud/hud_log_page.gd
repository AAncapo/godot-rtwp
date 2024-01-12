extends Control

@export var font_size = 12
@export var autor_font_size = 13
@onready var logs_container = $ScrollContainer/logs_container



func _ready():
	GameEvents.ui_toggle_combat_log.connect(toggle_combat_log)
	GameEvents.update_clg.connect(on_combat_log_updated)


func on_combat_log_updated(autor, new_info, target):
	var label_container = create_label(autor,new_info,target)
	
	if logs_container.get_child_count() >= get_parent().max_entries:
		var total_entries = logs_container.get_children().size()-1
		logs_container.get_child(total_entries).queue_free()
	
	logs_container.add_child(label_container)
	logs_container.move_child(label_container,0)
	get_parent().entry_index += 1
	$"../entries_counter".text = str(get_parent().entry_index)


func create_label(autor: Character, text: String, target: Character):
	var rich_label = RichTextLabel.new()
	rich_label.bbcode_enabled = true
	rich_label.fit_content = true
	rich_label.scroll_active = false
	rich_label.set("theme_override_font_sizes/normal_font_size",font_size)
	
	var a_color
	var t_color
	var player_color = '[color=blue]'
	var enemy_color = '[color=red]'
	a_color=player_color if autor.team==0 else enemy_color
	t_color=player_color if target.team==0 else enemy_color
	
	rich_label.text = str(a_color,'[',autor.name,'] ','[/color]',text,' ',t_color,target.name,'[/color]')
	
	return rich_label


func toggle_combat_log():
	self.visible = !self.visible
