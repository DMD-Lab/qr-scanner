enum QrType {
  url,
  text,
  unsupported;

  static QrType detect(String raw) {
    final lower = raw.trim().toLowerCase();
    if (lower.startsWith('http://') || lower.startsWith('https://')) {
      return QrType.url;
    }
    // Types réservés pour les futures versions
    if (lower.startsWith('wifi:') ||
        lower.startsWith('begin:vcard') ||
        lower.startsWith('mailto:') ||
        lower.startsWith('tel:') ||
        lower.startsWith('smsto:') ||
        lower.startsWith('geo:') ||
        lower.startsWith('begin:vevent')) {
      return QrType.unsupported;
    }
    return QrType.text;
  }
}

extension QrTypeX on QrType {
  String get label {
    switch (this) {
      case QrType.url:
        return 'URL';
      case QrType.text:
        return 'Texte';
      case QrType.unsupported:
        return 'Non supporté';
    }
  }
}
