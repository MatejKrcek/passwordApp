import 'package:flutter/material.dart';
import 'package:pass_app/data/password_item.dart';
import 'package:pass_app/pages/detail_page.dart';
import 'package:pass_app/data/db_helper.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  List<Password> _listOfPasswords = [];
  bool _hasData = false;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loadEle();
  }

  Future<void> _loadEle() async {
    setState(() {
      _loading = true;
    });
    final dbHelper = DatabaseHelper.instance;
    final allRows = await dbHelper.queryAllRows();
    for (var i = 0; i < allRows.length; i++) {
      List<Password> _data = [
        Password(
          id: allRows[i]['_id'],
          name: allRows[i]['name'],
          username: allRows[i]['username'],
          password: allRows[i]['password'],
          date: allRows[i]['date'],
        ),
      ];
      _listOfPasswords.add(_data[0]);
    }
    setState(() {
      if (_listOfPasswords.isNotEmpty) {
        _hasData = true;
      }
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My items'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: _hasData == false
            ? const Center(
                child: Text('Hey, you have not data'),
              )
            : _loading == true
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : ListView.builder(
                    itemCount: _listOfPasswords.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: ListTile(
                            title: Text(_listOfPasswords[index].name),
                            subtitle: Text(_listOfPasswords[index].username),
                            trailing: IconButton(
                              onPressed: () {
                                Navigator.of(context)
                                    .push(
                                  MaterialPageRoute(
                                    builder: (context) => DetailPage(
                                      type: 'edit',
                                      data: _listOfPasswords[index],
                                    ),
                                  ),
                                )
                                    .then((value) {
                                  setState(() {
                                    _listOfPasswords.clear();
                                  });
                                  _loadEle();
                                });
                              },
                              icon: const Icon(Icons.arrow_forward_ios),
                            ),
                            leading: const Icon(Icons.password),
                          ),
                        ),
                      );
                    },
                  ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context)
              .push(MaterialPageRoute(
            builder: (context) => const DetailPage(
              type: 'create',
            ),
          ))
              .then((value) {
            setState(() {
              _listOfPasswords.clear();
            });
            _loadEle();
          });
        },
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: const Icon(Icons.add),
      ),
    );
  }
}
