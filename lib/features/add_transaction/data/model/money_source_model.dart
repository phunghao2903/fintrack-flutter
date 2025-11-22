import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fintrack/core/constants/assets.dart';
import 'package:fintrack/features/add_transaction/domain/entities/money_source_entity.dart';

class MoneySourceModel extends MoneySourceEntity {
  MoneySourceModel({
    required super.id,
    required super.name,
    required super.icon,
    required super.balance, // 👈 thêm
  });

  factory MoneySourceModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    // Lấy raw value
    final rawAmount = data['balance']; // hoặc 'amount', 'currentAmount' tùy bạn

    double parsedAmount;

    if (rawAmount is num) {
      // Nếu Firestore lưu dạng Number (int/double)
      parsedAmount = rawAmount.toDouble();
    } else if (rawAmount is String) {
      // Nếu Firestore lưu dạng String, ví dụ "300000" hoặc "300,000"
      parsedAmount =
          double.tryParse(rawAmount.replaceAll('.', '').replaceAll(',', '')) ??
          0.0;
    } else {
      parsedAmount = 0.0; // fallback nếu null hoặc type lạ
    }

    final rawIcon = (data['icon'] as String?)?.trim();
    final resolvedIcon = (rawIcon != null && rawIcon.isNotEmpty)
        ? rawIcon
        : kDefaultIconAsset;

    final rawName = (data['name'] as String?)?.trim();

    return MoneySourceModel(
      id: doc.id,
      name: rawName?.isNotEmpty == true ? rawName! : 'Money source',
      icon: resolvedIcon,
      balance: parsedAmount,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'icon': icon, 'balance': balance};
  }
}
