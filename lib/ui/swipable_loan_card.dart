import 'package:flutter/material.dart';

import '../loans/loan.dart';
import 'loan_card_widget.dart';

/// Wraps a [LoanCardWidget] with physics-based drag-to-swipe mechanics.
/// Swiping left = TAKE, swiping right = REFUSE.
class SwipableLoanCard extends StatefulWidget {
  const SwipableLoanCard({
    super.key,
    required this.loan,
    required this.offerIndex,
    required this.totalOffers,
    required this.onTake,
    required this.onRefuse,
    this.swipeThreshold = 90.0,
    this.animationDuration = const Duration(milliseconds: 180),
  });

  final Loan loan;
  final int offerIndex;
  final int totalOffers;
  final VoidCallback onTake;
  final VoidCallback onRefuse;
  final double swipeThreshold;
  final Duration animationDuration;

  @override
  State<SwipableLoanCard> createState() => SwipableLoanCardState();
}

class SwipableLoanCardState extends State<SwipableLoanCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  Animation<Offset>? _offsetAnim;
  Animation<double>? _angleAnim;

  Offset _dragOffset = Offset.zero;
  bool _isDismissed = false;

  double get dragProgress =>
      (_dragOffset.dx / widget.swipeThreshold).clamp(-1.0, 1.0);

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    );
  }

  @override
  void didUpdateWidget(SwipableLoanCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.loan.id != widget.loan.id) {
      _dragOffset = Offset.zero;
      _isDismissed = false;
      _animController.reset();
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _onPanStart(DragStartDetails details) {
    if (_isDismissed) return;
    _animController.stop();
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (_isDismissed) return;
    setState(() {
      _dragOffset += details.delta;
    });
  }

  void _onPanEnd(DragEndDetails details) {
    if (_isDismissed) return;

    final vx = details.velocity.pixelsPerSecond.dx;
    if (_dragOffset.dx <= -widget.swipeThreshold || vx < -350) {
      // Swiped Left -> TAKE
      dismissLeft();
    } else if (_dragOffset.dx >= widget.swipeThreshold || vx > 350) {
      // Swiped Right -> REFUSE
      dismissRight();
    } else {
      // Spring back to center
      _springBack();
    }
  }

  void _springBack() {
    final startOffset = _dragOffset;
    final startAngle = _calculateAngle(startOffset.dx);

    _offsetAnim = Tween<Offset>(
      begin: startOffset,
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutQuad,
    ));

    _angleAnim = Tween<double>(
      begin: startAngle,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutQuad,
    ));

    _animController.reset();
    _animController.forward().then((_) {
      if (mounted) {
        setState(() {
          _dragOffset = Offset.zero;
        });
      }
    });
  }

  /// Programmatically triggers the left-swipe (TAKE) dismiss animation.
  void dismissLeft() {
    if (_isDismissed) return;
    _isDismissed = true;

    final startOffset = _dragOffset;
    final targetOffset = Offset(-MediaQuery.of(context).size.width * 1.3, _dragOffset.dy);
    final startAngle = _calculateAngle(startOffset.dx);
    final targetAngle = -0.3;

    _animateDismiss(
      startOffset: startOffset,
      targetOffset: targetOffset,
      startAngle: startAngle,
      targetAngle: targetAngle,
      onComplete: widget.onTake,
    );
  }

  /// Programmatically triggers the right-swipe (REFUSE) dismiss animation.
  void dismissRight() {
    if (_isDismissed) return;
    _isDismissed = true;

    final startOffset = _dragOffset;
    final targetOffset = Offset(MediaQuery.of(context).size.width * 1.3, _dragOffset.dy);
    final startAngle = _calculateAngle(startOffset.dx);
    final targetAngle = 0.3;

    _animateDismiss(
      startOffset: startOffset,
      targetOffset: targetOffset,
      startAngle: startAngle,
      targetAngle: targetAngle,
      onComplete: widget.onRefuse,
    );
  }

  void _animateDismiss({
    required Offset startOffset,
    required Offset targetOffset,
    required double startAngle,
    required double targetAngle,
    required VoidCallback onComplete,
  }) {
    _offsetAnim = Tween<Offset>(
      begin: startOffset,
      end: targetOffset,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutQuad,
    ));

    _angleAnim = Tween<double>(
      begin: startAngle,
      end: targetAngle,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutQuad,
    ));

    _animController.reset();
    _animController.forward().then((_) {
      if (mounted) {
        onComplete();
      }
    });
  }

  double _calculateAngle(double dx) {
    // Subtle rotation based on drag offset
    return (dx / 900.0).clamp(-0.25, 0.25);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animController,
      builder: (context, child) {
        final currentOffset = _animController.isAnimating && _offsetAnim != null
            ? _offsetAnim!.value
            : _dragOffset;

        final currentAngle = _animController.isAnimating && _angleAnim != null
            ? _angleAnim!.value
            : _calculateAngle(currentOffset.dx);

        return Transform.translate(
          offset: Offset(currentOffset.dx, currentOffset.dy * 0.3),
          child: Transform.rotate(
            angle: currentAngle,
            alignment: Alignment.bottomCenter,
            child: GestureDetector(
              onPanStart: (d) => _onPanStart(d),
              onPanUpdate: _onPanUpdate,
              onPanEnd: _onPanEnd,
              child: LoanCardWidget(
                loan: widget.loan,
                offerIndex: widget.offerIndex,
                totalOffers: widget.totalOffers,
              ),
            ),
          ),
        );
      },
    );
  }
}
