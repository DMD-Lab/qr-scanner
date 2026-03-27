import 'qr_type.dart';

class ScanResult {
  ScanResult({
    required this.id,
    required this.raw,
    required this.type,
    required this.scannedAt,
  });

  final int id;
  final String raw;
  final QrType type;
  final DateTime scannedAt;

  bool get isUrl => type == QrType.url;
  bool get isText => type == QrType.text;
  bool get isUnsupported => type == QrType.unsupported;

  bool get isHttpWarning =>
      isUrl && raw.trim().toLowerCase().startsWith('http://');

  bool get isShortUrl {
    if (!isUrl) return false;
    const shorteners = [
      'bit.ly', 't.co', 'tinyurl.com', 'goo.gl', 'ow.ly',
      'short.link', 'tiny.cc', 'is.gd', 'buff.ly', 'rb.gy',
    ];
    final host = Uri.tryParse(raw)?.host.toLowerCase() ?? '';
    return shorteners.any((s) => host == s || host.endsWith('.$s'));
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'raw': raw,
        'type': type.name,
        'scanned_at': scannedAt.millisecondsSinceEpoch,
      };

  factory ScanResult.fromMap(Map<String, dynamic> map) => ScanResult(
        id: map['id'] as int,
        raw: map['raw'] as String,
        type: QrType.values.byName(map['type'] as String),
        scannedAt: DateTime.fromMillisecondsSinceEpoch(map['scanned_at'] as int),
      );
}
