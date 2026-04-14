import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';

class WebSocketService {
  WebSocketChannel? _channel;

  // Função para conectar
  void conectar(String jwt, Function(Map<String, dynamic>) onMessageReceived) {
    // Fecha conexão anterior se existir
    desconectar();

    // A URL que o Jefferson definiu, passando o token via query string
    final encodedToken = Uri.encodeComponent(jwt);
    final url =
        "wss://projeto-salmon-roe.onrender.com/v1/api/salmon_roe/user/ws?token=$encodedToken";

    try {
      _channel = WebSocketChannel.connect(Uri.parse(url));

      // Fica "ouvindo" as mensagens do servidor
      _channel!.stream.listen(
        (message) {
          final data = jsonDecode(message);
          onMessageReceived(data); // Envia os dados para a UI ou Provider
        },
        onError: (error) => print("Erro no WebSocket: $error"),
        onDone: () => print("Conexão WebSocket encerrada"),
      );
    } catch (e) {
      print("Não foi possível conectar ao WebSocket: $e");
    }
  }

  void desconectar() {
    _channel?.sink.close();
    _channel = null;
  }
}
