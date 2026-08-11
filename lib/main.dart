import 'package:flutter/material.dart';

import 'app.dart';
import 'data/app_db.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppDb.init();
  runApp(const EnergyApp());
}
