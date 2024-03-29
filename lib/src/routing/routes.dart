import 'package:flutter/material.dart';
import 'package:flutter_application_1/src/features/auth/screens/forgetPswrd/forget_pswrd_mail.dart';
import 'package:flutter_application_1/src/features/auth/screens/privacy_security/privacy_security.dart';
import 'package:flutter_application_1/src/features/users/business_owner/menu_list/price_list/pricelist_page.dart';
import 'package:flutter_application_1/src/features/users/business_owner/order/add_order.dart';
import 'package:flutter_application_1/src/features/users/business_owner/order/order_cancelled/cancel_order.dart';
import 'package:flutter_application_1/src/features/users/business_owner/order/create_order.dart';
import 'package:flutter_application_1/src/features/users/business_owner/menu_list/payment_method/choose_paymethod.dart';
import 'package:flutter_application_1/src/features/users/business_owner/menu_list/menu_function/menu_add_dish.dart';
import 'package:flutter_application_1/src/features/users/business_owner/menu_list/menu_function/menu_mainpage.dart';
import 'package:flutter_application_1/src/features/users/business_owner/menu_list/price_list/create_price_list.dart';
import 'package:flutter_application_1/src/features/users/business_owner/menu_list/payment_method/fpx_method/create_fpx.dart';
import 'package:flutter_application_1/src/features/users/business_owner/menu_list/payment_method/tng_method/create_tng_page.dart';
import 'package:flutter_application_1/src/features/users/business_owner/owner_function/owner_edit_profile.dart';
import 'package:flutter_application_1/src/features/users/business_owner/owner_homepage.dart';
import 'package:flutter_application_1/src/features/users/business_owner/owner_function/owner_profile.dart';
import 'package:flutter_application_1/src/features/users/business_owner/menu_list/payment_method/create_paymethod_page.dart';
import 'package:flutter_application_1/src/features/users/customer_page/cust_homepage.dart';
import 'package:flutter_application_1/src/features/users/customer_page/cust_profile/cust_profile.dart';

import 'package:flutter_application_1/src/features/users/customer_page/cust_profile/cust_edit_profile.dart';
import 'package:flutter_application_1/src/features/users/customer_page/place_order/place_order_pages/b_menu_page.dart';
import 'package:flutter_application_1/src/features/users/customer_page/place_order/place_order_pages/a_price_list_page.dart';
import 'package:flutter_application_1/src/features/users/customer_page/view_order/view_list_order.dart';

import 'package:flutter_application_1/src/features/users/deliveryman/deliveryman_profile/delivery_edit_profile.dart';
import 'package:flutter_application_1/src/features/users/deliveryman/delivery_homepage.dart';
import 'package:flutter_application_1/src/features/auth/screens/login/login_page.dart';
import 'package:flutter_application_1/src/features/auth/screens/register/register_page.dart';
import 'package:flutter_application_1/src/features/auth/screens/email_verify/verify_emailpage.dart';
import 'package:flutter_application_1/src/features/auth/screens/welcome/welcome_page.dart';
import 'package:flutter_application_1/src/features/users/deliveryman/deliveryman_profile/delivery_profile.dart';
import 'package:flutter_application_1/src/routing/routes_const.dart';

var customRoute = <String, WidgetBuilder>{
  loginRoute: (context) => const LoginPage(),
  registerRoute: (context) => const Register(),
  verifyEmailRoute: (context) => const VerifyEmailView(),
  welcomeRoute: (context) => const WelcomePage(),
  privacySecurityRoute:(context) => const PrivacyAndSecurity(),
  resetPswrdEmailRoute: (context) => const ForgetPasswordMailScreen(),

  //----------------------Customer Route------------------------------
  customerRoute: (context) => const CustomerHomePage(),
  menuPageRoute: (context) => const DisplayMenuPage(),
  custMenuPriceListRoute: (context) => const PriceListPage(),
  custProfileRoute: (context) => const CustomerProfilePage(),
  editCustProfileRoute: (context) => const CustomerEditProfilePage(),
  viewCustOrderListPageRoute : (context) => const CustViewOrderListPage(),
  //------------------------------------------------------------------

  //---------------------Business Owner Route------------------------------
  businessOwnerRoute: (context) => const BusinessOwnerHomePage(),
  ownrProfileRoute: (context) => const OwnerProfilePage(),
  editOwnerProfileRoute: (context) => const OwnerEditProfilePage(),
  menuMainPageRoute: (context) => const MenuMainPage(),
  menuAddDishRoute: (context) => const MenuAddDishPage(),
  //-----------------------Price list--------------------------------------
  priceListCreatingRoute: (context) => const CreatePriceListPage(),

  priceListRoute:(context) => const PriceListMainPage(),
  //-----------------------Payment method----------------------------------

  payMethodPageRoute: (context) => const PaymentMethodPage(),
  choosePayMethodRoute: (context) => const ChoosePaymentMethodPage(),
  payMethodTnGRoute: (context) => const TouchNGoPage(),
  payMethodOnlineBankingRoute: (context) => const OnlineBankingPage(),

  //--------------------------Order----------------------------------------
  orderOpenPageRoute: (context) => const OpenOrderPage(),
  orderAddPageRoute: (context) => const AddOrDisplayOrderPage(),
  ownerViewCancelledOrderRoute:(context) => const CancelledOrderInOwnerPage(),
  //-----------------------------------------------------------------------
  //-----------------------------------------------------------------------

  //------------------------Deliveryman Route----------------------------
  deliveryManRoute: (context) => const DeliveryManHomePage(),
  deliveryProfileRoute: (context) => const DeliveryManProfilePage(),
  editDeliveryProfileRoute: (context) => const DeliveryEditProfilePage(),
  //---------------------------------------------------------------------
};
