import 'package:flutter/material.dart';

import '../models/chat_message.dart';
import '../widgets/te_ayudo_app_bar.dart';

class ChatScreen extends StatefulWidget {
  final String recipientName;
  final String taskTitle;

  const ChatScreen({
    super.key,
    required this.recipientName,
    required this.taskTitle,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();

  // Lista inicial de mensajes simulados para la conversación
  final List<ChatMessage> _messages = [
    ChatMessage(
      text: "¡Hola! Vi que aceptaste mi solicitud de ayuda.",
      isMe: false,
      time: "15:10",
    ),
    ChatMessage(
      text: "Hola, así es. ¿En qué dirección exacta nos vemos?",
      isMe: true,
      time: "15:11",
    ),
    ChatMessage(
      text: "Es en la calle principal #12, cerca de la plaza.",
      isMe: false,
      time: "15:12",
    ),
  ];

  void _sendMessage() {
    if (_controller.text.trim().isEmpty) return;

    setState(() {
      _messages.add(
        ChatMessage(
          text: _controller.text.trim(),
          isMe: true,
          time: TimeOfDay.now().format(context),
        ),
      );
      _controller.clear();
    });

    // Simular respuesta automática del otro usuario después de 1 segundo
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _messages.add(
            ChatMessage(
              text: "¡Perfecto! Quedamos de acuerdo entonces.",
              isMe: false,
              time: TimeOfDay.now().format(context),
            ),
          );
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    const primaryBlue = Color(0xFF1976D2);
    final colorScheme = Theme.of(context).colorScheme;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: isDarkMode ? const Color(0xFF12202E) : primaryBlue,
        foregroundColor: Colors.white,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.recipientName, style: const TextStyle(fontSize: 16)),
            Text(
              "Trabajo: ${widget.taskTitle}",
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w300),
            ),
          ],
        ),
        actions: [
          const ThemeToggleButton(),
          IconButton(
            icon: const Icon(Icons.phone),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Llamada interna protegida simulada"),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Aviso de seguridad del chat interno y retención escrow
          Container(
            padding: const EdgeInsets.all(8),
            color: isDarkMode ? const Color(0xFF12202E) : Colors.blue.shade50,
            child: Row(
              children: const [
                Icon(Icons.security, size: 16, color: primaryBlue),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "Chat protegido. El pago está retenido de forma segura hasta completar el microturno.",
                    style: TextStyle(fontSize: 11, color: Colors.blueAccent),
                  ),
                ),
              ],
            ),
          ),

          // Lista de mensajes
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                return Align(
                  alignment: msg.isMe
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.75,
                    ),
                    decoration: BoxDecoration(
                      color: msg.isMe
                          ? primaryBlue
                          : colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          msg.text,
                          style: TextStyle(
                            color: msg.isMe
                                ? Colors.white
                                : colorScheme.onSurface,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          msg.time,
                          style: TextStyle(
                            color: msg.isMe
                                ? Colors.white70
                                : colorScheme.onSurfaceVariant,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Barra inferior para escribir mensajes
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            color: colorScheme.surface,
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.add_circle_outline,
                    color: primaryBlue,
                  ),
                  onPressed: () {},
                ),
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: "Escribe un mensaje...",
                      filled: true,
                      fillColor: colorScheme.surfaceContainerHighest,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: const Color(
                    0xFF2E7D32,
                  ), // Botón verde de acción
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white, size: 18),
                    onPressed: _sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
