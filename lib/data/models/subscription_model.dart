import 'package:hive/hive.dart';

part 'subscription_model.g.dart';

@HiveType(typeId: 0)
class SubscriptionModel extends HiveObject {
  SubscriptionModel({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.currency,
    required this.billingCycle,
    required this.startDate,
    required this.nextRenewalDate,
    this.notes,
    this.iconName,
    required this.colorHex,
    this.isActive = true,
    this.notifyBeforeRenewal = true,
    this.notifyDaysBefore = 3,
    this.email,
    this.username,
    this.password,
    this.pin,
    this.loginUrl,
    this.codeUrl,
    this.isPaid = true,
    this.paymentMethod,
    this.paidAt,
    this.autoPaidOn,
  });

  @HiveField(0)
  String id;
  @HiveField(1)
  String name;
  @HiveField(2)
  String category;
  @HiveField(3)
  double price;
  @HiveField(4)
  String currency;
  @HiveField(5)
  String billingCycle;
  @HiveField(6)
  DateTime startDate;
  @HiveField(7)
  DateTime nextRenewalDate;
  @HiveField(8)
  String? notes;
  @HiveField(9)
  String? iconName;
  @HiveField(10)
  String colorHex;
  @HiveField(11)
  bool isActive;
  @HiveField(12)
  bool notifyBeforeRenewal;
  @HiveField(13)
  int notifyDaysBefore;
  @HiveField(14)
  String? email;
  @HiveField(15)
  String? username;
  @HiveField(16)
  String? password;
  @HiveField(17)
  String? pin;
  @HiveField(18)
  String? loginUrl;
  @HiveField(19)
  String? codeUrl;
  @HiveField(20, defaultValue: true)
  bool isPaid;
  @HiveField(21)
  String? paymentMethod;
  @HiveField(22)
  DateTime? paidAt;
  @HiveField(23)
  DateTime? autoPaidOn;

  SubscriptionModel copyWith({
    String? id,
    String? name,
    String? category,
    double? price,
    String? currency,
    String? billingCycle,
    DateTime? startDate,
    DateTime? nextRenewalDate,
    String? notes,
    String? iconName,
    String? colorHex,
    bool? isActive,
    bool? notifyBeforeRenewal,
    int? notifyDaysBefore,
    String? email,
    String? username,
    String? password,
    String? pin,
    String? loginUrl,
    String? codeUrl,
    bool? isPaid,
    String? paymentMethod,
    DateTime? paidAt,
    DateTime? autoPaidOn,
  }) => SubscriptionModel(
    id: id ?? this.id,
    name: name ?? this.name,
    category: category ?? this.category,
    price: price ?? this.price,
    currency: currency ?? this.currency,
    billingCycle: billingCycle ?? this.billingCycle,
    startDate: startDate ?? this.startDate,
    nextRenewalDate: nextRenewalDate ?? this.nextRenewalDate,
    notes: notes ?? this.notes,
    iconName: iconName ?? this.iconName,
    colorHex: colorHex ?? this.colorHex,
    isActive: isActive ?? this.isActive,
    notifyBeforeRenewal: notifyBeforeRenewal ?? this.notifyBeforeRenewal,
    notifyDaysBefore: notifyDaysBefore ?? this.notifyDaysBefore,
    email: email ?? this.email,
    username: username ?? this.username,
    password: password ?? this.password,
    pin: pin ?? this.pin,
    loginUrl: loginUrl ?? this.loginUrl,
    codeUrl: codeUrl ?? this.codeUrl,
    isPaid: isPaid ?? this.isPaid,
    paymentMethod: paymentMethod ?? this.paymentMethod,
    paidAt: paidAt ?? this.paidAt,
    autoPaidOn: autoPaidOn ?? this.autoPaidOn,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'category': category,
    'price': price,
    'currency': currency,
    'billingCycle': billingCycle,
    'startDate': startDate.toIso8601String(),
    'nextRenewalDate': nextRenewalDate.toIso8601String(),
    'notes': notes,
    'iconName': iconName,
    'colorHex': colorHex,
    'isActive': isActive,
    'notifyBeforeRenewal': notifyBeforeRenewal,
    'notifyDaysBefore': notifyDaysBefore,
    'email': email,
    'username': username,
    'password': password,
    'pin': pin,
    'loginUrl': loginUrl,
    'codeUrl': codeUrl,
    'isPaid': isPaid,
    'paymentMethod': paymentMethod,
    'paidAt': paidAt?.toIso8601String(),
    'autoPaidOn': autoPaidOn?.toIso8601String(),
  };

  factory SubscriptionModel.fromJson(Map<String, dynamic> json) =>
      SubscriptionModel(
        id: json['id'] as String,
        name: json['name'] as String,
        category: json['category'] as String? ?? 'apps',
        price: (json['price'] as num).toDouble(),
        currency: json['currency'] as String? ?? 'USD',
        billingCycle: json['billingCycle'] as String? ?? 'monthly',
        startDate: DateTime.parse(json['startDate'] as String),
        nextRenewalDate: DateTime.parse(json['nextRenewalDate'] as String),
        notes: json['notes'] as String?,
        iconName: json['iconName'] as String?,
        colorHex: json['colorHex'] as String? ?? '#6C63FF',
        isActive: json['isActive'] as bool? ?? true,
        notifyBeforeRenewal: json['notifyBeforeRenewal'] as bool? ?? true,
        notifyDaysBefore: json['notifyDaysBefore'] as int? ?? 3,
        email: json['email'] as String?,
        username: json['username'] as String?,
        password: json['password'] as String?,
        pin: json['pin'] as String?,
        loginUrl: json['loginUrl'] as String?,
        codeUrl: json['codeUrl'] as String?,
        isPaid: json['isPaid'] as bool? ?? true,
        paymentMethod: json['paymentMethod'] as String?,
        paidAt: json['paidAt'] == null
            ? null
            : DateTime.parse(json['paidAt'] as String),
        autoPaidOn: json['autoPaidOn'] == null
            ? null
            : DateTime.parse(json['autoPaidOn'] as String),
      );
}
