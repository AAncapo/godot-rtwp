extends Node

#Character
signal character_died(character_node)
signal update_char_ui(character)
#Formations
signal ui_toggle_form_tab
signal form_selected(formation_index)
#Camera
signal focus_worldobject(obj, center_cam)
#Debug Console
signal ui_toggle_combat_log
signal update_clg(autor, new_info, target)