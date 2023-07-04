extends Node3D

var enemy_tscn = preload("res://characters/enemy.tscn")
@export_range(1,3) var enemies_in_team = 1


func _on_player_team_player_team_initialized():
	var enemy_pos = $SpawnPositions.get_children()
	for e in range(enemies_in_team):
		var enemy:Character = enemy_tscn.instantiate()
		
		add_child(enemy)
		enemy.name = str('enemy ', e)
		enemy.global_position = enemy_pos[e].global_position
