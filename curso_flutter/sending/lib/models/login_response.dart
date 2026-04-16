class LoginResponse {
  
  final Map<String, dynamic> rawData;
  final bool isSuccess;
  final String? message;  // ← Mensaje amigable para el usuario
  
  LoginResponse({
    required this.rawData,
    required this.isSuccess,
    this.message,
  });
  
  dynamic get(String key) => rawData[key];
  
  String? get token => rawData['token'] as String?;
  
  String? get rawMessage => rawData['message'] as String?;
  
  @override
  String toString() => rawData.toString();
}