import 'package:flutter/material.dart';
import 'package:signalr_netcore/signalr_client.dart';
import 'package:en_masse_app/config.dart';

class SignalRService {
  HubConnection? _hubConnection;
  final String serverUrl = 'https://${Config.apiBaseUrl}/cafeHub';

  // Callbacks to handle SignalR events
  Function(String userName, String message)? onMessageReceived;

  SignalRService() {
    _hubConnection = HubConnectionBuilder().withUrl(serverUrl).build();
    _hubConnection?.onclose(({Exception? error}) => print('Connection Closed'));
    _hubConnection?.on('ReceiveMessage', _handleIncomingMessage);
  }

  Future<void> startConnection() async {
    await _hubConnection?.start();
    print('Connection Started');
  }

  Future<void> joinCafeGroup(String cafeId, String userId) async {
    await _hubConnection?.invoke('JoinCafeGroup', args: [cafeId, userId]);
    print('Attempted to join Cafe Group: $cafeId with User: $userId');
  }


  Future<void> sendMessage(String cafeId, String userName, String message) async {
    await _hubConnection?.invoke('SendMessage', args: [cafeId, userName, message]);
  }

  void _handleIncomingMessage(List<dynamic>? arguments) {
    if (arguments != null && arguments.length >= 2) {
      String userName = arguments[0];
      String message = arguments[1];
      onMessageReceived?.call(userName, message);
    }
  }

  void dispose() {
    _hubConnection?.stop();
  }
}
