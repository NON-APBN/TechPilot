class AppConfig {
  // Base URL for the backend API
  // Use 10.0.2.2 for Android Emulator, localhost for Windows/iOS Simulator
  static const String apiUrl = 'http://127.0.0.1:5000'; 
  
  // Timeout duration for API calls
  static const Duration apiTimeout = Duration(seconds: 30);
  
  // Headers
  static const Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json',
  };
}
