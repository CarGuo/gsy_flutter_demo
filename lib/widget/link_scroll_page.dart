import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class LinkListViewPage extends StatefulWidget {
  const LinkListViewPage({super.key});

  @override
  LinkListViewPageState createState() => LinkListViewPageState();
}

class LinkListViewPageState extends State<LinkListViewPage> {
  final ScrollController _leftController = ScrollController();
  final ScrollController _rightController = ScrollController();
  final List<double> _itemOffsets = [];
  final List<double> _itemHeights = [];
  int _selectedIndex = 0;
  final List<GlobalKey> _itemKeys = List.generate(20, (_) => GlobalKey());

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _calculateItemOffsets();
    });
    _rightController.addListener(_handleRightScroll);
  }

  void _calculateItemOffsets() {
    _itemOffsets.clear();
    _itemHeights.clear();
    double offset = 0;
    for (var key in _itemKeys) {
      final context = key.currentContext;
      if (context != null) {
        final RenderBox? box = context.findRenderObject() as RenderBox?;
        if (box != null && box.hasSize) {
          _itemHeights.add(box.size.height);
          _itemOffsets.add(offset);
          offset += box.size.height;
        } else {
          // Fallback height if not rendered
          _itemHeights.add(100.0); // Use minimum height as fallback
          _itemOffsets.add(offset);
          offset += 100.0;
        }
      } else {
        // Fallback for unrendered items
        _itemHeights.add(100.0);
        _itemOffsets.add(offset);
        offset += 100.0;
      }
    }
    if (kDebugMode) {
      print('Offsets: $_itemOffsets, Heights: $_itemHeights');
    } // Debug
    setState(() {});
  }

  void _handleRightScroll() {
    if (_itemOffsets.isEmpty) return;
    final scrollPosition = _rightController.offset;
    int newIndex = 0;
    if (_itemOffsets.length == 1) {
      newIndex = 0;
    } else {
      for (int i = 0; i < _itemOffsets.length - 1; i++) {
        if (scrollPosition >= _itemOffsets[i] &&
            scrollPosition < _itemOffsets[i + 1]) {
          newIndex = i;
          break;
        }
      }
      if (scrollPosition >= _itemOffsets.last) {
        newIndex = _itemOffsets.length - 1;
      }
    }
    if (newIndex != _selectedIndex) {
      setState(() {
        _selectedIndex = newIndex;
      });
      _scrollToSelectedLeftItem();
    }
  }

  void _scrollToSelectedLeftItem() {
    if (_leftController.hasClients) {
      const itemExtent = 60.0;
      final targetOffset = _selectedIndex * itemExtent;
      final maxOffset = _leftController.position.maxScrollExtent;
      _leftController.animateTo(
        targetOffset.clamp(0.0, maxOffset),
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _onLeftItemTap(int index) {
    setState(() {
      _selectedIndex = index;
    });
    if (_itemOffsets.length <= index) {
      // Retry calculating offsets if not enough data
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _calculateItemOffsets();
        // Retry scrolling after offsets are recalculated
        if (_itemOffsets.length > index && _rightController.hasClients) {
          final targetOffset = _itemOffsets[index].clamp(
            0.0,
            _rightController.position.maxScrollExtent,
          );
          _rightController.animateTo(
            targetOffset,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        }
      });
      return;
    }
    if (_rightController.hasClients) {
      final targetOffset = _itemOffsets[index].clamp(
        0.0,
        _rightController.position.maxScrollExtent,
      );
      _rightController.animateTo(
        targetOffset,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dual ListView Demo')),
      body: Row(
        children: [
          Expanded(
            flex: 1,
            child: Container(
              color: Colors.grey[200],
              child: ListView.builder(
                controller: _leftController,
                itemCount: 20,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () => _onLeftItemTap(index),
                    child: Container(
                      height: 60,
                      color: _selectedIndex == index
                          ? Colors.blue[100]
                          : Colors.transparent,
                      child: Center(
                        child: Text(
                          'Item $index',
                          style: TextStyle(
                            fontWeight: _selectedIndex == index
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: ListView.builder(
              controller: _rightController,
              itemCount: 20,
              itemBuilder: (context, index) {
                final height = 100.0 + (index % 5) * 50.0;
                return Container(
                  key: _itemKeys[index],
                  height: height,
                  color: index % 2 == 0 ? Colors.white : Colors.grey[100],
                  child: Center(
                    child: Text(
                      'Content $index',
                      style: const TextStyle(fontSize: 18),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _leftController.dispose();
    _rightController.dispose();
    super.dispose();
  }
}
