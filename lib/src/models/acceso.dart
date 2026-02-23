class Acceso {
  final int accesoId;
  final String accesoDes;
  final int appId;
  final String appDes;

  Acceso({
    required this.accesoId,
    required this.accesoDes,
    required this.appId,
    required this.appDes,
  });

  factory Acceso.fromJson(Map<String, dynamic> json) {
    return Acceso(
      accesoId: json['accesoId'] ?? 0,
      accesoDes: (json['accesoDes'] ?? '').trim(),
      appId: json['appId'] ?? 0,
      appDes: (json['appDes'] ?? '').trim(),
    );
  }

  Map<String, dynamic> toJson() => {
        'accesoId': accesoId,
        'accesoDes': accesoDes,
        'appId': appId,
        'appDes': appDes,
      };
}
