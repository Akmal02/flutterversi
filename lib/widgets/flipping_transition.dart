import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutteversi/constants.dart';

class FlippingTransition extends StatefulWidget {
  final Widget child;
  final double angle;
  final Duration delay;
  final bool enabled;

  const FlippingTransition(
      {Key key, this.child, this.angle = 0.0, this.delay, this.enabled = true})
      : super(key: key);

  @override
  _FlippingTransitionState createState() => _FlippingTransitionState();
}

class _FlippingTransitionState extends State<FlippingTransition>
    with SingleTickerProviderStateMixin {
  Widget currentChild;

  AnimationController _controller;
  Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: mediumAnimDuration,
    );
    _animation =
        CurvedAnimation(parent: _controller, curve: Curves.fastOutSlowIn);
    currentChild = widget.child;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(FlippingTransition oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.child?.key != oldWidget.child?.key) {
      _startAnimation();
    }
  }

  _startAnimation() async {
    _controller.reset();
    if (!widget.enabled) {
      return;
    }
    if (widget.delay != null) {
      await Future.delayed(widget.delay);
    }
    _controller.addListener(() {
      if (_animation.value > 0.5) {
        currentChild = widget.child;
      }
    });
    _controller.forward(from: 0.0);
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) {
      return currentChild = widget.child ?? SizedBox();
    }
    // If new child = old child, no need to animate
    if (widget.child == currentChild) {
      return currentChild ?? SizedBox();
    }

    // Animate entrance if only new widget exists
    if (widget.child != null && currentChild == null) {
      return FadeTransition(
        opacity: _animation,
        child: ScaleTransition(
          scale: Tween(begin: 2.0, end: 1.0).animate(_animation),
          child: widget.child ?? SizedBox(),
        ),
      );
    }
    if (widget.child?.key == currentChild?.key) {
      return currentChild ?? SizedBox();
    }
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..rotateZ(widget.angle)
            ..rotateX(_animation.value * pi),
          child: currentChild ?? SizedBox(),
        );
      },
    );
  }
}
