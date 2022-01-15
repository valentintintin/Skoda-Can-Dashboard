import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:skoda_can_dashboard/model/dashcam_params.dart';
import 'package:skoda_can_dashboard/utils.dart';
import 'package:skoda_can_dashboard/widgets/dashcam_widget.dart';

class DashcamPage extends StatefulWidget {
  final StreamController<DashcamParams> streamParams;
  final String dashcamParamsFile;
  final Stream<Image> streamImage;

  DashcamPage(this.streamImage, this.streamParams, this.dashcamParamsFile);

  @override
  State<DashcamPage> createState() => _DashcamPageState();
}

class _DashcamPageState extends State<DashcamPage> {
  late StreamSubscription<Image> _subscriptionEvent;

  DashcamParams? params;
  Image? image;

  Future<DashcamParams> _getDashcamParams() async {
    if (params != null) {
      return params!;
    }
    return params = DashcamParams.fromRawJson(await getStringFromAssets(widget.dashcamParamsFile));
  }

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
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.max,
      children: [
        FutureBuilder<DashcamParams>(
            future: _getDashcamParams(),
            builder: (BuildContext context, AsyncSnapshot<DashcamParams> snapshot) {
              if (snapshot.hasData) {
                return Container(
                    color: Colors.grey,
                    child: Padding(
                        padding: EdgeInsets.all(8),
                        child: SingleChildScrollView(
                            child: Column(
                                children: [
                                  const Text('Settings', style: const TextStyle(fontSize: 25, fontWeight: FontWeight.w500),),

                                  DropdownButton<String>(
                                      value: params!.result,
                                      onChanged: (String? newValue) {
                                        setState(() {
                                          params!.result = newValue!;
                                        });
                                        widget.streamParams.add(params!);
                                      },
                                      items: [
                                        DropdownMenuItem<String>(
                                          value: 'source',
                                          child: const Text('Source image'),
                                        ),
                                        DropdownMenuItem<String>(
                                          value: 'resized',
                                          child: const Text('Resized image'),
                                        ),
                                        DropdownMenuItem<String>(
                                          value: 'rotated',
                                          child: const Text('Rotated image'),
                                        ),
                                        DropdownMenuItem<String>(
                                          value: 'gray',
                                          child: const Text('Grayscaled image'),
                                        ),
                                        DropdownMenuItem<String>(
                                          value: 'gaussian',
                                          child: const Text('Gaussian blured image'),
                                        ),
                                        DropdownMenuItem<String>(
                                          value: 'canny',
                                          child: const Text('Canny image'),
                                        ),
                                        DropdownMenuItem<String>(
                                          value: 'mask_lanes',
                                          child: const Text('Mask lanes'),
                                        ),
                                        DropdownMenuItem<String>(
                                          value: 'masked_lanes',
                                          child: const Text('Masked lanes image'),
                                        ),
                                        DropdownMenuItem<String>(
                                          value: 'lanes',
                                          child: const Text('Lanes image'),
                                        ),
                                        DropdownMenuItem<String>(
                                          value: 'mask_panels',
                                          child: const Text('Mask panels'),
                                        ),
                                        DropdownMenuItem<String>(
                                          value: 'masked_panels',
                                          child: const Text('Masked panels image'),
                                        ),
                                        DropdownMenuItem<String>(
                                          value: 'panels',
                                          child: const Text('Panels image'),
                                        ),
                                        DropdownMenuItem<String>(
                                          value: 'result',
                                          child: const Text('Result image'),
                                        )
                                      ]),
                                  _getSlider('Resized', 5, 100, () => params!.resizePercent, (value) => params!.resizePercent = value.toInt(), suffix: '%'),
                                  _getSlider('Rotation', 0, 360, () => params!.rotationAngle, (value) => params!.rotationAngle = value.toInt(), suffix: '°'),
                                  _getSlider('Gaussian blur', 0, 50, () => params!.gaussianBlur, (value) => params!.gaussianBlur = value.toInt()),

                                  const Text('Canny', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500),),
                                  _getSlider('Low threshold', 0, 250, () => params!.canny.lowThreshold, (value) {
                                    params!.canny.lowThreshold = value.toInt();
                                    params!.canny.highThreshold = params!.canny.lowThreshold * 3;
                                  }),
                                  _getSlider('High threshold', 0, 250, () => params!.canny.highThreshold, (value) => params!.canny.highThreshold = value.toInt()),

                                  const Text('Lanes', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500),),
                                  _getSlider('Length multiplier', 0, 1, () => params!.lanes.lengthMultiplier, (value) => params!.lanes.lengthMultiplier = value),

                                  const Text('Lanes polygon mask multiplier', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),),
                                  _getSlider('Bottom left X', 0, 1, () => params!.lanes.polygonMultiplier.bottomLeft[0], (value) => params!.lanes.polygonMultiplier.bottomLeft[0] = value),
                                  _getSlider('Bottom left Y', 0, 1, () => params!.lanes.polygonMultiplier.bottomLeft[1], (value) => params!.lanes.polygonMultiplier.bottomLeft[1] = value),
                                  _getSlider('Top left X', 0, 1, () => params!.lanes.polygonMultiplier.topLeft[0], (value) => params!.lanes.polygonMultiplier.topLeft[0] = value),
                                  _getSlider('Top left Y', 0, 1, () => params!.lanes.polygonMultiplier.topLeft[1], (value) => params!.lanes.polygonMultiplier.topLeft[1] = value),
                                  _getSlider('Bottom right X', 0, 1, () => params!.lanes.polygonMultiplier.bottomRight[0], (value) => params!.lanes.polygonMultiplier.bottomRight[0] = value),
                                  _getSlider('Bottom right Y', 0, 1, () => params!.lanes.polygonMultiplier.bottomRight[1], (value) => params!.lanes.polygonMultiplier.bottomRight[1] = value),
                                  _getSlider('Top right X', 0, 1, () => params!.lanes.polygonMultiplier.topRight[0], (value) => params!.lanes.polygonMultiplier.topRight[0] = value),
                                  _getSlider('Top right Y', 0, 1, () => params!.lanes.polygonMultiplier.topRight[1], (value) => params!.lanes.polygonMultiplier.topRight[1] = value),

                                  const Text('Lanes hough lines', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),),
                                  _getSlider('Threshold', 5, 50, () => params!.lanes.houghLines.threshold, (value) => params!.lanes.houghLines.threshold = value.toInt()),
                                  _getSlider('Min length', 10, 100, () => params!.lanes.houghLines.minLineLength, (value) => params!.lanes.houghLines.minLineLength = value.toInt()),
                                  _getSlider('Max gap', 5, 500, () => params!.lanes.houghLines.maxLineGap, (value) => params!.lanes.houghLines.maxLineGap = value.toInt()),

                                  const Text('Lanes angle detection', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),),
                                  _getSlider('Center', 0, 1000, () => params!.lanes.angle.center, (value) => params!.lanes.angle.center = value.toInt()),
                                  _getSlider('Interval', 5, 100, () => params!.lanes.angle.interval, (value) => params!.lanes.angle.interval = value.toInt()),

                                  const Text('Panels', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500),),
                                  const Text('Panels polygon mask multiplier', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),),
                                  _getSlider('Bottom left X', 0, 1, () => params!.panels.polygonMultiplier.bottomLeft[0], (value) => params!.panels.polygonMultiplier.bottomLeft[0] = value),
                                  _getSlider('Bottom left Y', 0, 1, () => params!.panels.polygonMultiplier.bottomLeft[1], (value) => params!.panels.polygonMultiplier.bottomLeft[1] = value),
                                  _getSlider('Top left X', 0, 1, () => params!.panels.polygonMultiplier.topLeft[0], (value) => params!.panels.polygonMultiplier.topLeft[0] = value),
                                  _getSlider('Top left Y', 0, 1, () => params!.panels.polygonMultiplier.topLeft[1], (value) => params!.panels.polygonMultiplier.topLeft[1] = value),
                                  _getSlider('Bottom right X', 0, 1, () => params!.panels.polygonMultiplier.bottomRight[0], (value) => params!.panels.polygonMultiplier.bottomRight[0] = value),
                                  _getSlider('Bottom right Y', 0, 1, () => params!.panels.polygonMultiplier.bottomRight[1], (value) => params!.panels.polygonMultiplier.bottomRight[1] = value),
                                  _getSlider('Top right X', 0, 1, () => params!.panels.polygonMultiplier.topRight[0], (value) => params!.panels.polygonMultiplier.topRight[0] = value),
                                  _getSlider('Top right Y', 0, 1, () => params!.panels.polygonMultiplier.topRight[1], (value) => params!.panels.polygonMultiplier.topRight[1] = value),

                                  const Text('Panel size detection', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),),
                                  _getSlider('Min width', 0, 200, () => params!.panels.sizeDetection.width.min, (value) => params!.panels.sizeDetection.width.min = value.toInt()),
                                  _getSlider('Max width', 0, 200, () => params!.panels.sizeDetection.width.max, (value) => params!.panels.sizeDetection.width.max = value.toInt()),
                                  _getSlider('Min height', 0, 200, () => params!.panels.sizeDetection.height.min, (value) => params!.panels.sizeDetection.height.min = value.toInt()),
                                  _getSlider('Max height', 0, 200, () => params!.panels.sizeDetection.height.max, (value) => params!.panels.sizeDetection.height.max = value.toInt()),
                                  _getSlider('Min ratio', 0, 2, () => params!.panels.sizeDetection.ratio.min, (value) => params!.panels.sizeDetection.ratio.min = value),
                                  _getSlider('Max ratio', 0, 2, () => params!.panels.sizeDetection.ratio.max, (value) => params!.panels.sizeDetection.ratio.max = value),

                                  Row(
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.all(8),
                                        child: ElevatedButton(onPressed: () {
                                          widget.streamParams.add(params!);
                                          File file = File(widget.dashcamParamsFile);
                                          file.writeAsStringSync(params!.toRawJson(), mode: FileMode.writeOnly);

                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(content: Text('Settings saved !')),
                                          );
                                        }, child: const Text('Save')),
                                      ),
                                      Padding(
                                          padding: EdgeInsets.all(8),
                                          child:
                                          ElevatedButton(onPressed: () async {
                                            params = null;
                                            await _getDashcamParams();
                                            widget.streamParams.add(params!);
                                            setState(() {});

                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(content: Text('Settings reset !')),
                                            );
                                          }, child: const Text('Reset'))
                                      )
                                    ],
                                  )
                                ]
                            )
                        )
                    )
                );
              }

              return SizedBox();
            }
        ),
        Expanded(
            child: DashcamWidget(widget.streamImage)
        ),
      ],
    );
  }

  Widget _getSlider(String name, double min, double max, Function() getter, Function(double value) setter, { String suffix = '' }) {
    return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(name + '\nValue : ' + getter().toString()),
          Slider(
            value: getter().toDouble(),
            max: max,
            min: min,
            divisions: ((max - min < 10) ? max * 100 : max).toInt(),
            label: getter().toString() + suffix,
            onChanged: (double value) {
              setState(() {
                setter(value);
              });
              widget.streamParams.add(params!);
            },
          )
        ]
    );
  }
}