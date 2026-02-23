class ImpresoraRed {
  String nombre;
  String ip;
  int puerto;
  String protocolo;

  ImpresoraRed({
    required this.nombre,
    required this.ip,
    required this.puerto,
    required this.protocolo,
  });

  Map<String, dynamic> toJson() => {
        'nombre': nombre,
        'ip': ip,
        'puerto': puerto,
        'protocolo': protocolo,
      };

  factory ImpresoraRed.fromJson(Map<String, dynamic> json) {
    return ImpresoraRed(
      nombre: json['nombre'],
      ip: json['ip'],
      puerto: json['puerto'],
      protocolo: json['protocolo'],
    );
  }
}
