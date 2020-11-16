import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:snapping_sheet/snapping_sheet.dart';
import 'package:file_picker/file_picker.dart';

import 'UserRepository.dart';

class MySnappingSheet extends StatefulWidget {
  @override
  _MySnappingSheetState createState() => _MySnappingSheetState();
}

class _MySnappingSheetState extends State<MySnappingSheet> with SingleTickerProviderStateMixin{
  var _controller = SnappingSheetController();
  @override
  Widget build(BuildContext context) {
    final UserRepository user = Provider.of<UserRepository>(context);

    return SnappingSheet(
      snappingSheetController: _controller,
      snapPositions: const [
        SnapPosition(positionPixel: 0.0, snappingCurve: Curves.elasticOut, snappingDuration: Duration(milliseconds: 750)),
        SnapPosition(positionFactor: 0.2),
      ],
      grabbingHeight: 55,
      grabbing: InkWell(
        child: Container(
            color: Colors.grey[400],
            child: Padding(
                padding: const EdgeInsets.only(left: 12.0, right: 12.0),
                child: Row(
                  children: [
                    Container(
                      width: 220 ,
                      child: FittedBox(
                        alignment: Alignment.centerLeft,
                        fit: BoxFit.contain,
                        child: Text('Welcome back, ${user.userEmail}', style: TextStyle(color: Colors.black)))),
                    Spacer(),
                    Container(
                        height: 36,
                        child: IconButton(icon: Icon(Icons.keyboard_arrow_up_sharp, color: Colors.black), onPressed: null)),
                  ],
                )
            )
        ),
        onTap: (){
          _controller.snapPositions.last != _controller.currentSnapPosition
              ? _controller.snapToPosition(_controller.snapPositions.last)
              : _controller.snapToPosition(_controller.snapPositions.first);
        },
      ),
      sheetBelow: SnappingSheetContent(
          child: Container(
            color: Colors.grey[200],
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                children: [
                  Column(
                    children: [
                      Flexible(
                        child: CircleAvatar(
                          backgroundImage: NetworkImage(
                            user.userPic
                          ),
                          radius: 40,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Flexible(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 12.0),
                            child: Container(
                              height: 30.0,
                              width: 180,
                              child: FittedBox(
                                alignment: Alignment.centerLeft,
                                fit: BoxFit.contain,
                                child: Text('${user.userEmail}')),
                            ),
                          )
                      ),
                      Flexible(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 12.0, top: 8.0),
                          child: FlatButton(
                            height: 25,
                            color: Colors.teal,
                            child: Text("Change avatar",
                              style: TextStyle(color: Colors.white),
                            ),
                            onPressed: () {
                              _openFileExplorer();
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          )
      ),
    );
  }

  void _openFileExplorer() async{
    FilePickerResult result = await FilePicker.platform.pickFiles();
    final UserRepository user = Provider.of<UserRepository>(context, listen: false);
    if (result != null) {
      File file = File(result.files.single.path);
      FirebaseStorage _firebaseStorage = FirebaseStorage.instance;
      await _firebaseStorage.ref('${user.userId}.img').putFile(file);
      user.setPicture(
          await _firebaseStorage.ref('${user.userId}.img').getDownloadURL()
      );
    } else {
      final unpickedFile = SnackBar(
        content: Text(
            'No image selected'),
      );
      Scaffold.of(context).showSnackBar(unpickedFile);
    }
  }

}