import 'package:dio/dio.dart';
import 'package:get/get.dart' as getx;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  late Dio _dio;
  final String baseUrl = 'https://e-commerce-store-bgmf.vercel.app';
  // final String baseUrl = 'http://localhost:3000';

  String? _token;

  void init() {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {'Content-Type': 'application/json'},
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final prefs = await SharedPreferences.getInstance();
          final savedToken = prefs.getString('token');

          // للتوافق مع NextAuth، نرسل token في cookie format أيضاً
          if (savedToken != null) {
            options.headers['Authorization'] = 'Bearer $savedToken';
            // محاولة إضافة session cookie إذا كان متاح
            final sessionCookie = prefs.getString('session_cookie');
            if (sessionCookie != null) {
              options.headers['Cookie'] = sessionCookie;
            }
          }

          // إضافة headers إضافية للتعرف على طلبات الموبايل
          options.headers['X-Mobile-App'] = 'true';
          options.headers['X-Platform'] = 'flutter';
          options.headers['X-App-Version'] = '1.0.0';

          if (_userId != null) {
            options.headers['X-User-ID'] = _userId!;
          }

          if (options.method == 'GET') {
            options.queryParameters['_t'] =
                DateTime.now().millisecondsSinceEpoch;
          }


          handler.next(options);
        },
        onResponse: (response, handler) {

          handler.next(response);
        },
        onError: (error, handler) {
          if (error.response?.statusCode == 401) {
            final path = error.requestOptions.path;

            // Only clear token for login/register failures
            if (path.contains('/api/mobile/login') ||
                path.contains('/api/mobile/register')) {
              print('🚫 Login/Register failed - clearing token');
              _clearInvalidToken();
            } else {
              print('⚠️ Server endpoint not found or authentication failed');
              print(
                '⚠️ Keeping user logged in - this is likely a server setup issue',
              );
            }
          }
          handler.next(error);
        },
      ),
    );
  }

  String? _userId;

  void setUserId(String userId) {
    _userId = userId;
  }

  void setToken(String token) {
    _token = token;
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  void clearToken() {
    _token = null;
    _dio.options.headers.remove('Authorization');
  }

  Future<void> _clearInvalidToken() async {
    try {
      // Clear token from memory
      clearToken();

      // Clear from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('token');
      await prefs.remove('user');
      await prefs.remove('userId');
      await prefs.setBool('isAuthenticated', false);

      // Redirect to login
      getx.Get.offAllNamed('/login');
    } catch (e) {
      print('Error clearing invalid token: $e');
    }
  }

  // ========== Auth ==========
  Future<Response> register(Map<String, dynamic> userData) async {
    return await _dio.post('/api/mobile/register', data: userData);
  }

  Future<Response> login(Map<String, dynamic> credentials) async {
    return await _dio.post('/api/mobile/login', data: credentials);
  }

  // ========== Products ==========
  Future<Response> getAllProducts() async {
    try {
      return await _dio.get('/api/products');
    } catch (e) {
      print('❗ getAllProducts failed: $e');
      rethrow;
    }
  }

  Future<Response> getProductById(String id) async {
    return await _dio.get('/api/products/$id');
  }

  Future<Response> createProduct(Map<String, dynamic> data) async {
    return await _dio.post('/api/products', data: data);
  }

  Future<Response> updateProduct(String id, Map<String, dynamic> data) async {
    return await _dio.put('/api/products/$id', data: data);
  }

  Future<Response> deleteProduct(String id) async {
    return await _dio.delete('/api/products/$id');
  }

  // ========== Cart ==========
  Future<Response> getCart() async {
    // استخدام endpoint الموبايل الجديد
    return await _dio.get('/api/mobile/cart');
  }

  Future<Response> addToCart(String productId, int quantity) async {
    // البيانات حسب توقعات السيرفر الجديد
    final data = {'productId': productId, 'quantity': quantity};

    return await _dio.post(
      '/api/mobile/cart/add', // استخدام endpoint الموبايل
      data: data,
    );
  }

  Future<Response> updateCartItem(String productId, int quantity) async {
    return await _dio.put(
      '/api/mobile/cart/update/$productId', // endpoint الموبايل
      data: {'quantity': quantity},
    );
  }

  Future<Response> removeFromCart(String productId) async {
    return await _dio.delete(
      '/api/mobile/cart/remove/$productId',
    ); // endpoint الموبايل
  }

  Future<Response> clearCart() async {
    return await _dio.delete('/api/mobile/cart/clear'); // endpoint الموبايل
  }

  // ========== Generic ==========
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    return await _dio.get(path, queryParameters: queryParameters);
  }

  Future<Response> post(String path, {dynamic data}) async {
    return await _dio.post(path, data: data);
  }

  Future<Response> put(String path, {dynamic data}) async {
    return await _dio.put(path, data: data);
  }

  Future<Response> delete(String path) async {
    return await _dio.delete(path);
  }

  Future<bool> testConnection() async {
    try {
      final response = await _dio.get('/');
      return response.statusCode == 200;
    } catch (e) {
      print('🚫 Test connection failed: $e');
      return false;
    }
  }
}
