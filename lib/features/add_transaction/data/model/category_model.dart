import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fintrack/core/constants/assets.dart';
import 'package:fintrack/features/add_transaction/domain/entities/category_entity.dart';

class CategoryModel extends CategoryEntity {
  CategoryModel({
    required super.id,
    required super.name,
    required super.icon,
    required super.isIncome,
  });

  factory CategoryModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final rawIcon = (data['icon'] as String?)?.trim();
    final resolvedIcon = (rawIcon != null && rawIcon.isNotEmpty)
        ? rawIcon
        : kDefaultIconAsset;
    final rawName = (data['name'] as String?)?.trim();
    return CategoryModel(
      id: doc.id,
      name: rawName?.isNotEmpty == true ? rawName! : 'Category',
      icon: resolvedIcon,
      isIncome: data['isIncome'],
    );
  }
}
