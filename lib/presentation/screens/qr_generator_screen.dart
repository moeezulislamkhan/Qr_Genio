import 'package:flutter/material.dart';
import 'package:gal/gal.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/qr/qr_encoder.dart';
import '../../services/clipboard_service.dart';
import '../../services/qr_export_service.dart';
import '../widgets/action_buttons.dart';
import '../widgets/qr_input_field.dart';
import '../widgets/qr_preview_card.dart';

enum _ExportAction { download, share }

class QRGeneratorScreen extends StatefulWidget {
  final Future<void> Function() onThemeToggle;
  final bool isDarkMode;

  const QRGeneratorScreen({
    super.key,
    required this.onThemeToggle,
    required this.isDarkMode,
  });

  @override
  State<QRGeneratorScreen> createState() => _QRGeneratorScreenState();
}

class _QRGeneratorScreenState extends State<QRGeneratorScreen> {
  final TextEditingController _controller = TextEditingController();
  QRCodeResult? _qrCode;
  String? _errorMessage;
  bool _exporting = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _generateQR(String value) {
    if (value.trim().isEmpty) {
      setState(() {
        _qrCode = null;
        _errorMessage = null;
      });
      return;
    }

    try {
      final result = QREncoder.encode(value);
      setState(() {
        _qrCode = result;
        _errorMessage = null;
      });
    } catch (error) {
      setState(() {
        _qrCode = null;
        _errorMessage = error.toString().replaceFirst('Invalid argument(s): ', '');
      });
    }
  }

  Future<void> _copyText() async {
    if (_controller.text.isEmpty) return;
    try {
      await ClipboardService.copyText(_controller.text);
      if (mounted) _showMessage('Content copied successfully.');
    } catch (_) {
      if (mounted) _showMessage('Unable to copy content.');
    }
  }

  Future<void> _exportQR() async {
    final qr = _qrCode;
    if (qr == null || _exporting) return;

    final action = await showModalBottomSheet<_ExportAction>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.download_rounded),
              title: const Text('Download PNG'),
              subtitle: const Text('Save the QR code to your gallery'),
              onTap: () => Navigator.pop(sheetContext, _ExportAction.download),
            ),
            ListTile(
              leading: const Icon(Icons.share_rounded),
              title: const Text('Share'),
              subtitle: const Text('Share the QR code with another app'),
              onTap: () => Navigator.pop(sheetContext, _ExportAction.share),
            ),
          ],
        ),
      ),
    );
    if (action == null || !mounted) return;

    setState(() => _exporting = true);
    try {
      final bytes = await QRExportService.generatePng(qrCode: qr);
      final fileName = 'qr_genio_${DateTime.now().millisecondsSinceEpoch}.png';

      if (action == _ExportAction.download) {
        if (!await Gal.requestAccess()) {
          if (mounted) {
            _showMessage('Gallery access was denied. Allow access to save the PNG.');
          }
          return;
        }

        await Gal.putImageBytes(
          bytes,
          name: fileName.replaceFirst(RegExp(r'\.png$'), ''),
        );
        if (mounted) _showMessage('QR code saved to your gallery.');
      } else {
        final result = await SharePlus.instance.share(
          ShareParams(
            files: [
              XFile.fromData(bytes, mimeType: 'image/png'),
            ],
            fileNameOverrides: [fileName],
            title: 'Share QR code',
          ),
        );

        if (!mounted) return;
        switch (result.status) {
          case ShareResultStatus.success:
            _showMessage('QR code shared successfully.');
          case ShareResultStatus.dismissed:
            _showMessage('Sharing cancelled.');
          case ShareResultStatus.unavailable:
            _showMessage('Share sheet opened.');
        }
      }
    } catch (error, stackTrace) {
      debugPrint('QR export failed ($action): $error\n$stackTrace');
      if (mounted) {
        _showMessage(
          action == _ExportAction.download
              ? 'Unable to save the QR code to your gallery.'
              : 'Unable to share the QR code.',
        );
      }
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  void _reset() {
    _controller.clear();
    setState(() {
      _qrCode = null;
      _errorMessage = null;
    });
    _showMessage('Generator reset successfully.');
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
        ),
      );
  }

  Future<void> _toggleTheme() async {
    try {
      await widget.onThemeToggle();
    } on Exception catch (error) {
      if (mounted) _showMessage('Unable to save theme preference: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 20,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                color: colors.primaryContainer,
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(Icons.qr_code_2_rounded,
                  color: colors.onPrimaryContainer),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('QR Genio',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    )),
                Text('QR Code Generator',
                    style: theme.textTheme.bodySmall),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: _toggleTheme,
            tooltip: 'Toggle theme',
            icon: Icon(widget.isDarkMode
                ? Icons.light_mode_rounded
                : Icons.dark_mode_rounded),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Create your QR code',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  )),
              const SizedBox(height: 8),
              Text(
                'Turn any text or URL into a scannable QR code instantly.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 24),
              QRInputField(
                controller: _controller,
                onChanged: _generateQR,
                onClear: _reset,
              ),
              if (_errorMessage != null) ...[
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: colors.errorContainer,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.error_outline_rounded,
                          color: colors.onErrorContainer),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(_errorMessage!,
                            style: TextStyle(color: colors.onErrorContainer)),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 24),
              QRPreviewCard(qrCode: _qrCode),
              const SizedBox(height: 22),
              ActionButtons(
                enabled: _qrCode != null,
                exporting: _exporting,
                onCopy: _copyText,
                onExport: _exportQR,
                onReset: _reset,
              ),
              const SizedBox(height: 28),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: colors.surfaceContainerHighest.withValues(alpha: 0.55),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.verified_user_outlined, color: colors.primary),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Private & Offline',
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              )),
                          const SizedBox(height: 5),
                          Text(
                            'QR generation happens locally on your device. No external QR API or server is required.',
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: Text(
                  'QR Genio • Generate. Scan. Connect.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
