import 'package:face/globals.dart';
import 'package:face/selfie.dart';
import 'package:flutter/material.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  String _phone = "";
  bool _ready = false;
  final _inputController = TextEditingController(text: Globals.phone);

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _inputController.addListener(() {
      if (_inputController.text.length == 11) {
        _ready = true;
      } else {
        _ready = false;
      }
      setState(() {
        _phone = _inputController.text;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Login"),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              const Icon(Icons.lock, size: 200),
              const SizedBox(
                height: 10,
              ),
              const Text("Enter a valid Phone Number to login.",
                  style: TextStyle(fontSize: 20)),
              const SizedBox(
                height: 10,
              ),
              TextFormField(
                controller: _inputController,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    _ready = false;

                    return 'Please enter some text';
                  }
                  if (value.length < 11) {
                    _ready = false;
                    return 'Please enter a valid phone number';
                  }
                  _ready = true;
                  return null;
                },
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5)),
                  labelText: "Phone",
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              SizedBox(
                height: 50,
                width: double.infinity,
                child: ElevatedButton(
                    onPressed: _ready
                        ? () {
                            Globals.phone = _phone;
                            Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const Selfie(),
                                ),
                                (route) => false);
                          }
                        : null,
                    child: Text("Login".toUpperCase())),
              )
            ],
          ),
        ),
      ),
    );
  }
}
