// lib/services/send_email_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;

class SendEmailService {
  static const String _sendGridAPIKey =
      

  static Future<void> sendProfessorEmail({
    required String nome,
    required String email,
    required String password,
  }) async {
    final url = Uri.parse('https://api.sendgrid.com/v3/mail/send');

    final body = {
      "personalizations": [
        {
          "to": [
            {"email": email},
          ],
          "subject": "Acesso à Plataforma",
        },
      ],
      "from": {"email": "campuslinkprojei@gmail.com"}, // OU sandbox
      "content": [
        {
          "type": "text/plain",
          "value":
              "Olá $nome,\n\nA sua conta foi criada com sucesso.\nLogin: $email\nSenha: $password\n\nPor favor, altere a sua senha ao entrar.\n\nObrigado!",
        },
      ],
    };

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $_sendGridAPIKey',
        'Content-Type': 'application/json',
      },
      body: json.encode(body),
    );

    if (response.statusCode == 202) {
      print("✅ Email enviado com sucesso para $email");
    } else {
      print("❌ Erro ao enviar email: ${response.statusCode}");
      print("BODY: ${response.body}");
    }
  }
}
