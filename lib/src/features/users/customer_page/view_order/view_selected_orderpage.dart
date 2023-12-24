import 'package:flutter/material.dart';
import 'package:flutter_application_1/services/firestoreDB/order_cust_db_service.dart';
import 'package:flutter_application_1/services/firestoreDB/order_owner_db_service.dart';
import 'package:flutter_application_1/src/constants/decoration.dart';
import 'package:flutter_application_1/src/features/auth/models/order_customer.dart';
import 'package:flutter_application_1/src/features/auth/models/order_owner.dart';
import 'package:flutter_application_1/src/features/auth/screens/app_bar_noarrow.dart';
import 'package:flutter_application_1/src/features/users/customer_page/view_order/edit_order.dart';
import 'package:intl/intl.dart';

class CustViewOrderPage extends StatefulWidget {
  const CustViewOrderPage({
    required this.orderSelected,
    super.key
  });

  final OrderCustModel orderSelected;

  @override
  State<CustViewOrderPage> createState() => _CustViewOrderPageState();
}

class _CustViewOrderPageState extends State<CustViewOrderPage> {
  OrderCustDatabaseService custOrderService = OrderCustDatabaseService();
  OrderOwnerDatabaseService orderService = OrderOwnerDatabaseService();
  DateTime now = DateTime.now();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    Widget buildDetailTile(String title, String details){
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 20
            ),
          ),
          const SizedBox(height: 5),
          Container(
            width: 300,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              border: Border.all()
            ),
            child: Text(
              details,
              style: const TextStyle(
              fontSize: 17
            ),
            ),
          ),
          const SizedBox(height: 5),
          const Divider(thickness: 3),
        ]
      );
    }
    Widget buildReceiptTile(String title, String subtitle, String receiptUrl){
      return Column(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 20
            ),
          ),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 15
            ),
          ),
          const SizedBox(height: 5),
          Image.network(
            receiptUrl,
            width: 200,
            height: 300,
            fit: BoxFit.cover,
          )
        ] 
      );
    }
    
    return SafeArea(
      child: Scaffold(
        key: _scaffoldKey,
        appBar: const AppBarNoArrow(
          title: 'Your order', 
          barColor: custColor
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: FutureBuilder<OrderCustModel?>(
              future: custOrderService.getCustOrderById(widget.orderSelected.id!), 
              builder: (context, snapshot){
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
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
                        "You haven't placed any order yet",
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Menu: ${order.menuOrderName}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Order placed at ${DateFormat('yyyy-MM-dd hh:mm:ss').format(order.dateTime!)}',
                        style: const TextStyle(
                          fontSize: 18
                        ),
                      ),
                      const SizedBox(height: 5),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          border: Border.all()
                        ),
                        child: Column(
                          children: [
                            buildDetailTile('Email Address', '${order.email}'),
                            buildDetailTile('Phone Number', '${order.phone}'),
                            buildDetailTile('Pickup your Oder at?', '${order.destination}'),
                            buildDetailTile('Name', '${order.custName}'),
                            buildDetailTile('Remark', '${order.remark}'),
                            buildDetailTile('Order 1', '${order.orderDetails}'),
                            buildDetailTile('Amount paid', '${order.payAmount}'),
                            buildDetailTile('Payment Method', '${order.payMethod}'),
                            order.receipt == '' 
                            ? const Text(
                              "You haven't paid for this order yet, please make sure you make your payment by today.",
                              style: TextStyle(
                                color: Color.fromARGB(255, 255, 34, 0),
                                fontSize: 20
                              ),
                              )
                            : buildReceiptTile('Receipt', 'You have made your payment. This is your receipt.', '${order.receipt}'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                            height: 50,
                            width: width*0.35,
                            child: ElevatedButton(
                              onPressed: (){
                                //if the order is closed/time out, display dialog to show cannot cancel order anymore
                                //else display a dialog to confirm cancellation, then lead the user to cancelled order page for money refund
                                showDialog(
                                  context: _scaffoldKey.currentContext!,
                                  builder: (BuildContext context){
                                    return AlertDialog(
                                      title: const Text(
                                        'Order cancellation',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18
                                        ),
                                      ),
                                      content: const Text('Confirm to cancel this order?'),
                                      actions: [
                                        TextButton(
                                          onPressed: (){
                                            Navigator.of(context).pop();
                                          }, 
                                          child: const Text(
                                            'Cancel',
                                            style: TextStyle(
                                              fontSize: 15
                                            ),
                                          )
                                        ),
                                        TextButton(
                                          onPressed: (){
                                            Navigator.of(context).pop();
                                          }, 
                                          child: const Text(
                                            'Confirm',
                                            style: TextStyle(
                                              fontSize: 15
                                            ),
                                          )
                                        ),
                                      ],
                                    );
                                  }
                                );
                              },
                              child: const Text(
                                'Cancel order',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.black
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 50,
                            width: width*0.35,
                            child: ElevatedButton(
                              onPressed: (){
                                MaterialPageRoute route = MaterialPageRoute(builder: (context) => CustEditSelectedOrderPage(orderSelected: widget.orderSelected));
                                Navigator.push(context, route);
                              },
                              child: const Text(
                                'Edit order',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.black
                                ),
                              ),
                            ),
                          )
                        ],
                      )
                    ],
                  );
                }
              }
            ),
          )   
        ),
      )
    );
  }
}