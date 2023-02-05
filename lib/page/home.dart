import 'dart:developer' as d;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod/riverpod.dart';
import 'package:flutter/material.dart';
import 'package:socket_chat_tut/model/message_model.dart';
import 'package:socket_chat_tut/provider/message_state_provider.dart';
// import 'package:flutter_socket_io/model/message.dart';
// import 'package:flutter_socket_io/providers/home.dart';
// import 'package:intl/intl.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
//import 'package:provider/provider.dart';

/*final messageNotifier = StateNotifierProvider<MessageStateNotifier, List<Message>>((ref) {
  final notifier = ref.watch(messageNotifierProvider);
  return notifier
});*/


class HomeScreen extends ConsumerStatefulWidget {
  final String username;
  const HomeScreen({Key? key, required this.username}) : super(key: key);

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  late IO.Socket _socket;
  final TextEditingController _messageInputController = TextEditingController();

  _connectSocket(){
    _socket.onConnect((data) => d.log('Connection Established'));
    _socket.onError((data) => 'Connection Error: ${data}');
    _socket.onDisconnect((data) => 'Socket Server IO disconnected');
    _socket.on('message', (data) => ref.read(messageNotifierProvider.notifier).addNewMessage(Message.fromJson(data)));
  }

  _sendMessage(){
    _socket.emit('message', {
      'message': _messageInputController.text.trim(),
      'sender': widget.username
    });
    _messageInputController.clear();
  }

  /*_sendMessage() {
    _socket.emit('message', {
      'message': _messageInputController.text.trim(),
      'sender': widget.username
    });
    _messageInputController.clear();
  }*/

  @override
  void initState() {
    super.initState();
    _socket = IO.io('http://localhost:3000', IO.OptionBuilder().setTransports(['websocket']).setQuery(
        {'userName': widget.username}).build());
    _connectSocket();
    //Important: If your server is running on localhost and you are testing your app on Android then replace http://localhost:3000 with http://10.0.2.2:3000
    /*_socket = IO.io(
      'http://localhost:3000',
      IO.OptionBuilder().setTransports(['websocket']).setQuery(
          {'username': widget.username}).build(),
    );
    _connectSocket();*/
  }

  @override
  void dispose() {
    _messageInputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final newMessage = ref.watch(messageNotifierProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Socket.IO'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemBuilder: (context, index) {
                final message = newMessage[index];
                return Wrap(
                  alignment: message.senderUserName == widget.username
                      ? WrapAlignment.end
                      : WrapAlignment.start,
                  children: [
                    Card(
                      color: message.senderUserName == widget.username
                          ? Theme.of(context).primaryColorLight
                          : Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment:
                          message.senderUserName == widget.username
                              ? CrossAxisAlignment.end
                              : CrossAxisAlignment.start,
                          children: [
                            Text(message.message),
                          ],
                        ),
                      ),
                    )
                  ],
                );
              },
              separatorBuilder: (_, index) => const SizedBox(
                height: 5,
              ),
              itemCount: newMessage.length,
            )
          ),
          /*newMessage.isNotEmpty ? ListView.builder(
            itemCount: newMessage.length,
              shrinkWrap: true,
              itemBuilder: (context, index){
                return Text('${newMessage[index].message}');
              }
          ) : const SizedBox(),*/
          Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageInputController,
                      decoration: const InputDecoration(
                        hintText: 'Type your message here...',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      if(_messageInputController.text.isNotEmpty){
                        _sendMessage();
                      }
                    },
                    icon: const Icon(Icons.send),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
