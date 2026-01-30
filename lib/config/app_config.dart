class AppConfig {
  // Base URL for the backend API
  // Base URL for the backend API
  // Gunakan 127.0.0.1 untuk Web (Chrome) atau iOS Simulator.
  // Jika nanti di-deploy, ganti dengan URL domain asli (misal https://api.techpilot.com)
  static const String apiUrl = 'http://127.0.0.1:5000'; 
  
  // Timeout duration for API calls
  static const Duration apiTimeout = Duration(seconds: 30);
  
  // Headers
  static const Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json',
  };
}
