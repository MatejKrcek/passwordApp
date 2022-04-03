import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:encrypt/encrypt.dart' as encrypt;

import 'package:pass_app/data/db_helper.dart';
import 'package:pass_app/data/password_item.dart';

class DetailPage extends StatefulWidget {
  const DetailPage({
    Key? key,
    required this.type,
    this.data,
  }) : super(key: key);

  final String type;
  final Password? data;

  @override
  _DetailPageState createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  late TextEditingController _nameController;
  late TextEditingController _usernameController;
  late TextEditingController _passwordController;
  final _formKey = GlobalKey<FormState>();
  List<Password> _listOfPasswords = [];
  bool _visiblePass = true;
  String _passQuality = 'Low';

  @override
  void initState() {
    super.initState();

    if (widget.type == 'edit') {
      final String _decryptedPass = _decrypt(widget.data!.password);
      _nameController = TextEditingController(text: widget.data!.name);
      _usernameController = TextEditingController(text: widget.data!.username);
      _passwordController = TextEditingController(text: _decryptedPass);
    } else {
      _nameController = TextEditingController();
      _usernameController = TextEditingController();
      _passwordController = TextEditingController();
    }
  }

  String _encrypt(String pass) {
    final key = encrypt.Key.fromUtf8('Ai01CfCJbSHDSJDKgZAKgPjq11iLnOEV');
    final iv = encrypt.IV.fromLength(16);
    final encrypter = encrypt.Encrypter(encrypt.AES(key));

    final encrypted = encrypter.encrypt(pass, iv: iv);
    print(encrypted.base64);
    return encrypted.base64;
  }

  String _decrypt(String pass) {
    final key = encrypt.Key.fromUtf8('Ai01CfCJbSHDSJDKgZAKgPjq11iLnOEV');
    final iv = encrypt.IV.fromLength(16);
    final encrypter = encrypt.Encrypter(encrypt.AES(key));

    final decrypted =
        encrypter.decrypt(encrypt.Encrypted.fromBase64(pass), iv: iv);

    return decrypted;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _passwordController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  void passwordQality(String text) {
    //* not an ideal solution
    setState(() {
      if (text.isNotEmpty) {
        if (text.contains(RegExp(r'[a-z]')) &&
            text.contains(RegExp(r'[A-Z]'))) {
          _passQuality = 'Good';
        }
        if (text.contains(RegExp(r'[a-z]')) &&
            text.contains(RegExp(r'[A-Z]')) &&
            text.contains(RegExp(r'[0-9]'))) {
          _passQuality = 'Great';
        }
        if (text.contains(RegExp(r'[a-z]')) &&
            text.contains(RegExp(r'[A-Z]')) &&
            text.contains(RegExp(r'[0-9]')) &&
            text.contains(RegExp(r'[_\-=@,\.;]'))) {
          _passQuality = 'Strong';
        }
      } else {
        _passQuality = 'Low';
      }
    });
  }

  Future<void> addEle(String name, String username, String password) async {
    final dbHelper = DatabaseHelper.instance;
    final _date = DateTime.now();
    final _cryptedPass = _encrypt(password);

    Map<String, dynamic> _row = {
      DatabaseHelper.columnId: _date.toString(),
      DatabaseHelper.columnName: name,
      DatabaseHelper.columnUsername: username,
      DatabaseHelper.columnPassword: _cryptedPass,
      DatabaseHelper.columnDate: _date.toString(),
    };
    await dbHelper.insert(_row);
    return;
  }

  Future<void> editEle(String name, String username, String password) async {
    final dbHelper = DatabaseHelper.instance;
    Map<String, dynamic> row = {
      DatabaseHelper.columnId: widget.data!.id,
      DatabaseHelper.columnName: name,
      DatabaseHelper.columnUsername: username,
      DatabaseHelper.columnPassword: password,
      DatabaseHelper.columnDate: DateTime.now().toString(),
    };

    await dbHelper.update(row);
    return;
  }

  Future<void> deleteEle(String id) async {
    final dbHelper = DatabaseHelper.instance;
    await dbHelper.delete(id);
    return;
  }

  Future<void> _copyToClipboard(String txt) async {
    await Clipboard.setData(ClipboardData(text: txt));
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Copied to clipboard'),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.type == 'edit'
            ? 'Detail - ${_nameController.text}'
            : 'Create a new password'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Form(
            key: _formKey,
            child: ListView(
              shrinkWrap: true,
              children: [
                SizedBox(
                  height: size.height * 0.05,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: size.width * 0.9,
                      child: TextFormField(
                        // initialValue: _controller.text,
                        controller: _nameController,
                        autofocus: true,
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.text_fields),
                          labelText: 'Name',
                          hintText: 'Name',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter some text';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: size.height * 0.02,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: size.width * 0.9,
                      child: TextFormField(
                        // initialValue: _controller.text,
                        controller: _usernameController,
                        autofocus: true,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.person),
                          labelText: 'Username',
                          hintText: 'Username',
                          border: const OutlineInputBorder(),
                          suffixIcon: IconButton(
                            onPressed: () {
                              _copyToClipboard(_usernameController.text);
                            },
                            icon: const Icon(Icons.copy),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter some text';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: size.height * 0.02,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: size.width * 0.9,
                      child: TextFormField(
                        // initialValue: _controller.text,
                        controller: _passwordController,
                        autofocus: true,
                        obscureText: _visiblePass,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.lock),
                          labelText: 'Password',
                          hintText: 'Password',
                          border: const OutlineInputBorder(),
                          suffixIcon: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                onPressed: () {
                                  setState(() {
                                    _visiblePass = !_visiblePass;
                                  });
                                },
                                icon: Icon(_visiblePass
                                    ? Icons.visibility
                                    : Icons.visibility_off),
                              ),
                              IconButton(
                                onPressed: () {
                                  _copyToClipboard(_passwordController.text);
                                },
                                icon: const Icon(Icons.copy),
                              ),
                            ],
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter some text';
                          }
                          return null;
                        },
                        onChanged: (text) {
                          passwordQality(text);
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: size.height * 0.04,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text.rich(
                      TextSpan(
                        children: [
                          const TextSpan(text: 'Password Quality:  '),
                          TextSpan(
                            text: _passQuality,
                            style: TextStyle(
                                color: _passQuality == 'Low'
                                    ? Colors.red
                                    : Colors.green),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
                SizedBox(
                  height: size.height * 0.04,
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (widget.type == 'edit') {
                      await editEle(
                        _nameController.text,
                        _usernameController.text,
                        _passwordController.text,
                      );
                      Navigator.pop(context);
                    } else {
                      if (_formKey.currentState!.validate()) {
                        await addEle(
                          _nameController.text,
                          _usernameController.text,
                          _passwordController.text,
                        );
                        Navigator.pop(context);
                        // _controller.clear();
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Error'),
                          ),
                        );
                      }
                    }
                  },
                  child: Text(widget.type == 'edit' ? 'Save' : 'Create'),
                ),
                if (widget.type == 'edit')
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: Colors.red,
                    ),
                    onPressed: () async {
                      await deleteEle(widget.data!.id);
                      Navigator.pop(context);

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Deleted'),
                        ),
                      );
                    },
                    child: const Text('Delete'),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
