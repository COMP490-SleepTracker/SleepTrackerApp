import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:sleeptrackerapp/Pages/Main/MainPage.dart';
import 'package:sleeptrackerapp/Pages/Main/LoginPage.dart';


class signUp extends StatefulWidget {
  const signUp({super.key});

  @override
  State<signUp> createState() => _signInState();
}

class _signInState extends State<signUp> {
  // Create a text controller and use it to retrieve the current value
  // of the TextField.
  final usernameController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final passwordController = TextEditingController();

  bool _passwordVisible = false;

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    usernameController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  void onFormSubmit(String username, String confirmPassword, String password) async {

    if(confirmPassword != password){
        ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match')),
      );
      return; 
    }

    // // Validate returns true if the form is valid, or false otherwise.
    // if (usernameController.text == 'admin' && passwordController.text == 'password') {
    //   Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const MainPage(title: 'Sleep Tracker+')));
    // }
    // else
    // {
    //   ScaffoldMessenger.of(context).showSnackBar( const SnackBar(content: Text('Invalid username or password')), );
    // }

    await FirebaseAuth.instance
        .createUserWithEmailAndPassword(email: username, password: password)
        .then((value) {
          print('created new account');
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => const MainPage(title: 'Sleep Tracker+')));
    }).onError((error, stackTrace) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid username or password')),
      );
      print(error.toString());
    });
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
          onFormSubmit(usernameController.text,confirmPasswordController.text ,passwordController.text);
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
      const SizedBox(height: 10),
      TextField(
        controller: confirmPasswordController,
        obscureText: !_passwordVisible,
        onSubmitted: (s) {
          onFormSubmit(usernameController.text,confirmPasswordController.text , passwordController.text);
        },
        textInputAction: TextInputAction.done,
        decoration: InputDecoration(
            icon: const Icon(Icons.lock),
            border: const OutlineInputBorder(),
            label: const Text('Confirm Password'),
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
          onFormSubmit(usernameController.text,confirmPasswordController.text,passwordController.text);
        },
        child: const Text('Sign Up'),
      ),
      ElevatedButton(
        onPressed: () {
          Navigator.pushReplacement(  
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      const LoginPage(title: 'Sleep Tracker+')));
        },
        child: const Text('Return'),
      ),
    ]);
  }
}

class signUpPage extends StatefulWidget {
  const signUpPage({super.key, required this.title});
  final String title;
  @override
  State<signUpPage> createState() => _signInPageState();
}

class _signInPageState extends State<signUpPage> {
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
            Text('Welcome to Sleep Tracker+'),
            signUp(),
          ],
        ),
      ),
    );
  }
}

///make a go back button on top left of app 
///test google signin with csun email
///