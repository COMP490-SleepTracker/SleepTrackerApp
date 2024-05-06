import 'package:flutter/material.dart';
import 'package:sleeptrackerapp/Pages/Main/MainPage.dart';
import 'package:sleeptrackerapp/Pages/Main/signUp.dart';
import 'package:sleeptrackerapp/Model/AuthenticationManager.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:sleeptrackerapp/Pages/Onboard/OnboardPage.dart';

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
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const OnBoardingPage()))
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
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const OnBoardingPage()))
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
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const OnBoardingPage()))
        }
        else
        {
          ScaffoldMessenger.of(context).showSnackBar( const SnackBar(content: Text('Invalid username or password')), )
        }
      }
    );
  }

    Future<String> loadAsset() async {
      return await rootBundle.loadString('assets/config.json');
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

      const SizedBox(height: 10),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
        children: [
          InkWell (
           child: Text('Sign Up', 
           style: TextStyle(color: Colors.grey[600]),
           ),
           onTap: (){
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => const signUpPage(title: 'Sign Up')));
           }
          )
        ], )
      ),

      const SizedBox(height: 26),

      ElevatedButton(
        style:ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 120, vertical: 20),
          backgroundColor: Colors.purple[100],
          shadowColor: Colors.white60,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        onPressed: () {
          onFormSubmit(usernameController.text, passwordController.text);
        },
        child: const Text('Sign In', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20,)),
      ),


      const SizedBox(height: 30),

      Row(children: [
        Expanded(
        child:  Divider(
        thickness: 0.5, 
        color: Colors.grey[300]
      ), 
      ),
      const Text(' or continue with '),
      Expanded(
        child:  Divider(
        thickness: 0.5, 
        color: Colors.grey[300]
      ), 
      ),
      ],),
    
    const SizedBox(height: 30),

    // const Row(
    //   mainAxisAlignment: MainAxisAlignment.center,
    //   children: [
    //     Image(image: AssetImage('assets/download.png'), height: 50,),
    //     Text('this is just a test'),

    //   ],
    // ),

      ElevatedButton(
        style:ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 50),

          ),

        onPressed: () {
          googleSignIn(); 
        },
        child:  const Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image(image: AssetImage('assets/download.png'), height: 40,),
        Text('     Sign In With Google', style: TextStyle(color: Colors.black))
      ],
    ),
  
        //const Text('Sign In With Google', style: TextStyle(color: Colors.black)),
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
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Image.asset('assets/sleep.png', height: 100),
            ),
            const Text('Welcome to Sleep Tracker+'),
            const LoginForm(),
          ],
        ),
      ),
    );
  }
}
