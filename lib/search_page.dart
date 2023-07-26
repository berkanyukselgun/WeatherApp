import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Search_Page extends StatefulWidget {
  const Search_Page({Key? key}) : super(key: key);

  @override
  State<Search_Page> createState() => _Search_PageState();
}

class _Search_PageState extends State<Search_Page> {
  String selectedCity = '';

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          fit: BoxFit.cover,
          image: AssetImage(
            'assets/search.jpg',
          ),
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 50.0),
                child: TextField(
                  onChanged: (value) {
                    selectedCity = value;
                  },
                  decoration: const InputDecoration(
                    hintText: 'Şehir Seçiniz',
                    border: OutlineInputBorder(
                      borderSide: BorderSide.none,
                    ),
                  ),
                  style: const TextStyle(fontSize: 30),
                  textAlign: TextAlign.center,
                ),
              ),
              ElevatedButton(
                  onPressed: () async {
                    var response = await http.get(Uri.parse(
                        'https://api.openweathermap.org/data/2.5/weather?q=$selectedCity&appid=471c2a6ae95fc5dba80d1974c88ca86b'));
                    if (response.statusCode == 200) {
                      Navigator.pop(context, selectedCity);
                    } else {
                      _showMyDialog();
                    }
                  },
                  style: ElevatedButton.styleFrom(primary: Colors.blueGrey),
                  child: Text('Selected City')),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showMyDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Location Not Found'),
          content: SingleChildScrollView(
            child: ListBody(
              children: const <Widget>[
                Text('Please select a valid location'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
