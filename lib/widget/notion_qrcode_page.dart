import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:qr/qr.dart';

class NotionFinalQRCodeEntryPage extends StatefulWidget {
  const NotionFinalQRCodeEntryPage({super.key});

  @override
  State<NotionFinalQRCodeEntryPage> createState() =>
      _NotionFinalQRCodeEntryPageState();
}

class _NotionFinalQRCodeEntryPageState
    extends State<NotionFinalQRCodeEntryPage> {
  final TextEditingController _controller =
      TextEditingController(text: "I Love Flutter");

  void _startDemo() {
    if (_controller.text.isEmpty) return;

    // 跳转到粒子展示页，并传递数据
    Navigator.of(context).push(PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) {
        return NotionFinalQRCodePage(qrData: _controller.text);
      },
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              //const Icon(Icons.qr_code_2, size: 60, color: Color(0xFF4A55A2)),
              const SizedBox(height: 40),
              TextField(
                controller: _controller,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 20, color: Colors.black87),
                decoration: InputDecoration(
                  hintText: "Enter text...",
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        const BorderSide(color: Color(0xFF4A55A2), width: 2),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
              ),
              const SizedBox(height: 30),
              GestureDetector(
                onTap: _startDemo,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                      color: const Color(0xFF4A55A2),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF4A55A2).withValues(alpha: 0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        )
                      ]),
                  child: const Text(
                    "Start",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- 2. 粒子展示页 (接收数据) ---

class _Particle3D {
  double xQr, yQr;
  double xChaos, yChaos, zChaos;
  double xOrdered, yOrdered, zOrdered;

  Color color;
  double size;
  bool isAvatarRandom;
  double zSort = 0;

  _Particle3D({
    required this.xQr,
    required this.yQr,
    required this.xChaos,
    required this.yChaos,
    required this.zChaos,
    required this.xOrdered,
    required this.yOrdered,
    required this.zOrdered,
    required this.color,
    required this.size,
    required this.isAvatarRandom,
  });
}

class NotionFinalQRCodePage extends StatefulWidget {
  final String qrData; // 接收传入的数据

  const NotionFinalQRCodePage({super.key, required this.qrData});

  @override
  State<NotionFinalQRCodePage> createState() => _NotionFinalQRCodePageState();
}

class _NotionFinalQRCodePageState extends State<NotionFinalQRCodePage>
    with TickerProviderStateMixin {
  late AnimationController _mainController;
  late Animation<double> _mainAnimation;

  late AnimationController _modeController;
  late Animation<double> _modeAnimation;

  late AnimationController _rotateController;

  List<_Particle3D> _particles = [];

  bool _isScattered = true;
  bool _isOrdered = false;

  @override
  void initState() {
    super.initState();

    _mainController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    _mainAnimation = CurvedAnimation(
      parent: _mainController,
      curve: Curves.easeInOutCubic,
    );

    _modeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _modeAnimation = CurvedAnimation(
      parent: _modeController,
      curve: Curves.easeInOutQuart,
    );

    _rotateController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 25),
    )..repeat();

    _mainController.value = 1.0;
    _modeController.value = 0.0;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initParticles(MediaQuery.of(context).size);
    });
  }

  @override
  void dispose() {
    _mainController.dispose();
    _modeController.dispose();
    _rotateController.dispose();
    super.dispose();
  }

  void _initParticles(Size screenSize) {
    // 关键修改：使用 QrCode.fromData 自动判断合适的版本
    // 这样无论用户输入多长，只要不超过 QR 极限，都不会报错
    final qrCode = QrCode.fromData(
        data: widget.qrData, errorCorrectLevel: QrErrorCorrectLevel.M);
    final qrImage = QrImage(qrCode);
    final int moduleCount = qrCode.moduleCount;

    final double qrSize = screenSize.width * 0.70;
    final double pixelSize = qrSize / moduleCount;
    final double startX = -qrSize / 2;
    final double startY = -qrSize / 2;

    List<_Particle3D> tempParticles = [];
    final Random random = Random();

    final List<Color> colors = [
      const Color(0xFFC8D0E7),
      const Color(0xFF9FB0D6),
      const Color(0xFF7E92C3),
      const Color(0xFFE0E5F5),
    ];

    List<Offset> validModules = [];
    for (int x = 0; x < moduleCount; x++) {
      for (int y = 0; y < moduleCount; y++) {
        if (qrImage.isDark(y, x)) {
          validModules.add(Offset(x.toDouble(), y.toDouble()));
        }
      }
    }

    int totalPoints = validModules.length;

    for (int i = 0; i < totalPoints; i++) {
      Offset module = validModules[i];
      int x = module.dx.toInt();
      int y = module.dy.toInt();

      // A. QR (2D)
      double targetX = startX + x * pixelSize + pixelSize / 2;
      double targetY = startY + y * pixelSize + pixelSize / 2;

      // B. Chaos (3D)
      double yFactorChaos = (random.nextDouble() - 0.5) * 2.2;
      double yChaos = yFactorChaos * screenSize.height * 0.5;
      double hProgressChaos = (yChaos / (screenSize.height * 0.6)).abs();
      double rChaos = screenSize.width * 0.12 +
          (screenSize.width * 0.25 * pow(hProgressChaos, 2.0));
      rChaos += (random.nextDouble() - 0.5) * (screenSize.width * 0.15);
      double thetaChaos = random.nextDouble() * 2 * pi + (yChaos * 0.005);

      double xChaos = rChaos * cos(thetaChaos);
      double zChaos = rChaos * sin(thetaChaos);

      // C. Ordered (Spiral)
      double t = i / (totalPoints - 1);
      double yNorm = (t - 0.5) * 2.0;
      double yOrdered = yNorm * screenSize.height * 0.55;
      double rBase = screenSize.width * 0.20;
      double rExpand = screenSize.width * 0.25;
      double radiusOrdered = rBase + rExpand * pow(yNorm, 2);
      double thetaStep = 0.5;
      double thetaOrdered = i * thetaStep;

      double xOrdered = radiusOrdered * cos(thetaOrdered);
      double zOrdered = radiusOrdered * sin(thetaOrdered);

      tempParticles.add(_Particle3D(
        xQr: targetX,
        yQr: targetY,
        xChaos: xChaos,
        yChaos: yChaos,
        zChaos: zChaos,
        xOrdered: xOrdered,
        yOrdered: yOrdered,
        zOrdered: zOrdered,
        color: colors[random.nextInt(colors.length)],
        size: pixelSize * 0.85,
        isAvatarRandom: random.nextDouble() < 0.15,
      ));
    }

    setState(() {
      _particles = tempParticles;
    });
  }

  void _toggleScatter() {
    if (_isScattered) {
      _mainController.reverse();
    } else {
      _mainController.forward();
    }
    setState(() {
      _isScattered = !_isScattered;
    });
  }

  void _setMode(bool ordered) {
    if (!_isScattered) return;
    if (_isOrdered == ordered) return;
    if (ordered) {
      _modeController.forward();
    } else {
      _modeController.reverse();
    }
    setState(() {
      _isOrdered = ordered;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // 增加一个返回按钮，允许回到首页重新输入
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black54),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      extendBodyBehindAppBar: true, // 让内容延伸到 AppBar 后面
      body: Stack(
        children: [
          Positioned.fill(
            child: AnimatedBuilder(
              animation: Listenable.merge(
                  [_mainAnimation, _modeAnimation, _rotateController]),
              builder: (context, child) {
                return CustomPaint(
                  painter: FinalPainter(
                    particles: _particles,
                    scatterProgress: _mainAnimation.value,
                    modeProgress: _modeAnimation.value,
                    rotation: _rotateController.value,
                  ),
                );
              },
            ),
          ),
          Positioned(
            bottom: 60,
            left: 0,
            right: 0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedOpacity(
                  opacity: _isScattered ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 300),
                  child: IgnorePointer(
                    ignoring: !_isScattered,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildModeButton("Chaos", false),
                          _buildModeButton("Ordered", true),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                GestureDetector(
                  onTap: _toggleScatter,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 36, vertical: 16),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 20,
                              offset: const Offset(0, 8))
                        ]),
                    child: Text(
                      _isScattered ? "CONNECT" : "SCAN QR",
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                          fontSize: 13),
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildModeButton(String title, bool isOrderedButton) {
    final bool isActive = _isOrdered == isOrderedButton;
    return GestureDetector(
      onTap: () => _setMode(isOrderedButton),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          boxShadow: isActive
              ? [
                  BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 4,
                      offset: const Offset(0, 2))
                ]
              : [],
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isActive ? Colors.black87 : Colors.grey[500],
          ),
        ),
      ),
    );
  }
}

class FinalPainter extends CustomPainter {
  final List<_Particle3D> particles;
  final double scatterProgress;
  final double modeProgress;
  final double rotation;

  FinalPainter({
    required this.particles,
    required this.scatterProgress,
    required this.modeProgress,
    required this.rotation,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()..isAntiAlias = true;
    final Offset center = Offset(size.width / 2, size.height / 2);
    const double focalLength = 1200.0;

    final double currentRotation = rotation * 2 * pi;
    const Color qrColor = Color(0xFF4A55A2);

    for (var p in particles) {
      double xScatter = ui.lerpDouble(p.xChaos, p.xOrdered, modeProgress)!;
      double zScatter = ui.lerpDouble(p.zChaos, p.zOrdered, modeProgress)!;
      double cosT = cos(currentRotation);
      double sinT = sin(currentRotation);
      p.zSort = xScatter * sinT + zScatter * cosT;
    }

    List<_Particle3D> drawList = List.from(particles);
    if (scatterProgress > 0.001) {
      drawList.sort((a, b) => a.zSort.compareTo(b.zSort));
    }

    for (var p in drawList) {
      double xScatter = ui.lerpDouble(p.xChaos, p.xOrdered, modeProgress)!;
      double yScatter = ui.lerpDouble(p.yChaos, p.yOrdered, modeProgress)!;
      double zScatter = ui.lerpDouble(p.zChaos, p.zOrdered, modeProgress)!;

      double cosT = cos(currentRotation);
      double sinT = sin(currentRotation);
      double xRot = xScatter * cosT - zScatter * sinT;
      double zRot = xScatter * sinT + zScatter * cosT;
      double yRot = yScatter;

      double t = scatterProgress;
      double currX = ui.lerpDouble(p.xQr, xRot, t)!;
      double currY = ui.lerpDouble(p.yQr, yRot, t)!;
      double zCurve = Curves.easeInQuad.transform(t);
      double currZ = ui.lerpDouble(0, zRot, zCurve)!;

      double perspective = focalLength / (focalLength + currZ);
      double screenX = center.dx + currX * perspective;
      double screenY = center.dy + currY * perspective;

      double chaosScale = p.isAvatarRandom ? 2.5 : 1.2;
      double orderedScale = 1.3;
      double targetScale3D =
          ui.lerpDouble(chaosScale, orderedScale, modeProgress)!;
      double baseScale = ui.lerpDouble(1.15, targetScale3D, t)!;
      double visualSize = p.size * baseScale * perspective;

      Color visualColor = Color.lerp(qrColor, p.color, t)!;
      if (t > 0.5) {
        double zNorm = zRot / 400.0;
        double opacity = 1.0;
        if (modeProgress > 0.5) {
          if (zNorm > 0) {
            opacity = (1.0 - zNorm * 2.0).clamp(0.05, 1.0);
          }
        } else {
          opacity = (1.0 - zNorm * 0.5).clamp(0.3, 1.0);
        }
        visualColor = visualColor.withValues(alpha: opacity);
      } else {
        visualColor = visualColor.withValues(alpha: 1.0);
      }

      paint.color = visualColor;
      canvas.drawCircle(Offset(screenX, screenY), visualSize / 2, paint);

      bool shouldShowAvatar = false;
      if (p.isAvatarRandom) shouldShowAvatar = true;
      if (modeProgress > 0.8) shouldShowAvatar = true;

      if (t > 0.6 && visualSize > 6 && shouldShowAvatar) {
        if (visualColor.a > 0.3) {
          Paint whitePaint = Paint()
            ..color = Colors.white.withValues(alpha: 0.9 * visualColor.a);
          canvas.drawCircle(Offset(screenX, screenY - visualSize * 0.12),
              visualSize * 0.22, whitePaint);
          Rect bodyRect = Rect.fromCenter(
              center: Offset(screenX, screenY + visualSize * 0.28),
              width: visualSize * 0.65,
              height: visualSize * 0.5);
          canvas.drawArc(bodyRect, pi, pi, true, whitePaint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant FinalPainter oldDelegate) {
    return true;
  }
}
