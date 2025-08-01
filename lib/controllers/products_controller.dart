import 'package:get/get.dart';
import 'package:ecommerce_store/services/api_service.dart';

class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final String image;
  final String category;
  final int stock;
  final double rating;
  final int reviews;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.image,
    required this.category,
    required this.stock,
    this.rating = 0.0,
    this.reviews = 0,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] ?? json['_id'] ?? '',
      name: json['name'] ?? json['title'] ?? '',
      description: json['description'] ?? '',
      price: double.tryParse(json['price'].toString()) ?? 0.0,
      image:
          (json['photos'] != null &&
              json['photos'] is List &&
              json['photos'].isNotEmpty)
          ? json['photos'][0]
          : '',
      category: json['category'] ?? '',
      stock:
          int.tryParse(
            json['stock']?.toString() ?? json['quantity']?.toString() ?? '0',
          ) ??
          0,
      rating: double.tryParse(json['rating']?.toString() ?? '') ?? 0.0,
      reviews: int.tryParse(json['reviews']?.toString() ?? '0') ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'image': image,
      'category': category,
      'stock': stock,
      'rating': rating,
      'reviews': reviews,
    };
  }
}

class ProductsController extends GetxController {
  final ApiService _apiService = ApiService();

  var products = <Product>[].obs;
  var filteredProducts = <Product>[].obs;
  var loading = false.obs;
  var error = ''.obs;
  var selectedCategory = 'All'.obs;
  var searchQuery = ''.obs;

  // Categories for filtering
  final List<String> categories = [
    'All',
    'Electronics',
    'Clothing',
    'Books',
    'Home & Garden',
    'Sports',
    'Beauty',
    'Toys',
  ];

  @override
  void onInit() {
    super.onInit();
    _apiService.init();
    _testConnection();
  }

  Future<void> _testConnection() async {
    final isConnected = await _apiService.testConnection();
    if (isConnected) {
      fetchProducts();
    } else {
      _loadDummyData();
    }
  }

  void _loadDummyData() {
    products.value = [
      Product(
        id: '1',
        name: 'iPhone 15 Pro',
        description:
            'Latest iPhone with advanced features and powerful performance.',
        price: 999.99,
        image: '',
        category: 'Electronics',
        stock: 10,
        rating: 4.5,
        reviews: 128,
      ),
      Product(
        id: '2',
        name: 'Samsung Galaxy S24',
        description: 'Premium Android smartphone with cutting-edge technology.',
        price: 899.99,
        image: '',
        category: 'Electronics',
        stock: 15,
        rating: 4.3,
        reviews: 95,
      ),
      Product(
        id: '3',
        name: 'MacBook Pro M3',
        description:
            'Professional laptop with M3 chip for ultimate performance.',
        price: 1999.99,
        image: '',
        category: 'Electronics',
        stock: 8,
        rating: 4.8,
        reviews: 67,
      ),
    ];
    applyFilters();
  }

  // Fetch all products from backend
  Future<void> fetchProducts() async {
    try {
      loading.value = true;
      error.value = '';

      final response = await _apiService.getAllProducts();

      final productsData = response.data;

      if (productsData is List) {
        products.value = productsData
            .map((product) => Product.fromJson(product))
            .toList();
      } else if (productsData is Map && productsData['products'] != null) {
        products.value = (productsData['products'] as List)
            .map((product) => Product.fromJson(product))
            .toList();
      } else {
        products.clear();
      }

      applyFilters();
    } catch (e) {
      error.value = 'Failed to fetch products: ${e.toString()}';
      products.clear();

      // Load dummy data if API fails
      _loadDummyData();
    } finally {
      loading.value = false;
    }
  }

  // Get product by ID
  Future<Product?> getProductById(String id) async {
    try {
      final response = await _apiService.getProductById(id);
      return Product.fromJson(response.data);
    } catch (e) {
      error.value = 'Failed to fetch product details';
      return null;
    }
  }

  // Create new product (admin only)
  Future<bool> createProduct(Map<String, dynamic> productData) async {
    try {
      loading.value = true;
      error.value = '';

      await _apiService.createProduct(productData);
      await fetchProducts(); // Refresh products list

      Get.snackbar(
        'Success',
        'Product created successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
      return true;
    } catch (e) {
      error.value = 'Failed to create product';
      return false;
    } finally {
      loading.value = false;
    }
  }

  // Update product (admin only)
  Future<bool> updateProduct(
    String id,
    Map<String, dynamic> productData,
  ) async {
    try {
      loading.value = true;
      error.value = '';

      await _apiService.updateProduct(id, productData);
      await fetchProducts(); // Refresh products list

      Get.snackbar(
        'Success',
        'Product updated successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
      return true;
    } catch (e) {
      error.value = 'Failed to update product';
      return false;
    } finally {
      loading.value = false;
    }
  }

  // Delete product (admin only)
  Future<bool> deleteProduct(String id) async {
    try {
      loading.value = true;
      error.value = '';

      await _apiService.deleteProduct(id);
      await fetchProducts(); // Refresh products list

      Get.snackbar(
        'Success',
        'Product deleted successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
      return true;
    } catch (e) {
      error.value = 'Failed to delete product';
      return false;
    } finally {
      loading.value = false;
    }
  }

  // Filter products by category
  void filterByCategory(String category) {
    selectedCategory.value = category;
    applyFilters();
  }

  // Search products
  void searchProducts(String query) {
    searchQuery.value = query;
    applyFilters();
  }

  // Apply filters and search
  void applyFilters() {
    var filtered = List<Product>.from(products);

    // Filter by category
    if (selectedCategory.value != 'All') {
      filtered = filtered
          .where(
            (product) =>
                product.category.toLowerCase() ==
                selectedCategory.value.toLowerCase(),
          )
          .toList();
    }

    // Filter by search query
    if (searchQuery.value.isNotEmpty) {
      filtered = filtered
          .where(
            (product) =>
                product.name.toLowerCase().contains(
                  searchQuery.value.toLowerCase(),
                ) ||
                product.description.toLowerCase().contains(
                  searchQuery.value.toLowerCase(),
                ),
          )
          .toList();
    }

    filteredProducts.value = filtered;
  }

  // Get products by category
  List<Product> getProductsByCategory(String category) {
    if (category == 'All') {
      return products;
    }
    return products
        .where(
          (product) => product.category.toLowerCase() == category.toLowerCase(),
        )
        .toList();
  }

  // Get featured products (top rated)
  List<Product> get featuredProducts {
    var sorted = List<Product>.from(products);
    sorted.sort((a, b) => b.rating.compareTo(a.rating));
    return sorted.take(6).toList();
  }

  // Get new arrivals (assuming products have creation date)
  List<Product> get newArrivals {
    // For now, return first 6 products
    // In a real app, you'd sort by creation date
    return products.take(6).toList();
  }

  // Refresh products
  Future<void> refreshProducts() async {
    await fetchProducts();
  }

  // Clear filters
  void clearFilters() {
    selectedCategory.value = 'All';
    searchQuery.value = '';
    applyFilters();
  }
}
