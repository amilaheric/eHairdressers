import 'package:ehairdressers_mobile/providers/AppointmentProvider.dart';
import 'package:ehairdressers_mobile/providers/BrandProvider.dart';
import 'package:ehairdressers_mobile/providers/EmployeeProvider.dart';
import 'package:ehairdressers_mobile/providers/ProductCategoryProvider.dart';
import 'package:ehairdressers_mobile/providers/ProductProvider.dart';
import 'package:ehairdressers_mobile/providers/ProductSalesReportProvider.dart';
import 'package:ehairdressers_mobile/providers/SalonOperationsReportProvider.dart';
import 'package:ehairdressers_mobile/providers/UserProvider.dart';
import 'package:ehairdressers_mobile/screens/product_insert_screen.dart';
import 'package:ehairdressers_mobile/screens/product_sales_report_screen.dart';
import 'package:ehairdressers_mobile/screens/salon_operations_report_screen.dart';
import 'package:ehairdressers_mobile/utils/util.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:provider/provider.dart';

void main() {
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => ProductProvider()),
      ChangeNotifierProvider(create: (_) => EmployeeProvider()),
      ChangeNotifierProvider(create: (_) => BrandProvider()),
      ChangeNotifierProvider(create: (_) => ProductCategoryProvider()),
      ChangeNotifierProvider(create: (_) => AppointmentProvider()),
      ChangeNotifierProvider(create: (_) => ProductSalesReportProvider()),
      ChangeNotifierProvider(create: (_) => SalonOperationsReportProvider()),
      ChangeNotifierProvider(create: (_) => UserProvider()),
    ],
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          brightness: Brightness.light,
          scaffoldBackgroundColor: Color.fromARGB(255, 255, 255, 255),
          textTheme: const TextTheme(
            displayLarge:
                TextStyle(fontSize: 72.0, fontWeight: FontWeight.bold),
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
        home: Login());
  }
}

class Login extends StatelessWidget {
  Login({Key? key}) : super(key: key);

  TextEditingController _usernameController = new TextEditingController();
  TextEditingController _passwordController = new TextEditingController();

  static String get _baseUrl {
    const String baseUrl =
        String.fromEnvironment("baseUrl", defaultValue: "http://localhost:7051/");
    return baseUrl.endsWith("/") ? baseUrl : "$baseUrl/";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Login", style: TextStyle(color: Color(0x0FFe5c89d))),
        backgroundColor: Color(0x0FF13414b),
      ),
      backgroundColor: Color.fromARGB(255, 255, 255, 255),
      body: Center(
          child: Container(
        constraints: BoxConstraints(maxHeight: 600, maxWidth: 600),
        child: Card(
          elevation: 0,

          color: Color.fromARGB(255, 255, 255, 255),
          child: Padding(
            padding: const EdgeInsets.all(40.0),
            child: Column(children: [
              Image(
                image: AssetImage('assets/images/logo.png'),
                height: 270,
                width: 270,
              ),
              SizedBox(height: 20),
              TextField(
                decoration: InputDecoration(
                    labelText: "Username", prefixIcon: Icon(Icons.email)),
                controller: _usernameController,
              ),
              SizedBox(
                height: 8,
              ),
              TextField(
                obscureText: true,
                decoration: InputDecoration(
                  labelText: "Password",
                  prefixIcon: Icon(Icons.password),
                ),
                controller: _passwordController,
              ),
              Expanded(
                  child: Align(
                      alignment: Alignment.center,
                      child: ElevatedButton(
                        onPressed: () async {
                          var username = _usernameController.text;
                          var password = _passwordController.text;

                          try {
                            // Authenticate against the real login endpoint -
                            // it both verifies the password and issues the
                            // JWT used for every subsequent request.
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

                            var roles = (data["Roles"] ?? data["roles"] ?? [])
                                .cast<String>();
                            Authorization.roles = List<String>.from(roles);
                            Authorization.userRole = roles.contains("Admin")
                                ? "Admin"
                                : (roles.contains("Employee")
                                    ? "Employee"
                                    : "User");

                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => ProductInsert()));
                          } on Exception catch (e) {
                            Authorization.clear();
                            showDialog(
                                context: context,
                                builder: (BuildContext context) => AlertDialog(
                                      title: Text("Error"),
                                      content: Text(e.toString()),
                                      actions: [
                                        TextButton(
                                            onPressed: (() =>
                                                Navigator.pop(context)),
                                            child: Text("OK"))
                                      ],
                                    ));
                          }
                        },
                        child: Text("Login"),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Color.fromARGB(255, 247, 233, 211),
                            foregroundColor: Color(0x0FF938f94)),
                      )))
            ]),
          ),
        ),
      )),
    );
  }
}
