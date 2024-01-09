import 'package:fluro/fluro.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

RouteTransitionsBuilder _standardTransitionsBuilder(
    TransitionType? transitionType) {
  return (
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    if (transitionType == TransitionType.fadeIn) {
      return FadeTransition(opacity: animation, child: child);
    } else {
      const topLeft = Offset(0.0, 0.0);
      const topRight = Offset(1.0, 0.0);
      const bottomLeft = Offset(0.0, 1.0);

      var startOffset = bottomLeft;
      var endOffset = topLeft;

      if (transitionType == TransitionType.inFromLeft) {
        startOffset = const Offset(-1.0, 0.0);
        endOffset = topLeft;
      } else if (transitionType == TransitionType.inFromRight) {
        startOffset = topRight;
        endOffset = topLeft;
      } else if (transitionType == TransitionType.inFromBottom) {
        startOffset = bottomLeft;
        endOffset = topLeft;
      } else if (transitionType == TransitionType.inFromTop) {
        startOffset = const Offset(0.0, -1.0);
        endOffset = topLeft;
      }

      return SlideTransition(
        position: Tween<Offset>(
          begin: startOffset,
          end: endOffset,
        ).animate(animation),
        child: child,
      );
    }
  };
}

/// A route that is added to the router tree.
class FluroDefaultRoute extends FluroDestinationRoute {
  FluroDefaultRoute(
    String route, {
    required super.pageBuilder,
    this.transitionType = TransitionType.native,
    this.transitionDuration = const Duration(milliseconds: 500),
    this.transitionBuilder,
    this.opaque,
  }) : super(route);

  TransitionType transitionType;
  Duration transitionDuration;
  RouteTransitionsBuilder? transitionBuilder;
  bool? opaque;

  @override
  Route routeBuilder({
    RouteSettings? routeSettings,
    Duration? transitionDuration,
    bool maintainState = true,
    bool? opaque,
    required Map<String, List<String>> parameters,
  }) {
    final isNativeTransition = transitionType == TransitionType.native ||
        transitionType == TransitionType.nativeModal;

    if (isNativeTransition) {
      return MaterialPageRoute<dynamic>(
        settings: routeSettings,
        fullscreenDialog: transitionType == TransitionType.nativeModal,
        maintainState: maintainState,
        builder: (BuildContext context) {
          return pageBuilder(context, parameters);
        },
      );
    } else if (transitionType == TransitionType.material ||
        transitionType == TransitionType.materialFullScreenDialog) {
      return MaterialPageRoute<dynamic>(
        settings: routeSettings,
        fullscreenDialog:
            transitionType == TransitionType.materialFullScreenDialog,
        maintainState: maintainState,
        builder: (BuildContext context) {
          return pageBuilder(context, parameters);
        },
      );
    } else if (transitionType == TransitionType.cupertino ||
        transitionType == TransitionType.cupertinoFullScreenDialog) {
      return CupertinoPageRoute<dynamic>(
        settings: routeSettings,
        fullscreenDialog:
            transitionType == TransitionType.cupertinoFullScreenDialog,
        maintainState: maintainState,
        builder: (BuildContext context) {
          return pageBuilder(context, parameters);
        },
      );
    } else {
      RouteTransitionsBuilder? routeTransitionsBuilder;

      if (transitionType == TransitionType.custom) {
        routeTransitionsBuilder = transitionBuilder;
      } else {
        routeTransitionsBuilder = _standardTransitionsBuilder(transitionType);
      }

      return PageRouteBuilder<dynamic>(
        opaque: opaque ?? opaque ?? true,
        settings: routeSettings,
        maintainState: maintainState,
        pageBuilder: (BuildContext context, Animation<double> animation,
                Animation<double> secondaryAnimation) =>
            pageBuilder(context, parameters),
        transitionDuration: transitionType == TransitionType.none
            ? Duration.zero
            : (transitionDuration ?? this.transitionDuration),
        reverseTransitionDuration: transitionType == TransitionType.none
            ? Duration.zero
            : (transitionDuration ?? this.transitionDuration),
        transitionsBuilder: transitionType == TransitionType.none
            ? (_, __, ___, child) => child
            : routeTransitionsBuilder!,
      );
    }
  }
}
