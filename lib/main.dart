import 'package:flutter/material.dart';
import 'dart:async';

void main() => runApp(MyApp());
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Login",
      home: Scaffold(
          appBar: AppBar(title: Text('登录')),
          body: Center(
            child: LoginWidget(),
          )),
    );
  }
}


class LoginWidget extends StatefulWidget {
  String userName;

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return new LoginWidgetState();
  }
}

class LoginWidgetState extends State<LoginWidget> {
  var userNameController = TextEditingController();
  var passwordController = TextEditingController();
  static const LOGIN_TYPE_PASSWORD = 1;
  static const LOGIN_TYPE_CODE = 2;
  var loginType = LOGIN_TYPE_PASSWORD;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _retrieveUserName();
    return Container(
        margin: EdgeInsets.only(left: 20.0, right: 20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _inputAndLoginTypeArea(),
            Container(
              margin: EdgeInsets.only(top: 16.0),
              child: MaterialButton(
                minWidth: double.infinity,
                color: Colors.blue,
                textColor: Colors.white,
                child: Text("登录"),
                onPressed: () {
                  _onLoading();
                },
              ),
            )
          ],
        ));
  }

  /// 根据输入方式切换输入框布局
  _inputAndLoginTypeArea() {
    if (LOGIN_TYPE_PASSWORD == loginType) {
      return _mobileAndPassword();
    } else if (LOGIN_TYPE_CODE == loginType) {
      return _mobileAndCode();
    } else {
      // 处理异常情况
    }
  }

  /// 登录方式为账号密码登录
  _mobileAndPassword() {
    return Column(
      children: <Widget>[
        TextField(
          decoration: InputDecoration(hintText: "请输入手机号"),
          controller: userNameController,
        ),
        TextField(
          decoration: InputDecoration(hintText: "请输入密码"),
          controller: passwordController,
          obscureText: true,
        ),
        Align(
          alignment: Alignment.centerRight,
          child: MaterialButton(
            child: Text("验证码登录"),
            textColor: Colors.blue,
            onPressed: () {
              _switchLoginType(LOGIN_TYPE_CODE);
            },
          ),
        )
      ],
    );
  }

  /// 登录方式为验证码登录
  _mobileAndCode() {
    return Column(
      children: <Widget>[
        TextField(
          decoration: InputDecoration(hintText: "请输入手机号"),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            Flexible(
              child: TextField(
                decoration: InputDecoration(hintText: "请输入验证码"),
              ),
            ),
            CodeButton()
          ],
        ),
        Align(
          alignment: Alignment.centerRight,
          child: MaterialButton(
            child: Text("账号密码登录"),
            textColor: Colors.blue,
            onPressed: () {
              _switchLoginType(LOGIN_TYPE_PASSWORD);
            },
          ),
        )
      ],
    );
  }

  /// 获取用户名
  _retrieveUserName() {
    userNameController.text = "185xxxx5883";
  }

  /// 修改登录方式
  _switchLoginType(int loginType) {
    setState(() {
      this.loginType = loginType;
    });
  }

  void _onLoading() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return LoadingDialog();
      },
    );
    new Future.delayed(new Duration(seconds: 3), () {
      Navigator.pop(context); //pop dialog
    });
  }
}

class LoadingDialog extends StatefulWidget {
  LoadingDialogState state;

  bool isShowing() {
    return state != null && state.mounted;
  }

  @override
  createState() => state = LoadingDialogState();
}

class LoadingDialogState extends State<LoadingDialog>
    with TickerProviderStateMixin {
  AnimationController controller;
  CurvedAnimation curve;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    curve = CurvedAnimation(parent: controller, curve: Curves.linear);
  }

  @override
  Widget build(BuildContext context) {
    controller.forward();
    return Align(
        alignment: Alignment.center,
        child: RotationTransition(
          turns: curve,
          child: FlutterLogo(
            size: 30,
          ),
        ));
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    controller.dispose();
  }
}

/// 自定义验证码按钮。
class CodeButton extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return CodeButtonState();
  }
}

class CodeButtonState extends State<CodeButton> {
  int number = 60;
  bool isRepeat = false;
  Timer timer;
  Duration oneSec = const Duration(seconds: 1);
  bool isPressed = false;
  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      color: Colors.blue,
      textColor: Colors.white,
      child: _child(),
      onPressed: () {
        _countDown();
      },
    );
  }

  _child() {
    if (number <= 0) {
      if (this.isRepeat) {
        return Text("重新发送");
      }
    } else if(number == 60){
      return Text("发送验证码");
    } else {
      return CustomPaint(
        painter: DrawNumberPainter(number),
      );
    }
  }

  /// 倒计时
  _countDown() {
    if(isPressed) {
      return;
    }
    isPressed = true;
    timer = new Timer.periodic(
      oneSec,
      (Timer timer) => setState(
        () {
          if (number <= 0) {
            timer.cancel();
            setState(() {
              isPressed = false;
              this.isRepeat = true;
            });
          } else {
            setState(() {
              this.number = number - 1;
            });
          }
        },
      ),
    );
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }
}

/// Canvas
class DrawNumberPainter extends CustomPainter {
  final int number;

  DrawNumberPainter(this.number);

  @override
  void paint(Canvas canvas, Size size) {
    final textStyle = TextStyle(
      color: Colors.white,
      fontSize: 16,
    );
    final textSpan = TextSpan(
      text: '$number',
      style: textStyle,
    );
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.rtl,
    );
    textPainter.layout(
      minWidth: 0,
      maxWidth: 20,
    );
    final offset = Offset(-10, -5);
    textPainter.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(DrawNumberPainter old) {
    // 值更新时重绘
    return old.number != this.number;
  }
}
