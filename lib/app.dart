import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:secondhand_app/config/routes.dart';
import 'package:secondhand_app/config/theme.dart';
import 'package:secondhand_app/providers/auth_provider.dart';
import 'package:secondhand_app/providers/product_provider.dart';
import 'package:secondhand_app/providers/chat_provider.dart';
import 'package:secondhand_app/providers/community_provider.dart';
import 'package:secondhand_app/providers/notification_provider.dart';
import 'package:secondhand_app/providers/transaction_provider.dart';
import 'package:secondhand_app/providers/payment_provider.dart';
import 'package:secondhand_app/providers/search_provider.dart';

class SecondHandApp extends StatelessWidget {
  const SecondHandApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ChangeNotifierProvider(create: (_) => CommunityProvider()),
        ChangeNotifierProvider(create: (_) => TransactionProvider()),
        ChangeNotifierProvider(create: (_) => PaymentProvider()),
        ChangeNotifierProvider(create: (_) => SearchProvider()),
      ],
      child: Builder(
        builder: (context) {
          final authProvider = context.read<AuthProvider>();
          final router = AppRoutes.createRouter(authProvider);
          return MaterialApp.router(
            title: 'SecondHand',
            theme: AppTheme.lightTheme,
            debugShowCheckedModeBanner: false,
            routerConfig: router,
          );
        },
      ),
    );
  }
}
