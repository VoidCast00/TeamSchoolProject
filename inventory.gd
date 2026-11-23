extends Node

signal inventory_changed
signal slot_selected(slot_index: int)
signal item_drop(item)

const Inventory_space := 5
var inventory: Array[ItemData]
var selected_slot: int = 0

func _init() -> void:
	for i in Inventory_space:
		inventory.append(null)
		
func _input(event):
	if event is InputEventKey and event.is_pressed():
		if event.keycode == KEY_G:
			drop_item(selected_slot)
		
func add_item(item: ItemData) -> bool:
	for i in Inventory_space:
		if inventory[i] == null:
				inventory[i] = item
				inventory_changed.emit()
				slot_selected.emit(i)
				return true
	return false

func select_slot(index: int):
	print(index)
	selected_slot = clamp(index, 0, Inventory_space - 1)
	slot_selected.emit(selected_slot)
	
func spawn_item(item : ItemData):
	var interactable = item.interactable_scene.instantiate()
	interactable.itemData = item
	get_tree().current_scene.add_child(interactable)
	item_drop.emit(interactable)
 
func drop_item(slot_index: int):
	if inventory[slot_index]:
		var dropped_item = inventory[slot_index]
		spawn_item(dropped_item)
		inventory[slot_index] = null
		inventory_changed.emit()
		if slot_index == selected_slot:
			slot_selected.emit(selected_slot)
