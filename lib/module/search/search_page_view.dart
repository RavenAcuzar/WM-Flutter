
import 'package:flutter/material.dart';

class SearchPage extends StatelessWidget {
  static const String routeName = '/search';

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: AppBar(
          title: Text('Search'),
        ),
        body: Center(child: Text('Search')));
  }
}