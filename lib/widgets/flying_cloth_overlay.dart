import 'package:flutter/material.dart';

/// Manages a list of flying cloth emojis and runs them from source→target.
class FlyingClothOverlay extends StatefulWidget {
  final Widget child;

  const FlyingClothOverlay({super.key, required this.child});

  static FlyingClothOverlayState of(BuildContext context) =>
      context.findAncestorStateOfType<FlyingClothOverlayState>()!;

  @override
  State<FlyingClothOverlay> createState() => FlyingClothOverlayState();
}

class FlyingClothOverlayState extends State<FlyingClothOverlay> {
  final List<_FlyingItem> _items = [];
  int _nextId = 0;

  void fly({
    required GlobalKey fromKey,
    required GlobalKey toKey,
    required String emoji,
    VoidCallback? onLanded,
  }) {
    final fromBox =
        fromKey.currentContext?.findRenderObject() as RenderBox?;
    final toBox =
        toKey.currentContext?.findRenderObject() as RenderBox?;

    if (fromBox == null || toBox == null) {
      onLanded?.call();
      return;
    }

    final fromPos = fromBox.localToGlobal(
        Offset(fromBox.size.width / 2, fromBox.size.height / 2));
    final toPos = toBox.localToGlobal(
        Offset(toBox.size.width / 2, toBox.size.height / 2));

    final id = _nextId++;
    setState(() {
      _items.add(_FlyingItem(
        id: id,
        from: fromPos,
        to: toPos,
        emoji: emoji,
        onDone: () {
          setState(() {
            _items.removeWhere((i) => i.id == id);
          });
          onLanded?.call();
        },
      ));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        ..._items.map((item) => _FlyingAnimWidget(key: ValueKey(item.id), item: item)),
      ],
    );
  }
}

class _FlyingItem {
  final int id;
  final Offset from;
  final Offset to;
  final String emoji;
  final VoidCallback onDone;

  _FlyingItem({
    required this.id,
    required this.from,
    required this.to,
    required this.emoji,
    required this.onDone,
  });
}

class _FlyingAnimWidget extends StatefulWidget {
  final _FlyingItem item;

  const _FlyingAnimWidget({super.key, required this.item});

  @override
  State<_FlyingAnimWidget> createState() => _FlyingAnimWidgetState();
}

class _FlyingAnimWidgetState extends State<_FlyingAnimWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<Offset> _posAnim;
  late Animation<double> _scaleAnim;
  late Animation<double> _opacityAnim;
  late Animation<double> _rotAnim;

  @override
  void initState() {
    super.initState();

    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    final from = widget.item.from;
    final to = widget.item.to;

    // Arc path through a control point above midpoint
    final mid = Offset(
      (from.dx + to.dx) / 2,
      (from.dy + to.dy) / 2 - 120, // arc upward
    );

    _posAnim = TweenSequence<Offset>([
      TweenSequenceItem(
        tween: Tween(begin: from, end: mid)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween(begin: mid, end: to)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 50,
      ),
    ]).animate(_ctrl);

    _scaleAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.6), weight: 40),
      TweenSequenceItem(tween: Tween(begin: 1.6, end: 0.6), weight: 60),
    ]).animate(_ctrl);

    _opacityAnim = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _ctrl, curve: const Interval(0.7, 1.0)),
    );

    _rotAnim = Tween<double>(begin: 0, end: 2.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );

    _ctrl.forward().then((_) => widget.item.onDone());
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, child) {
        return Positioned(
          left: _posAnim.value.dx - 24,
          top: _posAnim.value.dy - 24,
          child: Transform.scale(
            scale: _scaleAnim.value,
            child: Transform.rotate(
              angle: _rotAnim.value,
              child: Opacity(
                opacity: _opacityAnim.value.clamp(0.0, 1.0),
                child: Text(
                  widget.item.emoji,
                  style: const TextStyle(fontSize: 48),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
