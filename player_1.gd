extends CharacterBody3D

# إعدادات الحارات (Lanes)
var current_lane = 0 
const LANE_WIDTH = 2.4 
const CHANGE_SPEED = 0.2 

# إعدادات القفز والجاذبية
const JUMP_VELOCITY = 4.5
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

# --- التعديل هنا للوصول للأنميشن بشكل أدق ---
@onready var anim_player = find_child("AnimationPlayer") 

# متغيرات السحب (Swipe)
var swipe_start_pos = Vector2.ZERO
var min_swipe_distance = 50

func _ready():
	# ننتظر فريم واحد للتأكد من تحميل كل العقد
	await get_tree().process_frame
	if anim_player:
		if anim_player.has_animation("Running1"):
			anim_player.play("Running1")
			print("تم تشغيل الأنميشن بنجاح!")
		else:
			print("خطأ: الأنميشن Running1 غير موجود داخل AnimationPlayer")
	else:
		print("خطأ: لم يتم العثور على عقدة AnimationPlayer")

func _input(event):
	if event is InputEventScreenTouch:
		if event.pressed:
			swipe_start_pos = event.position
		else:
			_calculate_swipe(event.position)

func _calculate_swipe(end_pos: Vector2):
	var swipe_vector = end_pos - swipe_start_pos
	
	if swipe_vector.length() > min_swipe_distance:
		if abs(swipe_vector.x) > abs(swipe_vector.y):
			if swipe_vector.x > 0:
				_change_lane(1) 
			else:
				_change_lane(-1) 
		else:
			if swipe_vector.y < 0 and is_on_floor():
				_jump()

func _change_lane(direction):
	current_lane = clampi(current_lane + direction, -1, 1)
	var target_x = current_lane * LANE_WIDTH
	
	var tween = create_tween()
	# استخدمت self.global_position.x لضمان دقة الحركة في الـ 3D
	tween.tween_property(self, "position:x", target_x, CHANGE_SPEED).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

func _jump():
	velocity.y = JUMP_VELOCITY
	# إذا أردت إضافة أنميشن قفز لاحقاً:
	# anim_player.play("Jump")

func _physics_process(delta):
	# الجاذبية
	if not is_on_floor():
		velocity.y -= gravity * delta
	
	move_and_slide()
