class Message{
  final String message;
  final String senderUserName;
  final DateTime sendAt;

  Message({required this.message, required this.senderUserName, required this.sendAt});

  factory Message.fromJson(Map<String, dynamic> message){
    return Message(message: message['message'], senderUserName: message['senderUserName'], sendAt: DateTime.fromMillisecondsSinceEpoch(message['sendAt'] * 1000));
  }

}