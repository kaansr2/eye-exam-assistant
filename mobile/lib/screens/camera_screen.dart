import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../config/app_config.dart';
import '../utils/constants.dart';
import '../providers/examination_provider.dart';

/// Kamera ekranı - Göz fotoğrafı çekme
class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  String _selectedEye = 'right'; // 'right', 'left', 'both'
  bool _isCameraReady = false;
  bool _isCapturing = false;
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  /// Kamera başlatma
  Future<void> _initializeCamera() async {
    // TODO: Kamera servisini başlat
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) {
      setState(() {
        _isCameraReady = true;
      });
    }
  }

  @override
  void dispose() {
    // TODO: Kamera servisini temizle
    super.dispose();
  }

  /// Fotoğraf çek
  Future<void> _captureImage() async {
    if (_isCapturing) return;

    setState(() {
      _isCapturing = true;
    });

    try {
      // Take photo with camera
      final XFile? photo = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );

      if (photo != null) {
        final examinationProvider = context.read<ExaminationProvider>();
        examinationProvider.addEyeImage({
          'eye': _selectedEye,
          'path': photo.path,
          'timestamp': DateTime.now().toIso8601String(),
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${_getEyeLabel(_selectedEye)} fotoğrafı çekildi'),
              backgroundColor: AppConfig.successColor,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Fotoğraf çekilemedi: $e'),
            backgroundColor: AppConfig.errorColor,
          ),
        );
      }
    } finally {
      setState(() {
        _isCapturing = false;
      });
    }
  }

  /// Galeriden fotoğraf seç
  Future<void> _pickFromGallery() async {
    if (_isCapturing) return;

    setState(() {
      _isCapturing = true;
    });

    try {
      // Pick image from gallery
      final XFile? photo = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (photo != null) {
        final examinationProvider = context.read<ExaminationProvider>();
        examinationProvider.addEyeImage({
          'eye': _selectedEye,
          'path': photo.path,
          'timestamp': DateTime.now().toIso8601String(),
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${_getEyeLabel(_selectedEye)} fotoğrafı eklendi'),
              backgroundColor: AppConfig.successColor,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Fotoğraf seçilemedi: $e'),
            backgroundColor: AppConfig.errorColor,
          ),
        );
      }
    } finally {
      setState(() {
        _isCapturing = false;
      });
    }
  }

  /// Çekilen fotoğrafı sil
  void _deleteImage(int index) {
    context.read<ExaminationProvider>().removeEyeImage(index);
  }

  /// Fotoğrafları atla ve devam et
  void _skipPhotos() {
    // Simply proceed to review without photos
    Navigator.pushNamed(context, '/review');
  }

  /// Onay ekranına git
  void _proceedToReview() {
    Navigator.pushNamed(context, '/review');
  }

  /// Göz etiketi al
  String _getEyeLabel(String eye) {
    switch (eye) {
      case 'right':
        return Constants.rightEye;
      case 'left':
        return Constants.leftEye;
      case 'both':
        return Constants.bothEyes;
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ExaminationProvider>(
      builder: (context, examinationProvider, _) {
        final capturedImages = examinationProvider.eyeImages;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Göz Fotoğrafı'),
            actions: [
              // Always show skip button
              TextButton.icon(
                onPressed: _proceedToReview,
                icon: const Icon(Icons.arrow_forward),
                label: Text(capturedImages.isNotEmpty ? 'İleri' : 'Atla'),
              ),
            ],
          ),
          body: SafeArea(
            child: Column(
              children: [
                // Kamera önizleme alanı
                Expanded(
                  flex: 3,
                  child: _buildCameraPreview(),
                ),
                
                // Göz seçimi ve kontroller
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(AppConfig.defaultPadding),
                    child: Column(
                      children: [
                        // Göz seçimi
                        _buildEyeSelector(),
                        
                        const SizedBox(height: AppConfig.defaultPadding),
                        
                        // Çekilen fotoğraflar
                        if (capturedImages.isNotEmpty)
                          Expanded(
                            child: _buildCapturedImagesList(capturedImages),
                          )
                        else
                          Expanded(
                            child: Center(
                              child: Text(
                                'Henüz fotoğraf çekilmedi',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                ),
                              ),
                            ),
                          ),
                        
                        const SizedBox(height: AppConfig.defaultPadding),
                        
                        // Çekim butonu
                        _buildCaptureButtons(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Kamera önizleme
  Widget _buildCameraPreview() {
    if (!_isCameraReady) {
      return Container(
        color: Colors.black,
        child: const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    // TODO: Gerçek kamera önizlemesi ile değiştir
    return Container(
      color: Colors.black87,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.camera_alt_outlined,
              size: 80,
              color: Colors.grey[600],
            ),
            const SizedBox(height: 16),
            Text(
              'Kamera Önizlemesi',
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppConfig.primaryColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                _getEyeLabel(_selectedEye),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Göz seçici
  Widget _buildEyeSelector() {
    return Row(
      children: [
        Expanded(
          child: _buildEyeButton('right', Constants.rightEye, Icons.visibility),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildEyeButton('left', Constants.leftEye, Icons.visibility),
        ),
      ],
    );
  }

  /// Göz seçim butonu
  Widget _buildEyeButton(String eye, String label, IconData icon) {
    final isSelected = _selectedEye == eye;
    return OutlinedButton.icon(
      onPressed: () {
        setState(() {
          _selectedEye = eye;
        });
      },
      style: OutlinedButton.styleFrom(
        backgroundColor: isSelected ? AppConfig.primaryColor : Colors.transparent,
        foregroundColor: isSelected ? Colors.white : AppConfig.primaryColor,
        side: BorderSide(
          color: AppConfig.primaryColor,
          width: isSelected ? 2 : 1,
        ),
        padding: const EdgeInsets.symmetric(vertical: 12),
      ),
      icon: Icon(icon),
      label: Text(label),
    );
  }

  /// Çekilen fotoğraflar listesi
  Widget _buildCapturedImagesList(List<Map<String, dynamic>> images) {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: images.length,
      itemBuilder: (context, index) {
        final image = images[index];
        return Padding(
          padding: const EdgeInsets.only(right: 8),
          child: Stack(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.image, color: Colors.grey[600]),
                    const SizedBox(height: 4),
                    Text(
                      image['eye'] == 'right' ? 'OD' : 'OS',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[700],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 0,
                right: 0,
                child: GestureDetector(
                  onTap: () => _deleteImage(index),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: AppConfig.errorColor,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close,
                      size: 12,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Çekim butonları (kamera + galeri + atla)
  Widget _buildCaptureButtons() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Galeri butonu
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: ElevatedButton.icon(
                  onPressed: _isCapturing ? null : _pickFromGallery,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppConfig.primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    side: BorderSide(color: AppConfig.primaryColor),
                  ),
                  icon: const Icon(Icons.folder_open),
                  label: const Text('📁 Cihazdan Aktar'),
                ),
              ),
            ),
            
            // Kamera butonu
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: ElevatedButton.icon(
                  onPressed: _isCapturing ? null : _captureImage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppConfig.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  icon: _isCapturing
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.camera_alt),
                  label: const Text('📷 Kamera ile Çek'),
                ),
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 12),
        
        // Atla butonu
        TextButton(
          onPressed: _skipPhotos,
          child: const Text('Fotoğrafsız Devam Et'),
        ),
      ],
    );
  }
}
