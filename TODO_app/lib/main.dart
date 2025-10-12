import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo_app/app/app.dart';
import 'package:todo_app/provider/task_provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(create: (context) => TaskProvider(), child: App()),
  );
}
