import 'package:flutter/material.dart';
import 'package:flutter_chatgpt/models/chat_model.dart';
import 'package:flutter_chatgpt/services/api_services.dart';

class ChatsProvider with ChangeNotifier{

  List<ChatModel> chatList = [];

  List<ChatModel> get getChatList {
    return chatList;
  }
  void addUserMessage ({required String msg}){
    chatList.add(ChatModel(chatIndex:0, msg: msg));
    notifyListeners();
  }
  Future<void> sendMessageAndGetAnswers({required String msg, required String choosenModelId}) async {
    chatList.addAll(await ApiServices.sendMessage(
        message: msg,
        modelId: choosenModelId));
    notifyListeners();
  }
}