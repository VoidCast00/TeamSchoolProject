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
