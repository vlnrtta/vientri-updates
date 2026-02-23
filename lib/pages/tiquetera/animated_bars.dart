import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

class AnimatedBars extends StatefulWidget {
  const AnimatedBars({super.key});

  @override
  State<AnimatedBars> createState() => _AnimatedBarsState();
}

class _AnimatedBarsState extends State<AnimatedBars> {
  final int barCount = 15;
  final Random random = Random();

  late List<double> heights;
  late Timer timer;

  @override
  void initState() {
    super.initState();

    heights = List.generate(barCount, (_) => _randomHeight());

    timer = Timer.periodic(const Duration(milliseconds: 200), (_) {
      setState(() {
        heights = List.generate(barCount, (_) => _randomHeight());
      });
    });
  }

  double _randomHeight() {
    return 6 + random.nextInt(18).toDouble(); // entre 6 y 24 px
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(barCount, (i) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeInOut,
          margin: const EdgeInsets.symmetric(horizontal: 2),
          width: 3,
          height: heights[i],
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(3),
          ),
        );
      }),
    );
  }
}
