// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_jeffrey_dev/theme_controller.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'calendar.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  const FlexScheme usedScheme = FlexScheme.materialBaseline;

  runApp(StreamBuilder<bool>(
      initialData: true,
      stream: ThemeController.isLightTheme.stream,
      builder: (context, snapshot) {
        return MaterialApp(
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
          theme: FlexThemeData.light(scheme: usedScheme, useMaterial3: true),
          darkTheme: FlexThemeData.dark(scheme: usedScheme, useMaterial3: true),
          themeMode: snapshot.data! ? ThemeMode.light : ThemeMode.dark,
        );
      }));
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
    double screenWidth = MediaQuery.of(context).size.width;

    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: FractionallySizedBox(
              widthFactor: screenWidth > 500 ? 0.5 : 0.8,
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
                        onPressed: () =>
                            setState(() => _visiblePw = !_visiblePw),
                        icon: Icon(
                          _visiblePw ? Icons.visibility : Icons.visibility_off,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 8),

                  /// Forgot password
                  Align(
                    alignment: Alignment.centerRight,
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
                    text: 'Log in',
                    onTap: () =>
                        login(emailAddress: _email, password: _password),
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    textStyle: TextStyle(
                      color: isDark ? Colors.black : Colors.white,
                    ),
                  ),

                  SizedBox(height: 16),

                  /// Sign up button
                  CoverPageButton(
                    backgroundColor: Colors.transparent,
                    text: 'Register',
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
                    onTap: () => signInAnnonymously(),
                    backgroundColor: Colors.transparent,
                    prefix: Image.network(
                      'https://upload.wikimedia.org/wikipedia/commons/thumb/5/53/Google_%22G%22_Logo.svg/2048px-Google_%22G%22_Logo.svg.png',
                      height: 24,
                    ),
                    text: 'Continue with Google',
                  ),

                  SizedBox(height: 16),

                  // Continue anonymously button
                  CoverPageButton(
                    onTap: () => signInAnnonymously(),
                    backgroundColor: Colors.transparent,
                    prefix: Icon(
                      Icons.person,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                    text: 'Continue anonymously',
                  ),
                ],
              ),
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

  signInAnnonymously() async {
    try {
      FirebaseAuth.instance.signInAnonymously();
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case "operation-not-allowed":
          print("Anonymous auth hasn't been enabled for this project.");
          break;
        default:
          print("Unknown error.");
      }
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
  final String text;
  final TextStyle? textStyle;
  final Color? backgroundColor;
  final Color? borderColor;
  final double borderRadius;
  final double widthFactor;

  final Widget? prefix;

  const CoverPageButton({
    Key? key,
    required this.onTap,
    required this.text,
    this.backgroundColor = Colors.white,
    this.borderColor = Colors.grey,
    this.borderRadius = 5,
    this.widthFactor = 1,
    this.prefix,
    this.textStyle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.8,
      child: OutlinedButton(
        onPressed: onTap,
        child: Row(
          children: [
            if (prefix != null) prefix!,
            Spacer(),
            Text(
              text,
              style: textStyle ??
                  TextStyle(color: isDark ? Colors.white : Colors.black),
            ),
            Spacer(),
          ],
        ),
        style: OutlinedButton.styleFrom(
          backgroundColor: backgroundColor,
          side: BorderSide(color: borderColor!),
          padding: EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        ),
      ),
    );
  }
}
