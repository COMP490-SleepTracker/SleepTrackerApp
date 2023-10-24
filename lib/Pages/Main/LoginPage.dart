import 'package:firebase_auth/firebase_auth.dart';
 import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:sleeptrackerapp/Pages/Main/MainPage.dart';
import 'package:sleeptrackerapp/Pages/Main/signUp.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sleeptrackerapp/Pages/Main/Authorization.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  // Create a text controller and use it to retrieve the current value
  // of the TextField.
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  bool _passwordVisible = false;

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void onFormSubmit(String username, String password) async {
    // Validate returns true if the form is valid, or false otherwise.
    // if (username == 'admin' && password == 'password') {
    //   Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const MainPage(title: 'Sleep Tracker+')));
    // }
    // else
    // {
    //   ScaffoldMessenger.of(context).showSnackBar( const SnackBar(content: Text('Invalid username or password')), );
    // }
    await FirebaseAuth.instance
        .signInWithEmailAndPassword(email: username, password: password)
        .then((value) {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => const MainPage(title: 'Sleep Tracker+')));
    }).onError((error, stackTrace) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid username or password')),
      );
    });
  }


///Test Google sign in 
  void googleSignIn() async {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('google button pressed')));
    final googleSignIn = GoogleSignIn();

  GoogleSignInAccount? user; 

  //Google Login Method 
    final googleUser = await googleSignIn.signIn(); 
    if(googleUser == null) return; 
    user = googleUser; 

    //Fetch the authentification 
    final googleAuth = await googleUser.authentication; 
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken
    );

    await FirebaseAuth.instance.signInWithCredential(credential); 
    //notifyListener();
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      TextField(
          controller: usernameController,
          decoration: const InputDecoration(
              icon: Icon(Icons.person),
              border: OutlineInputBorder(),
              label: Text('Username'))),
      // add padding between username and password
      const SizedBox(height: 10),
      TextField(
        controller: passwordController,
        obscureText: !_passwordVisible,
        onSubmitted: (s) {
          onFormSubmit(usernameController.text, passwordController.text);
        },
        textInputAction: TextInputAction.done,
        decoration: InputDecoration(
            icon: const Icon(Icons.lock),
            border: const OutlineInputBorder(),
            label: const Text('Password'),
            // set password field to be obscured
            suffixIcon: IconButton(
                icon: Icon(
                    _passwordVisible ? Icons.visibility : Icons.visibility_off,
                    color: Theme.of(context).primaryColorLight),
                onPressed: () {
                  setState(() {
                    _passwordVisible = !_passwordVisible;
                  });
                })),
      ),
      ElevatedButton(
        onPressed: () {
          onFormSubmit(usernameController.text, passwordController.text);
        },
        child: const Text('Submit'),
      ),
      ElevatedButton(
        onPressed: () {
          googleSignIn(); 
        },
        child: const Text('Sign In With Google'),
      ),
      ElevatedButton(
        onPressed: () {
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => const signUpPage(title: 'Sign Up')));
        },
        child: const Text('Sign Up'),
      ),
    ]);
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key, required this.title});
  final String title;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      // drawer : const NavigationPanel(), disabled for login page
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('Welcome to Sleep Tracker-'),
            LoginForm(),
          ],
        ),
      ),
    );
  }
}
