import 'package:flutter/material.dart';

//models
import '../models/litter_visit_model.dart';

//services
import '../services/litter_visit_service.dart';

//////////////////////////////////////////LATEST VISIT WIDGET//////////////////////////////////////////
class LatestVisit extends StatefulWidget {

  final String catId;
  final TextStyle? style;

  const LatestVisit({
    super.key,
    required this.catId,
    this.style,
  });

  @override
  State<LatestVisit> createState() =>
      _LatestVisitState();
}


//////////////////////////////////////////LATEST VISIT STATE//////////////////////////////////////////
class _LatestVisitState extends State<LatestVisit> {

  late Stream<LitterVisit?> visitStream;


  //////////////////////////////////////////INITIALIZE STREAM//////////////////////////////////////////
  @override
  void initState() {
    super.initState();

    visitStream =
        LitterVisitService.watchLatestVisit(
      widget.catId,
    );
  }


  //////////////////////////////////////////UPDATE CAT//////////////////////////////////////////
  @override
  void didUpdateWidget(
    covariant LatestVisit oldWidget,
  ) {

    super.didUpdateWidget(oldWidget);

    if (oldWidget.catId != widget.catId) {

      visitStream =
          LitterVisitService.watchLatestVisit(
        widget.catId,
      );
    }
  }


  //////////////////////////////////////////FORMAT TIMESTAMP//////////////////////////////////////////
  String _formatTimestamp(DateTime timestamp) {

    final date = timestamp.toLocal();

    // FORMAT DATE
    final month =
        date.month.toString().padLeft(2, '0');

    final day =
        date.day.toString().padLeft(2, '0');

    final year = date.year;

    // FORMAT TIME
    final hour =
        date.hour % 12 == 0
            ? 12
            : date.hour % 12;

    final minute =
        date.minute.toString().padLeft(2, '0');

    final period =
        date.hour >= 12 ? 'PM' : 'AM';

    return '$month/$day/$year $hour:$minute$period';
  }


  //////////////////////////////////////////BUILD WIDGET//////////////////////////////////////////
  @override
  Widget build(BuildContext context) {

    return StreamBuilder<LitterVisit?>(

      stream: visitStream,

      builder: (context, snapshot) {

        // LOADING OR ERROR
        // if (snapshot.connectionState ==
        //         ConnectionState.waiting ||
        //     snapshot.hasError) {

        //   return Text(
        //     'Last visit —',
        //     textAlign: TextAlign.center,
        //     style: widget.style,
        //   );
        // }

        // LOADING
        if (snapshot.connectionState ==
            ConnectionState.waiting) {

          return Text(
            'Last visit —',
            textAlign: TextAlign.center,
            style: widget.style,
          );
        }

        // ERROR
        if (snapshot.hasError) {

          debugPrint(
            'Error loading latest visit: ${snapshot.error}',
          );

          return Text(
            'Last visit —',
            textAlign: TextAlign.center,
            style: widget.style,
          );
        }

        final visit = snapshot.data;

        // NO RECORDED VISITS
        if (visit == null) {

          return Text(
            'Last visit —',
            textAlign: TextAlign.center,
            style: widget.style,
          );
        }

        // DISPLAY MOST RECENT VISIT
        return Text(
          'Last visit ${_formatTimestamp(visit.timestamp)}',
          textAlign: TextAlign.center,
          style: widget.style,
        );
      },
    );
  }
}