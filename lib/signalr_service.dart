import 'package:flutter/material.dart';
import 'package:signalr_netcore/signalr_client.dart';
import 'package:en_masse_app/config.dart';
import 'Authentication/authentication.dart';
import 'BarItems/Cafe/session_message.dart';
import 'package:logging/logging.dart';

class SignalRService {
  HubConnection? _hubConnection;

  final hubProtLogger = Logger("SignalR - hub");
  final transportProtLogger = Logger("SignalR - transport");

  final String serverUrl = 'https://${Config.apiBaseUrl}/hubs/cafeHub';
  Function(String userName, String messageJson)? onMessageReceived;
  Function(String cafeId, List<SessionMessage> newMessages)? onNewMessagesReceived;

  SignalRService() {
    _configureLogging();
    _hubConnection = HubConnectionBuilder().withUrl(serverUrl).configureLogging(hubProtLogger).build();
    _hubConnection?.onclose(({Exception? error}) => print('Connection Closed'));
    _hubConnection?.on('ReceiveMessage', _handleIncomingMessage);
    _hubConnection?.on('ReceiveNewMessages', _handleNewMessages);
  }

  void _configureLogging() {
    // Configure the root logger
    Logger.root.level = Level.ALL; // Record all logs
    Logger.root.onRecord.listen((LogRecord rec) {
    print('${rec.level.name}: ${rec.time}: ${rec.message}');});
  }

  Future<void> startConnection() async {
    if (_hubConnection?.state != HubConnectionState.Connected) {
      await _hubConnection?.start();
      print('Connection Started');
      await reconnectToAllGroupsAndRetrieveNewMessages();
    }
  }

  Future<void> reconnectToAllGroupsAndRetrieveNewMessages() async {
    String? userId = await AuthService.getUserId();

    userId ??= "";

    if (_hubConnection?.state == HubConnectionState.Connected) {
      await _hubConnection?.invoke('ReconnectToAllGroupsAndRetrieveNewMessages', args: [userId]);
    } else {
      print('Connection is not in a Connected State');
    }
  }

  Future<void> joinCafeGroup(String cafeId, String userId) async {
    if (_hubConnection?.state == HubConnectionState.Connected) {
      await _hubConnection?.invoke('JoinCafeGroupAndRetrieveMessages', args: [cafeId, userId]);
      print('Attempted to join Cafe Group: $cafeId with User: $userId');
    } else {
      print('Connection is not in a Connected State');
    }
  }

  Future<void> sendMessage(String message) async {
    if (_hubConnection?.state == HubConnectionState.Connected) {
      await _hubConnection?.invoke('SendMessage', args: [message]);
    } else {
      print('Connection is not in a Connected State to send a message');
    }
  }

  void _handleIncomingMessage(List<dynamic>? arguments) {
    if (arguments != null && arguments.length >= 2) {
      String userName = arguments[0];
      String messageJson = arguments[1];
      onMessageReceived?.call(userName, messageJson);
    }
  }

  void _handleNewMessages(List<dynamic>? arguments) {
    if (arguments != null && arguments.length >= 2) {
      String cafeId = arguments[0];
      List<dynamic> messagesJson = arguments[1];
      List<SessionMessage> messages = messagesJson.map((m) => SessionMessage.fromJson(m)).toList();
      onNewMessagesReceived?.call(cafeId, messages);
    }
  }

  void dispose() {
    _hubConnection?.stop();
  }
}
