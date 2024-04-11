extends Node

#Character
signal character_died(character_node)
signal update_char_ui(character)

signal hover_target(target:Character, is_hovered:bool)
#Formations
signal ui_toggle_form_tab
signal form_selected(formation_index)
#Camera
signal focus_world_object(obj, center_cam)
#Debug Console
signal ui_toggle_combat_log
