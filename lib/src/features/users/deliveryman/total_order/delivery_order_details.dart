import 'package:flutter/material.dart';
import 'package:flutter_application_1/services/firestoreDB/order_cust_db_service.dart';
import 'package:flutter_application_1/services/firestoreDB/paymethod_db_service.dart';
import 'package:flutter_application_1/src/constants/decoration.dart';
import 'package:flutter_application_1/src/features/auth/models/order_customer.dart';
import 'package:flutter_application_1/src/features/auth/models/pay_method.dart';
import 'package:flutter_application_1/src/features/auth/screens/appBar/direct_appbar_noarrow.dart';

//one click in every order to view the details of the orders
class DeliveryManOrderDetails extends StatefulWidget {
  const DeliveryManOrderDetails({
    required this.orderSelected,
    super.key
  });

  final OrderCustModel orderSelected;

  @override
  State<DeliveryManOrderDetails> createState() => _DeliveryManOrderDetailsState();
}

class _DeliveryManOrderDetailsState extends State<DeliveryManOrderDetails> {
  OrderCustDatabaseService custOrderService = OrderCustDatabaseService();
  PayMethodDatabaseService paymentService = PayMethodDatabaseService();
  @override
  Widget build(BuildContext context) {
    Widget buildDetailTile(String title, String details){
      return Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 140,
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold
                  ),
                ),
              ),
              SizedBox(
                width: 150,
                child: title == 'Payment Status'
                ? details == 'No'
                  ? const Text(
                      "Not yet paid",
                      style: TextStyle(
                        color: Color.fromARGB(255, 255, 34, 0),
                        fontSize: 20
                      ),
                    )
                  : const Text(
                      "Paid",
                      style: TextStyle(
                        color: Color.fromARGB(255, 0, 185, 9),
                        fontSize: 20
                      ),
                    )
                : Text(
                    details,
                    style: const TextStyle(
                      fontSize: 17,
                    ),
                  ),
              ),
            ]
          ),
          const SizedBox(height: 5),
          const Divider(thickness: 3),
        ],
      );
    }

    return SafeArea(
      child: Scaffold(
        appBar: DirectAppBarNoArrow(
          title: "${widget.orderSelected.custName}'s Order", 
          userRole: 'deliveryMan',
          barColor: deliveryColor
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: FutureBuilder<OrderCustModel?>(
              future: custOrderService.getCustOrderById(widget.orderSelected.id!),
              builder: (context, snapshot){
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else if (!snapshot.hasData || snapshot.data == null) {
                  return Container(
                    height: 400,
                    width: 400,
                    decoration: BoxDecoration(
                      border: Border.all()
                    ),
                    child: const Center(
                      child: Text(
                        "Error in fetching data of your order. Press type again",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 30
                        ),
                      )
                    ),
                  );
                } else{
                  OrderCustModel order = snapshot.data!;
                  return Column(
                    children: [
                      RichText(
                        text: TextSpan(
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 18
                          ),
                          children: [
                            const TextSpan(
                              text: 'Order for menu: ',
                              style: TextStyle(
                                fontWeight: FontWeight.bold
                              )
                            ),
                            TextSpan(
                              text: order.menuOrderName, 
                              style: const TextStyle(
                                fontSize: 16
                              )
                            )
                          ]
                        )
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          border: Border.all()
                        ),
                        child: Column(
                          children: [
                            buildDetailTile('Email Address', '${order.email}'),
                            buildDetailTile('Phone Number', '${order.phone}'),
                            buildDetailTile('Destination', '${order.destination}'),
                            buildDetailTile('Name', '${order.custName}'),
                            buildDetailTile('Remark', '${order.remark}'),
                            buildDetailTile('Order 1', '${order.orderDetails}'),
                            buildDetailTile('Amount paid', 'RM${order.payAmount!.toStringAsFixed(2)}'),
                            FutureBuilder(
                              future: paymentService.getPayMethodDetails(order.payMethodId!), 
                              builder:(context, snapshot) {
                                if(snapshot.connectionState == ConnectionState.waiting){
                                  return const CircularProgressIndicator();
                                }else if (snapshot.hasError){
                                  return buildDetailTile('Error', 'Error in fetching payment data');
                                }else if(!snapshot.hasData || snapshot.data == null){
                                  return buildDetailTile('Error', 'No data available');
                                }else{
                                  PaymentMethodModel payMethodDetails = snapshot.data!;
                                  return buildDetailTile('Payment Method', '${payMethodDetails.methodName}');
                                }
                              },
                            ),
                            buildDetailTile('Payment Status', '${order.paid}'),
                            Container(
                              width: double.infinity,
                              alignment: Alignment.center,
                              padding: const EdgeInsets.all(10),
                              color: order.delivered == 'Yes' ? orderDeliveredColor : orderHasNotDeliveredColor,
                              child: order.delivered == 'Yes'
                              ? const Text(
                                  'This order has been delivered.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 18),
                                )
                              : const Text(
                                  'This order has not been delivered yet.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 18),
                                ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                }
              }
            )
          ),
        ),
      )
    );
  }
}