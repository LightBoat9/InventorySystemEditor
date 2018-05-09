tool
extends "res://addons/inventory/types/inventory_slot.gd"

var modulate_color = Color(230.0/255.0,230.0/255.0,230.0/255.0,1)

func _ready():
	connect("global_mouse_entered", self, "mouse_entered")
	connect("global_mouse_exited", self, "mouse_exited")
	
func mouse_entered():
	modulate = Color(230.0/255.0,230.0/255.0,230.0/255.0,1)
	
func mouse_exited():
	modulate = Color(1,1,1)