import 'package:ehairdressers_mobile/providers/appointment_provider.dart';
import 'package:ehairdressers_mobile/providers/cart_provider.dart';
import 'package:ehairdressers_mobile/providers/chat_provider.dart';
import 'package:ehairdressers_mobile/providers/user_account_provider.dart';
import 'package:ehairdressers_mobile/providers/recommendation_provider.dart';
import 'package:ehairdressers_mobile/providers/employees_provider.dart';
import 'package:ehairdressers_mobile/providers/order_item_provider.dart';
import 'package:ehairdressers_mobile/providers/order_provider.dart';
import 'package:ehairdressers_mobile/providers/payment_provider.dart';
import 'package:ehairdressers_mobile/providers/product_provider.dart';
import 'package:ehairdressers_mobile/providers/review_provider.dart';
import 'package:ehairdressers_mobile/providers/service_provider.dart';
import 'package:ehairdressers_mobile/providers/user_provider.dart';

import 'package:ehairdressers_mobile/screens/product_list_screen.dart';
import 'package:ehairdressers_mobile/utils/util.dart';
import 'package:flutter/material.dart' hide Card;
import 'package:flutter/material.dart' as material show Card;
import 'package:provider/provider.dart';
import 'package:flutter_stripe/flutter_stripe.dart' hide Card;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Stripe.publishableKey = StripeConfig.publishableKey;

  await Stripe.instance.applySettings();

  HttpOverrides.global = _DevHttpOverrides();
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => ProductProvider()),
      ChangeNotifierProvider(create: (_) => CartProvider()),
      ChangeNotifierProvider(create: (_) => ServiceProvider()),
      ChangeNotifierProvider(create: (_) => UserProvider()),
      ChangeNotifierProvider(create: (_) => AppointmentProvider()),
      ChangeNotifierProvider(create: (_) => EmployeesProvider()),
      ChangeNotifierProvider(create: (_) => PaymentProvider()),
      ChangeNotifierProvider(create: (_) => ReviewProvider()),
      ChangeNotifierProvider(create: (_) => OrderItemProvider()),
      ChangeNotifierProvider(create: (_) => OrderProvider()),
      ChangeNotifierProvider(create: (_) => ChatProvider()),
      ChangeNotifierProvider(create: (_) => UserAccountProvider()),
      ChangeNotifierProvider(create: (_) => RecommendationProvider()),
    ],
    child: const MyApp(),
  ));
}

class _DevHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'eHairdressers',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        textTheme: const TextTheme(
          displayLarge: TextStyle(fontSize: 72.0, fontWeight: FontWeight.bold),
          titleLarge: TextStyle(fontSize: 36.0, fontStyle: FontStyle.normal),
          bodyMedium: TextStyle(fontSize: 14.0),
        ),
        inputDecorationTheme: const InputDecorationTheme(
          labelStyle: TextStyle(color: Color(0x0FF938f94)),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Color(0x0FFe5c89d)),
          ),
          focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0x0FF13414b))),
          prefixIconColor: Color(0x0FFe5c89d),
        ),
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  MyHomePage({Key? key}) : super(key: key);
  TextEditingController _usernameController = new TextEditingController();
  TextEditingController _passwordController = new TextEditingController();
  late ProductProvider _productProvider;

  static String get _baseUrl {
    const String baseUrl =
        String.fromEnvironment("baseUrl", defaultValue: "http://10.0.2.2:7051/");
    return baseUrl.endsWith("/") ? baseUrl : "$baseUrl/";
  }

  @override
  Widget build(BuildContext context) {
    _productProvider = context.read<ProductProvider>();

    return Scaffold(
        body: Center(
            child: SingleChildScrollView(
      child: Container(
        constraints: BoxConstraints(maxHeight: 600, maxWidth: 600),
        child: material.Card(
          child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image(
                    image: AssetImage('assets/images/logo.png'),
                    height: 150,
                    width: 150,
                  ),
                  SizedBox(height: 16),
                  TextField(
                    decoration: InputDecoration(
                        labelText: "Username", prefixIcon: Icon(Icons.email)),
                    controller: _usernameController,
                  ),
                  SizedBox(height: 12),
                  TextField(
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: "Password",
                      prefixIcon: Icon(Icons.password),
                    ),
                    controller: _passwordController,
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      var username = _usernameController.text;
                      var password = _passwordController.text;

                      try {
                        // Authenticate against the real login endpoint - it
                        // both verifies the password and issues the JWT used
                        // for every subsequent request. No credentials are
                        // stored after this point, only the token.
                        var uri = Uri.parse("${_baseUrl}User/login");
                        var response = await http.post(
                          uri,
                          headers: {"Content-Type": "application/json"},
                          body: jsonEncode({
                            "Username": username,
                            "Password": password,
                          }),
                        );

                        if (response.statusCode != 200) {
                          throw Exception("Incorrect username or password");
                        }

                        var data = jsonDecode(response.body);

                        Authorization.token = data["Token"] ?? data["token"];
                        Authorization.username =
                            data["Username"] ?? data["username"] ?? username;
                        Authorization.currentUserId =
                            data["UserId"] ?? data["userId"] ?? 1;
                        Authorization.userEmail =
                            data["Email"] ?? data["email"];

                        var roles = (data["Roles"] ?? data["roles"] ?? [])
                            .cast<String>();
                        Authorization.roles = List<String>.from(roles);
                        Authorization.userRole =
                            roles.contains("Employee") ? "Employee" : "User";

                        await _productProvider.get();

                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => ProductListScreen()));
                      } catch (e) {
                        Authorization.clear();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Login failed: $e'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                    child: Text("Login"),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Color.fromARGB(255, 247, 233, 211),
                        foregroundColor: Color(0x0FF938f94)),
                  ),
                ],
              )),
        ),
      ),
    )));
  }
}
