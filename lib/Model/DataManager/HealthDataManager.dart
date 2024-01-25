import 'package:sleeptrackerapp/Utility/DatabaseStore.dart';

class HealthConnectDataEntry extends IRecord
{
  HealthConnectDataEntry({required this.dataType, required this.value,required this.unit, required this.dateFrom, required this.dateTo});

  String dataType;
  String value;
  String unit; 
  String dateFrom;
  String dateTo;

  @override
  Map<String, dynamic> toJson() => {
    'dataType': dataType,
    'value': value,
    'unit': unit,
    'dateFrom' : dateFrom,
    'dateTo' : dateTo,
  };

  @override
  void fromJson(Map<String, dynamic> json) {
    dataType = json['dataType'];
    value = json['value'];
    unit = json['unit'];
    dateFrom = json['dateFrom'];
    dateTo = json['dateTo'];
  }

  factory HealthConnectDataEntry.fromJson(Map<String, dynamic> json) => HealthConnectDataEntry(
    dataType: json['dataType'],
    value: json['value'],
    unit: json['unit'],
    dateFrom: json['dateFrom'],
    dateTo: json['dateTo'],
  );
}

class HealthConnectDataManager extends DatabaseStore<HealthConnectDataEntry>
{ 

  @override
  String get databasePath => 'users/userID/${firebaseAuth.currentUser?.uid}';

  @override
  HealthConnectDataEntry createRecord() => HealthConnectDataEntry(dataType: '', value: '' , unit: '', dateFrom: '' , dateTo: '' );
}