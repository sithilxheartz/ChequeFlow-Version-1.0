import 'package:cheque_manager/navigation_bar.dart';
import 'package:flutter/material.dart' hide NavigationBar;
import 'package:go_router/go_router.dart';

class RouterClass {
  final router = GoRouter(
    initialLocation: "/",
    errorPageBuilder: (context, state) {
      return MaterialPage(
        child: Scaffold(
          body: Center(child: Text("This page is not available")),
        ),
      );
    },
    routes: [
      // home page
      GoRoute(
        path: "/",
        name: "home",
        builder: (context, state) {
          return NavigationBar();
        },
      ),
    ],
  );
}
