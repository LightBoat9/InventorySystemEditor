tool
extends "res://addons/inventory/types/inventory_slot.gd"

var modulate_color = Color(230.0/255.0,230.0/255.0,230.0/255.0,1)

func _ready():
	connect("mouse_entered", self, "mouse_entered")
	connect("mouse_exited", self, "mouse_exited")
	
func mouse_entered(test):
	modulate = Color(230.0/255.0,230.0/255.0,230.0/255.0,1)
	
func mouse_exited(test):
	modulate = Color(1,1,1)