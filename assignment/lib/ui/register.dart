import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:assignment/bloc/register/register_cubit.dart';
import '../utils/routes.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final emailEdc = TextEditingController();
  final passEdc = TextEditingController();
  bool passInvisible = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF2C3639),
      body: BlocListener<RegisterCubit, RegisterState>(
          listener: (context, state) {
            if (state is RegisterLoading) {
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(SnackBar(content: Text('Loading..')));
            }
            if (state is RegisterFailure) {
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(SnackBar(
                  content: Text(state.msg),
                  backgroundColor: Colors.red,
                ));
            }
            if (state is RegisterSuccess) {
              // context.read<AuthCubit>().loggedIn();
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(SnackBar(
                  content: Text(state.msg),
                  backgroundColor: Colors.green,
                ));
              Navigator.pushNamedAndRemoveUntil(
                  context, rLogin, (route) => false);
            }
          },
          child: Center(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 50, vertical: 40),
              child: ListView(
                shrinkWrap: true,
                children: [
                  Text(
                    "Register",
                    style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFA27B5C)),
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  Text(
                    "Silahkan masukan email dan password anda",
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFFDCD7C9),
                    ),
                  ),
                  SizedBox(
                    height: 25,
                  ),
                  Text(
                    "Email",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFDCD7C9),
                    ),
                  ),
                  TextFormField(
                    controller: emailEdc,
                    style: TextStyle(
                      color: Color(0xFFDCD7C9),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    "Password",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFDCD7C9),
                    ),
                  ),
                  TextFormField(
                    controller: passEdc,
                    style: TextStyle(
                      color: Color(0xFFDCD7C9),
                    ),
                    decoration: InputDecoration(
                      suffixIcon: IconButton(
                        icon: Icon(passInvisible
                            ? Icons.visibility
                            : Icons.visibility_off),
                        onPressed: () {
                          setState(() {
                            passInvisible =
                                !passInvisible; // Toggle _isPasswordVisible ketika ikon mata ditekan
                          });
                        },
                      ),
                    ),
                    obscureText:
                        !passInvisible, // Atur obscureText berdasarkan _isPasswordVisible
                  ),
                  SizedBox(
                    height: 50,
                  ),
                  ElevatedButton(
                      onPressed: () {
                        context.read<RegisterCubit>().register(
                            email: emailEdc.text, password: passEdc.text);
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFFA27B5C),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10))),
                      child: Text(
                        "Register",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 24,
                            color: Colors.white),
                      )),
                  SizedBox(
                    height: 25,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Sudah punya akun ?",
                        style: TextStyle(color: Colors.white),
                      ),
                      TextButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/login');
                          },
                          child: Text(
                            "Login",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFA27B5C)),
                          ))
                    ],
                  )
                ],
              ),
            ),
          )),
    );
  }
}
