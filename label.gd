extends Label
@export var label: Label

func _process(delta: float) -> void:
	label.text = Globals.curItemName
