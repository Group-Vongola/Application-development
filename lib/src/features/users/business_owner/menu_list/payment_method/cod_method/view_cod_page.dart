import 'package:flutter/material.dart';
import 'package:flutter_application_1/services/firestoreDB/paymethod_db_service.dart';
import 'package:flutter_application_1/src/constants/decoration.dart';
import 'package:flutter_application_1/src/features/auth/models/pay_method.dart';
import 'package:flutter_application_1/src/features/auth/screens/appBar/direct_appbar_arrow.dart';
import 'package:flutter_application_1/src/features/users/business_owner/menu_list/payment_method/cod_method/edit_cod_page.dart';
import 'package:flutter_application_1/src/routing/routes_const.dart';

class ViewCODPage extends StatefulWidget {
  const ViewCODPage({
    required this.payMethodSelected,
    super.key
  });

  final PaymentMethodModel payMethodSelected;

  @override
  State<ViewCODPage> createState() => _ViewCODPageState();
}

class _ViewCODPageState extends State<ViewCODPage> {
  bool isPayMethodOpened = false;
  final PayMethodDatabaseService methodService = PayMethodDatabaseService();
  late Future<void> codPaymentFuture;

  Future<void> loadCODPaymentStatus()async{
    try{
      PaymentMethodModel? openedCOD = await methodService.getPayMethodDetails(widget.payMethodSelected.id!);
      if(openedCOD!.openedStatus == 'Yes'){
        isPayMethodOpened = true;
      }else{
        isPayMethodOpened = false;
      }
    }catch(e){
      rethrow;
    }
  }

  @override
  void initState() {
    super.initState();
    codPaymentFuture = loadCODPaymentStatus();
  }
  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    
    return SafeArea(
      child: Scaffold(
        appBar: GeneralDirectAppBar(
          title: 'COD', 
          userRole: 'owner',
          onPress: (){
            Navigator.of(context).pushNamedAndRemoveUntil(
              payMethodPageRoute, 
              (route) => false,
            );
          }, 
          barColor: ownerColor
        ),
        body: FutureBuilder<void>(
          future: codPaymentFuture,
          builder: (context, snapshot) {
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Center(
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          isPayMethodOpened
                          ? Container(
                              height: 50,
                              width: 200,
                              alignment: Alignment.center,
                              padding: const EdgeInsets.all(5),
                              color: orderOpenedColor,
                              child: const Text(
                                'In Open State',
                                style: TextStyle(
                                  fontSize: 20
                                ),
                              ),
                            )
                          : Container(),
                          SizedBox(
                            height: 50,
                            width: 100,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isPayMethodOpened
                                ? Colors.red
                                : Colors.amber,
                                elevation: 5,
                                shadowColor: const Color.fromARGB(255, 92, 90, 85),
                              ),
                              onPressed: ()async{
                                if(isPayMethodOpened){
                                  await methodService.updateToClosedStatus(widget.payMethodSelected.id!);
                                }else{
                                  await methodService.updateToOpenedStatus(widget.payMethodSelected.id!);
                                }
                                setState(() {
                                  isPayMethodOpened = !isPayMethodOpened;
                                });
                                // ignore: use_build_context_synchronously
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      isPayMethodOpened
                                        ? 'Payment method is opened'
                                        : 'Payment method is closed'
                                      ),
                                    duration: const Duration(seconds: 2),
                                  ),
                                );
                              }, 
                              child: Text(
                                isPayMethodOpened ? 'Close' : 'Open',
                                style: TextStyle(
                                  fontSize: 20,
                                  color: isPayMethodOpened ? yellowColorText : Colors.black
                                ),
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
                            width: width*0.4,
                            child: const Text(
                              "Method name: ",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold
                              ),
                            ),
                          ),
        
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                border: Border.all()
                              ),
                              child: Text(
                                widget.payMethodSelected.methodName!,
                                style: const TextStyle(
                                  fontSize: 20,
                                ),
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
                            width: width*0.4,
                            child: const Text(
                              "Description: ",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold
                              ),
                            ),
                          ),
        
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                border: Border.all()
                              ),
                              child: Text(
                                widget.payMethodSelected.desc1 ?? '',
                                style: const TextStyle(
                                  fontSize: 18,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 40),
        
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                            height: 50,
                            width: 100,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: deleteButtonColor,
                                elevation: 10,
                                shadowColor: const Color.fromARGB(255, 92, 90, 85),
                              ),
                              onPressed: (){
                                showDialog(
                                  context: context, 
                                  builder: (BuildContext context){
                                    return AlertDialog(
                                      title: const Text(
                                        'You are deleting this payment method',
                                        textAlign: TextAlign.start,
                                        style: TextStyle(
                                          fontSize: 23,
                                          fontWeight: FontWeight.bold
                                        ),
                                      ),
                                      content: const Text(
                                        'Confirm to delete this payment method?',
                                        textAlign: TextAlign.start,
                                        style: TextStyle(
                                          fontSize: 18
                                        ),
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: (){
                                            Navigator.of(context).pop();
                                          }, 
                                          child: const Text(
                                            'Cancel',
                                            style: TextStyle(
                                              fontSize: 22
                                            ),
                                          )
                                        ),
                                        TextButton(
                                          onPressed: ()async {
                                            await methodService.deletePayment(widget.payMethodSelected.id!.toString(), context); 
                                          }, 
                                          child: const Text(
                                            'Delete',
                                            style: TextStyle(
                                              fontSize: 22
                                            ),
                                          )
                                        ),
                                      ],
                                    );
                                  }
                                );
                              }, 
                              child: const Text(
                                'Delete',
                                style: TextStyle(
                                  fontSize: 20,
                                  color: yellowColorText
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 50,
                            width: 100,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.amber,
                                elevation: 10,
                                shadowColor: const Color.fromARGB(255, 92, 90, 85),
                              ),
                              onPressed: (){
                                MaterialPageRoute route = MaterialPageRoute(
                                  builder: (context) => EditReplaceMealOrCODPage(
                                    payMethodSelected: widget.payMethodSelected,
                                  )
                                );
                                Navigator.push(context, route);
                              }, 
                              child: const Text(
                                'Edit',
                                style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.black
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
        
                    ],
                  ),
                ),
              ),
            );
          }
        ),
      ),
    );
  }
}