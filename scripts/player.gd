extends Area2D

signal hit

@export var speed: int = 400
var screen_size
var game_over: bool = false
enum direction {DOWN, UP, RIGHT, LEFT}

@export var facing: direction = direction.DOWN

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	screen_size = get_viewport_rect().size
	hide()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var velocity = Vector2.ZERO
	if Input.is_action_pressed("move_right"):
		velocity.x += 1
	if Input.is_action_pressed("move_left"):
		velocity.x -= 1
	if Input.is_action_pressed("move_up"):
		velocity.y -= 1
	if Input.is_action_pressed("move_down"):
		velocity.y += 1
	
	$AnimatedSprite2D.play()
	if velocity.length() > 0:
		velocity = velocity.normalized() * speed
		#$AnimatedSprite2D.play()
	else:
		#$AnimatedSprite2D.stop()
		# pick idle pose
		pick_idle_sprite()
	
	position += velocity * delta
	position = position.clamp(Vector2.ZERO, screen_size)
	
	if velocity.x < 0:
		$AnimatedSprite2D.animation = "walk_left"
		facing = direction.LEFT
		#$AnimatedSprite2D.flip_v = false
		#$AnimatedSprite2D.flip_h = velocity.x < 0
		
	elif velocity.x > 0:
		$AnimatedSprite2D.animation = "walk_right"
		facing = direction.RIGHT
	elif velocity.y < 0:
		$AnimatedSprite2D.animation = "walk_back"
		facing = direction.UP
		#$AnimatedSprite2D.flip_v = velocity.y > 0
	elif velocity.y > 0:
		$AnimatedSprite2D.animation = "walk_front"
		facing = direction.DOWN


func _on_body_entered(body: Node2D) -> void:
	#hide() # Player disappears after being hit.
	hit.emit()
	$CollisionShape2D.set_deferred("disabled", true)
	$AnimationPlayer.play("iframes")
	await $AnimationPlayer.animation_finished
	if not game_over:
		$CollisionShape2D.set_deferred("disabled", false)
	# Must be deferred as we can't change physics properties on a physics callback.
	# $CollisionShape2D.set_deferred("disabled", true)
	
func start(pos):
	position = pos
	facing = direction.DOWN
	show()
	$CollisionShape2D.disabled = false

func pick_idle_sprite():
	match facing:
		direction.DOWN:
			$AnimatedSprite2D.animation = "idle_front"
		direction.UP:
			$AnimatedSprite2D.animation = "idle_back"
		direction.LEFT:
			$AnimatedSprite2D.animation = "idle_left"
		direction.RIGHT:
			$AnimatedSprite2D.animation = "idle_right"
