import 'dart:math';

import 'package:flutter/material.dart';
import 'package:gsy_flutter_demo/widget/particle/particle_model.dart';
import 'package:gsy_flutter_demo/widget/particle/particle_painter.dart';
import 'package:simple_animations/simple_animations.dart';
import 'package:supercharged/supercharged.dart';

class ParticlesWidget extends StatefulWidget {
  final int numberOfParticles;

  const ParticlesWidget(this.numberOfParticles, {super.key});

  @override
  _ParticlesWidgetState createState() => _ParticlesWidgetState();
}

class _ParticlesWidgetState extends State<ParticlesWidget> {
  final Random random = Random();

  final List<ParticleModel> particles = [];

  @override
  void initState() {
    widget.numberOfParticles.times(() => particles.add(ParticleModel(random)));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return LoopAnimationBuilder(
      duration: const Duration(seconds: 1),
      tween: ConstantTween(1),
      builder: (context, child, dynamic _) {
        _simulateParticles();
        return CustomPaint(
          painter: ParticlePainter(particles),
        );
      },
    );
  }

  _simulateParticles() {
    for (var particle in particles) {
      particle.checkIfParticleNeedsToBeRestarted();
    }
  }

}
