class_name DialogBox extends PanelContainer

@onready var portrait := %Portrait
@onready var portrait_name := %PortraitName
@onready var text := %Text
@onready var dialog_options := %DialogOptions


func start(key:String):
	hide()
	if key == "close_dialog":
		close()
		return
	var portrait_path := str("res://character/portraits/",dialogs[key].speaker,".png")
	portrait.texture = load(portrait_path)
	portrait_name.text = dialogs[key].speaker.capitalize()
	
	text.text = dialogs[key].text
	
	update_options(dialogs[key].options)
	show()


func update_options(options:=[]):
	for do in dialog_options.get_children():
		do.queue_free()
	#add options
	for o in options:
		var dialog_option = Button.new()
		dialog_option.text = str(o.keys()[0])
		dialog_options.add_child(dialog_option)
		dialog_option.name = o[o.keys()[0]]
		dialog_option.pressed.connect(_on_dialog_option_selected.bind(dialog_option))


func _on_dialog_option_selected(dialog_btn:Button):
	Global.dialog_triggered.emit(dialog_btn.name)


func close():
	Global.close_dialog.emit()
	hide()


const dialogs := {
	"close_dialog":"",
	
	"mission_briefing":{
		"speaker": "tbug",
		"text": "Target's Sandra Dorsett. Her biomon went mute a couple hours back. Suspected abduction. Target could've been possibly flatlined already. Not sure you're in time.",
		"options":[{"Continue":'close_dialog'}]
		},
	
	"corpse_inspection":{
		"speaker": "v-male",
		"text": "Chrome is too simple. Not our girl I think",
		"options":[{"Ask T-Bug for more information":"corpse_inspection_tbug"},{"Ignore":"close_dialog"}]
		},
	
	"corpse_inspection_tbug":{
		"speaker": "tbug",
		"text": "Sandra Dorsett is protected under echelon II corpo immunity. Our girl's top shelf... This one's packin' black market Zetatech repros. Typical back-alley fix-ups. Not our lucky gal. Let's keep lookin'.",
		"options":[{"Continue":'close_dialog'}]
		}
	
	}
