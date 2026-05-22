extends Node3D

@onready var terminal_ui = $TerminalUI
@onready var code_input = $TerminalUI/Control/Panel/VBoxContainer/LineEdit
@onready var posicao_tela = $monitor/PosicaoTela # Arraste o Marker3D pra cá!
@onready var player = $Player3D # Arraste o seu Player pra cá!

var camera_player : Camera3D
var transform_original_camera : Transform3D

func _ready():
	terminal_ui.hide()
	# Pega a referência da câmera de dentro do player
	camera_player = player.get_node("Camera3D")

func _on_zona_terminal_body_entered(body: Node3D) -> void:
	if body.name == "Player3D":
		# 1. Trava o jogador para ele não andar enquanto mexe no PC
		player.set_physics_process(false) 
		player.set_process_input(false)
		
		# 2. Salva a posição original da câmera para ela poder voltar depois
		transform_original_camera = camera_player.transform 
		
		# 3. Anima a câmera indo até o monitor (duração de 0.5 segundos)
		var tween = create_tween()
		# Move a câmera globalmente para a posição do Marker3D
		tween.tween_property(camera_player, "global_transform", posicao_tela.global_transform, 0.5).set_trans(Tween.TRANS_SINE)
		
		# Quando a animação terminar, mostra a UI e libera o mouse
		tween.tween_callback(abrir_interface)

func abrir_interface():
	terminal_ui.show()
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func liberar_jogador():
	player.set_physics_process(true)
	player.set_process_input(true)


func _on_sair_pressed() -> void:
	terminal_ui.hide()
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	# Faz a câmera voltar para o corpo do jogador
	var tween = create_tween()
	# Volta a câmera para o transform LOCAL original dela
	tween.tween_property(camera_player, "transform", transform_original_camera, 0.5).set_trans(Tween.TRANS_SINE)
	
	# Libera o jogador para andar de novo
	tween.tween_callback(liberar_jogador)
