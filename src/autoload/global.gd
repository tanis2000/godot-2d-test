extends Node

var player: Node2D
var main: Node2D
var menu: Node2D
var hud: Node2D

enum InputType {
	INPUT_KEYBOARD,
	INPUT_CONTROLLER
}
var inputType := InputType.INPUT_KEYBOARD

var options := {
    name = "",
	sound_volume = 0.75,
	music_volume = 0.6,
}

var state := {
    dead = false,
    health = 10,
}

var stats := {
    total_enemies_killed = 0,
    total_bullets_fired = 0,
}
