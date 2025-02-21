extends AudioStreamPlayer

var rng:RandomNumberGenerator=RandomNumberGenerator.new()

var ambience:AudioStream=load("res://assets/audio/music/ambience.ogg")
var battle_tracks:Array[AudioStream]

func _ready() -> void:
	battle_tracks=[load("res://assets/audio/music/battle1.ogg"),load("res://assets/audio/music/battle2.ogg"),load("res://assets/audio/music/battle3.ogg")]

func play_battle_music():
	@warning_ignore("narrowing_conversion")
	var which_track:int=rng.randf_range(0,battle_tracks.size())
	stream=battle_tracks[which_track]
	play()

func stop_battle_music():
	$AnimationPlayer.play("stop_battle_music")

func play_ambience():
	stream=ambience
	play()
