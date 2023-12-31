import 'package:flutter/material.dart';
import 'package:sleeptrackerapp/Pages/Main/MainPage.dart';
import 'package:sleeptrackerapp/Pages/Main/signUp.dart';
import 'package:sleeptrackerapp/Model/AuthenticationManager.dart';
import 'package:get_it/get_it.dart';

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
    
       // use the authentication manager to validate the username and password
  if(username == 'admin'){
    GetIt.instance<AuthenticationManager>().authenticate(username, password).then((value) => 
      {
        // check if the user is authenticated
        if(GetIt.instance<AuthenticationManager>().isAuthenticated)
        {
          // navigate to the main page
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const MainPage(title: 'Sleep Tracker+')))
        }
        else
        {
          ScaffoldMessenger.of(context).showSnackBar( const SnackBar(content: Text('Invalid username or password')), )
        }
      }
    );
  }
  else
  {
  GetIt.instance<AuthenticationManager>().loginWithEmailAndPassword(email: username, password: password).then((value) => 
      {
        // check if the user is authenticated
        if(GetIt.instance<AuthenticationManager>().isAuthenticated)
        {
          // navigate to the main page
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const MainPage(title: 'Sleep Tracker+')))
        }
        else
        {
          ScaffoldMessenger.of(context).showSnackBar( const SnackBar(content: Text('Invalid username or password')), )
        }
      }
    );
  }

  }


///Test Google sign in 
  void googleSignIn() async {
    GetIt.instance<AuthenticationManager>().googleLogin().then((value) => 
      {
        // check if the user is authenticated
        if(GetIt.instance<AuthenticationManager>().isAuthenticated)
        {
          // navigate to the main page
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const MainPage(title: 'Sleep Tracker+')))
        }
        else
        {
          ScaffoldMessenger.of(context).showSnackBar( const SnackBar(content: Text('Invalid username or password')), )
        }
      }
    );
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
