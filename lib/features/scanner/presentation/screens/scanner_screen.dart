import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import '../../domain/models/qr_type.dart';
import '../../../history/presentation/providers/history_provider.dart';
import '../../../settings/presentation/providers/settings_provider.dart';
import '../widgets/scan_overlay.dart';
import '../widgets/scan_result_sheet.dart';
import '../../../../app/theme/app_colors.dart';

class ScannerScreen extends ConsumerStatefulWidget {
  const ScannerScreen({super.key});

  @override
  ConsumerState<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends ConsumerState<ScannerScreen> {
  final MobileScannerController _controller = MobileScannerController();
  bool _torchOn = false;
  bool _processing = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) async {
    if (_processing) return;
    final raw = capture.barcodes.firstOrNull?.rawValue;
    if (raw == null || raw.isEmpty) return;

    setState(() => _processing = true);

    final settings = ref.read(settingsProvider);

    // Feedback haptique
    if (settings.hapticEnabled) {
      HapticFeedback.mediumImpact();
    }

    // Son
    if (settings.soundEnabled) {
      SystemSound.play(SystemSoundType.click);
    }

    // Sauvegarder dans l'historique
    await ref.read(historyProvider.notifier).add(raw);

    final type = QrType.detect(raw);

    if (!mounted) return;

    if (type == QrType.url && settings.autoOpen) {
      final uri = Uri.tryParse(raw);
      if (uri != null) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } else {
      await _showResultSheet(raw, type);
    }

    // Cooldown anti-doublon
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) setState(() => _processing = false);
  }

  Future<void> _showResultSheet(String raw, QrType type) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ScanResultSheet(
        raw: raw,
        type: type,
        onShare: () => Share.share(raw),
        onCopy: () {
          Clipboard.setData(ClipboardData(text: raw));
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Copié dans le presse-papier')),
          );
        },
        onOpen: type == QrType.url
            ? () async {
                final uri = Uri.tryParse(raw);
                if (uri != null) await launchUrl(uri, mode: LaunchMode.externalApplication);
              }
            : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          MobileScanner(controller: _controller, onDetect: _onDetect),
          const ScanOverlay(),
          // Bouton torche
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            right: 16,
            child: IconButton(
              onPressed: () {
                _controller.toggleTorch();
                setState(() => _torchOn = !_torchOn);
              },
              icon: Icon(
                _torchOn ? Icons.flash_on : Icons.flash_off,
                color: _torchOn ? AppColors.primary : Colors.white,
                size: 28,
              ),
            ),
          ),
          // Texte guide
          Positioned(
            bottom: 120,
            left: 0,
            right: 0,
            child: Text(
              'Placez un QR code dans le cadre',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
                fontFamily: 'Inter',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
