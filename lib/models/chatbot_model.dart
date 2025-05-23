class UserMessage {
  final String sender;
  final String message;

  UserMessage({
    required this.sender,
    required this.message,
  });

  factory UserMessage.fromJson(Map<String, dynamic> json) {
    return UserMessage(
      sender: json['sender'] as String,
      message: json['message'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sender': sender,
      'message': message,
    };
  }
}

class ChatbotResponse {
  final String recipientId;
  final String text;

  ChatbotResponse({
    required this.recipientId,
    required this.text,
  });

  factory ChatbotResponse.fromJson(Map<String, dynamic> json) {
    return ChatbotResponse(
      recipientId: json['recipient_id'] as String,
      text: json['text'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'recipient_id': recipientId,
      'text': text,
    };
  }
}
