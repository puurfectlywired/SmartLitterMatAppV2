import 'package:flutter/material.dart';

import '../models/weight_measurement_model.dart';
import '../services/weight_measurement_service.dart';

import '../other/global_variables.dart';

//////////////////////////////////////////LATEST WEIGHT//////////////////////////////////////////
class LatestWeight extends StatefulWidget {

  final String catId;
  final TextStyle? style;

  const LatestWeight({
    super.key,
    required this.catId,
    this.style,
  });

  @override
  State<LatestWeight> createState() =>
      _LatestWeightState();
}

//////////////////////////////////////////LATEST WEIGHT STATE//////////////////////////////////////////
class _LatestWeightState extends State<LatestWeight> {

  late Stream<WeightMeasurement?> weightStream;

  @override
  void initState() {
    super.initState();

    weightStream = WeightService.watchLatestWeight(
      widget.catId,
    );
  }

  @override
  void didUpdateWidget(covariant LatestWeight oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.catId != widget.catId) {

      weightStream = WeightService.watchLatestWeight(
        widget.catId,
      );
    }
  }

  //////////////////////////////////////////BUILD//////////////////////////////////////////
  @override
  Widget build(BuildContext context) {

    return StreamBuilder<WeightMeasurement?>(
      stream: weightStream,

      builder: (context, snapshot) {

        final measurement = snapshot.data;

        // NO WEIGHT DATA
        if (snapshot.connectionState ==
                ConnectionState.waiting ||
            snapshot.hasError ||
            measurement == null) {

          return Text(
            '—',
            style: widget.style,
          );
        }

        // DISPLAY LATEST MEASUREMENT
        return Text(
          displayWeight(measurement.weight),
          style: widget.style,
        );
      },
    );
  }
}