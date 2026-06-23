class_name EquipmentItem
extends Item

enum SlotType { WEAPON, ARMOR, HELMET, UTILITY }

@export_multiline var description: String = ""
@export var slot_type: SlotType = SlotType.WEAPON
