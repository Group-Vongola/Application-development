import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/services/firestoreDB/order_cust_db_service.dart';
import 'package:flutter_application_1/services/firestoreDB/paymethod_db_service.dart';
import 'package:flutter_application_1/src/constants/decoration.dart';
import 'package:flutter_application_1/src/features/auth/models/order_customer.dart';
import 'package:flutter_application_1/src/features/auth/models/pay_method.dart';
import 'package:flutter_application_1/src/features/auth/screens/appBar/direct_appbar_noarrow.dart';
import 'package:flutter_application_1/src/features/users/deliveryman/pending_order/complete_pending_order.dart';
import 'package:flutter_application_1/src/features/users/deliveryman/total_order/delivery_order_details.dart';

class OrderPendingPage extends StatefulWidget {
  const OrderPendingPage({
    required this.orderDeliveryOpened,
    required this.userId,
    super.key
  });

  final OrderCustModel orderDeliveryOpened;
  final String userId;

  @override
  State<OrderPendingPage> createState() => _OrderPendingPageState();
}

class _OrderPendingPageState extends State<OrderPendingPage> {
  final searchBarController = TextEditingController();
  final OrderCustDatabaseService custOrderService = OrderCustDatabaseService();
  final PayMethodDatabaseService paymentService = PayMethodDatabaseService();
  late StreamController<List<OrderCustModel>> _streamController;
  late List<OrderCustModel> _allOrders;
  List<String> selectedOrderIdList = [];
  bool isMultiSelectionEnabled = false;

  void _loadOrders() {
    custOrderService.getDeliveryManSpecificPendingOrder(widget.orderDeliveryOpened.menuOrderID!, widget.userId).listen((List<OrderCustModel> orders) {
      _allOrders = orders;
      _applySearchFilter();
    });
  }
  void _loadOriginalOrder() {
    _loadOrders();
  }
  void _applySearchFilter() {
    final String query = searchBarController.text.toLowerCase();
    final List<OrderCustModel> filteredOrders = _allOrders.where((order) {
      return order.destination!.toLowerCase().contains(query);
    }).toList();

    _streamController.add(filteredOrders);
  }
  
  @override
  void initState() {
    super.initState();
    _allOrders = [];
    _streamController = StreamController<List<OrderCustModel>>.broadcast();
    _loadOrders();
  }
  @override
  void dispose(){
    super.dispose();
    searchBarController.dispose();
  }

  var options = [
    'Default',
    'Location',
    'DishType',
    'Name',
    'PayMethod',
    'Status'
  ];
  var selectedFeature = 'Default';

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    InkWell getOrderList(OrderCustModel orderDetails){
      bool isSelected = selectedOrderIdList.contains(orderDetails.id);
      return InkWell(
        onTap:(){
          isMultiSelectionEnabled 
          ? setState(() {
              isSelected = !isSelected;
              if (isSelected) {
                selectedOrderIdList.add(orderDetails.id!);
              } else {
                selectedOrderIdList.remove(orderDetails.id);
              }
            })
          : Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DeliveryManOrderDetails(orderSelected: orderDetails),
              )
            );
        },
        onLongPress: (){
          setState(() {
            isSelected = !isSelected;
            isMultiSelectionEnabled = !isMultiSelectionEnabled;
            if (isSelected) {
              selectedOrderIdList.add(orderDetails.id!);
            } else {
              selectedOrderIdList.remove(orderDetails.id);
            }
          });
        },
        child: GestureDetector(
          child: Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  blurRadius: 20.0, 
                  spreadRadius: 0.0,
                  offset: const Offset(
                    5.0, 
                    5.0,
                  ),
                )
              ]
            ),
            child: Card(
              clipBehavior: Clip.hardEdge,
              child: Material(
                color: isMultiSelectionEnabled
                ? longPressCardColor
                : orderHasNotDeliveredColor,
                child: InkWell(
                  child: Container(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      children: [
                        SizedBox(
                          height: 30,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                orderDetails.custName!,
                                style: const TextStyle(
                                  fontSize: 16.0,
                                  fontFamily: 'Roboto',
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                )
                              ),
                              const SizedBox(width: 20),
                              InkWell(
                                onTap: (){
                                  showDialog(
                                    context: context, 
                                    builder: (BuildContext context){
                                      return AlertDialog(
                                        title: const Text('Update delivered status'),
                                        content: const Text("Click 'Delivered' button if this order is delivered"),
                                        actions: [
                                          TextButton(
                                            onPressed: (){
                                              Navigator.pop(context);
                                            }, 
                                            child: const Text('Cancel')
                                          ),
                                          TextButton(
                                            onPressed:()async{
                                              await custOrderService.updateDeliveredInOrder(orderDetails.id!);
                                              // ignore: use_build_context_synchronously
                                              Navigator.pop(context);
                                            }, 
                                            child: const Text('Delivered')
                                          )
                                        ],
                                      );
                                    }
                                  );
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(5),
                                  width: 110,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(11),
                                    color: onTheWayBarColor,
                                  ),
                                  child: const Text(
                                    'On the way',
                                    style: TextStyle(
                                      fontSize: 16.0,
                                      fontFamily: 'Roboto',
                                      color: yellowColorText
                                    )
                                  )
                                ),
                              ),
                              isMultiSelectionEnabled
                              ? Checkbox(
                                  value: isSelected, 
                                  onChanged: (value){
                                    setState(() {
                                      isSelected = value!;
                                      if (isSelected) {
                                        selectedOrderIdList.add(orderDetails.id!);
                                      } else {
                                        selectedOrderIdList.remove(orderDetails.id);
                                      }
                                    });
                                  }
                                )
                              : Container()
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        
                        SizedBox(
                          height: 20,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              FutureBuilder(
                                future: paymentService.getPayMethodDetails(orderDetails.payMethodId!), 
                                builder:(context, snapshot) {
                                  if(snapshot.connectionState == ConnectionState.waiting){
                                    return const CircularProgressIndicator();
                                  }else if (snapshot.hasError){
                                    return const Text('Error in fetching payment data');
                                  }else if(!snapshot.hasData || snapshot.data == null){
                                    return const Text('No data available');
                                  }else{
                                    PaymentMethodModel payMethodDetails = snapshot.data!;
                                    return RichText(
                                      text: TextSpan(
                                        style: const TextStyle(
                                          fontSize: 15.0,
                                          fontFamily: 'Roboto',
                                          color: Colors.black,
                                        ),
                                        children: [
                                          const TextSpan(
                                            text: "Payment Type: ",
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold
                                            )
                                          ),
                                          TextSpan(
                                            text: payMethodDetails.methodName,
                                          )
                                        ]
                                      ),
                                    );
                                  }
                                },
                              ),
                              
                              isMultiSelectionEnabled
                              ? InkWell(
                                onTap: (){
                                  setState(() {
                                    isMultiSelectionEnabled = !isMultiSelectionEnabled;
                                    selectedOrderIdList.clear();
                                  });
                                },
                                  child: const Icon(
                                    Icons.cancel_outlined,
                                    color: Colors.red,
                                  )
                                )
                              : Container()
                            ],
                          ),
                        ),
                        const SizedBox(height: 5),
                        Row(
                          children: [
                            RichText(
                              text: TextSpan(
                                style: const TextStyle(
                                  fontSize: 15.0,
                                  fontFamily: 'Roboto',
                                  color: Colors.black,
                                ),
                                children: [
                                  const TextSpan(
                                    text: "Destination: ",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold
                                    )
                                  ),
                                  TextSpan(
                                    text: orderDetails.destination!,
                                  )
                                ]
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            RichText(
                              text: TextSpan(
                                style: const TextStyle(
                                  fontSize: 15.0,
                                  fontFamily: 'Roboto',
                                  color: Colors.black,
                                ),
                                children: [
                                  const TextSpan(
                                    text: "Amount: ",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold
                                    )
                                  ),
                                  TextSpan(
                                    text: 'RM${orderDetails.payAmount!.toStringAsFixed(2)}',
                                  )
                                ]
                              ),
                            ),
                            InkWell(
                              onTap: orderDetails.paid == 'No'
                              ? () {
                                  showDialog(
                                    context: context, 
                                    builder: (BuildContext context){
                                      return AlertDialog(
                                        title: const Text('Update payment status'),
                                        content: const Text("Click 'Paid' button if the customer has made the payment"),
                                        actions: [
                                          TextButton(
                                            onPressed: (){
                                              Navigator.pop(context);
                                            }, 
                                            child: const Text('Cancel')
                                          ),
                                          TextButton(
                                            onPressed:()async{
                                              await custOrderService.updatePaymentStatus(orderDetails.id!);
                                              // ignore: use_build_context_synchronously
                                              Navigator.pop(context);
                                            }, 
                                            child: const Text('Paid')
                                          )
                                        ],
                                      );
                                    }
                                  );
                                }
                              : (){},
                              child: Container(
                                padding: const EdgeInsets.all(5),
                                width: 110,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(11),
                                  border: Border.all(width:0.5),
                                  color: orderDetails.paid == 'No' 
                                  ? statusRedColor
                                  : statusYellowColor
                                ),
                                child: orderDetails.paid == 'No'
                                ? const Text(
                                  'Not Yet Paid',
                                  style: TextStyle(
                                    color: yellowColorText,
                                    fontWeight: FontWeight.bold
                                  ),
                                  )
                                : const Text(
                                    'Paid',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w500
                                    ),
                                  )
                              ),
                            )
                          ],
                        ),
                      ],
                    ),
                  )  
                ),
              ),
            ),
          ),
        )
      );
    }
    
    return SafeArea(
      child: Scaffold(
        appBar: DirectAppBarNoArrow(
          title: '${widget.orderDeliveryOpened.menuOrderName}', 
          userRole: 'deliveryMan',
          textSize: 20,
          barColor: deliveryColor
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      width: 190,
                      child: TextField(
                        controller: searchBarController,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(
                            Icons.search,
                            size: 20,
                          ),
                          labelText: 'Search by destination',
                          labelStyle: const TextStyle(
                            fontSize: 15
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onChanged:(_) => _applySearchFilter(),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(5),
                      width: 120,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.amber
                      ),
                      child: Center(
                        child: Column(
                          children: [
                            DropdownButton<String>(
                              items: options.map((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value)
                                );
                              }).toList(),
                              onChanged: (newValueSelected){
                                setState(() {
                                  selectedFeature = newValueSelected!;
                                  if (selectedFeature == 'Default') {
                                    _loadOriginalOrder(); 
                                  }
                                });
                              },
                              value: selectedFeature,
                            ),
                          ],
                        )
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Text(
                      'List arrangement:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      selectedFeature == 'Default'
                      ? 'Default'
                      : selectedFeature == 'Location'
                        ? 'Sorted by destination'
                        : selectedFeature == 'DishType'
                          ? 'Sorted by Type of Dish'
                          : selectedFeature == 'Name'
                            ? 'Sorted by Customer Name'
                            : selectedFeature == 'PayMethod'
                              ? 'Sorted by Payment Method'
                              : selectedFeature == 'Status'
                                ? 'Sorted by Payment Status'
                                : 'Default'
                    )
                  ]
                ),
                const SizedBox(height: 10),
                const Text(
                  'Pending Orders',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold
                  ),
                ),
                const SizedBox(height: 10),
                StreamBuilder<List<OrderCustModel>>(
                  stream: _streamController.stream,  
                  builder: (context, snapshot){
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Container(
                        height: 400,
                        width: 400,
                        decoration: BoxDecoration(
                          border: Border.all()
                        ),
                        child: const Center(
                          child: Text(
                            "No order found",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 30
                            ),
                          )
                        ),
                      );
                    }else {
                      List<OrderCustModel> orders = snapshot.data!;
                      if (selectedFeature == 'Location') {
                        orders.sort((a, b) => a.destination!.toLowerCase().compareTo(b.destination!.toLowerCase()));
                      }else if (selectedFeature == 'DishType') {
                        orders.sort((a, b) => a.orderDetails!.toLowerCase().compareTo(b.orderDetails!.toLowerCase()));
                      }else if (selectedFeature == 'Name') {
                        orders.sort((a, b) => a.custName!.toLowerCase().compareTo(b.custName!.toLowerCase()));
                      }else if (selectedFeature == 'PayMethod') {
                        orders.sort((a, b) => a.payMethodId!.compareTo(b.payMethodId!));
                      }else if (selectedFeature == 'Status') {
                        orders.sort((a, b) => a.paid!.compareTo(b.paid!));
                      }
                      
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            height: height,
                            width: width,
                            color: const Color.fromARGB(255, 244, 255, 141),
                            child: ListView(
                              children: orders.map((order){
                                return Card(
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  child: SizedBox(
                                    height: 150.0,
                                    child: getOrderList(order),
                                  )
                                );
                              }).toList(),
                            ),
                          )
                        ],
                      );
                    }
                  }
                ),
              ],
            )
          ),
        ),
        floatingActionButton: isMultiSelectionEnabled
        ? SizedBox(
            height: 60,
            width: 150,
            child: FloatingActionButton(
              backgroundColor: const Color.fromARGB(255, 238, 255, 0),
              onPressed: (){
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DeliveryManCompletePendingOrderPage(completeOrderList: selectedOrderIdList)
                  )
                );
              },
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),     
              ),
              child: const Text(
                'Completed order',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.black
                ),
              ),
            ),
          )
        : Container()
      )
    );
  }
}