extends Interactable


func interact():
	Global.dialog_triggered.emit("corpse_inspection")
