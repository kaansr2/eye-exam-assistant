import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../config/app_config.dart';

/// Ses kayıt butonu widget'ı - Animasyonlu ve haptic feedback destekli
class VoiceInputButton extends StatefulWidget {
  final VoidCallback? onStartRecording;
  final VoidCallback? onStopRecording;
  final VoidCallback? onLongPressStart;
  final VoidCallback? onLongPressEnd;
  final bool isRecording;
  final double size;
  final Color? activeColor;
  final Color? inactiveColor;
  final bool enableHaptics;

  const VoiceInputButton({
    super.key,
    this.onStartRecording,
    this.onStopRecording,
    this.onLongPressStart,
    this.onLongPressEnd,
    this.isRecording = false,
    this.size = 80,
    this.activeColor,
    this.inactiveColor,
    this.enableHaptics = true,
  });

  @override
  State<VoiceInputButton> createState() => _VoiceInputButtonState();
}

class _VoiceInputButtonState extends State<VoiceInputButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.1, curve: Curves.easeOut),
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
    _triggerHaptic();
    if (widget.isRecording) {
      widget.onStopRecording?.call();
    } else {
      widget.onStartRecording?.call();
    }
  }

  void _handleLongPressStart() {
    _triggerHaptic(heavy: true);
    widget.onLongPressStart?.call();
  }

  void _handleLongPressEnd() {
    _triggerHaptic();
    widget.onLongPressEnd?.call();
  }

  void _triggerHaptic({bool heavy = false}) {
    if (!widget.enableHaptics) return;
    
    if (heavy) {
      HapticFeedback.heavyImpact();
    } else {
      HapticFeedback.mediumImpact();
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
          animation: _animationController,
          builder: (context, child) {
            return Transform.scale(
              scale: widget.isRecording ? _pulseAnimation.value : _scaleAnimation.value,
              child: child,
            );
          },
          child: GestureDetector(
            onTap: _handleTap,
            onLongPressStart: widget.onLongPressStart != null 
                ? (_) => _handleLongPressStart() 
                : null,
            onLongPressEnd: widget.onLongPressEnd != null 
                ? (_) => _handleLongPressEnd() 
                : null,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
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
        AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 200),
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: widget.isRecording ? activeColor : inactiveColor,
          ),
          child: Text(
            widget.isRecording ? 'Kaydı Durdur' : 'Kayda Başla',
          ),
        ),
      ],
    );
  }
}

/// Dalga animasyonu ile ses kayıt butonu - Gelişmiş versiyon
class AnimatedVoiceButton extends StatefulWidget {
  final VoidCallback? onStartRecording;
  final VoidCallback? onStopRecording;
  final VoidCallback? onLongPressStart;
  final VoidCallback? onLongPressEnd;
  final bool isRecording;
  final double size;
  final bool enableHaptics;
  final String? currentText;

  const AnimatedVoiceButton({
    super.key,
    this.onStartRecording,
    this.onStopRecording,
    this.onLongPressStart,
    this.onLongPressEnd,
    this.isRecording = false,
    this.size = 100,
    this.enableHaptics = true,
    this.currentText,
  });

  @override
  State<AnimatedVoiceButton> createState() => _AnimatedVoiceButtonState();
}

class _AnimatedVoiceButtonState extends State<AnimatedVoiceButton>
    with TickerProviderStateMixin {
  late AnimationController _waveController;
  late AnimationController _pulseController;
  late List<Animation<double>> _waveAnimations;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    
    // Dalga animasyonu
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

    // Pulse animasyonu
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      ),
    );

    _pulseController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _pulseController.reverse();
      } else if (status == AnimationStatus.dismissed && widget.isRecording) {
        _pulseController.forward();
      }
    });
  }

  @override
  void didUpdateWidget(AnimatedVoiceButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isRecording && !_waveController.isAnimating) {
      _waveController.repeat();
      _pulseController.forward();
    } else if (!widget.isRecording) {
      _waveController.stop();
      _waveController.reset();
      _pulseController.stop();
      _pulseController.reset();
    }
  }

  @override
  void dispose() {
    _waveController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _handleTap() {
    _triggerHaptic();
    if (widget.isRecording) {
      widget.onStopRecording?.call();
    } else {
      widget.onStartRecording?.call();
    }
  }

  void _handleLongPressStart() {
    _triggerHaptic(heavy: true);
    widget.onLongPressStart?.call();
  }

  void _handleLongPressEnd() {
    _triggerHaptic();
    widget.onLongPressEnd?.call();
  }

  void _triggerHaptic({bool heavy = false}) {
    if (!widget.enableHaptics) return;
    
    if (heavy) {
      HapticFeedback.heavyImpact();
    } else {
      HapticFeedback.mediumImpact();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Anlık transkripsiyon göstergesi
        if (widget.isRecording && widget.currentText != null && widget.currentText!.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppConfig.primaryColor.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.hearing, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    widget.currentText!,
                    style: const TextStyle(
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                      color: Colors.grey,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),

        // Buton
        GestureDetector(
          onTap: _handleTap,
          onLongPressStart: widget.onLongPressStart != null 
              ? (_) => _handleLongPressStart() 
              : null,
          onLongPressEnd: widget.onLongPressEnd != null 
              ? (_) => _handleLongPressEnd() 
              : null,
          child: SizedBox(
            width: widget.size * 1.6,
            height: widget.size * 1.6,
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
                AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: widget.isRecording ? _pulseAnimation.value : 1.0,
                      child: child,
                    );
                  },
                  child: Container(
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
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 8),

        // Durum metni
        Text(
          widget.isRecording ? 'Kaydı Durdur' : 'Kayda Başla',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: widget.isRecording ? AppConfig.errorColor : AppConfig.primaryColor,
          ),
        ),

        // İpucu metni
        if (!widget.isRecording)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              'Mikrofona basarak konuşmaya başlayın',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ),
      ],
    );
  }
}
