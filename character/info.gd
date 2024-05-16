extends Sprite3D

@onready var actionBar:ProgressBar = $SubViewport/ActionBar

func _ready() -> void:
	texture = $SubViewport.get_texture()

func update(value, max_value):
	actionBar.max_value = max_value
	actionBar.value = value
