extends Node

var player: Node2D
var main: Node2D
var menu: Node2D
var hud: Node2D

var options := {
    name = "",
	sound_volume = 0.75,
	music_volume = 0.6,
}

var state := {
    dead = false,
    health = 10,
}