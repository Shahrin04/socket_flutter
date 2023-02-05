import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:socket_chat_tut/model/message_model.dart';

final messageNotifierProvider = StateNotifierProvider<MessageStateNotifier, List<Message>>((ref) => MessageStateNotifier());

class MessageStateNotifier extends StateNotifier<List<Message>>{
  MessageStateNotifier() : super([]);

  addNewMessage(Message message){
    state = [...state, message];
  }

}