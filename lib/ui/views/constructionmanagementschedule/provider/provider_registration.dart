import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'home_provider/fetch_api_provider.dart';
import 'home_provider/home_provider.dart';

final homeProvider =
    ChangeNotifierProvider<HomeProvider>((ref) => HomeProvider(ref));
final fetchApiProvider =
    ChangeNotifierProvider<FetchApiProvider>((ref) => FetchApiProvider(ref));
