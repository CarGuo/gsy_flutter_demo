import 'package:flutter/material.dart';
import 'dart:ui';
import 'dart:math' as math;

class GlassDemoPage extends StatefulWidget {
  const GlassDemoPage({super.key});

  @override
  State<GlassDemoPage> createState() => _GlassDemoPageState();
}

class _GlassDemoPageState extends State<GlassDemoPage>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _floatingController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();

    _floatingController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _floatingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF667eea),
              Color(0xFF764ba2),
              Color(0xFFf093fb),
              Color(0xFFf5576c),
            ],
          ),
        ),
        child: Stack(
          children: [
            // 背景动态气泡
            ...List.generate(6, (index) => _buildFloatingBubble(index)),

            // 主要内容
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 大的玻璃卡片
                  _buildGlassCard(
                    width: 320,
                    height: 200,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.wb_sunny_outlined,
                          size: 48,
                          color: Colors.white.withAlpha(220),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '毛玻璃效果',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                            color: Colors.white.withAlpha(220),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Flutter Glass',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white.withAlpha(200),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  // 小的玻璃按钮组
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildGlassButton(
                        icon: Icons.favorite,
                        onTap: () => _showGlassDialog(context),
                      ),
                      const SizedBox(width: 20),
                      _buildGlassButton(
                        icon: Icons.star,
                        onTap: () => _showGlassBottomSheet(context),
                      ),
                      const SizedBox(width: 20),
                      _buildGlassButton(
                        icon: Icons.share,
                        onTap: () {},
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGlassCard({
    required double width,
    required double height,
    required Widget child,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withAlpha(55),
          width: 1.5,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withAlpha(65),
                  Colors.white.withAlpha(25),
                ],
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }

  Widget _buildGlassButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white.withAlpha(55),
            width: 1,
          ),
        ),
        child: ClipOval(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    Colors.white.withAlpha(75),
                    Colors.white.withAlpha(25),
                  ],
                ),
              ),
              child: Icon(
                icon,
                color: Colors.white.withAlpha(220),
                size: 24,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingBubble(int index) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        final offset =
            math.sin(_animationController.value * 2 * math.pi + index) * 50;
        final size = 80.0 +
            math.sin(_animationController.value * 2 * math.pi + index) * 20;

        return Positioned(
          left: 50.0 + index * 60 + offset,
          top: 100.0 + index * 100 + offset,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  Colors.white.withAlpha(25),
                  Colors.white.withAlpha(2),
                ],
              ),
            ),
            child: ClipOval(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withAlpha(25),
                      width: 1,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showGlassDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withAlpha(75),
      builder: (context) => Center(
        child: _buildGlassCard(
            width: 280,
            height: 180,
            child: Material(
              color: Colors.transparent,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.check_circle_outline,
                      size: 48,
                      color: Colors.white.withAlpha(220),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '玻璃对话框',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.white.withAlpha(220),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '这是一个玻璃材质的对话框',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withAlpha(200),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            )),
      ),
    );
  }

  void _showGlassBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: 300,
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          border: Border.all(
            color: Colors.white.withAlpha(55),
            width: 1,
          ),
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withAlpha(60),
                    Colors.white.withAlpha(25),
                  ],
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(130),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      '玻璃底部弹窗',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.white.withAlpha(220),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Expanded(
                      child: ListView.builder(
                        itemCount: 5,
                        itemBuilder: (context, index) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.white.withAlpha(25),
                                width: 1,
                              ),
                              gradient: LinearGradient(
                                colors: [
                                  Colors.white.withAlpha(35),
                                  Colors.white.withAlpha(5),
                                ],
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.list,
                                  color: Colors.white.withAlpha(210),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  '选项 ${index + 1}',
                                  style: TextStyle(
                                    color: Colors.white.withAlpha(220),
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
