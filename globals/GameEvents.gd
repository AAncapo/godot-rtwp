extends Node

#Character
signal command(target)
signal character_died(character_node)
signal update_char_ui(character)

signal hover_target(target, is_hovered:bool)

signal form_selected(formation_index)
#Camera
signal focus_world_object(obj, center_cam)


signal switch_weapon(weapon)
