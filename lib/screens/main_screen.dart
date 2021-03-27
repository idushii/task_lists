import 'package:app_tasks_lists/imports.dart';
import 'package:google_sign_in/google_sign_in.dart';

class MainScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          return Scaffold(
            appBar: AppBar(
              title: Builder(builder: (context) {
                if (snapshot.data != null) {
                  return Text(
                      '${snapshot.data.displayName ?? snapshot.data.email ?? 'Anonymous'}');
                }
                return Text('Anonymous');
              }),
              actions: [
                if (snapshot.data != null && !snapshot.data.isAnonymous)
                  GestureDetector(
                    child: Icon(Icons.logout),
                    onTap: () async {
                      await FirebaseAuth
                          .instance
                          .signOut();
                      await FirebaseAuth
                          .instance
                          .signInAnonymously();
                    },
                  ),
                if (snapshot.data == null || snapshot.data.isAnonymous)
                  GestureDetector(
                    child: Icon(Icons.login),
                    onTap: () async {
                      signInWithMail(context);
                    },
                  ),
                SizedBox(width: 10),
              ],
            ),
            body: SafeArea(
              child: Container(
                child: Center(
                  child: Column(
                    children: [
                      if (snapshot.data == null)
                        TextButton(
                            onPressed: () async {
                              FirebaseAuth
                                  .instance
                                  .signInAnonymously();
                            },
                            child: Text('Продолжить без регистрации')),
                      if (snapshot.data == null)
                        TextButton(
                            onPressed: () async {
                              signInWithGoogle();
                            },
                            child: Text('Войти через google')),
                      if (snapshot.data == null)
                        TextButton(
                            onPressed: () async {
                              signInWithMail(context);
                            },
                            child: Text('Войти через почту')),
                    ],
                  ),
                ),
              ),
            ),
          );
        });
  }
}

Future<UserCredential> signInWithGoogle() async {
  // Trigger the authentication flow
  final GoogleSignInAccount googleUser = await GoogleSignIn().signIn();

  // Obtain the auth details from the request
  final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

  // Create a new credential
  final GoogleAuthCredential credential = GoogleAuthProvider.credential(
    accessToken: googleAuth.accessToken,
    idToken: googleAuth.idToken,
  );

  // Once signed in, return the UserCredential
  return await FirebaseAuth.instance.signInWithCredential(credential);
}

Future<UserCredential> signInWithMail(BuildContext context) async {
  Navigator.of(context).pushNamed(AuthScreen.route);
}
