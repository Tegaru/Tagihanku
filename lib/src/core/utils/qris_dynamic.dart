class QrisDynamic {
  const QrisDynamic._();

  static String toDynamic({
    required String staticQris,
    required String amount,
    String? feeType,
    String? feeValue,
  }) {
    final base = staticQris.trim();
    if (base.length < 4) {
      throw ArgumentError('QRIS terlalu pendek');
    }

    final noCrc = base.substring(0, base.length - 4);
    final step1 = noCrc.replaceFirst('010211', '010212');
    final parts = step1.split('5802ID');
    if (parts.length != 2) {
      throw ArgumentError('Format QRIS tidak valid');
    }

    final amountField = _buildAmountField(amount, feeType, feeValue);
    final fixed = parts[0] + amountField + '5802ID' + parts[1];
    final crc = _crc16(fixed);
    return fixed + crc;
  }

  static String _buildAmountField(
    String amount,
    String? feeType,
    String? feeValue,
  ) {
    final amt = amount.trim();
    final amountField = '54${_len2(amt)}$amt';

    if (feeType == null || feeValue == null || feeValue.trim().isEmpty) {
      return amountField;
    }

    final fee = feeValue.trim();
    if (feeType == 'r') {
      return amountField + '55020256${_len2(fee)}$fee';
    }
    if (feeType == 'p') {
      return amountField + '55020357${_len2(fee)}$fee';
    }
    throw ArgumentError('feeType harus "r" atau "p"');
  }

  static String _len2(String value) {
    final len = value.length;
    return len.toString().padLeft(2, '0');
  }

  static String _crc16(String input) {
    var crc = 0xFFFF;
    for (var i = 0; i < input.length; i++) {
      crc ^= input.codeUnitAt(i) << 8;
      for (var j = 0; j < 8; j++) {
        if ((crc & 0x8000) != 0) {
          crc = (crc << 1) ^ 0x1021;
        } else {
          crc = crc << 1;
        }
      }
    }
    final hex = (crc & 0xFFFF).toRadixString(16).toUpperCase();
    return hex.padLeft(4, '0');
  }
}
