import 'package:flutter/material.dart';
import 'package:flutter_application_1/services/firestoreDB/menu_db_service.dart';
import 'package:flutter_application_1/services/firestoreDB/order_owner_db_service.dart';
import 'package:flutter_application_1/src/constants/decoration.dart';
import 'package:flutter_application_1/src/features/auth/models/dish.dart';
import 'package:flutter_application_1/src/features/auth/models/order_owner.dart';
import 'package:flutter_application_1/src/features/auth/screens/appBar/direct_appbar_arrow.dart';
import 'package:flutter_application_1/src/features/users/customer_page/place_order/place_order_pages/c_place_order_page.dart';

import 'package:flutter_application_1/src/routing/routes_const.dart';
import 'package:intl/intl.dart';

import '../../../../auth/models/menu.dart';

class DisplayMenuPage extends StatefulWidget {
  const DisplayMenuPage({super.key});

  @override
  State<DisplayMenuPage> createState() => _DisplayMenuPageState();
}

class _DisplayMenuPageState extends State<DisplayMenuPage> {
  final OrderOwnerDatabaseService ownerOrderService = OrderOwnerDatabaseService();
  OrderOwnerModel? currentOrderOpened;
  late Future<void> orderOpenedStatusFuture;
  
  Future<void> loadOpenedStatusState()async{
    currentOrderOpened = await ownerOrderService.getTheOpenedOrder();
  }

  String _formatDateTime(DateTime? dateTime) {
    if (dateTime != null) {
      return DateFormat('yyyy-MM-dd HH:mm a').format(dateTime);
    } else {
      return 'N/A';
    }
  }
  
  @override
  void initState(){
    super.initState();
    orderOpenedStatusFuture = loadOpenedStatusState();
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height= MediaQuery.of(context).size.height;
    
    Widget buildDishCategory(String categoryTitle, List<DishModel> dishes) {
      return Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                border: Border.all(width: 0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                categoryTitle,
                style: const TextStyle(fontSize: 20),
              ),
            ),
            const SizedBox(height: 5),
      
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10.0,
                mainAxisSpacing: 10.0,
              ),
              itemCount: dishes.length,
              itemBuilder: (context, index) {
                DishModel dish = dishes[index];
                return Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    border: Border.all(width: 0.5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Text('${dish.dishSpcId}- ${dish.dishName}'),
                        const SizedBox(height: 5),
                        dish.dishPhoto.isNotEmpty
                        ? Image.network(
                            dish.dishPhoto,
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                          )
                        : Container(
                            height: 100,
                            width: 100,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.grey
                              )
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.image, 
                                size: 50, 
                                color: Colors.grey
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 15),
          ],
        ),
      );
    }
    
    Widget buildMenu(MenuModel menu){
      return Container(
        height: height*0.7,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          border: Border.all(),
          borderRadius: BorderRadius.circular(10),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Row(
                children: [
                  RichText(
                    text: TextSpan(
                      style: const TextStyle(
                        fontSize: 20,
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
                ],
              ),
              const SizedBox(height: 10),
              buildDishCategory('Main dishes', menu.mainDishList),
              const SizedBox(height: 30),
              buildDishCategory('Side dishes', menu.sideDishList),
              const SizedBox(height: 30),
              buildDishCategory('Special dishes', menu.specialDishList),
                  
            ],
          ),
        ),
      );
    }
  
    Widget buildError(String text){
      return Container(
        padding: const EdgeInsets.all(10),
        width: 300,
        height: 500,
        decoration: BoxDecoration(
          border: Border.all(),
        ),
        child: Center(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold
            ),
          ),
        ),
      );
    }
    
    return SafeArea(
      child: Scaffold(
        appBar: GeneralDirectAppBar(
          title: 'Menu',
          userRole: 'customer',
          onPress: (){
            Navigator.of(context).pushNamedAndRemoveUntil(
              custMenuPriceListRoute, 
              (route) => false,
            );
          }, 
          barColor: custColor
        ),
        body: FutureBuilder<void>(
          future: orderOpenedStatusFuture,
          builder: (context, snapshot) {
            if(snapshot.connectionState == ConnectionState.done){
              return SingleChildScrollView(
                child: currentOrderOpened == null 
                ? Padding(
                    padding: const EdgeInsets.all(20),
                    child: Container(
                      height: height*0.8,
                      width: width,
                      decoration: BoxDecoration(
                        border: Border.all()
                      ),
                      child: const Center(
                        child: Text(
                          'No open order found.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 40
                          ),
                          ),
                      ),
                    ),
                  )
                : Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              const Text(
                                'Start time: ',
                                style: TextStyle(
                                  fontSize: 18
                                ),
                              ),
                              Text(
                                _formatDateTime(currentOrderOpened!.startTime),
                                style: const TextStyle(
                                  fontSize: 18
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 5),
                          Row(
                            children: [
                              const Text(
                                'Closing time: ',
                                style: TextStyle(
                                  fontSize: 18
                                ),
                              ),
                              Text(
                                _formatDateTime(currentOrderOpened!.endTime),
                                style: const TextStyle(
                                  fontSize: 18
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
          
                          FutureBuilder<MenuModel?>(
                            future: MenuDatabaseService().getMenu(currentOrderOpened!.menuChosenId!),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return const CircularProgressIndicator();
                              } else if (snapshot.hasError) {
                                return buildError('Error: ${snapshot.error}');
                              } else if (!snapshot.hasData || snapshot.data == null) {
                                return buildError('No menu found');
                              } else {
                                MenuModel menu = snapshot.data!;
                                return buildMenu(menu);
                              }
                            },
                          ),
                          const SizedBox(height: 20),
                    
                          SizedBox(
                            height: 50,
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color.fromARGB(255, 240, 145, 3), 
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(25)),
                                ),
                                elevation: 10,
                                shadowColor: const Color.fromARGB(255, 92, 90, 85),
                              ),
                              onPressed: () async {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => CustPlaceOrderPage(currentOrderOpened: currentOrderOpened!) 
                                  )
                                );
                              },
                              child: const Text(
                                'Next',
                                style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.black
                                ),
                              ),
                            ),
                          )
                        ]
                      ),
                    ),
                  ),
              );
            }else{
              return const Center(child: CircularProgressIndicator());
            }
          }
        ),
      ),
    );
  }
}
