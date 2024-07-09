class_name Consumable extends Item

@export var total_amount:int
@onready var current_amount := total_amount:
	set(value): current_amount = max(0,value)


func consume():
	current_amount -= 1
