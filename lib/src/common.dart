/*
 * fluro
 * Created by Yakka
 * https://theyakka.com
 * 
 * Copyright (c) 2019 Yakka, LLC. All rights reserved.
 * See LICENSE for distribution and usage details.
 */

import 'package:flutter/widgets.dart';

/// Builds out a screen based on string path [parameters] and context.
///
/// Note: you can access [RouteSettings] with the [context.settings] extension
typedef PageBuilder = Widget Function(
  BuildContext context,
  Map<String, List<String>> parameters,
);

typedef RedirectResolver = String Function(
    Map<String, List<String>> parameters);

sealed class FluroRoute {
  FluroRoute(this.route);

  final String route;
}

abstract class FluroDestinationRoute extends FluroRoute {
  FluroDestinationRoute(super.route, {required this.pageBuilder});
  final PageBuilder pageBuilder;

  Route routeBuilder({
    RouteSettings? routeSettings,
    Duration? transitionDuration,
    bool maintainState = true,
    bool? opaque,
    required Map<String, List<String>> parameters,
  });
}

class FluroRedirectRoute extends FluroRoute {
  FluroRedirectRoute(super.route, {required this.resolver});

  final RedirectResolver resolver;
}

/// The type of transition to use when pushing/popping a route.
///
/// [TransitionType.custom] must also provide a transition when used.
enum TransitionType {
  native,
  nativeModal,
  inFromLeft,
  inFromTop,
  inFromRight,
  inFromBottom,
  fadeIn,
  custom,
  material,
  materialFullScreenDialog,
  cupertino,
  cupertinoFullScreenDialog,
  none,
  customRoute,
}

/// The match type of the route.
enum RouteMatchType {
  visual,
  noMatch,
}

/// The route that was matched.
class RouteMatch {
  RouteMatch({
    this.matchType = RouteMatchType.noMatch,
    this.route,
    this.errorMessage = 'Unable to match route. Please check the logs.',
  });

  final Route? route;
  final RouteMatchType matchType;
  final String errorMessage;
}

/// When the route is not found.
class RouteNotFoundException implements Exception {
  RouteNotFoundException(
    this.message,
    this.path,
  );

  final String message;
  final String path;

  @override
  String toString() {
    return "No registered route was found to handle '$path'";
  }
}
