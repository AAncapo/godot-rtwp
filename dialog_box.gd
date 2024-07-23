class_name DialogBox extends PanelContainer

@onready var portrait := %Portrait
@onready var portrait_name := %PortraitName
@onready var text := %Text
@onready var dialog_options := %DialogOptions


func start(key:String):
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
	if dialog_btn.name.begins_with("close_dialog"):
		end_dialog()
		return
	if dialog_btn.name.begins_with("traumateam_bot"):
		#trigger trauma team event
		pass
	Global.dialog_triggered.emit(dialog_btn.name)


func end_dialog():
	Global.close_dialog.emit()
	hide()


const dialogs := {
	"close_dialog":"",
	
	"mission_briefing":{
		"speaker": "tbug",
		"text": "Target's Sandra Dorsett. Her biomon went mute a couple hours back. Suspected abduction. Target could've been possibly flatlined already. Not sure you're in time.",
		"options":[{"Continue":'close_dialog'}]
		},
	
	"corpse_inspection_jackie":{
		"speaker": "jackie",
		"text": "Grr, are we fuckin' late? Is that her. That our target, V?!",
		"options":[{"Inspect":"corpse_inspection"}]
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
		},
	
	"sandra_dorsett":{
		"speaker": "v-male",
		"text": "Think I got her, got our target\nT-Bug: We make it? She alive?",
		"options":[{"Check target's biomonitor":'sandra_biomonitor'}]
		},
	
	"sandra_biomonitor":{
		"speaker": "v-male",
		"text": "Sandra Dorsett. NC570442. Got a winner. Or she will be if we get her to a hospital... Sheesh, Trauma Team Platinum too.",
		"options":[{"Continue":'jackie_tt_commentary'}]
		},
	
	"jackie_tt_commentary":{
		"speaker": "jackie",
		"text": "Platinum? Shit. TT shoulda swooped in if she sneezed.",
		"options":[{"Continue":'check_biomon_jamming'}]
		},
	
	"check_biomon_jamming":{
		"speaker": "v-male",
		"text": "Something's jamming the biomon signal. Talk to me, T-Bug.\nT-Bug: Virus, probably. Locate her neurosocket - should be a shard slotted in , shit's probably on that. If we clear it, free up the signal, TT could actually drop in, take her off our hands.",
		"options":[{"Pull the shard":'traumateam_bot'}]
		},
	
	"traumateam_bot":{
		"speaker": "v-male", #TODO change to TT logo
		"text": "Trauma Team International: Greetings Sandra. An emergency evacuation unit has been dispatched and is due to arrive at your location in 180 seconds.\nV: Biomon claims Trauma'll be here in three minutes.\nTrauma Team International: Your Premium plan will cover 90% of the projected of your rescue and treatment-",
		"options":[{"Pick up the woman":'close_dialog'}]
		}
	
	}
