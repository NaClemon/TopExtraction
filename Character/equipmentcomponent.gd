class_name EquipmentComponent
extends Node

var equipment: Dictionary = {
	EquipmentItem.SlotType.WEAPON: null,
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func equip_item(slot: EquipmentItem.SlotType, item: Item) -> void:
	if equipment.has(slot):
		equipment[slot] = item

func unequip_item(slot: EquipmentItem.SlotType) -> void:
	var old_item = equipment[slot]
	equipment[slot] = null
