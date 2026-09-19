extends Node

@export var mob_scene: PackedScene
var health: int
var score
@onready var lowPassFilter = AudioServer.get_bus_effect(1, 0)

signal game_over_signal

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func player_hit() -> void:
	$HitSound.play()
	health -= 1
	$HUD.update_health(health)
	if health <= 0:
		game_over()
	else: 
		lowPassFilter.cutoff_hz = 300.0
		await get_tree().create_timer(1.8).timeout
		lowPassFilter.cutoff_hz = 20000

func game_over() -> void:
	$Player.game_over = true
	$Player.hide()
	$Player/CollisionShape2D.set_deferred("disabled", true)
	$Music.stop()
	$DeathSound.play()
	$ScoreTimer.stop()
	$MobTimer.stop()
	$HUD.show_game_over()

func new_game():
	$Player.game_over = false
	get_tree().call_group("mobs", "queue_free")
	score = 0
	health = 3
	$Player.start($StartPosition.position)
	$HUD.update_score(score)
	$HUD.update_health(health)
	$HUD.show_message("Get Ready")
	$StartTimer.start()
	$Music.play()


func _on_mob_timer_timeout() -> void:
	# Create a new instance of the Mob scene.
	var mob = mob_scene.instantiate()

	# Choose a random location on Path2D.
	var mob_spawn_location = $MobPath/MobSpawnLocation
	mob_spawn_location.progress_ratio = randf()

	# Set the mob's position to the random location.
	mob.position = mob_spawn_location.position

	# Set the mob's direction perpendicular to the path direction.
	var direction = mob_spawn_location.rotation + PI / 2

	# Add some randomness to the direction.
	direction += randf_range(-PI / 4, PI / 4)
	mob.rotation = direction

	# Choose the velocity for the mob.
	var velocity = Vector2(randf_range(150.0, 250.0), 0.0)
	mob.linear_velocity = velocity.rotated(direction)

	# Spawn the mob by adding it to the Main scene.
	add_child(mob)

func _on_score_timer_timeout() -> void:
	score += 1
	$HUD.update_score(score)

func _on_start_timer_timeout() -> void:
	$MobTimer.start()
	$ScoreTimer.start()
