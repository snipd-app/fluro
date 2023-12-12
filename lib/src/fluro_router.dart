/*
 * fluro
 * Created by Yakka
 * https://theyakka.com
 * 
 * Copyright (c) 2019 Yakka, LLC. All rights reserved.
 * See LICENSE for distribution and usage details.
 */

import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';

/// {@template fluro_router}
/// Attach [FluroRouter] to [MaterialApp] by connnecting [FluroRouter.generator] to [MaterialApp.onGenerateRoute].
///
/// Define routes with [FluroRouter.define], optionally specifying transition types and connecting string path params to
/// your screen widget's constructor.
///
/// Push new route paths with [FluroRouter.appRouter.navigateTo] or continue to use [Navigator.of(context).push] if you prefer.
/// {@endtemplate}
class FluroRouter {
  FluroRouter({
    required List<FluroRoute> routes,
    required this.notFoundRoute,
  }) {
    for (final route in routes) {
      _routeTree.addRoute(route);
    }
  }

  /// The tree structure that stores the defined routes
  final _routeTree = RouteTree();

  /// Generic handler for when a route has not been defined
  FluroRoute notFoundRoute;

  /// The default transition duration to use throughout Fluro
  static const defaultTransitionDuration = Duration(milliseconds: 250);

  /// Finds a defined [FluroRoute] for the path value. If no [FluroRoute] definition was found
  /// then function will return null.
  AppRouteMatch? match(String path) {
    return _routeTree.matchRoute(path);
  }

  /// Similar to [Navigator.pop]
  void pop<T>(BuildContext context, [T? result]) =>
      Navigator.of(context).pop(result);

  /// Attempt to match a route to the provided [path].
  RouteMatch matchRoute(
    String? path, {
    RouteSettings? routeSettings,
    Duration? transitionDuration,
    bool maintainState = true,
    bool? opaque,
  }) {
    RouteSettings settingsToUse = routeSettings ?? RouteSettings(name: path);

    if (settingsToUse.name == null) {
      settingsToUse = settingsToUse.copyWithShim(name: path);
    }

    final match = _routeTree.matchRoute(path!);
    final route = match?.route;

    final parameters = match?.parameters ?? <String, List<String>>{};

    if (route != null) {
      return RouteMatch(
        matchType: RouteMatchType.visual,
        route: route.routeBuilder(
            parameters: parameters,
            maintainState: maintainState,
            opaque: opaque,
            routeSettings: routeSettings,
            transitionDuration: transitionDuration),
      );
    } else {
      return RouteMatch(
          matchType: RouteMatchType.visual,
          route: notFoundRoute.routeBuilder(
              parameters: parameters,
              maintainState: maintainState,
              opaque: opaque,
              routeSettings: routeSettings,
              transitionDuration: transitionDuration));
    }
  }

  /// Route generation method. This function can be used as a way to create routes on-the-fly
  /// if any defined handler is found. It can also be used with the [MaterialApp.onGenerateRoute]
  /// property as callback to create routes that can be used with the [Navigator] class.
  Route<dynamic>? generator(RouteSettings routeSettings) {
    final RouteMatch match = matchRoute(
      routeSettings.name,
      routeSettings: routeSettings,
    );

    return match.route;
  }

  /// Prints the route tree so you can analyze it.
  void printTree() {
    _routeTree.printTree();
  }
}

extension on RouteSettings {
  // shim for 3.5.0 breaking change
  // ignore: unused_element
  RouteSettings copyWithShim({String? name, Object? arguments}) {
    return RouteSettings(
      name: name ?? this.name,
      arguments: arguments ?? this.arguments,
    );
  }
}
