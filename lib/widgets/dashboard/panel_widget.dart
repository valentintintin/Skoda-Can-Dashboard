import 'dart:async';
import 'dart:collection';

import 'package:flutter/material.dart';


class PanelWidget extends StatefulWidget {
  final Stream<Image> streamImage;

  PanelWidget(this.streamImage);

  @override
  State<PanelWidget> createState() => _PanelWidgetState();
}

class _PanelWidgetState extends State<PanelWidget> {
  late StreamSubscription<Image> _subscriptionEvent;

  Queue<Image> images = new Queue();

  @override
  void initState() {
    super.initState();
    _subscriptionEvent = widget.streamImage.asBroadcastStream().listen((image) {
      setState(() {
        images.addFirst(image);
        if (images.length > 6) {
          images.removeLast();
        }
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
    return SizedBox(
        width: 64 * 3,
        child: Wrap(
            children: images.map((e) => SizedBox(
                width: 64,
                height: 64,
                child: e
            )).toList()
        )
    );
  }
}
