import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:talkr_demo/chat/MessageModel.dart';
class NewChatScreen extends StatelessWidget {

  final Map<String,dynamic> userMap;
  final String newChatRoomId; 
   NewChatScreen(this.newChatRoomId,this.userMap);

  final TextEditingController _message = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  void onSendMessage() async{

    if(_message.text.isNotEmpty) {
      Map<String,dynamic> messages = {
      "sendby": _auth.currentUser!.displayName,
      "message": "",
      "time": FieldValue.serverTimestamp(),

      
    };
    _message.clear();
    
    await _firestore
      .collection('chats')
      .doc(newChatRoomId)
      .collection('chats')
      .add(messages);
      
    }else{
      print('Enter some text');
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text(userMap['email']),
      ),
      body: SingleChildScrollView(
        child: Expanded(
          child: Column(
            children: [
        
        
              Container(
              height: size.height / 1.25,
              width: size.width,
              // child: StreamBuilder<QuerySnapshot>(
              //   stream: _firestore
              //   .collection("chatRoom")
              //   .doc(newChatRoomId)
              //   .collection('chats')
              //   .orderBy('time',descending: false)
              //   .snapshots(),
        
              //   builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              //     if(snapshot.data!= null){
              //       return ListView.builder(
              //         itemCount: snapshot.data!.docs.length,
              //         itemBuilder: (BuildContext context, int index) {
              //           Map<String, dynamic> map = snapshot.data!.docs[index]
              //                 .data() as Map<String, dynamic>;
              //           return messages(size,map);
              //          // return Text(snapshot.data!.docs[index]['message']);
              //         },
              //       );
              //     }else{
              //       return Container(color: Colors.black,);
              //     }
                  
              //   },
              // ),
        
        
              child: StreamBuilder(
                stream: FirebaseFirestore.instance.collection('chatroom').doc(newChatRoomId).collection('chats').orderBy('time',descending:true).snapshots(),
                builder: (context, snapshot) {
                  if(snapshot.connectionState == ConnectionState.active){
                    if(snapshot.hasData){
                      QuerySnapshot dataSnapshot = snapshot.data as QuerySnapshot;
                      
                      return ListView.builder(
                        reverse: true,
                        itemCount: dataSnapshot.docs.length,
                        itemBuilder: (context,index){
                          MessageModel currentMessage = MessageModel.fromMap(dataSnapshot.docs[index].data() as Map<String,dynamic>);
                          return Row(
                            children: [
                              Container(
                                margin: EdgeInsets.symmetric(vertical: 2),
                                padding: EdgeInsets.symmetric(vertical: 10,horizontal: 10),
                                decoration: BoxDecoration(
                                  color: (currentMessage.sendby ==_auth.currentUser!.displayName) ? Colors.grey : Colors.black
                                ),
                                child: Text(currentMessage.message.toString(),style: TextStyle(color: Colors.black),),
                              ),  
                            ],
                          );
                        }
                        );
                    }else if(snapshot.hasError){
                      return Text('error');
                    }
                  }else{
                    return Text('Say hii to new friend');
                  }return CircularProgressIndicator();
                }
              )
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(
                  height: size.height / 12,
                  width: size.width / 1.3,
                  child: TextField(
                    controller: _message,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8), 
                      )
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () {
                    onSendMessage();
                  },)
              ],
            ),
          ]),
        ),
      ),
    );
  }
  Widget messages(Size size,Map<String,dynamic> map){
    return Container(
      width: size.width,
      alignment: map['sendby'] == _auth.currentUser!.displayName
      ? Alignment.centerRight
      :Alignment.centerLeft,

      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10,horizontal: 14),
        margin: EdgeInsets.symmetric(vertical: 5, horizontal: 8), 
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(15)),
        color: Colors.black,
        child: Text(map['message'],style: TextStyle(color: Colors.black,fontSize: 16,fontWeight: FontWeight.bold),),


      ),
    );
  }
}