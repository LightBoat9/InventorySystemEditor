extends Control

const armor = preload("res://demos/minecraft/items/armor.gd")
const boots = preload("res://demos/minecraft/items/boots.gd")
const gloves = preload("res://demos/minecraft/items/gloves.gd")
const helmet = preload("res://demos/minecraft/items/helmet.gd")
const shield = preload("res://demos/minecraft/items/shield.gd")

func _ready() -> void:
	$PanelContainer/VBoxContainer/Toolbar/DragSlot.item = armor.new()
	$PanelContainer/VBoxContainer/Toolbar/DragSlot2.item = boots.new()
	$PanelContainer/VBoxContainer/Toolbar/DragSlot3.item = gloves.new()
	$PanelContainer/VBoxContainer/Toolbar/DragSlot4.item = helmet.new()
	$PanelContainer/VBoxContainer/Toolbar/DragSlot5.item = shield.new()
