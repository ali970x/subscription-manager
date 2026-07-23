// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subscription_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SubscriptionModelAdapter extends TypeAdapter<SubscriptionModel> {
  @override
  final int typeId = 0;

  @override
  SubscriptionModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SubscriptionModel(
      id: fields[0] as String,
      name: fields[1] as String,
      category: fields[2] as String,
      price: fields[3] as double,
      currency: fields[4] as String,
      billingCycle: fields[5] as String,
      startDate: fields[6] as DateTime,
      nextRenewalDate: fields[7] as DateTime,
      notes: fields[8] as String?,
      iconName: fields[9] as String?,
      colorHex: fields[10] as String,
      isActive: fields[11] as bool,
      notifyBeforeRenewal: fields[12] as bool,
      notifyDaysBefore: fields[13] as int,
      email: fields[14] as String?,
      username: fields[15] as String?,
      password: fields[16] as String?,
      pin: fields[17] as String?,
      loginUrl: fields[18] as String?,
      codeUrl: fields[19] as String?,
      isPaid: fields[20] == null ? true : fields[20] as bool,
      paymentMethod: fields[21] as String?,
      paidAt: fields[22] as DateTime?,
      autoPaidOn: fields[23] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, SubscriptionModel obj) {
    writer
      ..writeByte(24)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.category)
      ..writeByte(3)
      ..write(obj.price)
      ..writeByte(4)
      ..write(obj.currency)
      ..writeByte(5)
      ..write(obj.billingCycle)
      ..writeByte(6)
      ..write(obj.startDate)
      ..writeByte(7)
      ..write(obj.nextRenewalDate)
      ..writeByte(8)
      ..write(obj.notes)
      ..writeByte(9)
      ..write(obj.iconName)
      ..writeByte(10)
      ..write(obj.colorHex)
      ..writeByte(11)
      ..write(obj.isActive)
      ..writeByte(12)
      ..write(obj.notifyBeforeRenewal)
      ..writeByte(13)
      ..write(obj.notifyDaysBefore)
      ..writeByte(14)
      ..write(obj.email)
      ..writeByte(15)
      ..write(obj.username)
      ..writeByte(16)
      ..write(obj.password)
      ..writeByte(17)
      ..write(obj.pin)
      ..writeByte(18)
      ..write(obj.loginUrl)
      ..writeByte(19)
      ..write(obj.codeUrl)
      ..writeByte(20)
      ..write(obj.isPaid)
      ..writeByte(21)
      ..write(obj.paymentMethod)
      ..writeByte(22)
      ..write(obj.paidAt)
      ..writeByte(23)
      ..write(obj.autoPaidOn);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SubscriptionModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
