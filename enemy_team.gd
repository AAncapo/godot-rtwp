extends Node

var enemy_tscn = preload("res://characters/enemy.tscn")
@export_range(1,3) var enemies_in_team = 1
@onready var enemy_pos = $SpawnPositions.get_children()

func _ready():
	for e in range(enemies_in_team):
		var enemy:Character = enemy_tscn.instantiate()
		
		add_child(enemy)
		enemy.name = 'enemy'
		enemy.global_position = enemy_pos[e].global_position
