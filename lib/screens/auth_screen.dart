import 'package:app_tasks_lists/imports.dart';
import 'package:email_validator/email_validator.dart';

class AuthScreen extends StatefulWidget {
  static const route = '/AuthScreen';

  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  bool obscureText = true;
  String email;
  String password;

  @override
  void didChangeDependencies() {
    if (Cache().prefs != null) {
      setState(() {
        email = Cache().prefs.getString('email');
        password = Cache().prefs.getString('password');
      });
    }

    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Form(
                autovalidateMode: AutovalidateMode.onUserInteraction,
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    TextFormField(
                      initialValue: email,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(labelText: 'Email'),
                      onSaved: (String value) {
                        email = value;
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Email необходимо заполнить';
                        }
                        if (!EmailValidator.validate(value)) {
                          return 'Email не является валидным';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      initialValue: password,
                      keyboardType: TextInputType.text,
                      onSaved: (String value) {
                        password = value;
                      },
                      decoration: InputDecoration(
                        labelText: 'Password',
                        suffix: GestureDetector(
                          child: Icon(Icons.remove_red_eye),
                          onTap: () =>
                              setState(() => obscureText = !obscureText),
                        ),
                      ),
                      obscureText: obscureText,
                      validator: (value) {
                        if (value == null ||
                            value.isEmpty ||
                            value.length < 6) {
                          return 'Минимальнаядлина пароля 6 символов';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  TextButton(
                    onPressed: () {
                      FocusScope.of(context).unfocus();
                      if (_formKey.currentState.validate()) {
                        ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Выполняется регистрация')));
                        _formKey.currentState.save();

                          FirebaseAuth.instance.createUserWithEmailAndPassword(
                            email: email,
                            password: password,
                          ).then((value) {
                            Cache().prefs.setString('email', email);
                            Cache().prefs.setString('password', password);
                            ScaffoldMessenger.of(context).removeCurrentSnackBar();
                            ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Регистрация успешно выполнена')));

                            Navigator.pop(context);
                          }).catchError((e) {
                            if (e.code == 'email-already-in-use') {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Данный email уже зарегистрирован')));
                            }
                          });
                      }
                    },
                    child: Text('Зарегистрироваться'),
                  ),
                  Spacer(),
                  ElevatedButton(
                    onPressed: () {
                      FocusScope.of(context).unfocus();
                      if (_formKey.currentState.validate()) {
                        ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Выполняется авторизация')));
                        _formKey.currentState.save();

                        FirebaseAuth.instance.signInWithEmailAndPassword(
                          email: email,
                          password: password,
                        ).then((value) {
                          ScaffoldMessenger.of(context).removeCurrentSnackBar();
                          ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Авторизация успешно выполнена')));
                          Navigator.pop(context);
                        }).catchError((e) {
                          if (e.code == 'user-not-found') {
                            ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Не найден пользователь')));
                          } else if (e.code == 'wrong-password') {
                            ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Ошибочный пароль')));
                          }
                        });
                      }
                    },
                    child: Text('Войти'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}