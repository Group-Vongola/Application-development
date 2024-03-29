import 'package:flutter/material.dart';
import 'package:flutter_application_1/services/firestoreDB/pricelist_db_service.dart';
import 'package:flutter_application_1/src/constants/decoration.dart';
import 'package:flutter_application_1/src/features/auth/models/price_list.dart';
import 'package:flutter_application_1/src/features/auth/screens/appBar/direct_appbar_arrow.dart';
import 'package:flutter_application_1/src/features/users/business_owner/menu_list/price_list/edit_price_list.dart';
import 'package:flutter_application_1/src/routing/routes_const.dart';

class ViewPriceListPage extends StatefulWidget {
  const ViewPriceListPage({
    required this.priceListSelected,
    super.key
  });

  final PriceListModel priceListSelected;

  @override
  State<ViewPriceListPage> createState() => _ViewPriceListPageState();
}


class _ViewPriceListPageState extends State<ViewPriceListPage> {
  bool isPriceListOpened = false;
  late Future<void> priceListStateFuture;
  final PriceListDatabaseService priceListService = PriceListDatabaseService();

  Future<void> loadPriceListState()async{
    try{
      PriceListModel? openPriceList = await PriceListDatabaseService().getPriceListDetails(widget.priceListSelected.priceListId!);
      if(openPriceList!.openStatus == 'Yes'){
        isPriceListOpened = true;
      }else{
        isPriceListOpened = false;
      }
    }catch(e){
      rethrow;
    }
  }

  @override
  void initState() {
    super.initState();
    priceListStateFuture = loadPriceListState();
  }

  @override
  Widget build(BuildContext context) {    
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;

    return SafeArea(
      child: Scaffold(
        appBar: GeneralDirectAppBar(
          title: 'View Price List', 
          userRole: 'owner',
          onPress: (){
            Navigator.of(context).pushNamedAndRemoveUntil(
              priceListRoute, 
              (route) => false,
            );
          }, 
          barColor: ownerColor
        ),
        body: FutureBuilder<void>(
          future: priceListStateFuture,
          builder:(context, snapshot) {
            if(snapshot.connectionState == ConnectionState.done){
              return SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Center(
                    child: Column(
                      children: [
                        isPriceListOpened 
                        ? Container(
                          height: 70,
                          width: width,
                          color: orderOpenedColor,
                          child: const Center(
                            child: Text(
                              'This price list is in OPEN state',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 25,
                              ),
                            )
                          ),
                        )
                        : Container(),

                        const SizedBox(height: 30),

                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              height: height*0.05,
                              width: width*0.25,
                              child: const Text(
                                "List's name: ",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold
                                ),
                              ),
                            ),

                            const SizedBox(width: 20),

                            Container(
                              padding: const EdgeInsets.all(5),
                              height: height*0.05,
                              width: width*0.55,
                              decoration: BoxDecoration(
                                border: Border.all()
                              ),
                              child: Text(
                                widget.priceListSelected.listName,
                                style: const TextStyle(
                                  fontSize: 20,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 30),
                        
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: width*0.25,
                              child: const Text(
                                "List's Description: ",
                                textAlign: TextAlign.start,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold
                                ),
                              ),
                            ),
                            const SizedBox(width: 20),

                            Container(
                              padding: const EdgeInsets.all(5),   
                              width: width*0.55,
                              decoration: BoxDecoration(
                                border: Border.all()
                              ),
                              child: Text(
                                widget.priceListSelected.priceDesc,
                                style: const TextStyle(
                                  fontSize: 20,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 80),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(
                              height: 50,
                              width: 100,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isPriceListOpened
                                  ? Colors.red 
                                  : const Color.fromARGB(255, 191, 48, 216),
                                  elevation: 10,
                                  shadowColor: const Color.fromARGB(255, 92, 90, 85),
                                ),
                                onPressed: ()async{
                                  if (isPriceListOpened) {
                                    //close the opened pricelist
                                    await PriceListDatabaseService().updateToClosedStatus(widget.priceListSelected.priceListId!);
                                  } else {
                                    //open the opened pricelist
                                    await PriceListDatabaseService().updateToOpenedStatus(widget.priceListSelected.priceListId!);
                                  }

                                  // Update the state to toggle between open and close
                                  setState(() {
                                    isPriceListOpened = !isPriceListOpened;
                                  });
                                  // ignore: use_build_context_synchronously
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        isPriceListOpened
                                          ? 'Price list is opened'
                                          : 'Price list is closed'
                                        ),
                                      duration: const Duration(seconds: 2),
                                    ),
                                  );
                                }, 
                                child: Text(
                                  isPriceListOpened ? 'Close' : 'Open',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    color:yellowColorText
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
                                    builder: (context) => EditPriceListPage(
                                      priceListSelected: widget.priceListSelected
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
            }else{
              return const Center(child: CircularProgressIndicator());
            }
          },
        )
      ),
    );
  }
}