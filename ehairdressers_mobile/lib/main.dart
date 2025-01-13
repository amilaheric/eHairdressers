import 'package:ehairdressers_mobile/providers/appointment_provider.dart';
import 'package:ehairdressers_mobile/providers/cart_provider.dart';
import 'package:ehairdressers_mobile/providers/product_provider.dart';
import 'package:ehairdressers_mobile/providers/service_provider.dart';
import 'package:ehairdressers_mobile/providers/user_provider.dart';
import 'package:ehairdressers_mobile/screens/product_list_screen.dart';
import 'package:ehairdressers_mobile/utils/util.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => ProductProvider()),
      ChangeNotifierProvider(create: (_) => CartProvider()),
      ChangeNotifierProvider(create: (_) => ServiceProvider()),
      ChangeNotifierProvider(create: (_) => UserProvider()),
      ChangeNotifierProvider(create: (_) => AppointmentProvider()),
    ],
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
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
  @override
  Widget build(BuildContext context) {
    _productProvider = context.read<ProductProvider>();
    return Scaffold(
        body: Center(
            child: Container(
      constraints: BoxConstraints(maxHeight: 600, maxWidth: 600),
      child: Card(
        child: Padding(
            padding: const EdgeInsets.all(40.0),
            child: Column(
              children: [
                Image(
                  image: AssetImage('.dart_tool/assets/logo.png'),
                  height: 270,
                  width: 270,
                ),
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

                            Authorization.username = username;
                            Authorization.password = password;

                            await _productProvider.get();
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => ProductListScreen()));
                          },
                          child: Text("Login"),
                          style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  Color.fromARGB(255, 247, 233, 211),
                              foregroundColor: Color(0x0FF938f94)),
                        )))
              ],
            )),
      ),
    )));
  }
}
