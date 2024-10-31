class UserInfoModel {
  String message;
  User user;
  Colaborador colaborador;
  Horario horario;
  Periodo periodo;
  List<Evento> eventos;

  UserInfoModel({
    required this.message,
    required this.user,
    required this.colaborador,
    required this.horario,
    required this.periodo,
    required this.eventos,
  });

  factory UserInfoModel.fromJson(Map<String, dynamic> json) => UserInfoModel(
        message: json["message"],
        user: User.fromJson(json["user"]),
        colaborador: Colaborador.fromJson(json["colaborador"]),
        horario: Horario.fromJson(json["horario"]),
        periodo: Periodo.fromJson(json["periodo"]),
        eventos:
            List<Evento>.from(json["eventos"].map((x) => Evento.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "message": message,
        "user": user.toJson(),
        "colaborador": colaborador.toJson(),
        "horario": horario.toJson(),
        "periodo": periodo.toJson(),
        "eventos": List<dynamic>.from(eventos.map((x) => x.toJson())),
      };
}

class Colaborador {
  int id;
  String tipoContrato;
  DateTime fechaInicio;
  DateTime fechaFin;
  String tipoColaborador;

  Colaborador({
    required this.id,
    required this.tipoContrato,
    required this.fechaInicio,
    required this.fechaFin,
    required this.tipoColaborador,
  });

  factory Colaborador.fromJson(Map<String, dynamic> json) => Colaborador(
        id: json["id"],
        tipoContrato: json["tipo_contrato"],
        fechaInicio: DateTime.parse(json["fecha_inicio"]),
        fechaFin: DateTime.parse(json["fecha_fin"]),
        tipoColaborador: json["tipo_colaborador"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "tipo_contrato": tipoContrato,
        "fecha_inicio":
            "${fechaInicio.year.toString().padLeft(4, '0')}-${fechaInicio.month.toString().padLeft(2, '0')}-${fechaInicio.day.toString().padLeft(2, '0')}",
        "fecha_fin":
            "${fechaFin.year.toString().padLeft(4, '0')}-${fechaFin.month.toString().padLeft(2, '0')}-${fechaFin.day.toString().padLeft(2, '0')}",
        "tipo_colaborador": tipoColaborador,
      };
}

class Evento {
  int id;
  DateTime fecha;
  String descripcion;

  Evento({
    required this.id,
    required this.fecha,
    required this.descripcion,
  });

  factory Evento.fromJson(Map<String, dynamic> json) => Evento(
        id: json["id"],
        fecha: DateTime.parse(json["fecha"]),
        descripcion: json["descripcion"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "fecha":
            "${fecha.year.toString().padLeft(4, '0')}-${fecha.month.toString().padLeft(2, '0')}-${fecha.day.toString().padLeft(2, '0')}",
        "descripcion": descripcion,
      };
}

class Horario {
  int id;
  String horaEntrada;
  String horaSalida;
  List<String> diasLaborales;

  Horario({
    required this.id,
    required this.horaEntrada,
    required this.horaSalida,
    required this.diasLaborales,
  });

  factory Horario.fromJson(Map<String, dynamic> json) => Horario(
        id: json["id"],
        horaEntrada: json["hora_entrada"],
        horaSalida: json["hora_salida"],
        diasLaborales: List<String>.from(json["dias_laborales"].map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "hora_entrada": horaEntrada,
        "hora_salida": horaSalida,
        "dias_laborales": List<dynamic>.from(diasLaborales.map((x) => x)),
      };
}

class Periodo {
  int id;
  int anio;
  DateTime fechaInicio;
  DateTime fechaFin;

  Periodo({
    required this.id,
    required this.anio,
    required this.fechaInicio,
    required this.fechaFin,
  });

  factory Periodo.fromJson(Map<String, dynamic> json) => Periodo(
        id: json["id"],
        anio: json["anio"],
        fechaInicio: DateTime.parse(json["fecha_inicio"]),
        fechaFin: DateTime.parse(json["fecha_fin"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "anio": anio,
        "fecha_inicio":
            "${fechaInicio.year.toString().padLeft(4, '0')}-${fechaInicio.month.toString().padLeft(2, '0')}-${fechaInicio.day.toString().padLeft(2, '0')}",
        "fecha_fin":
            "${fechaFin.year.toString().padLeft(4, '0')}-${fechaFin.month.toString().padLeft(2, '0')}-${fechaFin.day.toString().padLeft(2, '0')}",
      };
}

class User {
  int id;
  String nombre;
  String apellidos;
  String email;
  String rol;

  User({
    required this.id,
    required this.nombre,
    required this.apellidos,
    required this.email,
    required this.rol,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json["id"],
        nombre: json["nombre"],
        apellidos: json["apellidos"],
        email: json["email"],
        rol: json["rol"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "nombre": nombre,
        "apellidos": apellidos,
        "email": email,
        "rol": rol,
      };
}
