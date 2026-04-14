import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../utils/config.dart';

class NotificationServices {
  final Dio dio = Dio()
    ..interceptors.add(LogInterceptor(responseBody: true, requestBody: true));
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  // Expõe a Stream para que o Provider possa ouvir as mensagens em tempo real
  Stream<RemoteMessage> get onMessageStream => FirebaseMessaging.onMessage;

  final String _urlFcm = "${Config.baseUrl}/user/fcm-token";

  // Apenas configura o básico do Firebase e registra o Token
  Future<void> inicializarNotificacoes(String? jwt) async {
    // Pede permissão (essencial para iOS e Android 13+)
    await _fcm.requestPermission();

    // Se o token mudar com o app aberto, atualiza no Go automaticamente
    _fcm.onTokenRefresh.listen((novoToken) {
      if (jwt != null) {
        registrarTokenNoBackend(jwt, novoToken);
      }
    });

    // Registrar o token atual agora
    if (jwt != null) {
      String? token = await _fcm.getToken();
      if (token != null) {
        await registrarTokenNoBackend(jwt, token);
      }
    }
  }

  Future<void> registrarTokenNoBackend(String jwt, String fcmToken) async {
    try {
      await dio.put(
        _urlFcm,
        data: {'token': fcmToken},
        options: Options(headers: {'Authorization': 'Bearer $jwt'}),
      );
      print("DIO_DEBUG: FCM Token registrado com sucesso");
    } on DioException catch (e) {
      print("DIO_DEBUG: Erro ao registrar FCM no Go: ${e.response?.data}");
    }
  }
}
