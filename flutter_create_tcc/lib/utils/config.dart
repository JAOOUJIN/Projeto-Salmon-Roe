
class Config {
  static String get baseUrl {
    // Para desenvolvimento, force o IP da máquina
    // Mude para "http://10.0.2.2:5000/api" quando for testar no emulador
    return "http://192.168.15.3:5000/api";
  }
}
