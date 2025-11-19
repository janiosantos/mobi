import 'package:flutter/material.dart';
import 'dart:async';

/// Emergency SOS button widget
/// Press and hold for 3 seconds to activate emergency mode
class SOSButton extends StatefulWidget {
  final VoidCallback onSOSActivated;
  final Duration holdDuration;
  final double size;
  final Color backgroundColor;
  final Color foregroundColor;
  final Color activeColor;
  final String label;
  final bool showLabel;

  const SOSButton({
    super.key,
    required this.onSOSActivated,
    this.holdDuration = const Duration(seconds: 3),
    this.size = 80.0,
    this.backgroundColor = Colors.red,
    this.foregroundColor = Colors.white,
    this.activeColor = Colors.redAccent,
    this.label = 'Emergência',
    this.showLabel = true,
  });

  @override
  State<SOSButton> createState() => _SOSButtonState();
}

class _SOSButtonState extends State<SOSButton>
    with SingleTickerProviderStateMixin {
  bool _isPressed = false;
  bool _isActivated = false;
  Timer? _holdTimer;
  double _progress = 0.0;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      ),
    );

    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _holdTimer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  void _onPressStart() {
    setState(() {
      _isPressed = true;
      _progress = 0.0;
    });

    // Start progress animation
    const stepDuration = Duration(milliseconds: 50);
    final totalSteps = widget.holdDuration.inMilliseconds ~/ stepDuration.inMilliseconds;
    int currentStep = 0;

    _holdTimer = Timer.periodic(stepDuration, (timer) {
      currentStep++;
      setState(() {
        _progress = currentStep / totalSteps;
      });

      if (currentStep >= totalSteps) {
        timer.cancel();
        _activateSOS();
      }
    });
  }

  void _onPressEnd() {
    setState(() {
      _isPressed = false;
      _progress = 0.0;
    });

    _holdTimer?.cancel();
  }

  void _activateSOS() {
    if (_isActivated) return;

    setState(() {
      _isActivated = true;
    });

    // Haptic feedback
    // HapticFeedback.heavyImpact(); // Uncomment if using services

    widget.onSOSActivated();

    // Show visual confirmation
    _showSOSDialog();
  }

  void _showSOSDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.red.shade900,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Icon(Icons.warning_rounded, color: widget.foregroundColor, size: 32),
            const SizedBox(width: 12),
            Text(
              'SOS ATIVADO',
              style: TextStyle(
                color: widget.foregroundColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Text(
          'Contatos de emergência foram notificados.\nSua localização está sendo compartilhada em tempo real.',
          style: TextStyle(
            color: widget.foregroundColor.withOpacity(0.9),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                _isActivated = false;
              });
            },
            child: Text(
              'OK',
              style: TextStyle(
                color: widget.foregroundColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTapDown: (_) => _onPressStart(),
          onTapUp: (_) => _onPressEnd(),
          onTapCancel: _onPressEnd,
          child: AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _isActivated ? _pulseAnimation.value : 1.0,
                child: Container(
                  width: widget.size,
                  height: widget.size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _isActivated
                        ? widget.activeColor
                        : widget.backgroundColor,
                    boxShadow: [
                      BoxShadow(
                        color: (_isActivated ? widget.activeColor : widget.backgroundColor)
                            .withOpacity(0.5),
                        blurRadius: _isActivated ? 20 : 10,
                        spreadRadius: _isActivated ? 5 : 2,
                      ),
                    ],
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Progress indicator
                      if (_isPressed && !_isActivated)
                        CircularProgressIndicator(
                          value: _progress,
                          strokeWidth: 6,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            widget.foregroundColor,
                          ),
                          backgroundColor: widget.foregroundColor.withOpacity(0.3),
                        ),

                      // Icon
                      Icon(
                        _isActivated ? Icons.warning_rounded : Icons.sos_rounded,
                        color: widget.foregroundColor,
                        size: widget.size * 0.5,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        if (widget.showLabel && !_isActivated) ...[
          const SizedBox(height: 8),
          Text(
            _isPressed ? 'Segure...' : widget.label,
            style: TextStyle(
              color: widget.backgroundColor,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
        if (_isActivated) ...[
          const SizedBox(height: 8),
          Text(
            'SOS ATIVO',
            style: TextStyle(
              color: widget.activeColor,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ],
    );
  }
}

/// Compact SOS button for app bars or floating action buttons
class CompactSOSButton extends StatelessWidget {
  final VoidCallback onPressed;
  final double size;
  final Color color;

  const CompactSOSButton({
    super.key,
    required this.onPressed,
    this.size = 48.0,
    this.color = Colors.red,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Row(
                children: [
                  Icon(Icons.warning_rounded, color: Colors.red),
                  SizedBox(width: 12),
                  Text('Confirmar Emergência'),
                ],
              ),
              content: const Text(
                'Tem certeza que deseja ativar o modo de emergência?\n\nSeus contatos serão notificados e sua localização será compartilhada.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    onPressed();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Ativar SOS'),
                ),
              ],
            ),
          );
        },
        borderRadius: BorderRadius.circular(size / 2),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
          ),
          child: Icon(
            Icons.sos_rounded,
            color: Colors.white,
            size: size * 0.5,
          ),
        ),
      ),
    );
  }
}
