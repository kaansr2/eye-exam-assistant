import 'package:flutter/material.dart';
import '../config/app_config.dart';

/// Ses kayıt butonu widget'ı
class VoiceInputButton extends StatefulWidget {
  final VoidCallback? onStartRecording;
  final VoidCallback? onStopRecording;
  final bool isRecording;
  final double size;
  final Color? activeColor;
  final Color? inactiveColor;

  const VoiceInputButton({
    super.key,
    this.onStartRecording,
    this.onStopRecording,
    this.isRecording = false,
    this.size = 80,
    this.activeColor,
    this.inactiveColor,
  });

  @override
  State<VoiceInputButton> createState() => _VoiceInputButtonState();
}

class _VoiceInputButtonState extends State<VoiceInputButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _animationController.reverse();
      } else if (status == AnimationStatus.dismissed) {
        if (widget.isRecording) {
          _animationController.forward();
        }
      }
    });
  }

  @override
  void didUpdateWidget(VoiceInputButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isRecording && !oldWidget.isRecording) {
      _animationController.forward();
    } else if (!widget.isRecording && oldWidget.isRecording) {
      _animationController.stop();
      _animationController.reset();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleTap() {
    if (widget.isRecording) {
      widget.onStopRecording?.call();
    } else {
      widget.onStartRecording?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    final activeColor = widget.activeColor ?? AppConfig.errorColor;
    final inactiveColor = widget.inactiveColor ?? AppConfig.primaryColor;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Ana buton
        AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: widget.isRecording ? _pulseAnimation.value : 1.0,
              child: child,
            );
          },
          child: GestureDetector(
            onTap: _handleTap,
            child: Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.isRecording ? activeColor : inactiveColor,
                boxShadow: [
                  BoxShadow(
                    color: (widget.isRecording ? activeColor : inactiveColor)
                        .withOpacity(0.3),
                    spreadRadius: widget.isRecording ? 8 : 4,
                    blurRadius: widget.isRecording ? 16 : 8,
                  ),
                ],
              ),
              child: Icon(
                widget.isRecording ? Icons.stop : Icons.mic,
                size: widget.size * 0.5,
                color: Colors.white,
              ),
            ),
          ),
        ),

        const SizedBox(height: 12),

        // Durum metni
        Text(
          widget.isRecording ? 'Kaydı Durdur' : 'Kayda Başla',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: widget.isRecording ? activeColor : inactiveColor,
          ),
        ),
      ],
    );
  }
}

/// Dalga animasyonu ile ses kayıt butonu
class AnimatedVoiceButton extends StatefulWidget {
  final VoidCallback? onStartRecording;
  final VoidCallback? onStopRecording;
  final bool isRecording;
  final double size;

  const AnimatedVoiceButton({
    super.key,
    this.onStartRecording,
    this.onStopRecording,
    this.isRecording = false,
    this.size = 100,
  });

  @override
  State<AnimatedVoiceButton> createState() => _AnimatedVoiceButtonState();
}

class _AnimatedVoiceButtonState extends State<AnimatedVoiceButton>
    with TickerProviderStateMixin {
  late AnimationController _waveController;
  late List<Animation<double>> _waveAnimations;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _waveAnimations = List.generate(3, (index) {
      final start = index * 0.2;
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _waveController,
          curve: Interval(start, start + 0.6, curve: Curves.easeOut),
        ),
      );
    });
  }

  @override
  void didUpdateWidget(AnimatedVoiceButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isRecording && !_waveController.isAnimating) {
      _waveController.repeat();
    } else if (!widget.isRecording) {
      _waveController.stop();
      _waveController.reset();
    }
  }

  @override
  void dispose() {
    _waveController.dispose();
    super.dispose();
  }

  void _handleTap() {
    if (widget.isRecording) {
      widget.onStopRecording?.call();
    } else {
      widget.onStartRecording?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: SizedBox(
        width: widget.size * 1.5,
        height: widget.size * 1.5,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Dalga animasyonları
            if (widget.isRecording)
              ...List.generate(3, (index) {
                return AnimatedBuilder(
                  animation: _waveAnimations[index],
                  builder: (context, child) {
                    return Container(
                      width: widget.size + (_waveAnimations[index].value * 60),
                      height: widget.size + (_waveAnimations[index].value * 60),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppConfig.errorColor.withOpacity(
                            (1 - _waveAnimations[index].value) * 0.5,
                          ),
                          width: 2,
                        ),
                      ),
                    );
                  },
                );
              }),

            // Ana buton
            Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.isRecording
                    ? AppConfig.errorColor
                    : AppConfig.primaryColor,
                boxShadow: [
                  BoxShadow(
                    color: (widget.isRecording
                            ? AppConfig.errorColor
                            : AppConfig.primaryColor)
                        .withOpacity(0.3),
                    spreadRadius: 4,
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Icon(
                widget.isRecording ? Icons.stop : Icons.mic,
                size: widget.size * 0.45,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
