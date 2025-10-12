import 'package:flutter/material.dart';
import 'package:peoples_book/view/people_view.dart';

class PeoplesHome extends StatefulWidget {
  const PeoplesHome({super.key});

  @override
  State<PeoplesHome> createState() => _PeoplesHomeState();
}

class _PeoplesHomeState extends State<PeoplesHome> {
  @override
  Widget build(BuildContext context) {
    return const PeopleView();
  }
}
