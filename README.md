# Godot Simple Multiplayer 3D

SimpleMultiplayer3D is a lightweight Godot plugin for real-time 3D multiplayer over WebSocket, designed with a mobile-first workflow in mind. It is suitable for fast prototyping, local mobile testing, and real multiplayer projects with a separate Node.js backend.

## Features

- WebSocket multiplayer
- Android support
- Desktop support
- Local server testing
- Online deployment support
- Fast setup
- Mobile-first workflow
- Godot integration
- Easy room/session handling
- Real-time sync

## Requirements

- Godot 4.x compatible version, tested with Godot 4.6
- Android export templates for mobile builds
- Internet permission enabled for Android online testing
- Node.js LTS recommended for the backend server
- Termux optional for local mobile testing on Android

## Installation

1. Install the plugin from the Godot Asset Library.
2. Enable the plugin in Godot: Project > Project Settings > Plugins.
3. The plugin files will be available under `res://addons/simplemultiplayer3d/`.
4. Make sure the autoloads are enabled in the project settings if you are integrating the addon manually:
   - `WebSocketClient`
   - `MultiplayerManager`
5. Configure the server URL in Project Settings if needed:
   - `simple_multiplayer/server_url`

## Quick Start

1. Enable the plugin.
2. Open the demo scene.
3. Start the local server.
4. Run the project.
5. Connect the client.

For the first test, the recommended flow is to run the Node.js server locally, open the demo lobby, and verify that the client connects and enters the waiting room correctly.

## Server Repository

This plugin was developed to work with a separate repository from the Node.js server, where you can find the complete step-by-step instructions for installing, configuring, and running the backend.

Server repository: [Open server repository](https://github.com/Studio-Zee/Godot-SimpleMultiplayerServer)

Use this repository when you need:

- Server configuration instructions
- Backend installation steps
- Local and online server execution
- Environment-specific configuration details

It is recommended to keep the Godot plugin and the backend in separate repositories so that the client project remains lightweight and easy to distribute.

## Local Testing on Android (Termux)

This is the recommended workflow for mobile development.

### Install Termux dependencies

```bash
pkg update
pkg install nodejs
```

### Run the local server

```bash
node server.js
```

### Find your local Wi-Fi IP address

```bash
ifconfig
```

Use the IP address assigned by your Wi-Fi network, not `localhost`, when connecting from another device.

### Connection example

```plaintext
ws://192.168.x.x:PORT
```

For local Android testing:

- The phone and the client device must be on the same network.
- Replace `localhost` with the local IP address of the machine running the server.
- Keep the server reachable from the mobile device over Wi-Fi.

If the server runs on the Android device itself, use the device's local network IP or the appropriate loopback route for the test environment.

## Testing Online

You can deploy the Node.js backend on:

- Render
- VPS
- Railway
- Any Node.js hosting provider

When exporting to Android as an APK, the Godot internet permission must be enabled.

> [!IMPORTANT]
> On exported Android APKs, enable internet permission in Godot:
> Project > Export > Android > Permissions > INTERNET
>
> Without this permission, the client will not connect to online servers.

## Mobile Export Setup

1. Generate the Android export templates.
2. Enable internet permission.
3. Export the project as APK.
4. Install the APK on the device.
5. Test the connection against your local or online server.

## Example Connection

```gdscript
extends Node

func _ready() -> void:
	var ws_client = get_node_or_null("/root/WebSocketClient")
	if ws_client:
		ws_client.connect_to_server("ws://127.0.0.1:9090")
```

## Project Structure

- `addons/simplemultiplayer3d/` - Plugin source code, editor entry point, WebSocket client, and multiplayer manager
- `exemplo/` - Demo content used to validate the workflow and show how the plugin is consumed
- `exemplo/cenas/` - Sample scenes for lobby, waiting room, test world, and related flows
- `exemplo/scripts/` - Gameplay and UI scripts used by the demo scenes
- `exemplo/player/` - Local and network player scenes
- `project.godot` - Godot project configuration and autoload registration

## Troubleshooting

- Connection refused: Verify that the server is running and that the URL and port are correct.
- Infinite reconnect: Check whether the server is closing the socket or rejecting the handshake.
- Android not connecting: Confirm that the device can reach the server over Wi-Fi and that the server URL is not using `localhost`.
- Localhost not working on device: Replace `localhost` with the local IP of the machine hosting the server.
- Missing internet permission: Enable `Project > Export > Android > Permissions > INTERNET` before building the APK.
- Wrong local IP: Use `ip addr show wlan0` on Termux or check the network adapter on your host machine.
- Server offline: Start the Node.js backend before launching the Godot client.
- Port blocked: Ensure the firewall allows inbound traffic on the selected WebSocket port.

## Performance Notes

- WebSocket is efficient for small to medium multiplayer state updates, but it is not a replacement for full netcode optimization.
- Prefer compact payloads and avoid sending unnecessary data every frame.
- Use a sensible network tick rate for position sync instead of spamming packets continuously.
- On mobile, keep replication lean to reduce battery use and network overhead.
- Avoid excessive RPC spam or redundant position broadcasts when state has not changed.

## Contribution

Contributions are welcome.

Please open an issue or pull request with clear reproduction steps, a short description of the change, and any relevant test notes.

## License

Placeholder.

## Support

Placeholder.

---

# Godot Simple Multiplayer 3D

SimpleMultiplayer3D é um plugin leve para multiplayer 3D em tempo real via WebSocket, desenvolvido com fluxo mobile-first em mente. Ele é indicado para prototipagem rápida, testes locais no celular e projetos multiplayer reais com backend separado em Node.js.

## Features

- Multiplayer via WebSocket
- Suporte a Android
- Suporte a desktop
- Testes locais com servidor
- Suporte a deploy online
- Configuração rápida
- Fluxo mobile-first
- Integração com Godot
- Gerenciamento simples de salas/sessões
- Sincronização em tempo real

## Requirements

- Versão compatível com Godot 4.x, testado com Godot 4.6
- Export templates de Android para builds mobile
- Permissão de internet habilitada para testes online no Android
- Node.js LTS recomendado para o servidor backend
- Termux opcional para testes locais mobile no Android

## Installation

1. Instale o plugin pela Godot Asset Library.
2. Ative o plugin em Godot: Project > Project Settings > Plugins.
3. Os arquivos do plugin ficam em `res://addons/simplemultiplayer3d/`.
4. Se estiver integrando manualmente, confirme os autoloads no projeto:
   - `WebSocketClient`
   - `MultiplayerManager`
5. Configure a URL do servidor no Project Settings, se necessário:
   - `simple_multiplayer/server_url`

## Quick Start

1. Ative o plugin.
2. Abra a cena de demo.
3. Inicie o servidor local.
4. Execute o projeto.
5. Conecte o cliente.

Para o primeiro teste, o fluxo recomendado é rodar o servidor Node.js localmente, abrir o lobby de demonstração e verificar se o cliente conecta e entra corretamente na sala de espera.

## Repositório do Servidor

Este plugin foi desenvolvido para funcionar com um repositório separado do servidor Node.js, onde está o passo a passo completo de instalação, configuração e execução do backend.

Repositório do servidor: [Abrir o repositório do servidor](https://github.com/Studio-Zee/Godot-SimpleMultiplayerServer)

Use esse repositório quando precisar de:

- Instruções de configuração do servidor
- Etapas de instalação do backend
- Execução local e online do servidor
- Detalhes de configuração específicos do ambiente

A recomendação é manter o plugin Godot e o backend em repositórios separados, para que o projeto do cliente continue leve e fácil de distribuir.

## Local Testing on Android (Termux)

Este é o fluxo recomendado para desenvolvimento mobile.

### Instalação do Termux

```bash
pkg update
pkg install nodejs
```

### Rodar o servidor local

```bash
node server.js
```

### Descobrir o IP local da rede Wi-Fi

```bash
ip addr show wlan0
```

Use o endereço IP fornecido pela sua rede Wi-Fi, e não `localhost`, ao conectar a partir de outro dispositivo.

### Exemplo de conexão

```plaintext
ws://192.168.x.x:PORT
```

Para testes locais no Android:

- O celular e o cliente precisam estar na mesma rede.
- Troque `localhost` pelo IP local da máquina que está executando o servidor.
- Garanta que o servidor esteja acessível via Wi-Fi para o dispositivo mobile.

Se o servidor estiver rodando no próprio Android, use o IP local da rede do dispositivo ou a rota de loopback adequada ao ambiente de teste.

## Testing Online

Você pode hospedar o backend Node.js em:

- Render
- VPS
- Railway
- Qualquer provedor de hospedagem Node.js

Ao exportar para Android como APK, a permissão de internet da Godot precisa estar habilitada.

> [!IMPORTANT]
> No APK exportado para Android, ative a permissão de internet em Godot:
> Project > Export > Android > Permissions > INTERNET
>
> Sem isso, o cliente não conecta em servidores online.

## Mobile Export Setup

1. Gere os export templates de Android.
2. Habilite a permissão de internet.
3. Exporte o projeto como APK.
4. Instale o APK no dispositivo.
5. Teste a conexão com seu servidor local ou online.

## Example Connection

```gdscript
extends Node

func _ready() -> void:
	var ws_client = get_node_or_null("/root/WebSocketClient")
	if ws_client:
		ws_client.connect_to_server("ws://127.0.0.1:9090")
```

## Project Structure

- `addons/simplemultiplayer3d/` - Código-fonte do plugin, ponto de entrada do editor, cliente WebSocket e gerenciador de multiplayer
- `exemplo/` - Conteúdo de demonstração usado para validar o fluxo e mostrar como o plugin é consumido
- `exemplo/cenas/` - Cenas de exemplo para lobby, sala de espera, mundo de teste e fluxos relacionados
- `exemplo/scripts/` - Scripts de gameplay e interface usados pelas cenas de demonstração
- `exemplo/player/` - Cenas do jogador local e do jogador de rede
- `project.godot` - Configuração do projeto Godot e registro dos autoloads

## Troubleshooting

- Connection refused: Verifique se o servidor está rodando e se a URL e a porta estão corretas.
- Infinite reconnect: Confirme se o servidor está encerrando o socket ou rejeitando o handshake.
- Android not connecting: Verifique se o dispositivo alcança o servidor via Wi-Fi e se a URL do servidor não usa `localhost`.
- Localhost not working on device: Troque `localhost` pelo IP local da máquina que hospeda o servidor.
- Missing internet permission: Habilite `Project > Export > Android > Permissions > INTERNET` antes de gerar o APK.
- Wrong local IP: Use `ip addr show wlan0` no Termux ou confira a interface de rede na máquina host.
- Server offline: Inicie o backend Node.js antes de abrir o cliente Godot.
- Port blocked: Garanta que o firewall permite tráfego de entrada na porta WebSocket escolhida.

## Performance Notes

- WebSocket é eficiente para estados multiplayer pequenos e médios, mas não substitui uma arquitetura de netcode otimizada.
- Prefira payloads compactos e evite enviar dados desnecessários a cada frame.
- Use uma taxa de atualização de rede sensata para sincronização de posição, em vez de saturar a rede com pacotes contínuos.
- No mobile, mantenha a replicação enxuta para reduzir consumo de bateria e overhead de rede.
- Evite spam excessivo de RPCs ou transmissões redundantes de posição quando o estado não mudou.

## Contribution

Contribuições são bem-vindas.

Abra uma issue ou pull request com passos claros de reprodução, uma descrição curta da mudança e qualquer nota de teste relevante.

## License

Placeholder.

## Support

Placeholder.
