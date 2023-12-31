import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/services/firestoreDB/paymethod_db_service.dart';
import 'package:flutter_application_1/src/constants/decoration.dart';
import 'package:flutter_application_1/src/features/auth/models/pay_method.dart';
import 'package:flutter_application_1/src/routing/routes_const.dart';
import 'package:image_picker/image_picker.dart';

class OnlineBankingPage extends StatefulWidget {
  const OnlineBankingPage({super.key});

  @override
  State<OnlineBankingPage> createState() => _OnlineBankingPageState();
}

enum Options{yes, no}

class _OnlineBankingPageState extends State<OnlineBankingPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final picker = ImagePicker();
  File? image;
  final bankAccController = TextEditingController();
  final accNumberController = TextEditingController();
  final description1Controller = TextEditingController();
  final description2Controller = TextEditingController();
  PayMethodDatabaseService methodService = PayMethodDatabaseService();
  bool btnYes = false;
  Options groupVal = Options.no;
  String? receiptChoice;
  bool isLoading = false;

  Future getImageFromGallery() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    
    setState(() {
      if (pickedFile != null) {
       image = File(pickedFile.path);
      }
    });
  }
  Future getImageFromCamera() async{
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    setState(() {
      if(pickedFile != null){
        image = File(pickedFile.path);
      }
    });
  }

  Future showOptions() async {
    showDialog(
      context: context, 
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Please select your option:'),
          content: SizedBox(
            height: 150,
            child: Column(
              children: [
                ListTile(
                  onTap: (){
                    getImageFromCamera();
                    Navigator.pop(context);
                  },
                  leading: const Icon(Icons.camera_outlined,size: 30),
                  title: const Text('Camera', style: TextStyle(fontSize: 20)),
                ),
                const SizedBox(height: 20),
                ListTile(
                  onTap: (){
                    getImageFromGallery();
                    Navigator.pop(context);
                  },
                  leading: const Icon(Icons.image_outlined, size: 30),
                  title: const Text('Gallery', style: TextStyle(fontSize: 20)),
                )
              ],
            ),
          ),
        );
      }
    );
  }

  Future<String> uploadImage(File? imageFile)async{
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      String randomChars = DateTime.now().microsecondsSinceEpoch.toRadixString(36);
      var storageRef = FirebaseStorage.instance.ref().child('paymethod_images/$fileName$randomChars'); 
      var uploadTask = storageRef.putFile(imageFile!);
      var snapshot = await uploadTask;
      var downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
  }

  Future<void> _showDialog(String title, String content) async{
    return showDialog(
      context: _scaffoldKey.currentContext!, 
      builder: (BuildContext context){
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pushNamedAndRemoveUntil(
                  payMethodPageRoute, 
                  (route) => false,
                );
              },
              child: const Text(
                'OK',
                style: TextStyle(
                  fontSize: 20
                )
              ),
            ),
          ],
        );
      }
    );
  }

  Future<void> _uploadData()async{
    String downloadUrl = await uploadImage(image);
    DocumentReference documentReference = await methodService.addFPXPayment(
      PaymentMethodModel(
        id: '',
        methodName: "Online banking",
        desc1: description1Controller.text,
        desc2: description2Controller.text,
        qrcode: downloadUrl,
        bankAcc: bankAccController.text,
        accNumber: accNumberController.text,
        requiredReceipt: receiptChoice,
      )
    );

    String docId = documentReference.id;

    await methodService.updateFPXPayment(
      PaymentMethodModel(
        id: docId,
        methodName: "Online banking",
        desc1: description1Controller.text,
        desc2: description2Controller.text,
        qrcode: downloadUrl,
        bankAcc: bankAccController.text,
        accNumber: accNumberController.text,
        requiredReceipt: receiptChoice,
      )
    );

    _showDialog('Payment Method Added', 'Payment method information has been saved successfully.');
  }

  void _handleSaveButtonPress() async {
    setState(() {
      isLoading = true;
    });

    await _uploadData();

    setState(() {
      isLoading = false;
    });
  }

  @override
  void initState(){
    super.initState();
  }

  @override
  void dispose(){
    description1Controller.dispose();
    description2Controller.dispose();
    bankAccController.dispose();
    accNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;

    return SafeArea(
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          backgroundColor: ownerColor,
          elevation: 0.0,
          leading: IconButton(
            onPressed: () async {
              return await showDialog(
                context: context, 
                builder: (BuildContext context){
                  return AlertDialog(
                    content: const Text(
                      'Confirm to leave this page?\nPlease save your work before you leave', 
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text('Cancel')
                      ),
                      TextButton(
                        onPressed: (){
                          Navigator.of(context).pushNamedAndRemoveUntil(
                            choosePayMethodRoute, 
                            (route) => false,
                          );
                        }, 
                        child: const Text('Confirm')
                      )
                    ],
                  );
                }
              );
            },
            icon: const Icon(
              Icons.arrow_back_outlined, 
              color: iconWhiteColor
            ),
          ),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Center(
              child: Column(
                children: [
                  Container(
                    height: height*0.06,
                    width: width*0.6,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(border: Border.all()),
                    child: const Text(  //method will change based on the selection
                      "Online Banking/FPX",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold
                      ),
                    ),   
                  ),
        
                  const SizedBox(height: 40),
        
                  Row(
                    children: [
                      SizedBox(
                        height: height*0.07,
                        width: width*0.3,
                        child: const Text(
                          'Bank Account:',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 20,
                          )
                        ),
                      ),

                      const SizedBox(width: 10),
        
                      SizedBox(
                        width: width*0.55,
                        child: TextField(
                          controller: bankAccController,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: 'Bank Account',
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      SizedBox(
                        height: height*0.07,
                        width: width*0.3,
                        child: const Text(
                          'Account No. :',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 20,
                          )
                        ),
                      ),
                      
                      const SizedBox(width: 10),
        
                      SizedBox(
                        width: width*0.55,
                        child: TextField(
                          controller: accNumberController,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: 'Account number',
                          ),
                        ),
                      ),
                    ],
                  ),
        
                  const SizedBox(height: 20),
                  //this will get the qr code image in file type
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: height*0.07,
                        width: width*0.3,
                        child: const Text(
                          'QR Code:',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 20,
                          )
                        ),
                      ),
        
                      const SizedBox(width: 10),
        
                      SizedBox(
                        height: 200,
                        width: width*0.55,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Container(
                              height: 130,
                              width: width*0.55,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: const Color.fromARGB(255, 99, 99, 99)
                                )
                              ),
                              child: image == null 
                              ? const Icon(Icons.image_outlined, size: 30)
                              : Image.file(
                                  image!,
                                  fit: BoxFit.fill,
                                ),
                            ),
                            
                            const SizedBox(height: 10),

                            Row(
                              children: [
                                SizedBox(
                                  width: 170,
                                  child: ElevatedButton.icon(
                                    onPressed: (){   
                                      showOptions();
                                    }, 
                                    icon: image == null 
                                    ? const Icon(Icons.upload_outlined)
                                    : const Icon(Icons.edit_outlined)
                                    , 
                                    label: image == null 
                                    ? const Text('Upload') 
                                    : const Text('Edit'),    //change name to edit if file exist
                                  )
                                ),
                                const SizedBox(width: 5),
                                image != null
                                ? Visibility(
                                    visible: true, 
                                    child: InkWell(
                                      onTap: () {
                                        setState(() {
                                          image = null;
                                        });
                                      },
                                      child: const Icon(
                                        Icons.delete_outline,
                                        size: 40,
                                      ),
                                    ),
                                  )
                                : Container(),
                              ],
                            )
                          ],
                        ),
                      )
                    ],
                  ),

                  const SizedBox(height: 20),

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: height*0.07,
                        width: width*0.3,
                        child: const Text(
                          'Any description:',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 20,
                          )
                        ),
                      ),
        
                      const SizedBox(width: 10),
        
                      SizedBox(
                        width: width*0.55,
                        child: TextField(
                          controller: description1Controller,
                          maxLines: null,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: 'Add your description',
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: height*0.07,
                        width: width*0.3,
                        child: const Text(
                          'Require receipt?',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 20,
                          )
                        ),
                      ),
        
                      const SizedBox(width: 10),
        
                      Container(
                        height: height*0.17,
                        width: width*0.55,
                        decoration: BoxDecoration(
                          border: Border.all(
                            width: 0.5
                          ),
                        ),
                        child: Column(
                          children: [
                            ListTile(
                              title: const Text('Yes'),         
                              leading: Radio(
                                value: Options.yes, 
                                groupValue: groupVal, 
                                onChanged: (Options? value){
                                  setState(() {
                                    groupVal = value!;
                                    btnYes = true;
                                    receiptChoice = 'Yes';
                                  });
                                }
                              ),
                            ),

                            const Divider(
                              thickness: 1,
                            ),

                            ListTile(
                              title: const Text('No'),
                              leading: Radio(
                                value: Options.no, 
                                groupValue: groupVal, 
                                onChanged: (Options? value){
                                  setState(() {
                                    groupVal = value!;
                                    btnYes = false;
                                    receiptChoice = 'No';
                                  });
                                }
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  btnYes 
                  ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: height*0.08,
                        width: width*0.3,
                        child: const Text(
                          'Description for payment proof:',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 17,
                          )
                        ),
                      ),
        
                      const SizedBox(width: 10),
        
                      SizedBox(
                        width: width*0.55,
                        child: TextField(
                          controller: description2Controller,
                          maxLines: null,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: 'Add your description',
                          ),
                        ),
                      ),
                    ],
                  )
                  : const SizedBox(height: 59),

                  const SizedBox(height: 40),

                  SizedBox(
                    height: 50,
                    width: 200,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber,
                        elevation: 10,
                        shadowColor: shadowClr,
                      ),
                      onPressed: isLoading ? null : _handleSaveButtonPress,
                      child: isLoading
                      ? const CircularProgressIndicator()
                      : const Text(
                          'Save',
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.black,
                          ),
                        ),
                    ),
                  ),
                ],  
              ),
            ),
          ),
        ),
      )
    );
  }
}