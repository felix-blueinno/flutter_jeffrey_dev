// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_jeffrey_dev/event_provider.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'calendar.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(ChangeNotifierProvider(
    create: (context) => EventProvider(),
    child: MaterialApp(
      routes: {'/calendar': (context) => CalendarPage()},
      debugShowCheckedModeBanner: false,
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Container();
          }
          if (snapshot.hasData) {
            return CalendarPage();
          }
          return LoginPage();
        },
      ),
      theme: ThemeData.dark().copyWith(useMaterial3: true),
    ),
  ));
}

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  /// ref: https://dribbble.com/shots/18219801-Mobile-App-Login-Signup

  bool _visiblePw = false;

  String _email = '';
  String _password = '';

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: FlutterLogo(size: screenHeight * 0.2),
                  ),
                ),

                /// Email
                TextField(
                  onChanged: (value) => _email = value,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    hintText: 'hello@example.com',
                    border: OutlineInputBorder(),
                  ),
                ),

                SizedBox(height: 32),

                /// Password
                TextField(
                  onChanged: (value) => _password = value,
                  obscureText: _visiblePw,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    hintText: 'Your password',
                    border: OutlineInputBorder(),
                    suffixIcon: IconButton(
                      onPressed: () => setState(() => _visiblePw = !_visiblePw),
                      icon: Icon(
                        _visiblePw ? Icons.visibility : Icons.visibility_off,
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 8),

                /// Forgot password
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton(
                    onPressed: () {},
                    child: Text('Forgot Password?'),
                    style: TextButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 32),

                /// Login button
                CoverPageButton(
                  child: Text('Login',
                      style: TextStyle(
                          color: Colors.black, fontWeight: FontWeight.bold)),
                  onTap: () => login(emailAddress: _email, password: _password),
                ),

                SizedBox(height: 8),

                /// Sign up button
                CoverPageButton(
                  backgroundColor: Colors.transparent,
                  child: Text(
                    'Register',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  onTap: () =>
                      signUp(emailAddress: _email, password: _password),
                ),

                SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(child: Divider(color: Colors.grey, height: 2)),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text('OR', style: TextStyle(color: Colors.grey)),
                    ),
                    Expanded(child: Divider(color: Colors.grey, height: 2)),
                  ],
                ),

                SizedBox(height: 16),

                // Continue with Google button
                CoverPageButton(
                  onTap: () => signInWithGoogle(),
                  backgroundColor: Color.fromRGBO(0, 0, 0, 0),
                  child: Row(
                    children: [
                      Image.network(
                        'https://upload.wikimedia.org/wikipedia/commons/thumb/5/53/Google_%22G%22_Logo.svg/2048px-Google_%22G%22_Logo.svg.png',
                        height: 24,
                      ),
                      Spacer(),
                      Text(
                        'Continue with Google',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                      Spacer(),
                    ],
                  ),
                ),

                SizedBox(height: 16),

                // Continue anonymously button
                CoverPageButton(
                  onTap: () {},
                  backgroundColor: Colors.transparent,
                  child: Row(
                    children: [
                      Icon(Icons.person, color: Colors.white),
                      Spacer(),
                      Text('Continue anonymously',
                          style: TextStyle(
                            color: Colors.white,
                          )),
                      Spacer(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// source: https://firebase.flutter.dev/docs/auth/password-auth
  void signUp({
    required String emailAddress,
    required String password,
  }) async {
    try {
      final credential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailAddress,
        password: password,
      );
      print(credential);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        showMyDialog('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        showMyDialog('The account already exists for that email.');
      } else if (e.code == 'invalid-email') {
        showMyDialog('Invalid email address.');
      }
    } catch (e) {
      print(e);
    }
  }

  /// source: https://firebase.flutter.dev/docs/auth/password-auth
  void login({
    required String emailAddress,
    required String password,
  }) async {
    try {
      final credential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: emailAddress, password: password);
      print(credential);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        showMyDialog('User not found.');
      } else if (e.code == 'wrong-password') {
        showMyDialog('Incorrect password.');
      } else if (e.code == 'invalid-email') {
        showMyDialog('Invalid email address.');
      }
    }
  }

  /// source: https://firebase.flutter.dev/docs/auth/social
  signInWithGoogle() async {
    if (kIsWeb) {
      // Create a new provider
      GoogleAuthProvider googleProvider = GoogleAuthProvider();

      googleProvider.setCustomParameters({'login_hint': 'user@example.com'});

      // Once signed in, return the UserCredential
      return await FirebaseAuth.instance.signInWithPopup(googleProvider);

      // Or use signInWithRedirect
      // return await FirebaseAuth.instance.signInWithRedirect(googleProvider);
    } else {
      /// In debug mode, cancelling google sign in will raise exception
      /// that can't be caught by the IDE.
      /// https://stackoverflow.com/questions/51914691/flutter-platform-exception-upon-cancelling-google-sign-in-flow
      GoogleSignIn().signIn().then((googleUser) {
        if (googleUser != null) {
          // Obtain the auth details from the request
          googleUser.authentication.then((googleAuth) {
            if (googleAuth.accessToken != null && googleAuth.idToken != null) {
              FirebaseAuth.instance.signInWithCredential(
                GoogleAuthProvider.credential(
                  idToken: googleAuth.idToken,
                  accessToken: googleAuth.accessToken,
                ),
              );
            }
          });
        }
      });
    }
  }

  void showMyDialog(String msg) => showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(msg),
          actions: [
            TextButton(
              child: Text('OK'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      );
}

class CoverPageButton extends StatelessWidget {
  final Function()? onTap;
  final Widget child;
  final Color? backgroundColor;
  final Color? borderColor;
  final double borderRadius;
  final double widthFactor;

  const CoverPageButton({
    Key? key,
    required this.onTap,
    required this.child,
    this.backgroundColor = Colors.white,
    this.borderColor = Colors.grey,
    this.borderRadius = 5,
    this.widthFactor = 1,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      widthFactor: widthFactor,
      child: OutlinedButton(
        onPressed: onTap,
        child: child,
        style: OutlinedButton.styleFrom(
          backgroundColor: backgroundColor,
          side: BorderSide(color: borderColor!),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        ),
      ),
    );
  }
}
