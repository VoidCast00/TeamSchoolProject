extends HBoxContainer
@export var curSlot: StyleBoxFlat

var slots: Array

func _ready() -> void:
	get_slots()
	Inventory.inventory_changed.connect(_update_inventory)
	Inventory.slot_selected.connect(_highlight_slot)
	_update_inventory()

func get_slots():
	slots = get_children()
	for slot : TextureButton in slots:
		slot.pressed.connect(Inventory.select_slot.bind(slot.get_index()))

func _update_inventory():
	for slot: TextureButton in slots:
		var item = Inventory.inventory[slot.get_index()]
		slot.texture_normal = item.icon if item else null

func _highlight_slot(slot_index: int):
	for i in range(5):
		slots[i].modulate = Color(0.5,0.5,0.5)
	slots[slot_index].modulate = Color(1.5,1.5,1.5)
