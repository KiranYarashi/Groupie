import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:groupchat/pages/group_info.dart';
import 'package:groupchat/services/data_base_service.dart';
import 'package:groupchat/widgets/message_tile.dart';
import 'package:groupchat/widgets/widgets.dart';

import 'dart:io';

class ChatPage extends StatefulWidget {
  final String groupId;
  final String groupName;
  final String userName;

  const ChatPage(
      {Key? key,
      required this.groupId,
      required this.groupName,
      required this.userName})
      : super(key: key);

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  Stream<QuerySnapshot>? chats;
  TextEditingController messageController = TextEditingController();
  String admin = "";
  String downloadURL = "";

  @override
  void initState() {
    getChatandAdmin();
    super.initState();
  }

  getChatandAdmin() {
    DatabaseService().getChats(widget.groupId).then((val) {
      setState(() {
        chats = val;
      });
    });
    DatabaseService().getGroupAdmin(widget.groupId).then((val) {
      setState(() {
        admin = val;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        title: Text(widget.groupName),
        backgroundColor: Theme.of(context).primaryColor,
        actions: [
          IconButton(
              onPressed: () {
                nextScreen(
                    context,
                    GroupInfo(
                      groupId: widget.groupId,
                      groupName: widget.groupName,
                      adminName: admin,
                    ));
              },
              icon: const Icon(Icons.info))
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
              alignment: Alignment.center,
              opacity: 0.3,
              image: AssetImage("assets/doodle.jpg"),
              fit: BoxFit.cover),
        ),
        child: Stack(
          children: <Widget>[
            // chat messages here
            chatMessages(),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 7),
              alignment: Alignment.bottomCenter,
              width: MediaQuery.of(context).size.width,
              child: Container(
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 242, 235, 235),
                  borderRadius: const BorderRadius.all(Radius.circular(25)),
                  boxShadow: [
                    BoxShadow(
                      color: Color.fromARGB(255, 58, 58, 58).withOpacity(0.5),
                      spreadRadius: 6,
                      blurRadius: 6,
                      offset: Offset(0, 3), // changes position of shadow
                    ),
                  ],
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                width: 500,
                height: 70,
                child: Row(children: [
                  Expanded(
                      child: TextFormField(
                    controller: messageController,
                    style:
                        const TextStyle(color: Color.fromARGB(255, 12, 12, 12)),
                    decoration: const InputDecoration(
                      hintText: "Send a message...",
                      hintStyle: TextStyle(
                          color: Color.fromARGB(255, 8, 8, 8), fontSize: 16),
                      border: InputBorder.none,
                    ),
                  )),
                  const SizedBox(
                    width: 12,
                  ),
                  IconButton(
                    padding: const EdgeInsets.only(bottom: 8),
                    icon: const Icon(
                      Icons.upload_file,
                      size: 40,
                    ),
                    color: Color.fromARGB(255, 63, 180, 230),
                    onPressed: () async {
                      FilePickerResult? result =
                          await FilePicker.platform.pickFiles();

                      if (result != null) {
                        PlatformFile file = result.files.first;

                        try {
                          // Upload file to Firebase Storage
                          TaskSnapshot snapshot = await FirebaseStorage.instance
                              .ref('uploads/${file.name}')
                              .putFile(File(file.path!));

                          // Once the file upload is complete, get the download URL
                          downloadURL = await snapshot.ref.getDownloadURL();

                          // Send the download URL as a message
                          sendMessage(fileURL: downloadURL);
                        } catch (e) {
                          // TODO: do something about this.
                          print(e);
                        }
                      } else {
                        // User canceled the picker
                      }
                    },
                  ),
                  GestureDetector(
                    onTap: () {
                      sendMessage();
                    },
                    child: Container(
                      height: 50,
                      width: 50,
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: const Center(
                          child: Icon(
                        Icons.send,
                        color: Colors.white,
                      )),
                    ),
                  ),
                ]),
              ),
            )
          ],
        ),
      ),
    );
  }

  chatMessages() {
    return StreamBuilder(
      stream: chats,
      builder: (context, AsyncSnapshot snapshot) {
        return snapshot.hasData
            ? ListView.builder(
                itemCount: snapshot.data.docs.length,
                itemBuilder: (context, index) {
                  var messageData = snapshot.data.docs[index].data();
                  return MessageTile(
                    message: snapshot.data.docs[index]['message'],
                    sender: snapshot.data.docs[index]['sender'],
                    fileURL: messageData['fileURL'],
                    //fileURL: downloadURL,
                    sentByMe:
                        widget.userName == snapshot.data.docs[index]['sender'],
                  );
                },
              )
            : Container();
      },
    );
  }

  sendMessage({String? fileURL}) {
    //if (messageController.text.isNotEmpty) {
    Map<String, dynamic> chatMessageMap = {
      "message": messageController.text,
      "sender": widget.userName,
      "time": DateTime.now().millisecondsSinceEpoch,
    };
    if (fileURL != null) {
      chatMessageMap["fileURL"] = fileURL;
    }

    DatabaseService().sendMessage(widget.groupId, chatMessageMap);
    setState(() {
      messageController.clear();
    });
    // }
  }
}
