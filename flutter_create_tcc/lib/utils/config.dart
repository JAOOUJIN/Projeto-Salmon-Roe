import 'package:flutter/foundation.dart';
class Config {
  static String get baseUrl {
    // Forçando o Render mesmo em Debug para o seu teste
    //return "https://projeto-salmon-roe.onrender.com/v1/api/salmon_roe";

    if (kReleaseMode) {
      return "https://projeto-salmon-roe.onrender.com/v1/api/salmon_roe";
    } else {
      return "http://192.168.15.4:8080/v1/api/salmon_roe";
    }

  }
}
// Para desenvolvimento, force o IP da máquina
// Mude para "http://10.0.2.2:5000/api" quando for testar no emulador // Android "http://192.168.15.3:5000/api"
// Mudar para o Render quando for para produção "https://projeto-salmon-roe.onrender.com/api"