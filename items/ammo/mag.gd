class_name Ammo extends Item

@export var total_amount:int
@onready var current_amount:int = total_amount:
	set(value): current_amount = max(0,value)


func is_empty(): return current_amount == 0

func is_full(): return current_amount == total_amount
