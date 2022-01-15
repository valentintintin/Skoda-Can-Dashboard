import 'dart:async';

import 'package:flutter/material.dart';

class DashcamWidget extends StatefulWidget {
  final Stream<Image> streamImage;
  
  DashcamWidget(this.streamImage);

  @override
  State<DashcamWidget> createState() => _DashcamWidgetState();
}

class _DashcamWidgetState extends State<DashcamWidget> {
  late StreamSubscription<Image> _subscriptionEvent;

  Image? image;

  @override
  void initState() {
    super.initState();

    _subscriptionEvent = widget.streamImage.asBroadcastStream().listen((image) {
      setState(() {
        this.image = image;
      });
    });
  }

  @override
  void dispose() {
    _subscriptionEvent.cancel();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return image != null ? FittedBox(
      child: image,
      fit: BoxFit.fill,
    ) : SizedBox();
  }
}