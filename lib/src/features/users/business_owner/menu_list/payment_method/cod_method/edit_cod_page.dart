import 'package:flutter/material.dart';
import 'package:flutter_application_1/services/firestoreDB/paymethod_db_service.dart';
import 'package:flutter_application_1/src/constants/decoration.dart';
import 'package:flutter_application_1/src/features/auth/models/pay_method.dart';
import 'package:flutter_application_1/src/features/auth/screens/appBar/app_bar_arrow.dart';
import 'package:flutter_application_1/src/features/users/business_owner/menu_list/payment_method/cod_method/view_cod_page.dart';
import 'package:flutter_application_1/src/routing/routes_const.dart';

class EditReplaceMealOrCODPage extends StatefulWidget {
  const EditReplaceMealOrCODPage({
    required this.payMethodSelected,
    super.key
  });

  final PaymentMethodModel payMethodSelected;

  @override
  State<EditReplaceMealOrCODPage> createState() => _EditReplaceMealOrCODPageState();
}

class _EditReplaceMealOrCODPageState extends State<EditReplaceMealOrCODPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController description1Controller = TextEditingController();
  final TextEditingController methodNameController = TextEditingController();
  final _formkey = GlobalKey<FormState>();
  PayMethodDatabaseService methodService = PayMethodDatabaseService();
  bool isLoading = false;
  bool anyChanges = false;

  Future<void> _showDialog(String title, String content) async {
    return showDialog(
      context: _scaffoldKey.currentContext!,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title, style: const TextStyle(fontSize: 21)),
          content: Text(content, style: const TextStyle(fontSize: 20)),
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
                  fontSize: 20,
                  color: okTextColor
                )
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  void initState(){
    super.initState();
    description1Controller.text = widget.payMethodSelected.desc1!;
    methodNameController.text = widget.payMethodSelected.methodName!;
    description1Controller.addListener(() {
      if(description1Controller.text.isNotEmpty){
        anyChanges = true;
      }
    });
    methodNameController.addListener(() {
      if(methodNameController.text.isNotEmpty){
        anyChanges = true;
      }
    });
  }

  @override
  void dispose() {
    description1Controller.dispose();
    methodNameController.dispose();
    super.dispose();
  }

  Future<void> _uploadData() async {
    if(_formkey.currentState!.validate()){
      await methodService.updateCODPayment(
        widget.payMethodSelected.id!,
        description1Controller.text,
        methodNameController.text
      );

      _showDialog('Payment Method Updated', '${methodNameController.text} has been updated successfully.');
    }
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
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;

    return SafeArea(
      child: Scaffold(
        key: _scaffoldKey,
        appBar: GeneralAppBar(
          title: 'Edit COD',
          userRole: 'owner',
          onPress: (){
            if(anyChanges){
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text(
                      'Confirm to leave this page?',
                      style: TextStyle(
                        fontSize: 21
                      ),
                    ),
                    content: const Text(
                      'Please save your work before you leave.', 
                      style: TextStyle(
                        fontSize: 18
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text(
                          'Cancel',
                          style: TextStyle(
                            fontSize: 20,
                            color: cancelTextColor
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                         Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ViewCODPage(payMethodSelected: widget.payMethodSelected)
                            ) 
                          );
                        },
                        child: const Text(
                          'Confirm',
                          style: TextStyle(
                            fontSize: 20,
                            color: confirmTextColor
                          ),
                        ),
                      )
                    ],
                  );
                },
              );
            }else{
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => ViewCODPage(payMethodSelected: widget.payMethodSelected)
                ) 
              );
            }
          },
          barColor: ownerColor,
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Center(
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: height * 0.07,
                        width: width * 0.3,
                        child: const Text(
                          'Method Name:',
                          textAlign: TextAlign.start,
                          style: TextStyle(
                            fontSize: 20,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),

                      SizedBox(
                        width: width * 0.55,
                        child: TextField(
                          controller:methodNameController,
                          maxLines: null,
                          style: const TextStyle(
                            color: editableTextColor
                          ),
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: 'Method name',
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: height * 0.07,
                        width: width * 0.3,
                        child: const Text(
                          'Any description:',
                          textAlign: TextAlign.start,
                          style: TextStyle(
                            fontSize: 20,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),

                      SizedBox(
                        width: width * 0.55,
                        child: TextField(
                          controller: description1Controller,
                          maxLines: null,
                          style: const TextStyle(
                            color: editableTextColor
                          ),
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: 'Add your description',
                          ),
                        ),
                      ),
                    ],
                  ),
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
                      onPressed: anyChanges
                      ? isLoading 
                        ? null 
                        : _handleSaveButtonPress
                      : null,
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
      ),
    );
  }
}