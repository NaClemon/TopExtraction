class_name EquipmentItem
extends Resource

enum SlotType { WEAPON, ARMOR, HELMET, UTILITY }

@export var item_name: String = ""
@export_multiline var description: String = ""
@export var icon: Texture2D
@export var slot_type: SlotType = SlotType.WEAPON
