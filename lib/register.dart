import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import "package:intl/intl.dart";
import 'package:intl/date_symbol_data_local.dart';
import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/services.dart';

class Register extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("新規登録"),
        backgroundColor: Colors.black87,
      ),
      body: RegisterForm(),
    );
  }
}

class RegisterForm extends StatefulWidget {
  @override
  RegisterFormState createState() {
    return RegisterFormState();
  }
}

class RegisterFormState extends State<RegisterForm> {
  final _formKey = GlobalKey<FormState>();
  final textEditingController = TextEditingController();

  String _labelText = '日付を選択してください';
  String _notification = 'なし';
  String readData = "";

  Future<void> _selectDate(BuildContext context) async {
    initializeDateFormatting("ja_JP");
    final DateTime selectedDate = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(DateTime.now().year),
        lastDate: DateTime(DateTime.now().year + 1),
        locale: const Locale('ja'));

    if (selectedDate != null) {
      var formatter = new DateFormat('yyyy/MM/dd(E)', "ja_JP");
      setState(() {
        _labelText = formatter.format(selectedDate);
      });
    }
  }

  void _changeNotification(String notification) => setState(() {
        _notification = notification;
      });

  /// QR及びバーコードスキャンを行うメソッド
  Future scan() async {
    try {
      // String型のcodeにBarcodeScanner.scan()の結果を代入
      // await：非同期対応の要素のキーワード
      String code = await BarcodeScanner.scan();
      // readDataに読み取ったデータを格納する
      setState(() => this.readData = code);
    }
    // 例外処理：プラグインが何らかのエラーを出したとき
    on PlatformException catch (e) {
      // エラーコードがBarcodeScanner.CameraAccessDeniedであるときは、
      // このアプリにカメラ機能のパーミッションを許可していない状態であることを示す
      if (e.code == BarcodeScanner.CameraAccessDenied) {
        setState(() {
          // readDataにエラー内容を代入
          this.readData = 'カメラのパーミッションが有効になっていません。';
        });
      }
      // その他の場合は不明のエラー
      else {
        setState(() => this.readData = '原因不明のエラー: $e');
      }
    }
    // 意図しない入力、操作を受けたとき
    on FormatException {
      setState(() => this.readData = '読み取れませんでした (スキャンを開始する前に戻るボタンを使用しました)');
    } catch (e) {
      setState(() => this.readData = '不明なエラー: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    margin: const EdgeInsets.all(16.0),
                    child: Text(
                      '消費期限：',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ],
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    margin: const EdgeInsets.all(16.0),
                    child: InkWell(
                      child: Text(
                        _labelText,
                        style: TextStyle(
                          fontSize: 18,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                      onTap: () => _selectDate(context),
                    ),
                  ),
                ],
              ),
            ],
          ),
          Row(
            children: <Widget>[
              Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    margin: const EdgeInsets.all(16.0),
                    child: Padding(
                      padding: EdgeInsets.all(20.0),
                      child: Text(
                        '通知：',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ),
                ],
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Radio(
                        activeColor: Colors.blueAccent,
                        value: 'なし',
                        groupValue: _notification,
                        onChanged: _changeNotification,
                      ),
                      Text('なし'),
                      Radio(
                        activeColor: Colors.blueAccent,
                        value: 'あり',
                        groupValue: _notification,
                        onChanged: _changeNotification,
                      ),
                      Text('あり'),
                    ],
                  ),
                ],
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Center(
                child: RaisedButton.icon(
                  icon: const Icon(
                    Icons.camera_alt,
                    color: Colors.black,
                  ),
                  label: Text('バーコードを読み取る'),
                  onPressed: () => scan(),
                  color: Colors.white60,
                  textColor: Colors.black,
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Expanded(
                child: Text(
                  '$readData',
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Center(
                child: RaisedButton(
                  onPressed: () {
                    if (_formKey.currentState.validate()) {
                      Scaffold.of(context).showSnackBar(
                          SnackBar(content: Text(textEditingController.text)));
                    }
                  },
                  child: Text('登録する'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
