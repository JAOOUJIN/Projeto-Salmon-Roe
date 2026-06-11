import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

class AppMasks {
  // Máscara para CPF
  static final cpfMask = MaskTextInputFormatter(
    mask: '###.###.###-##',
    filter: {"#": RegExp(r'[0-9]')},
    type: MaskAutoCompletionType.lazy,
  );

  // Máscara para Telefone
  static final phoneMask = MaskTextInputFormatter(
    mask: '(##) #####-####',
    filter: {"#": RegExp(r'[0-9]')},
    type: MaskAutoCompletionType.lazy,
  );

  // Função para validar CPF 
  static bool isValidCPF(String? cpf) {
    if (cpf == null || cpf.isEmpty) return false;

    // Remove tudo que não for número
    String cleanCPF = cpf.replaceAll(RegExp(r'[^0-9]'), '');

    if (cleanCPF.length != 11) return false;
    if (RegExp(r'^(\d)\1*$').hasMatch(cleanCPF)) return false;

    int calcDigit(String str, int length) {
      int sum = 0;
      for (int i = 0; i < length; i++) {
        sum += int.parse(str[i]) * (length + 1 - i);
      }
      int mod = sum % 11;
      return mod < 2 ? 0 : 11 - mod;
    }

    int d1 = calcDigit(cleanCPF, 9);
    int d2 = calcDigit(cleanCPF, 10);

    return d1 == int.parse(cleanCPF[9]) && d2 == int.parse(cleanCPF[10]);
  }
}
