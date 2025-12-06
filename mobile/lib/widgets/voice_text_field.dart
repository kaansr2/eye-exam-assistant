import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/app_config.dart';
import '../providers/speech_provider.dart';

/// TextField with integrated voice input button
/// Combines text editing with speech-to-text capability
class VoiceTextField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final int maxLines;
  final bool enabled;
  final bool appendMode; // true: append to existing text, false: replace
  final ValueChanged<String>? onChanged;

  const VoiceTextField({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
    this.maxLines = 1,
    this.enabled = true,
    this.appendMode = true,
    this.onChanged,
  });

  @override
  State<VoiceTextField> createState() => _VoiceTextFieldState();
}

class _VoiceTextFieldState extends State<VoiceTextField> {
  bool _isRecording = false;
  String _recordingText = '';

  @override
  void dispose() {
    // Stop recording if still active
    if (_isRecording) {
      _stopRecording();
    }
    super.dispose();
  }

  /// Start voice recording
  Future<void> _startRecording() async {
    final speechProvider = context.read<SpeechProvider>();
    
    if (!speechProvider.isInitialized) {
      await speechProvider.initialize();
    }

    if (!speechProvider.isAvailable) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ses tanıma kullanılamıyor'),
            backgroundColor: AppConfig.errorColor,
          ),
        );
      }
      return;
    }

    setState(() {
      _isRecording = true;
      _recordingText = '';
    });

    await speechProvider.startListening();
  }

  /// Stop voice recording
  Future<void> _stopRecording() async {
    final speechProvider = context.read<SpeechProvider>();
    await speechProvider.stopListening();

    // Get the final transcript
    final transcript = speechProvider.fullTranscription;
    
    if (transcript.isNotEmpty) {
      setState(() {
        if (widget.appendMode) {
          // Append to existing text
          final currentText = widget.controller.text;
          final separator = currentText.isEmpty ? '' : '\n';
          widget.controller.text = currentText + separator + transcript;
        } else {
          // Replace existing text
          widget.controller.text = transcript;
        }
      });

      // Call onChanged callback
      widget.onChanged?.call(widget.controller.text);

      // Clear the speech provider transcript for next use
      speechProvider.clearTranscription();
    }

    setState(() {
      _isRecording = false;
      _recordingText = '';
    });
  }

  /// Toggle recording
  Future<void> _toggleRecording() async {
    if (_isRecording) {
      await _stopRecording();
    } else {
      await _startRecording();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Text field with voice button
        TextField(
          controller: widget.controller,
          maxLines: widget.maxLines,
          enabled: widget.enabled && !_isRecording,
          decoration: InputDecoration(
            labelText: widget.label,
            hintText: widget.hint,
            border: const OutlineInputBorder(),
            suffixIcon: _buildVoiceButton(),
          ),
          onChanged: widget.onChanged,
        ),

        // Recording indicator
        if (_isRecording) _buildRecordingIndicator(),
      ],
    );
  }

  /// Build voice input button
  Widget _buildVoiceButton() {
    return Consumer<SpeechProvider>(
      builder: (context, speechProvider, _) {
        final isListening = speechProvider.isListening;
        
        return IconButton(
          icon: Icon(
            isListening ? Icons.mic : Icons.mic_none,
            color: isListening ? AppConfig.errorColor : AppConfig.primaryColor,
          ),
          onPressed: widget.enabled ? _toggleRecording : null,
          tooltip: isListening ? 'Kaydı Durdur' : 'Sesle Ekle',
        );
      },
    );
  }

  /// Build recording indicator
  Widget _buildRecordingIndicator() {
    return Consumer<SpeechProvider>(
      builder: (context, speechProvider, _) {
        return Container(
          margin: const EdgeInsets.only(top: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppConfig.errorColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppConfig.errorColor.withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Recording indicator
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppConfig.errorColor,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Dinleniyor... ${speechProvider.formattedDuration}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppConfig.errorColor,
                    ),
                  ),
                  const Spacer(),
                  // Stop button
                  TextButton.icon(
                    onPressed: _stopRecording,
                    icon: const Icon(Icons.stop, size: 16),
                    label: const Text('Durdur'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppConfig.errorColor,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                  ),
                ],
              ),
              
              // Current text being recognized
              if (speechProvider.currentText.isNotEmpty) ...[
                const SizedBox(height: 8),
                const Divider(),
                const SizedBox(height: 8),
                Text(
                  speechProvider.currentText,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],

              // Full transcription preview
              if (speechProvider.fullTranscription.isNotEmpty) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    speechProvider.fullTranscription,
                    style: const TextStyle(fontSize: 12),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
