extends Button

@onready var name_:Label = %Name
@onready var hitpoints_bar:ProgressBar = %Hitpoints
@onready var set1:Button = %Set1
#@onready var set2:Button = %Set2

var unit:
	set(val):
		unit = val
		if unit:
			name_.text = unit.name
			update_hp(unit.health, unit.max_health)
			
			set1.disabled = not unit.weapons.get_children()
			#set2.disabled = unit.weapons.get_child_count() < 2


func update_hp(hp, max_hp):
	hitpoints_bar.max_value = max_hp
	hitpoints_bar.value = hp


func _on_set_1_pressed() -> void:
	if unit and unit.is_selected: 
		for w in unit.weapons.get_children():
			if w.get_index() == 1:
				unit.equip(w)


#func _on_set_2_pressed() -> void:
	#if unit and unit.is_selected: 
		#for w in unit.weapons.get_children():
			#if w.get_index() == 1:
				#unit.equip(w)
