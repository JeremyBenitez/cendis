class LoginRequest {
  final String tienda;
  final String usuario;
  final String password;
  
  LoginRequest({
    required this.tienda,
    required this.usuario,
    required this.password,
  });
  
  Map<String, dynamic> toJson() => {
    'tienda': tienda,
    'usuario': usuario,
    'password': password,
  };
}