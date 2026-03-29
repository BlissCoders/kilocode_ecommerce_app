import 'package:equatable/equatable.dart';
import 'cart_model.dart';
import 'user_model.dart';

enum OrderStatus {
  pending,
  processing,
  shipped,
  delivered,
  cancelled,
}

class OrderModel extends Equatable {
  final String id;
  final UserModel user;
  final List<CartItemModel> items;
  final double subtotal;
  final double tax;
  final double total;
  final ShippingAddress shippingAddress;
  final OrderStatus status;
  final String? paymentIntentId;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const OrderModel({
    required this.id,
    required this.user,
    required this.items,
    required this.subtotal,
    required this.tax,
    required this.total,
    required this.shippingAddress,
    required this.status,
    this.paymentIntentId,
    required this.createdAt,
    this.updatedAt,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'] as String,
      user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
      items: (json['items'] as List<dynamic>)
          .map((item) => CartItemModel.fromJson(item as Map<String, dynamic>))
          .toList(),
      subtotal: (json['subtotal'] as num).toDouble(),
      tax: (json['tax'] as num).toDouble(),
      total: (json['total'] as num).toDouble(),
      shippingAddress: ShippingAddress.fromJson(json['shippingAddress'] as Map<String, dynamic>),
      status: OrderStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => OrderStatus.pending,
      ),
      paymentIntentId: json['paymentIntentId'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt'] as String) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user': user.toJson(),
      'items': items.map((item) => item.toJson()).toList(),
      'subtotal': subtotal,
      'tax': tax,
      'total': total,
      'shippingAddress': shippingAddress.toJson(),
      'status': status.name,
      'paymentIntentId': paymentIntentId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  OrderModel copyWith({
    String? id,
    UserModel? user,
    List<CartItemModel>? items,
    double? subtotal,
    double? tax,
    double? total,
    ShippingAddress? shippingAddress,
    OrderStatus? status,
    String? paymentIntentId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return OrderModel(
      id: id ?? this.id,
      user: user ?? this.user,
      items: items ?? this.items,
      subtotal: subtotal ?? this.subtotal,
      tax: tax ?? this.tax,
      total: total ?? this.total,
      shippingAddress: shippingAddress ?? this.shippingAddress,
      status: status ?? this.status,
      paymentIntentId: paymentIntentId ?? this.paymentIntentId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        user,
        items,
        subtotal,
        tax,
        total,
        shippingAddress,
        status,
        paymentIntentId,
        createdAt,
        updatedAt,
      ];
}

class ShippingAddress extends Equatable {
  final String name;
  final String address;
  final String city;
  final String zipCode;
  final String country;
  final String? phone;

  const ShippingAddress({
    required this.name,
    required this.address,
    required this.city,
    required this.zipCode,
    required this.country,
    this.phone,
  });

  factory ShippingAddress.fromJson(Map<String, dynamic> json) {
    return ShippingAddress(
      name: json['name'] as String,
      address: json['address'] as String,
      city: json['city'] as String,
      zipCode: json['zipCode'] as String,
      country: json['country'] as String,
      phone: json['phone'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'address': address,
      'city': city,
      'zipCode': zipCode,
      'country': country,
      'phone': phone,
    };
  }

  @override
  List<Object?> get props => [name, address, city, zipCode, country, phone];
}
