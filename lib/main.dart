import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_application_1/src/features/auth/screens/welcome/welcome_page.dart';
import 'package:flutter_application_1/firebase_options.dart';
import 'package:flutter_application_1/src/features/users/customer/order_detail.dart';
import 'package:flutter_application_1/src/features/users/customer/view_order.dart';
import 'package:flutter_application_1/src/routing/routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // title: ,
      // theme: ThemeData(),



      home: OrderDetails(),
      


      routes: customRoute,
    );
  }
}

// class Homepage extends StatelessWidget {
//   const Homepage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return FutureBuilder(
//       future: AuthService.firebase().initialize(),
//       builder: (context, snapshot) {
//         //loading page
//           switch(snapshot.connectionState){
//             //when completed
//             case ConnectionState.done:
//               final user = AuthService.firebase().currentUser;
//               if(user != null){
//                 //if the user is registered
//                 if(user.isEmailVerified){
//                   //return scaffold in notesview
//                   //return const userMainPage();
                  
//                 } else{
//                   //return const VerifyEmailPage();
//                 }
//               }else{
//                 //if have not register as an user
//                 return const LoginPage();
//               }
              
//             default:
//               return const CircularProgressIndicator();
//           }
//       },
//     );
//   }
// }
