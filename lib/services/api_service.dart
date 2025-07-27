import 'package:dio/dio.dart';
import 'package:get/get.dart' as getx;

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  late Dio _dio;
  final String baseUrl = 'https://e-commerce-store-bgmf.vercel.app';

  void init() {
    print('Initializing API Service with base URL: $baseUrl');
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {'Content-Type': 'application/json'},
      ),
    );

    // Request interceptor
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          // Add timestamp for cache control
          if (options.method == 'GET') {
            options.queryParameters = {
              ...options.queryParameters,
              '_t': DateTime.now().millisecondsSinceEpoch,
            };
          }
          print('Sending request to: ${options.path}');
          print('Request headers: ${options.headers}');
          handler.next(options);
        },
        onResponse: (response, handler) {
          print('Received response from: ${response.requestOptions.path}');
          print('Response status: ${response.statusCode}');
          print('Response headers: ${response.headers}');
          handler.next(response);
        },
        onError: (error, handler) {
          // Handle errors
          if (error.response?.statusCode == 401) {
            // Redirect to login if unauthorized
            getx.Get.offAllNamed('/login');
          }
          print('API call failed: ${error.message}');
          handler.next(error);
        },
      ),
    );
  }

  // Products API
  Future<Response> getAllProducts() async {
    print('Making API call to: ${_dio.options.baseUrl}/api/products');
    try {
      // First try the main endpoint
      final response = await _dio.get('/api/products');
      print('API call successful: ${response.statusCode}');
      print('Response headers: ${response.headers}');
      return response;
    } catch (e) {
      print('API call failed: $e');
      if (e is DioException) {
        print('DioException type: ${e.type}');
        print('DioException message: ${e.message}');
        print('DioException response: ${e.response}');

        // Try alternative endpoints if the main one fails
        if (e.response?.statusCode == 404) {
          print('Trying alternative endpoint: /products');
          try {
            final altResponse = await _dio.get('/products');
            print('Alternative API call successful: ${altResponse.statusCode}');
            return altResponse;
          } catch (altE) {
            print('Alternative API call also failed: $altE');
          }
        }
      }
      rethrow;
    }
  }

  Future<Response> getProductById(String id) async {
    return await _dio.get('/api/products/$id');
  }

  Future<Response> createProduct(Map<String, dynamic> productData) async {
    return await _dio.post('/api/products', data: productData);
  }

  Future<Response> updateProduct(
    String id,
    Map<String, dynamic> productData,
  ) async {
    return await _dio.put('/api/products/$id', data: productData);
  }

  Future<Response> deleteProduct(String id) async {
    return await _dio.delete('/api/products/$id');
  }

  // Cart API
  Future<Response> getCart() async {
    print('=== API SERVICE GET CART ===');
    final userId = _dio.options.headers['X-User-ID'];
    print('User ID from headers: $userId');
    
    try {
      final response = await _dio.get('/api/cart', queryParameters: {'userId': userId});
      print('Get cart successful: ${response.statusCode}');
      return response;
    } catch (e) {
      print('Get cart failed: $e');
      rethrow;
    }
  }

  Future<Response> addToCart(String productId, int quantity) async {
    print('=== API SERVICE ADD TO CART ===');
    print('Product ID: $productId');
    print('Quantity: $quantity');
    print('Current headers: ${_dio.options.headers}');
    print('Authorization header: ${_dio.options.headers['Authorization']}');
    print('X-User-ID header: ${_dio.options.headers['X-User-ID']}');
    
    try {
      // Get user ID from headers
      final userId = _dio.options.headers['X-User-ID'];
      print('User ID from headers: $userId');
      
      final requestData = {
        'productId': productId, 
        'quantity': quantity,
        'userId': userId, // Add user ID to request body
      };
      
      print('Request data: $requestData');
      
      final response = await _dio.post(
        '/api/cart/add',
        data: requestData,
      );
      print('API call successful: ${response.statusCode}');
      return response;
    } catch (e) {
      print('API call failed: $e');
      rethrow;
    }
  }

  Future<Response> updateCartItem(String productId, int quantity) async {
    print('=== API SERVICE UPDATE CART ===');
    final userId = _dio.options.headers['X-User-ID'];
    print('User ID from headers: $userId');
    
    try {
      final response = await _dio.put(
        '/api/cart/update/$productId',
        data: {'quantity': quantity, 'userId': userId},
      );
      print('Update cart successful: ${response.statusCode}');
      return response;
    } catch (e) {
      print('Update cart failed: $e');
      rethrow;
    }
  }

  Future<Response> removeFromCart(String productId) async {
    print('=== API SERVICE REMOVE FROM CART ===');
    final userId = _dio.options.headers['X-User-ID'];
    print('User ID from headers: $userId');
    
    try {
      final response = await _dio.delete('/api/cart/remove/$productId', data: {'userId': userId});
      print('Remove from cart successful: ${response.statusCode}');
      return response;
    } catch (e) {
      print('Remove from cart failed: $e');
      rethrow;
    }
  }

  Future<Response> clearCart() async {
    print('=== API SERVICE CLEAR CART ===');
    final userId = _dio.options.headers['X-User-ID'];
    print('User ID from headers: $userId');
    
    try {
      final response = await _dio.delete('/api/cart/clear', data: {'userId': userId});
      print('Clear cart successful: ${response.statusCode}');
      return response;
    } catch (e) {
      print('Clear cart failed: $e');
      rethrow;
    }
  }

  // Auth API
  Future<Response> register(Map<String, dynamic> userData) async {
    return await _dio.post('/api/mobile/register', data: userData);
  }

  Future<Response> login(Map<String, dynamic> credentials) async {
    return await _dio.post('/api/mobile/login', data: credentials);
  }

  // Generic methods
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    return await _dio.get(path, queryParameters: queryParameters);
  }

  // Test API connection
  Future<bool> testConnection() async {
    try {
      print('Testing API connection...');
      final response = await _dio.get('/');
      print('Connection test successful: ${response.statusCode}');
      return true;
    } catch (e) {
      print('Connection test failed: $e');
      return false;
    }
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

  void setUserId(String userId) {
    print('Setting user ID in API service: $userId');
    _dio.options.headers['X-User-ID'] = userId;
    print('Updated headers: ${_dio.options.headers}');
  }

  void setToken(String token) {
    print('Setting token in API service: $token');
    _dio.options.headers['Authorization'] = 'Bearer $token';
    print('Updated headers: ${_dio.options.headers}');
  }
}
