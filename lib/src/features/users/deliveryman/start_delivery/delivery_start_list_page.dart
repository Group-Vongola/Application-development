import 'package:flutter/material.dart';
import 'package:flutter_application_1/services/auth/auth_service.dart';
import 'package:flutter_application_1/services/firestoreDB/order_cust_db_service.dart';
import 'package:flutter_application_1/src/constants/decoration.dart';
import 'package:flutter_application_1/src/features/auth/models/order_customer.dart';
import 'package:flutter_application_1/src/features/auth/screens/appBar/direct_appbar_noarrow.dart';
import 'package:flutter_application_1/src/features/users/deliveryman/start_delivery/delivery_start_mainpage.dart';

class DeliveryViewStartDeliveryListPage extends StatefulWidget {
  const DeliveryViewStartDeliveryListPage({super.key});

  @override
  State<DeliveryViewStartDeliveryListPage> createState() => _DeliveryViewStartDeliveryListPageState();
}

class _DeliveryViewStartDeliveryListPageState extends State<DeliveryViewStartDeliveryListPage> {
  final OrderCustDatabaseService custOrderService = OrderCustDatabaseService();
  
  Widget orderLongStatusBar(String detailsTxt, bool greenStatus){
    return Positioned(
      top: 55,
      right: 20,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Container(
          color: greenStatus ? statusYellowColor : statusRedColor, 
          height: 23,
          width: 280,
          alignment: Alignment.center,
          child: Text(
            detailsTxt,
            style: TextStyle(
              color: greenStatus ? Colors.black : yellowColorText,
              fontSize: greenStatus ? 16 : 14
            ),
          ),
        ),
      ),
    );
  }

  Widget orderStatusBar(String detailsTxt){
    return Positioned(
      top: 55,
      right: 20,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Container(
          color: Colors.amber, 
          height: 23,
          width: 160,
          alignment: Alignment.center,
          child: Text(
            detailsTxt,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 16
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = AuthService.firebase().currentUser!;
    final userId = currentUser.id;
    return SafeArea(
      child: Scaffold(
        appBar: DirectAppBarNoArrow(
          title: 'Delivery List', 
          barColor: deliveryColor, 
          textSize: 0,
          userRole: 'deliveryMan'
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const Text(
                  'Start your delivery now.',
                  style: TextStyle(
                    fontSize: 20
                  ),
                ),
                const SizedBox(height: 20),
                FutureBuilder<List<OrderCustModel>>(
                  future: custOrderService.getDistinctMenuOrderIds(),
                  builder: (context, snapshot){
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Text('No order found');
                    } else{
                      List<OrderCustModel> distinctOrdersMenuId = snapshot.data!;
                      return Column(
                        children: distinctOrdersMenuId.map((order){
                          return Column(
                            children: [
                              Stack(
                                children: [
                                  ListTile(
                                    tileColor: const Color.fromARGB(255, 36, 255, 251),
                                    shape: BeveledRectangleBorder(
                                      side: const BorderSide(width: 0.5),
                                      borderRadius: BorderRadius.circular(20)
                                    ),
                                    contentPadding: const EdgeInsetsDirectional.all(12),
                                    title: RichText(
                                      text: TextSpan(
                                        style: const TextStyle(
                                          fontSize: 18,
                                          color: Colors.black,
                                        ),
                                        children: [
                                          const TextSpan(
                                            text: 'Orders For: ',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          TextSpan(
                                            text: order.menuOrderName,
                                            style: const TextStyle(
                                              fontSize: 16
                                            )
                                          ),
                                        ],
                                      ),
                                    ),
                                    trailing: const Icon(
                                      Icons.arrow_right_outlined,
                                      size: 40,
                                    ),
                                    onTap: () {
                                      MaterialPageRoute route = MaterialPageRoute(
                                        builder: (context) => DeliveryStartMainPage(orderDeliveryOpened: order)
                                      );
                                      Navigator.push(context, route);
                                    },
                                  ),
                                  StreamBuilder<List<OrderCustModel>>(
                                    stream: custOrderService.getDeliveryManSpecificPendingOrder(order.menuOrderID!, userId),
                                    builder: (context, snapshot){
                                      if (snapshot.connectionState == ConnectionState.waiting) {
                                        return const CircularProgressIndicator();
                                      } else if (snapshot.hasError) {
                                        return orderLongStatusBar('Error: ${snapshot.error}', false);
                                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                                        return orderStatusBar('No pending order');
                                      }else {
                                        List<OrderCustModel> orders = snapshot.data!;
                                        int totalOrders = orders.length;
                                        return totalOrders > 1 
                                        ? orderStatusBar('Total: $totalOrders pending orders')
                                        : orderStatusBar('Total: $totalOrders pending order');
                                      }
                                    }
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20)
                            ],
                          );
                        }).toList(),
                      );
                    }
                  }
                )
              ],
            ),
          ),
        )
      )
    );
  }
}