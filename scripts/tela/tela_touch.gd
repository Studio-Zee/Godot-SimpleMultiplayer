extends StaticBody3D

@export var viewport: SubViewport
@onready var shape = $CollisionShape3D.shape as BoxShape3D

@warning_ignore("unused_parameter")
func _on_input_event(camera: Node, event: InputEvent, hit_position: Vector3, normal: Vector3, shape_idx: int) -> void:
	
	if event is InputEventMouseButton or event is InputEventScreenTouch:
		
		# NOVA LINHA: Agora calculamos a posição local exata da Caixa de Colisão (mesmo que ela esteja fora de centro)
		var local_pos = $CollisionShape3D.to_local(hit_position)
		
		var box_size = shape.size
		var vp_size = viewport.size

		# X continua invertido pelo espelhamento:
		var percent_x = 1.0 - ((local_pos.x + (box_size.x / 2.0)) / box_size.x)
		# Y normalizado:
		var percent_y = ((box_size.y / 2.0) - local_pos.y) / box_size.y

		var vp_pos = Vector2(round(percent_x * vp_size.x), round(percent_y * vp_size.y))

		var ev = event.duplicate()
		ev.position = vp_pos
		
		if ev is InputEventMouseButton:
			ev.global_position = vp_pos

		viewport.push_input(ev)
		
func _input(event):
	if event is InputEventKey:
		viewport.push_input(event)
		# Avisa a engine principal: "Já cuidei dessa tecla, não duplique ela!"
		get_viewport().set_input_as_handled()
