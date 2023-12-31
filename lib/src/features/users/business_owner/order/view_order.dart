import 'package:flutter/material.dart';
import 'package:flutter_application_1/services/firestoreDB/menu_db_service.dart';
import 'package:flutter_application_1/services/firestoreDB/order_owner_db_service.dart';
import 'package:flutter_application_1/services/firestoreDB/paymethod_db_service.dart';
import 'package:flutter_application_1/services/firestoreDB/pricelist_db_service.dart';
import 'package:flutter_application_1/src/constants/decoration.dart';
import 'package:flutter_application_1/src/features/auth/models/pay_method.dart';
import 'package:flutter_application_1/src/features/auth/provider/order_provider.dart';
import 'package:flutter_application_1/src/features/auth/provider/paymethod_provider.dart';
import 'package:flutter_application_1/src/features/auth/screens/appBar/direct_appbar_noarrow.dart';
import 'package:flutter_application_1/src/features/users/business_owner/order/close_order.dart';
import 'package:provider/provider.dart';

import '../../../auth/models/dish.dart';
import '../../../auth/models/menu.dart';
import '../../../auth/models/order_owner.dart';
import '../../../auth/models/price_list.dart';
import '../../../auth/provider/selectedpricelist_provider.dart';

class ViewOrderPage extends StatefulWidget {
  const ViewOrderPage({
    required this.orderSelected,
    super.key
  });

  final OrderOwnerModel orderSelected;

  @override
  State<ViewOrderPage> createState() => _ViewOrderPageState();
}

class _ViewOrderPageState extends State<ViewOrderPage> {
  OrderOwnerDatabaseService orderService = OrderOwnerDatabaseService();
  
  Widget buildMenuDetails(String menuId) {
    return FutureBuilder<MenuModel?>(
      future: MenuDatabaseService().getMenu(menuId), 
      builder: (context, snapshot){
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Loading state
          return const CircularProgressIndicator();
        } else if (snapshot.hasError || snapshot.data == null) {
          // Error state or no data
          return buildErrorTile('Error in the Menu chosen');
        }else{
          MenuModel menu = snapshot.data!;
          return Container(
            height: 500,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                border: Border.all(),
                borderRadius: BorderRadius.circular(20),
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Menu Details:',
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    RichText(
                      text: TextSpan(
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.black,
                        ),
                        children: [
                          const TextSpan(
                            text: 'Menu Name: ',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextSpan(
                            text: menu.menuName,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 5),
                    RichText(
                      text: TextSpan(
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.black,
                        ),
                        children: [
                          const TextSpan(
                            text: 'Created Date: ',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextSpan(
                            text: menu.createdDate,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 5),

                    const Text(
                      'Main Dishes:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    buildDishList(menu.mainDishList),
                    const SizedBox(height: 20),
                    const Text(
                      'Side Dishes:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    buildDishList(menu.sideDishList),
                    const SizedBox(height: 20),
                    const Text(
                      'Special Dishes:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    buildDishList(menu.specialDishList),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            
          );
        }
      }
    );
  }
  
  Widget buildDishList(List<DishModel> dishList) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: dishList.map((dish) => Container(
          width: 300,
          color: const Color.fromARGB(255, 255, 228, 148),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                '${dish.dishSpcId}- ${dish.dishName}',
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 5),
              if (dish.dishPhoto.isNotEmpty) // Check if the dish has an image
                Image.network(
                  dish.dishPhoto,
                  width: 200, 
                  height: 200, 
                  fit: BoxFit.cover,
                ),
              const SizedBox(height: 15),
            ],
          ),
        )).toList(),
      ),
    );
  }

  Widget buildPriceList(String id){
    return FutureBuilder<PriceListModel?>(
      future: PriceListDatabaseService().getPriceListDetails(id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Loading state
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          // Error state
          return buildErrorTile("Error loading price list details");
        } else if (!snapshot.hasData || snapshot.data == null) {
          // No data state
          return buildErrorTile("No data available for the selected price list");
        } else {
          // Data loaded successfully
          PriceListModel priceList = snapshot.data!;
          // Display the contents of the price list
          return Container(
            width: 300,
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              border: Border.all(),
              borderRadius: BorderRadius.circular(20)
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Price List Details:',
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                RichText(
                  text: TextSpan(
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.black,
                    ),
                    children: [
                      const TextSpan(
                        text: 'List Name: ',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextSpan(
                        text: priceList.listName,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 5),
                RichText(
                  text: TextSpan(
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.black,
                    ),
                    children: [
                      const TextSpan(
                        text: 'Created Date: ',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextSpan(
                        text: priceList.createdDate,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 5),
                RichText(
                  text: TextSpan(
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.black, 
                    ),
                    children: [
                      const TextSpan(
                        text: 'Details: ',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextSpan(
                        text: priceList.priceDesc,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }
      },
    );
  }

  Widget buildPayMethod(){
    return Consumer<SelectedPayMethodProvider>(
      builder: (context, selectedPayMethodProvider, child) {
        List<String> paymentMethodIds = selectedPayMethodProvider.selectedPaymentMethodsId;

        if (paymentMethodIds.isEmpty) {
          return buildErrorTile("You haven't chosen any payment method");
        }

        return Container(
          width: 300,
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            border: Border.all(),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Payment methods: ',
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              ListView.builder(
                shrinkWrap: true,
                itemCount: paymentMethodIds.length,
                itemBuilder: (context, index) {
                  String payMethodId = paymentMethodIds[index];

                  return Column(
                    children: [
                      FutureBuilder<PaymentMethodModel?>(
                        future: PayMethodDatabaseService().getPayMethodDetails(payMethodId),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const CircularProgressIndicator();
                          } else if (snapshot.hasError) {
                            return buildErrorTile('Error fetching payment method details');
                          } else if (!snapshot.hasData || snapshot.data == null) {
                            return buildErrorTile('Payment method not found');
                          } else {
                            PaymentMethodModel payMethodDetails = snapshot.data!;
                            return Container(
                              decoration: BoxDecoration(border: Border.all()),
                              child: ListTile(
                                title: Text(
                                  payMethodDetails.methodName ?? 'No method name',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold
                                  ),
                                ),
                              ), 
                            );
                          }
                        },
                      ),
                      const SizedBox(height: 10)
                    ],
                  );
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget buildErrorTile(String text){
    return Container(
      width: 300,
      height: 60,
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        border: Border.all(),
        borderRadius: BorderRadius.circular(20),
        color: menuErrorColor
      ),
      child: Center(
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 20,
            color: errorTextColor
          ),
        )
      ),  
    );
  }

  @override
  Widget build(BuildContext context) {
    // var height = MediaQuery.of(context).size.height;
    // var width = MediaQuery.of(context).size.width;
    final selectedPriceListProvider = Provider.of<SelectedPriceListProvider>(context);
    OrderOwnerModel? currentOrder = Provider.of<OrderProvider>(context).currentOrder;
    return SafeArea(
      child: Scaffold(
        appBar: DirectAppBarNoArrow(
          title: widget.orderSelected.orderName!, 
          userRole: 'owner',
          barColor: ownerColor
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Center(
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      currentOrder == null 
                      ? Container()
                      : InkWell(
                          onTap: (){
                            MaterialPageRoute route = MaterialPageRoute(
                              builder: (context) => CloseOrderPage(
                                orderSelected: widget.orderSelected
                              )
                            );
                            Navigator.push(context, route);
                          },
                          child: Container(
                            width: 170,
                            height: 50,
                            color: orderOpenedColor,
                            child: const Center(
                              child: Text(
                                'Order is opening',
                                style: TextStyle(
                                  fontSize: 18
                                ),
                              )
                            )
                          ),
                        ), 
                      InkWell(
                        onTap: (){
                          MaterialPageRoute route = MaterialPageRoute(
                            builder: (context) => CloseOrderPage(
                              orderSelected: widget.orderSelected
                            )
                          );
                          Navigator.push(context, route);
                        },
                        child: Container(
                          width: 170,
                          height: 50,
                          color: currentOrder == null ? const Color.fromARGB(255, 60, 255, 0) : const Color.fromARGB(255, 242, 255, 0),
                          child: Center(
                            child: Text(
                              currentOrder == null ? 'Press to OPEN order' : 'Press to CLOSE order',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 18
                              ),
                            )
                          )
                        ),
                      )
                    ],
                  ),
                  
                  const SizedBox(height: 40),
                                  
                  selectedPriceListProvider.selectedPriceListId != null
                  ? buildPriceList(selectedPriceListProvider.selectedPriceListId!)
                  : buildErrorTile("You haven't chosen any price list"),
                  const SizedBox(height: 40),

                  buildMenuDetails(widget.orderSelected.menuChosenId!),
                  const SizedBox(height: 40),

                  buildPayMethod(),
                  const SizedBox(height: 100),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
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
                            showDialog(
                              context: context, 
                              builder: (BuildContext context){
                                return AlertDialog(
                                  title: const Text(
                                    'You are deleting this order',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 25,
                                      fontWeight: FontWeight.bold
                                    ),
                                  ),
                                  content: const Text(
                                    'Confirm to delete this order?',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 20
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
                                          fontSize: 20
                                        ),
                                      )
                                    ),
                                    TextButton(
                                      onPressed: ()async {
                                        await orderService.deleteOrder(widget.orderSelected.id, context);
                                      }, 
                                      child: const Text(
                                        'Delete',
                                        style: TextStyle(
                                          fontSize: 20
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
                              color: Colors.black
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
                            // MaterialPageRoute route = MaterialPageRoute(
                            //   builder: (context) => EditFPXPaymentPage(
                            //     payMethodSelected: widget.payMethodSelected
                            //   )
                            // );
                            // Navigator.pushReplacement(context, route);
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
        ),
      )
    );
  }
}
