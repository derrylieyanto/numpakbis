class PlatBus{
  String key;
  String noPlat;
  String type;
  String city;

  PlatBus({ this.key, this.noPlat, this.city, this.type });

  bool operator ==(o) => o is PlatBus && o.noPlat == noPlat;
  int get hashCode => noPlat.hashCode;

  @override toString() => 'Nomor Plat: $noPlat';
}

class TypeBus{
  String key;
  String type;
  String city;

  TypeBus({ this.key, this.city, this.type });

  bool operator ==(o) => o is TypeBus && o.type == type;
  int get hashCode => type.hashCode;

  @override toString() => 'Type: $type';
}