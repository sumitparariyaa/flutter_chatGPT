import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_chatgpt/constants/constants.dart';
import 'package:flutter_chatgpt/providers/chats_provider.dart';
import 'package:flutter_chatgpt/providers/model_provider.dart';
import 'package:flutter_chatgpt/services/services.dart';
import 'package:flutter_chatgpt/widgets/prompt_widget.dart';
import 'package:flutter_chatgpt/widgets/text_widget.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  bool _isTyping = false;
  final TextEditingController _textEditingController = TextEditingController();
  late FocusNode focusNode;
  late ScrollController _listScrollController;

  @override
  void initState() {
    _textEditingController;
    _listScrollController = ScrollController();
    focusNode = FocusNode();
    super.initState();
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    _listScrollController.dispose();
    focusNode.dispose();
    super.dispose();
  }

  // List<ChatModel> chatList = [];

  @override
  Widget build(BuildContext context) {
    final modelsProvider = Provider.of<ModelsProvider>(context);
    final chatsProvider = Provider.of<ChatsProvider>(context);
    return Scaffold(
      appBar: AppBar(
        elevation: 2,
        centerTitle: true,
        title: const Text('ChatGPT'),
        actions: [
          IconButton(
              onPressed: () async {
                await Services.showModalSheet(context: context);
              },
              icon: const Icon(Icons.more_vert_outlined, color: Colors.white))
        ],
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.asset('assets/images/Open.jpg'),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                  controller: _listScrollController,
                  itemCount:
                      chatsProvider.getChatList.length, //chatList.length,
                  itemBuilder: (context, index) {
                    return ChatWidget(
                        msg: chatsProvider
                            .getChatList[index].msg, //chatList[index].msg,
                        chatIndex: chatsProvider.getChatList[index]
                            .chatIndex // chatList[index].chatIndex
                        );
                  }),
            ),
            //here ... used when you needed multiple widgets for conditions like condtion ? widgte : widgte.
            if (_isTyping) ...[
              //for loading animation
              const SpinKitThreeBounce(
                color: Colors.white,
                size: 18,
              ),

              //for spcae
              const SizedBox(
                height: 15,
              ),
            ],
            //textfield for question
            Material(
              color: cardColor,
              child: Padding(
                padding: const EdgeInsets.all(8.0),

                //for align of widget in row
                child: Row(
                  children: [
                    Expanded(
                        child: TextField(
                            focusNode: focusNode,
                            style: const TextStyle(color: Colors.white),
                            controller: _textEditingController,
                            onSubmitted: (value) async {
                              await sendMessageFCT(
                                  modelsProvider: modelsProvider,
                                  chatsProvider: chatsProvider);
                            },
                            decoration: const InputDecoration.collapsed(
                                hintText: "How can i help you",
                                hintStyle: TextStyle(color: Colors.grey)))),
                    IconButton(
                      onPressed: () async {
                        await sendMessageFCT(
                            modelsProvider: modelsProvider,
                            chatsProvider: chatsProvider);
                      },
                      icon: const Icon(
                        Icons.send,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  void scrollListToEnd() {
    _listScrollController.animateTo(
        _listScrollController.position.maxScrollExtent,
        duration: const Duration(seconds: 2),
        curve: Curves.easeOut);
  }

  Future<void> sendMessageFCT(
      {required ModelsProvider modelsProvider,
      required ChatsProvider chatsProvider}) async {
        if(_isTyping){
           ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: TextWidget(
              label: "You can't send multiple messages at a time",
            ),
            backgroundColor: Colors.red,
          )
         );
          return;
        }
        if(_textEditingController.text.isEmpty){
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: TextWidget(
              label: "Please type a Message",
            ),
            backgroundColor: Colors.red,
          )
          );
          return;
        }
    try {
          String msg = _textEditingController.text;
      setState(() {
        _isTyping = true;
        chatsProvider.addUserMessage(msg: msg);
        //  chatList.add(ChatModel(chatIndex:0, msg: _textEditingController.text));
        _textEditingController.clear();
        focusNode.unfocus();
      });
      await chatsProvider.sendMessageAndGetAnswers(
          msg: msg,
          choosenModelId: modelsProvider.getcurrentModel);
      // chatList.addAll(await ApiServices.sendMessage(
      //     message: _textEditingController.text,
      //     modelId: modelsProvider.getcurrentModel)

      setState(() {});
    } catch (error) {
      log("error $error");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: TextWidget(
          label: error.toString(),
        ),
        backgroundColor: Colors.red,
      ));
    } finally {
      setState(() {
        scrollListToEnd();
        _isTyping = false;
        log('Request has been sent');
      });
    }
  }
}
