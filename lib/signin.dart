import 'dart:convert';
import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'user_provider.dart';

class LoginModal extends StatelessWidget {
  final Function(BuildContext) onLogin;

  LoginModal({Function(BuildContext)? onLogin})
      : onLogin = onLogin ??
      ((BuildContext context) =>
          Navigator.of(context).pushNamed("/home"));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Column(mainAxisAlignment: MainAxisAlignment.end, children: <Widget>[
                Padding(
                    padding: EdgeInsets.only(top: 20),
                    child: Image(
                        image: AssetImage('assets/betty_logo_name.png'),
                        height: 200
                        )),
                Align(
                    alignment: Alignment.center,
                    child: Padding(
                        padding: EdgeInsets.only(top: 20),
                        child: Text("Sign in",
                            style: Theme.of(context).textTheme.headline6))),
              ]),
              Container(
                  padding: const EdgeInsets.all(16),
                  alignment: Alignment.center,
                  child: SignInButtonBuilder(
                      image: Image(
                        image: AssetImage('assets/logos/google_light.png',
                            package: 'flutter_signin_button'),
                      ),
                      backgroundColor: Colors.white,
                      textColor: Colors.black,
                      innerPadding: EdgeInsets.all(4),
                      text: 'Sign in with Google',
                      fontSize: 18,
                      width: 400,
                      onPressed: () async {
                        await _signInWithGoogle(context);
                      })),
              Container(
                padding: const EdgeInsets.only(
                  left: 16,
                  right: 16,
                ),
                alignment: Alignment.center,
                child: SignInButtonBuilder(
                  icon: Icons.email_outlined,
                  iconColor: Colors.black,
                  backgroundColor: Colors.white,
                  textColor: Colors.black,
                  innerPadding: EdgeInsets.all(18),
                  text: 'Sign in with email',
                  fontSize: 18,
                  width: 400,
                  onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) =>
                          SigninWithPasswordScreen(onLogin: onLogin))),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(16),
                alignment: Alignment.center,
                child: SignInButtonBuilder(
                  icon: Icons.person_add,
                  iconColor: Colors.white,
                  backgroundColor: Colors.black,
                  textColor: Colors.white,
                  elevation: 0,
                  text: 'Register new account',
                  onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => RegistrationScreen(onLogin: onLogin))),
                ),
              ),
            ]));
  }

  Future<void> _signInWithGoogle(context) async {
    try {
      UserCredential userCredential;

      if (kIsWeb) {
        GoogleAuthProvider googleProvider = GoogleAuthProvider();
        userCredential =
        await FirebaseAuth.instance.signInWithPopup(googleProvider);

        await _onSuccessfulLogin(
            context, "Signed in to google", userCredential);
      } else {
        final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
        if (googleUser != null) {
          final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
          String? accessToken = googleAuth.accessToken;
          String? idToken = googleAuth.idToken;

          if (accessToken != null && idToken != null) {
            final OAuthCredential googleAuthCredential =
            GoogleAuthProvider.credential(
                accessToken: accessToken, idToken: idToken);
            userCredential = await FirebaseAuth.instance
                .signInWithCredential(googleAuthCredential);

            await _onSuccessfulLogin(
                context, "Signed in to google", userCredential);
            return;
          }
        }
      }
    } catch (e) {
      print(e);
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Failed to sign in with Google: $e'),
      ),
    );
  }

  // Generates a cryptographically secure random nonce, to be included in a
  // credential request.
  String generateNonce([int length = 32]) {
    final charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(length, (_) => charset[random.nextInt(charset.length)])
        .join();
  }

  // Returns the sha256 hash of [input] in hex notation.
  String sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<void> _onSuccessfulLogin(BuildContext context, String message,
      UserCredential userCredential) async {
    final user = userCredential.user;
    if (user != null) {
      await context.read<UserProvider>().getOrCreateUser(user);
    }

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
    ));

    onLogin(context);
  }
}


class SigninWithPasswordScreen extends StatelessWidget {
  final Function(BuildContext)? onLogin;

  SigninWithPasswordScreen({this.onLogin});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
        leading: Padding(
        padding: EdgeInsets.only(left:10, top:15, bottom: 15),
          child: Image(image: AssetImage('assets/betty_logo.png'))),
          title: Text("Sign in"),),
        body: Builder(builder: (BuildContext context) {
          return ListView(
              padding: const EdgeInsets.all(8),
              children: <Widget>[
                Align(
                    alignment: Alignment.center, //or choose another Alignment
                    child: SizedBox(
                    width: 400,
                child: EmailSignin(onLogin: onLogin)))]);
        }));
  }
}

class EmailSignin extends StatefulWidget {
  final Function(BuildContext)? onLogin;

  EmailSignin({this.onLogin});

  @override
  State<EmailSignin> createState() => _EmailSigninState();
}

class _EmailSigninState extends State<EmailSignin> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Form(
        key: _formKey,
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                  validator: (String? value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(labelText: 'Password'),
                  validator: (String? value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a password';
                    }
                    return null;
                  },
                  obscureText: true,
                ),
                Container(
                    alignment: Alignment.bottomRight,
                    child: TextButton(
                        child: Text("Forgot password?",
                            style: TextStyle(fontSize: 14)),
                        onPressed: () {
                          Navigator.of(context).pushNamed("/forgotpass");
                        })),
                SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.only(top: 10),
                  alignment: Alignment.bottomRight,
                  child: ElevatedButton.icon(
                    icon: Icon(Icons.email_outlined),
                    onPressed: () async {
                      var currentState = _formKey.currentState;
                      if (currentState != null && currentState.validate()) {
                        await _signInWithEmailAndPassword();
                      }
                    },
                    label: Text('Sign in'),
                    style: ElevatedButton.styleFrom(
                      primary: Colors.orange,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ));
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signInWithEmailAndPassword() async {
    try {
      final UserCredential userCredential =
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
      final User? user = userCredential.user;

      if (user != null) {
        await context.read<UserProvider>().getOrCreateUser(user);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${user?.email} signed in'),
        ),
      );

      var onLogin = widget.onLogin;
      if (onLogin != null) {
        await onLogin(context);
      }
    } on FirebaseAuthException catch (e) {
      _showFailedLoginDialog(e.message);
    }
  }

  _showFailedLoginDialog(errorMsg) {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(
              'Failed to sign in',
              style: TextStyle(color: Colors.black),
            ),
            content: Text(errorMsg),
          );
        });
  }
}

class ForgotPasswordScreen extends StatefulWidget {
  final String title = 'Forgot password?';

  @override
  _ForgotPasswordState createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPasswordScreen> {
  final _auth = FirebaseAuth.instance;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        leading: Padding(
        padding: EdgeInsets.only(left:10, top:15, bottom: 15),
        child: Image(image: AssetImage('assets/betty_logo.png'))),
        title: Text("Forgot Password"),),
      body: Builder(builder: (BuildContext context) {
        return ListView(
          padding: const EdgeInsets.all(16),
          children: <Widget>[
            Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.only(bottom: 30),
                child: Text("No worries. Let's get you back in!")),
        Align(
        alignment: Alignment.center, //or choose another Alignment
        child: SizedBox(
        width: 400,
        child: Form(
                key: _formKey,
                child: Card(
                    child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            TextFormField(
                              controller: _emailController,
                              decoration: InputDecoration(
                                labelText: 'Email',
                                icon: Icon(Icons.mail),
                              ),
                              validator: (String? value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter a valid email';
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: 20),
                            Text(
                                "You will receive an email with a password reset link. ",),
                            Container(
                              padding: const EdgeInsets.only(top: 30),
                              alignment: Alignment.bottomRight,
                              child: ElevatedButton.icon(
                                icon: Icon(Icons.person_add),
                                onPressed: _passwordReset,
                                label: Text('Send Email'),
                                style: ElevatedButton.styleFrom(
                                  primary: Colors.orange,
                                  ),
                              ),
                            )
                          ],
                        )))))),
          ],
        );
      }),
    );
  }

  _passwordReset() async {
    try {
      _formKey.currentState?.save();

      final _ =
      await _auth.sendPasswordResetEmail(email: _emailController.text);

      Navigator.of(context).pushReplacementNamed("/signinpass");

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("An email has just been sent to you at " +
              _emailController.text +
              ". Click the link provided in the email to complete password reset."),
          duration: const Duration(seconds: 20)));
    } catch (e) {
      print(e);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }
}


class RegistrationScreen extends StatelessWidget {
  final Function(BuildContext)? onLogin;

  RegistrationScreen({this.onLogin});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        leading: Padding(
            padding: EdgeInsets.only(left:10, top:15, bottom: 15),
            child: Image(image: AssetImage('assets/betty_logo.png'))),
        title: Text("Register new account"),),
      body: Builder(builder: (BuildContext context) {
        return ListView(
          padding: const EdgeInsets.all(8),
          children: <Widget>[
            Align(
                alignment: Alignment.center, //or choose another Alignment
                child: SizedBox(
                width: 400,
                child:
                _EmailPasswordForm(onLogin: onLogin)))
          ],
        );
      }),
    );
  }
}

class _EmailPasswordForm extends StatefulWidget {
  final Function(BuildContext)? onLogin;

  _EmailPasswordForm({this.onLogin});

  @override
  State<StatefulWidget> createState() => _EmailPasswordFormState();
}

class _EmailPasswordFormState extends State<_EmailPasswordForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Form(
        key: _formKey,
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                  validator: (String? value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(labelText: 'Password'),
                  validator: (String? value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a password';
                    }
                    return null;
                  },
                  obscureText: true,
                ),
                SizedBox(height: 30),
                Container(
                  padding: const EdgeInsets.only(top: 30),
                  alignment: Alignment.bottomRight,
                  child: ElevatedButton.icon(
                    icon: Icon(Icons.person_add),
                    onPressed: () async {
                      var currentState = _formKey.currentState;
                      if (currentState != null && currentState.validate()) {
                        await _register();
                      }
                    },
                    label: Text('Register'),
                    style: ElevatedButton.styleFrom(
                      primary: Colors.orange,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ));
  }

  @override
  void dispose() {
    // Clean up the controller when the Widget is disposed
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    try {
      final UserCredential userCredential =
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
      final User? user = userCredential.user;

      if (user != null) {
        await context.read<UserProvider>().getOrCreateUser(user);
      }
      var onLogin = widget.onLogin;
      if (onLogin != null) {
        await onLogin(context);
      }
    } on FirebaseAuthException catch (e) {
      _showFailedRegisterDialog(e.message);
    }
  }

  _showFailedRegisterDialog(errorMsg) {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(
              'Failed to register',
              style: TextStyle(color: Colors.black),
            ),
            content: Text(errorMsg),
          );
        });
  }
}