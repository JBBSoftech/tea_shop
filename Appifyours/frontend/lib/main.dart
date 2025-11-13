import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

// Define PriceUtils class
class PriceUtils {
  static String formatPrice(double price, {String currency = '\$'}) {
    return '$currency\${price.toStringAsFixed(2)}';
  }
  
  // Extract numeric value from price string with any currency symbol
  static double parsePrice(String priceString) {
    if (priceString.isEmpty) return 0.0;
    // Remove all currency symbols and non-numeric characters except decimal point
    String numericString = priceString.replaceAll(RegExp(r'[^\\d.]'), '');
    return double.tryParse(numericString) ?? 0.0;
  }
  
  // Detect currency symbol from price string
  static String detectCurrency(String priceString) {
    if (priceString.contains('₹')) return '₹';
    if (priceString.contains('\$')) return '\$';
    if (priceString.contains('€')) return '€';
    if (priceString.contains('£')) return '£';
    if (priceString.contains('¥')) return '¥';
    if (priceString.contains('₩')) return '₩';
    if (priceString.contains('₽')) return '₽';
    if (priceString.contains('₦')) return '₦';
    if (priceString.contains('₨')) return '₨';
    return '\$'; // Default to dollar
  }
  
  static double calculateDiscountPrice(double originalPrice, double discountPercentage) {
    return originalPrice * (1 - discountPercentage / 100);
  }
  
  static double calculateTotal(List<double> prices) {
    return prices.fold(0.0, (sum, price) => sum + price);
  }
  
  static double calculateTax(double subtotal, double taxRate) {
    return subtotal * (taxRate / 100);
  }
  
  static double applyShipping(double total, double shippingFee, {double freeShippingThreshold = 100.0}) {
    return total >= freeShippingThreshold ? total : total + shippingFee;
  }
}

// Cart item model
class CartItem {
  final String id;
  final String name;
  final double price;
  final double discountPrice;
  int quantity;
  final String? image;
  
  CartItem({
    required this.id,
    required this.name,
    required this.price,
    this.discountPrice = 0.0,
    this.quantity = 1,
    this.image,
  });
  
  double get effectivePrice => discountPrice > 0 ? discountPrice : price;
  double get totalPrice => effectivePrice * quantity;
}

// Cart manager
class CartManager extends ChangeNotifier {
  final List<CartItem> _items = [];
  
  List<CartItem> get items => List.unmodifiable(_items);
  
  void addItem(CartItem item) {
    final existingIndex = _items.indexWhere((i) => i.id == item.id);
    if (existingIndex >= 0) {
      _items[existingIndex].quantity += item.quantity;
    } else {
      _items.add(item);
    }
    notifyListeners();
  }
  
  void removeItem(String id) {
    _items.removeWhere((item) => item.id == id);
    notifyListeners();
  }
  
  void updateQuantity(String id, int quantity) {
    final item = _items.firstWhere((i) => i.id == id);
    item.quantity = quantity;
    notifyListeners();
  }
  
  void clear() {
    _items.clear();
    notifyListeners();
  }
  
  double get subtotal {
    return _items.fold(0.0, (sum, item) => sum + item.totalPrice);
  }
  
  double get totalWithTax {
    final tax = PriceUtils.calculateTax(subtotal, 8.0); // 8% tax
    return subtotal + tax;
  }
  
  double get totalDiscount {
    return _items.fold(0.0, (sum, item) => 
      sum + ((item.price - item.effectivePrice) * item.quantity));
  }
  
  double get gstAmount {
    return PriceUtils.calculateTax(subtotal, 18.0); // 18% GST
  }
  
  double get finalTotal {
    return subtotal + gstAmount;
  }
  
  double get finalTotalWithShipping {
    return PriceUtils.applyShipping(totalWithTax, 5.99); // $5.99 shipping
  }
}

// Wishlist item model
class WishlistItem {
  final String id;
  final String name;
  final double price;
  final double discountPrice;
  final String? image;
  
  WishlistItem({
    required this.id,
    required this.name,
    required this.price,
    this.discountPrice = 0.0,
    this.image,
  });
  
  double get effectivePrice => discountPrice > 0 ? discountPrice : price;
}

// Wishlist manager
class WishlistManager extends ChangeNotifier {
  final List<WishlistItem> _items = [];
  
  List<WishlistItem> get items => List.unmodifiable(_items);
  
  void addItem(WishlistItem item) {
    if (!_items.any((i) => i.id == item.id)) {
      _items.add(item);
      notifyListeners();
    }
  }
  
  void removeItem(String id) {
    _items.removeWhere((item) => item.id == id);
    notifyListeners();
  }
  
  void clear() {
    _items.clear();
    notifyListeners();
  }
  
  bool isInWishlist(String id) {
    return _items.any((item) => item.id == id);
  }
}

final List<Map<String, dynamic>> productCards = [
];


void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Generated E-commerce App',
    theme: ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorSchemeSeed: Colors.blue,
      appBarTheme: const AppBarTheme(
        elevation: 4,
        shadowColor: Colors.black38,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      cardTheme: const CardThemeData(
        elevation: 3,
        shadowColor: Colors.black12,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
        ),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
        filled: true,
        fillColor: Colors.grey,
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    ),
    home: const HomePage(),
    debugShowCheckedModeBanner: false,
  );
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late PageController _pageController;
  int _currentPageIndex = 0;
  final CartManager _cartManager = CartManager();
  final WishlistManager _wishlistManager = WishlistManager();
  String _searchQuery = '';
  List<Map<String, dynamic>> _filteredProducts = [];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    _filteredProducts = List.from(productCards);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) => setState(() => _currentPageIndex = index);

  void _onItemTapped(int index) {
    setState(() => _currentPageIndex = index);
    _pageController.jumpToPage(index);
  }

  void _filterProducts(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _filteredProducts = List.from(productCards);
      } else {
        _filteredProducts = productCards.where((product) {
          final productName = (product['productName'] ?? '').toString().toLowerCase();
          final price = (product['price'] ?? '').toString().toLowerCase();
          final discountPrice = (product['discountPrice'] ?? '').toString().toLowerCase();
          final searchLower = query.toLowerCase();
          return productName.contains(searchLower) || price.contains(searchLower) || discountPrice.contains(searchLower);
        }).toList();
      }
    });
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'home':
        return Icons.home;
      case 'shopping_cart':
        return Icons.shopping_cart;
      case 'favorite':
        return Icons.favorite;
      case 'person':
        return Icons.person;
      default:
        return Icons.error;
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: IndexedStack(
      index: _currentPageIndex,
      children: [
        _buildHomePage(),
        _buildCartPage(),
        _buildWishlistPage(),
        _buildProfilePage(),
      ],
    ),
    bottomNavigationBar: _buildBottomNavigationBar(),
  );

  Widget _buildHomePage() {
    return Column(
      children: [
                  Container(
                    color: Color(0xff2196f3),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Row(
                      children: [
                                                Container(
                          width: 32,
                          height: 32,
                          child: Image.memory(
                                base64Decode('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'),
                                width: 32,
                                height: 32,
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) => const Icon(Icons.store, size: 32, color: Colors.white),
                              ),
                        ),
                        
                        const SizedBox(width: 8),
                        Text(
                          'Sai Tea Shop',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const Spacer(),
                        Stack(
                          children: [
                            const Icon(Icons.shopping_cart, color: Colors.white, size: 20),
                            if (_cartManager.items.isNotEmpty)
                              Positioned(
                                right: 0,
                                top: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(2),
                                  decoration: const BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                  constraints: const BoxConstraints(
                                    minWidth: 16,
                                    minHeight: 16,
                                  ),
                                  child: Text(
                                    '${_cartManager.items.length}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(width: 16),
                        Stack(
                          children: [
                            const Icon(Icons.favorite, color: Colors.white, size: 20),
                            if (_wishlistManager.items.isNotEmpty)
                              Positioned(
                                right: 0,
                                top: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(2),
                                  decoration: const BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                  constraints: const BoxConstraints(
                                    minWidth: 16,
                                    minHeight: 16,
                                  ),
                                  child: Text(
                                    '${_wishlistManager.items.length}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      children: [
                        TextField(
                          onChanged: (value) {
                            _filterProducts(value);
                          },
                          decoration: InputDecoration(
                            hintText: 'Tea',
                            prefixIcon: const Icon(Icons.search),
                            suffixIcon: const Icon(Icons.filter_list),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            filled: true,
                            fillColor: Colors.grey.shade100,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.info_outline, size: 16, color: Colors.grey),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                'Search by product name or price (e.g., "Product Name" or "\$299")',
                                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                  Container(
                    height: 160,
                    child: Stack(
                      children: [
                                                Container(
                          width: double.infinity,
                          height: 160,
                          child: Image.memory(
                            base64Decode('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'),
                            width: double.infinity,
                            height: 160,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Container(color: Color(0xFFBDBDBD)),
                          ),
                        ),
                        
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Welcome to Our Store!',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  shadows: [
                                    Shadow(
                                      blurRadius: 4.0,
                                      color: Colors.black,
                                      offset: Offset(1.0, 1.0),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 12),
                              ElevatedButton(
                                onPressed: () {},
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                                child: Text('Shop Now', style: const TextStyle(fontSize: 12)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CarouselSlider(
                          options: CarouselOptions(
                            height: 200,
                            autoPlay: true,
                            autoPlayInterval: Duration(seconds: 1),
                            autoPlayAnimationDuration: const Duration(milliseconds: 800),
                            autoPlayCurve: Curves.fastOutSlowIn,
                            enlargeCenterPage: true,
                            scrollDirection: Axis.horizontal,
                            enableInfiniteScroll: true,
                            viewportFraction: 0.8,
                            enlargeFactor: 0.3,
                          ),
                          items: [
                            Builder(
                              builder: (BuildContext context) => Container(
                                width: 300,
                                margin: const EdgeInsets.symmetric(horizontal: 5.0),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.memory(
                                    base64Decode('/9j/4AAQSkZJRgABAQAAAQABAAD/2wCEAAkGBxMTEhUSExMVFhUWGBkXGRgXFyAaGhoYGBgdFxoYGhsaHSggGBslHRgXITElJSkrLi4uGCAzODMtNygtLysBCgoKDg0OGxAQGzUmICUtLzU1Ky8tLTUtLy0tLS0tLS0tLy0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLf/AABEIAOEA4QMBEQACEQEDEQH/xAAcAAEAAwEBAQEBAAAAAAAAAAAABAUGAwcCAQj/xABHEAABAwIEAgcEBwQIBQUAAAABAAIRAyEEBRIxQVEGEyJhcYGhMpGxwQcUQlJi0fAzcpKyIyRDgqLC4fEVU6PD0xZjc4PS/8QAGgEBAAIDAQAAAAAAAAAAAAAAAAMEAQIFBv/EADcRAAICAQMCBAQFAwQBBQAAAAABAgMRBBIhMUEFEyJRFDJhgXGRobHwI0JSwdHh8RUWJDNDU//aAAwDAQACEQMRAD8A9xQBAEAQBAEAQBAEAQBAEAQBAEAQBAEAQBAEAQBAEAQBAEAQBAEAQBAEAQBAEAQBAEAQBAEAQBAEAQBAEAQBAEAQBAEAQBAEAQBAEAQBAEAQBAEAQBAEAQBAEAQBAEAQBAEAQBAEAQBAEAQBAEAQBAEAQBAfFZxDSQATFgTAJ4SeCMEfLMU6ozU5oa6SCAZEgxYwPgsJ5MtYJayYCAIAgCAIAgCAIAgCAIAgCAIAgCAIAgCAIAgCAIAgCAID4rDsnwWH0MrqQsm2qDlUPwafmsRMyLBbGoQBAEAQBAEAQBAEAQBAEAQBAEAQBAEAQBAEAQBAEAQBAfNTY+Cwwivyg9qsP/c+LGrETaRZLY1CAIAgCA4U8WwmAb7CRExynfyUcbYSeE+TZxa5O6kNQSgM9jcxcHB4cRJsNxp2Et5lcPU6+cbUq39vcvVaeMo8krMsxcGaW2eR2jyPED81Y1+v8mGI/N+xHRQpyy+hBwmfObSJeJ0kjWTAI+Z4KnT4w41LfFuX6E89FmzEHwXmXYrraTKkRraHRykLuVWeZCM/dZKNkNk3H2ZJUhoEAQBAEAQBAEAQBAEAQBAEAQHPEPAa4nYAn3BYfQyupAyo/wBJWHe0+8R8liJmXQs1sahAV2bZiaUAASb32VHW61aZLjLZPRT5jJODxTajZFjxB3BVmm+F0N0GRTg4PDONXNabX6L29o8G+P6sop6yqFirb5/nUkjRNw39ij6QHsPaN2u1A9x7QPr6LieJqULPT1zlF7RbW+S/yzFipTaZ7WlpcOIJHEeMr0FNsbIqSZzrIOMmjjmeLbemHXIl0cG8Z8dvNQazUKuDWeTaqtyeTN4zHNbUEuAIh0cTwa0cuc+HNeZrucZ+b37HWjRKcdq6ECpmmtxZqgD2yPsjfSPxR7tyoWpWNzn/ANk3lKCwup9Ydv1ipTaRpw7Tf7scieJO08JVnRxU7VGx8Z/iMWvyK3t5kz0CkwAANAAAAAGwA2heuSSWEcBvPLK05uBW0Edk2DvxD5XVJ66Cv8p/n9fYnWnk696/iLRXiuEAQBAEAQBAEAQBAEAQHGviWt7zyG/5DzWG8GUslNic9xDZ04Gq4c+sZHoSfRY3P2Ntq9zlWzmu5jmnDFsgj7btxHCmsbhtRyoZlUZWeRRqaHtZ2nU3WLdU8O9Yy8mcLBIrZ/VbtRDvPR/Ms7mY2o5N6XBv7akWNmC5rxUidi4AAx4Sm8bCTmWMp1RBg0xBFVpmDztu3gVzdbZTa3Rb09/ZlimM4+uP5FPiCWvDH9lxsCD2XA3HcRZcXy7tNJ1t4+q7l+KhZHev+iAysKNZzX2a7tA8ASJIPcfiVDPL5fUsKO+v0n3jK1SBUAJLAH6SYAaDZp8QXeEjkp5ahtRU+cEddcMuK7/uTW48ml1+Hdu0TaSWbkfvAT5renUWUye19SGVEd22xEfE5k1rZHa1dombx9kTxPE96ivtc+O/cmp0zbKrD02VGVHvPbILwbiGgbg+70UaT4RYlJxklHofXRktbSJDYa1sSd3OJlxPu9Usm02+7F8cyUT8y3FvLOrY3UHP0t4AajYH8uC2hXOySiurM2Rrh6n2N3gGOoYYNc8PcBAI5k2HeBPovUR/9vR6nnCPP2NWWtpYyU9XD9ZVp028CJP+Jx9wHvXCord2ojH25Zfc/Lqbfc1q9OckIAgCAIAgCAIAgCAICNj6xaw6fbMhvjz8lhsykZ59Ks0hxZVmZs6m8Se46XEqPDJMo+nZhUG+tsc8O/1LXELOWMI4Vs9dsX/9KoP8ixljCI7s3BEGrbl1dU/5FjJnBDxGb0xImoT3UH/5oWDOCmzDFkgtNKtBtJDWT7yShnB+5RXfTbp0uFJ09nUXuLj9oSByMhvOVzfENJ5sN0Fz+5a09iUuWW1TGl9HS0A6e0031Mi/Z7u5cqvVy8vyprOOj7ovPTJT39M9fqSq9FuKfh3t9kjW7vaBcHumPcsY3TI1N1QlEj5vif6vVIiajiBw27LfgotyeF7sm08H5i+iKjoljurLqBtJloPBxEkecHzHetruVuRY1Vak1JEvB5YatZ4j+gZ2ye8/2ccpv4GEgsx3PrgitucIqPdkHpBitbuxIbIojT9su9oDmIBCVRx+PUlqioRzIuMxoClhmUZhz7Og7A+1B4Q0RPgjSWH7EFbdlrkScDSDaWvR2QIYwcfxH5f6rVemLlLqyOyTlPbFkNuauHaaIa21zIc7ujkAb95WtUrK4OOevJLLTQb56mq6J4Qin1z/AGn7TvpN589/ABej8M0zrr3y6y/Y5GutUrNseiL5dMpBAEAQBAEAQBAEAQBAccXQD2OaRMg+/gRyKMymeI4fpBjqb6jGYmppYC5rakVLaNcEvBcbW3XM86aeD2C8L0llKnjDeOh3w30hZiWg66PnSv6OCy9XJD/09S+kmTcT01zDqm1gcMQTpI6pwIN4/tLiAs/FSwRR8Dp3uGXn7f7FMfpMx5sBh5/+N3/kW/n92YfgUHxGTKrGdO8f2nzQB2MUr+rjyW6sTKl3hXlxbz0KTGdM8dUHaxBH7jWt9Yn1W+Sp8PBRyegfQ2+q52JxDnOe5rKbdTu0QHFxcRPgFHJzUZOHLN9dCEY1x6ZNQOqe8vo1BrJ1R9h07xaB5eMFeZ1Nm+blJfkTwU4Q2tcEbJqppPxQeNB/s2k7tI1O08D2itvMShui+xtYvMcF2OGeO04Sk4/vHzcD81GlmaX0JtP/APJI5uw1HEUm6bVCGgObubiPEAjxELEZShLDN5ucJNvoTc3xPU0mYamYc+08Y+0896zGW5N9kQ0Vb5b5DL8LSZFd5Ap0WkMnaftP8fsjxPMKStN9O5rfKT9KIOV6sZX+sOaRRFqbDxb953cSNuPhvvZitbV1MyahXhPlkzNcea9QYWi6J/aPH3W3cB3cD424rRRb9TNa4qtb5Ff0ix7ML1TSzUCQGsmJaPaJ8h6hb6WtW25/tibTtbg33Z6J0czuniqWtgLS2A5h3bIkeRBEL1UJbkefsg4PBbLc0CAIAgCAIAgCAIAgCAIDxDOMKW4+syLEVQP+oxvoWrlWrFjPb6GxS0Uft+mDNYYENgiCLEFV5dTtReVwWhd/VXD8fyP5rPYgx/Xz9DP4ZsCTuVvJ54JK1jkj5lT/AKF7uZaPj/opaX6sFDxKP9J4KCoLR4K4jzk1xg97+gnDxha7+dYM/gptP+Yreno2V/FX/UjH2icM7yiqx5fRMuk6muB0uLDpLhpnSdr94VHU6GFv0Zrp9W61h8o7MxT9AFai6ox2zm9qDtYtuCO+CuNPQW1N4WfwLsLK7MOMsP6kLpDWeaDKbKVR4GkAhhJABBOoRyG6U6a2ct0o4Jqp11tty6nzk9F1Kqyo6lVpiHE9g6CYieU33W9mlvUXmJm++qxYjIi49pr4k1A15a2xIaYLRwnhckzyWtentUNqiSQtrrgluRHzRtSo/S6m/qxBPZ9ruECw4KWvSWwWccmVqKf8ibjc9qdX1bKZpNi7iQIAGwvJPlZIeHWOWZfkVnbQpbm8kDo7jqgD+rbqe4yS0WDWzpbJAsLk8SSVtqdOo8OXH6mysjY8tEipkzqtbra7w6obMEWaBwEi+8zCihq/LjtrX3MumL5ZbYV9SjIp1HtL41Qd4m/qtVrtR1TMrSUtepZPw47EN2q1eXtuM9+9kWuvT+Y3+Eof9qOtPP8AFsP7ZxO3aAPyUsPEr4vl5/HBifh2ml0jj7sssH03qtMVqYc2YlljtyNjx5K5T4r/AJr7op2+EL/65fZmrynOqOIH9G643abOHlx8RIXUqvrtWYM5N2nspeJosVMQhAEAQBAEAQBAeP8ATzLmjMQTqioYPaNpYyIGwuHLnalYmeu8Gsb0rSfKyY11Nwc4FxkOIuqjPQw5imWuFqF1GowxA7UaRvETO8+aynwVra2rYyTKAUHTGv0CzvXsWHVL/L9iDmgeJBeSCOQVilxfKRzdZGyKacsr8EUsS5oHFWexw8bpqKP6P+h/CdXllL8bqj/e4gegClr+U5evx58kuxaZrTh77buBjuezT/NT9UkQV8tIquilfrKAMFpDjY2I4x8VrW9yyS6ivyrHDOfqdsgxpr161Krh9Ap+y599QPAbi3GDxHesQnuk1joWNVpYVVQsjPO7t7H30yxdLC0DUiHHssa0lupxsLNOw3PcCs2SUY5K+mqldYoIwOVdIml4+th728Iuwd5p8fVVYX/5HX1Hhc4L+nz+5rKpwtdgezqqjZg6Ym/MbgjvVnKfQ47hOLxJYMjhsr63Elg7NNoBcBYG9h5/mqer1Cpjx1ZZohv6mxoYK0MaABawXCcbLfUdDfGHDP1tEidUDhYJJbXhhSz0ILsIQZA4yePCIhRvlcdSwpnGsybge7itVybxljuR6jI2gc1gmj9SJiGArdPHQki2Q+sLHAtJDgbOBIIM7iO63mp65uL3ReGJQVi2zXB6X0Q6Q/WGaH/tGjf7w59xuLd67+j1fnLbL5l+v1PMa/RfDzzH5X/MGjV454QBAEAQBAEB5r9KNGK1Kp+56F4P8zVR1a5TPSeAyypw/n84MRnNDTWd+Ilw8yqEup6fTT3Vr6H1lTZFQc2ojGoeNrKoe0hZIOfiABzGr37Kzp13OXr7E44RncOZqDun4K3L5Tgaf1alfQ/qnoRh+ry/Cs4iiwnxc0OPqVPBYikcbUy3XSl9Wfeds7QPNjh/eYQ9voHpIjiVGSCKtZv4tXv/ANwtYm0ueS6pui4W5oYzOMwwuOrvoVHEGm4tpmYBIHbc07TMi/LvXP1Fm57V2Ozo6bqIK+K6mfxnQ6o1xDHaxaOBgmD3WVY60PEIuOZLkpM8w76DxpY6npA7bZDieTj5G3FbQk0bJV3R9WGWHQrOg0VzXqNDi5mkvIbqaA6Y+9B5BQ6yErdrRzHVCmbinwbnBZ41zQWQ8ETLXA28j3KvGyyCw4kcqoS5UiO7M+uMUmOcRcja3+wOyrT9bNYX1xe3JFGaSbQGgank7wCAeG99lFFS6MsWzhDHfJ91c1GwFkcixHT92cXYqnHC/kteSVVyyQa+IYeI8vlyRJkyiynxT7mLhWIrPUlXQv8AoRSc2tTdJkuHuNj6E+5WdHN/Exwc/wATw9O0z1XUJiRO8cY5r0p5U/UAQBAEAQBAYT6WKE0GPjYkf4mP+DHKpq16UzueAzxqGvp/P3MN0hEim7m1vq0fkufI9Ponhyj7NnDJB+0P4D8CViJJq3xH8Sn+1+uSwXSq6S1pdP4Wj3CPkrmn6HD8R9CKXK6ep8cTbzJhWJ9MHG0T9cpPsmf17hKOhjGDZrQ33CFZOC3lkPPTFMP+45pPgewfRxWsuhmPUyeR5kx9clhv7DhycIt6KKEk2WbaLK0nJdeRm1Z9PEa+v0trNNPq+DSBeoLxIHdvCjsexubfBYqcLKlUoerOc/T2MdmOT0xUmi8uYZJEEEeHMLi2amOfS8no9NOWzZNYJ+EzepSAA7bWxYkzA4B260hc0+TW7R1zWVwy0xWZ4bEtGuJuND+/0OytTfHBzfJspfBAwNZrANFBrqdMPexzWyJ1EuAMQNrwdwVQt35w3ycq+xuxszA6PfWajsS+m+i112ikBLmkTJcPZBMFW/PnVDbHn8yrl9Ua7LcFrosqCs8PMtJsBDSQLNHcuZbNKWMGdueUyizjMG4Z8VaznEtJGuQCZiACrVdc7l6V0MbZN4RSU8xdWbGEa91UG7STBbx/dj/RWvIUObehdp12ppn6stfU0LMtf1LhY1KYOtwcYHE2PtEAwPDyVJ2R38dOxl+I3uW5fkc8xdQpljJqBzhMt7Tj36eI8glSnPLwsG8PFb4yy3kYTJcTVpOcR1dSew1xnUAdzA7Nrj1WZW1RmorkvPxZdME3CPrU3dYx7S1ga5rpbd4BDgBxG2/NIWRrkpR4lkoarWu6OOxrOj+eh1TXVLwYLXONxG4iO/3Srml1r+I3XS6rH0+n+pQ6rCNqvQkYQBAEAQBAZn6Q8Prwbu4/zNLB6uCg1CzBnQ8Lns1MTzDGu14ak7k0fEj5rly6Hs6eLZL6kfKHQKh/D8itUS6hZcUVLfaQuMz3SKr2o5Qr2nXpPN+MW5ltR16D4fXiqXZJaKlMugTDQ8Ekx3BSWzjHDk8I5emT8uz3xhH9EY7pUR+ypT+8Y84HA+KrXeKQj8qyVKfDnP5ngpsfnleqx1N+kMeC0gACx7zsqb8VsfGEXI+G1LnczN0KGhzqrC4EnUTI5QJtwUC8QsUspF2WjjOChJvCOGcUKlZwc+q4vb7JiG7XlvpupJa52cSRnTaVUPdD/ciNbiWey5j7bXafC/HzUGapPD4Lrn7o+qGfsB0V6ZYeYF7/AMwUi03HBHy1mD+zKzpniQaTWsAe10kOaeI4Hlvx7lb0lb7lbVajbD6nfCve2lFOk/qzNw2o1paTMFtm87j1Vtw0spet8o2rp0V63SeHjp0IeNxGIJaddcFoAYKZc1rQAAAA23Dit3LTJfMiT4HQQTxz9y/6J4ytQoHXh8TVc55cbDbgQXEcFwdXCqy1Ymkji3aSO9+X0KTNcc6tig/EsNKnfSCCNDe8j7U3J225K5VCEK8VPJY0V1embhasPPDfQ75tl9Gm81KDw5skS13aHIhzY4c1NP2Z2qIV6qHrSzgrBWqanFlaqAQRDjMhwhwIuLrRwh3iaPwKiXXj8CsxuIeXmpqPWEG7ZDoGwEcApoRjjbjgh1Om02lpe7H+pYZfnOMZRfTe5wFUDTUqmS2dwCTxHPZaS0tE5qWOnsefoektltcmmWOXdI6OrRiGCm8AjrKd2OgQAQCd+5V7dDPrW8r2fUlu8PaacHlGx+jHCYivSZWeGluqCfZnTE2vffgApV4c5XRnH5U/cr6uhaezZnnB6qu4UggCAIAgCAq+k9LVhao5AO/gcHfJaWrMGWNLLbdF/U8ewNOaHVcWl7P4SPzXIZ7hvE1L3SOWUU+xUPMR6LRE+ofqiUGJq6A53IH38FtCO5pE99ihW2QujPRupj65EltNt6lTlOzW83H0Vy22NUeTyGo9c8nr2U5RQw7TSoM0tETzJj2nH7RXCv1E7JZM1xUEforXc1o24gR5d6gcn1RYUOOTkaIneT429R5LEoYeM5NoTys4wcjhwbm/D3Wt3LXnOCTckuCJVZEeFr/Ayts9kSRfGSKWgtkHv4z/AKrbPY3y1LnoQcfQa+A7/UX5x+rqWuco9DfqVlPLGss7taxqa7mNoI4ObO3n4dnS2xnHjscLWQnGeZM0XQLNKv1qpRqVHOYKUtBMwWwBE8IPoqPiFMIR3RWP+iBZawTs76Xta4soxUcJBI9hpHAkXJ7h5kLk1aOyfqseF7dzpU6ZyXBAwVbHV5c6o1rOAFO8/wB4mysSp08ekW3+JK6lB9TrisurA06tSo11NjtTxohwbBaSCDFpkyOCm08q4S6Yz9Tn+JQ82lxXLRRZuMJJ04epWN9T6LAAI79ifBdCMu25I4FGj1bW6GUfPRzLsPUdrawVWWBY9xa4GeIJi+24W0m+htbfrqWt8mvuaPGYalQZqeBSp76AA2ecniFHy2UpzssfqbZj6ObVn4l+IpsYW3DQ8GzdyRfsz8AFrqIVuGyTf2PVeF6Cyqvd0bLfBY6jXqBlXBxUP2mDWL2vEOF+4qn8Pcl/Snn6dzoTzVzL8z0PonjGUSKAAawmzfuv29x28fNWPC9bONjou79Px9jl66jfHzY/xGzXojkBAEAQBAEBxxtHXTez7zXN94hYZmLw8niWBcQ+oD/zSf42By40up71PdXF/T/U/aNVrGvB+86y1JJJyaZhc1rE6vHZWqY4NNdPMD13oblLaGEotgl7g17o4ueNRNuQMKjbZ5lko5PNyb6l3XwhY4md/wBHxVS2iUHg3rtUkQ62GcJfw4Dnx8uCidfvwTRtXynJtLtcPDj/ALKJ5JMn49kXJt8O+f1skuenBlMr6pBO1jIE8/mnR8k6zjCZCxdDTfYExIHFbQy1kljYs4KjGDSQ3VMX1RF/PdWI4fKNlIGuDSqNP9nNQd2m597dQ81Np5Ou2L9+CrrK1OtvujKtFTEVCKZgm5MkaW95HujiutdZGuOZHHpqlbLbE0GB6JYl4Bp1NIAA9kQYtx224LmS1cJdY5Oq4OrCUy5wuRY6nc4imByIPxaVDOdP+L/Mx5kpPrn7HatiMYzfS4HgHRPhqYfiof6T90SqGeVg/G4nEMEOw5A5Sw/kjjU/7v0CzJ5S/UzmbfWA7raVJzHC4LdPmCJgtPIyrmmlWuHIi1lXnV7JxyVuYY99cDrKVVrZm9+0PE3AtAKtLCfEkc3QeHKn1yi2/wBju3NWMaB1dTbgGjzMuKhen3P5jtO+SXym7+izE4epVBLNLjOiXSS9ok6rC+kagAIse5WdJVCNvPLSOV4lK2Val29j0nFZPSfUbVLYcCDIMTFxPNXZ6Wqdisa5Xc5Mb7IwcE+GWCsEIQBAEAQBAEB4RnjjSxdZgAHaB/hLqfwauRcsSZ73w3Fmnj+H+xA1S557/koi90SMnmZuQrtK4OZrpcpHtHRHMxVw9I7PDGhzTYggRseBiQeK490dljkjiNf2s0TjIkpvb9REo4eCG2kR9qRAERa3moZvL5Jo8Ij9XfY/Lh5cAodzxgmTXUPw88f1+visNZRhTw8ldXoOmNMwtcSxgtwnHGSHUsZj9fLh7k7JGY5RHqaXSHAHxWUmuhJkqK2HaBVY09uq002jveInwA1HyVyqTTUpdERX5lHau5UdG8xZgatZlUtkkAO3BLJBE+J+KvauE74RlDoUNL5cHKM39zd5X0ooaLkGbiCIN+5czy5QeHEt2Ub3uhLg54zpZSB0gtBO0kfBPKskm0hGiKxukRKOajVr9o8JNvVR+TPuixLZtxk/KvSJr7kBzROxkWsbiy3+Fs9iOHlx+WRX1ekGHm9Rrf7w/NbR0lr6Ik86tdZEPMekGGe3QHMI3JkXPOBJU0NJdF5NY6mrvIyGOzCmXEN1HwBHleF066Z45Kd+rg3hG/8AoZxlGpiQ2qzS9oJo9q2rSWuBEXcWuMedlPRXGM37lLW3zsqWOF7HuCunICAIAgCAIAgCA8T+kejox7iBZwI+D/8AuFczVL1M9r4DPOnx7FDhzcjwVZHYs7HLoicGMS+pjHNApgFjXCWudzIggxa3f3LbUytjWlWs59v+Tga/dKbUTTV+lGFqvLqDarnMtqaNIE/vxbyhcyvR6mHV4z2/6IaK3dldcHzlXTatLwWU6rWnZjg17R37hx5ltl0fh4pLP/A+DUniM1n2LzAdMsNUOkirTd91zJ/kmfJV56eMVlsgnp7oS2tFh/xmj9+PFrh8WqBKHv8Aqa7Jexxr5zRizz5Ncfg1bShX2ZmMZvsQambUyPbef/qqf/hR7Y+/6kqjNdiFWxUnsU6j/IN/mIKPy11aJobscmW6R9InULCmNfIumBMSQ0/O6uabSxs5zwR6i10xycej/TGixxq1KFVxs3V2Dpkg9ltoFt1vqNDOS2xkkvbkr/Fb442lZgK7TW7QB1AmXCYkyXcVbtUlBYItPt3PcWNDLsLMGm0g3LrjhMjx7lX86z3LvlQ6YP3/AIDQiSwEXggm9iYvMW+C1Wpm3hGXp4dWj8/4Rh41dWwW+7ba3mnnWe48mHsR25Jhy64BnYAWtwW3xE/ceRD2ODsCwFzgBygi2/BZ82TWB5MF2O+CyY1dYphpcGlxjjeAGgDdayu24ciK2VdOM9yvzzJMTRYHvoPaAbugEXsLNJhT0aiqb2qRRsur6o1XQDD/AFbRVe3VUeGvGoRp27JB4yN+R7lS1OpatUodIvp7lCy6TeM8HtORZ0MTqhhZpDbEzvM7Wiy7Gm1UdQm4roRFsrRgIAgCAFAVGOzKoy2gN5SZPuBVK7UTh2wWq6YS7le/Nap+1HgFVeqtfcnVEF2PPPpBJNWm8kkki5/E0j/thauTkstnofBfTmKMvgX3ee8+i1fB3HyjLYp3aJPP5roR+U85qX6mavCVqNZp1NBiNrGABYkC4sqE3OD6kdeHyiQ3JqBEuY2bkESDG4vci0eq086fuZ8qOc4IWNyhpLSC9rYs4vJ0mI7IBF+K2V7xyJVZfV/mWeW9J8bhiGkivSI+02XxztwEcRKhempmnt9L/QilVzzyavLOl2FqwHxTJ4n2Z5TwPcYXJu8OthnHP4f7f7GXXNR3ReUaRlMRLbhcuUJoic/cz3TTOG4albTrdsNvM9w3Kv8Ah+mndNJ9OpJU8Zkzx/Eu63U8kyTJJ3cefcBwC9YvRiKNLJRsjhdP3IlNwLhAFhyNydpW+OCr05RseiGZPB+rtose83aXAbe0ZJ4COYAVDX0r592EVbFJrKfQs8dkJrVSWVOpO51AFjQR2nSwxeDbmVVr1OyOJLP17matXZDg+85yZ4FD6oDUpSGVKhuNWqC7SSLXNhyhK7oep2cPsi0tdKK5QxvRes5w6qo1zWmDLC0Azu2CZIE2SvVwx6k0F4g+6KXPclxeGYwjTVZUeGh9MEkOOzXNIlvw71bptpsz2x7mZa7K4J+ZdDsSytSBeH0ajgHVAIFOeJbPHaeZuoY6yqUW0uV0XuaPWtFxl+Cp4M1qtNh1t0sgyZJMNcR3kySLWgQqk7ZXKKk+ClbbKfLKPpliawrUKzg+q2D2BOnULSYMcRH7qsaNQlCUOn1IownY9serJWTZpjCWlwYym6SYmQOBJ1EchstbdPThpZbRdv8AD50V7m+fY9W6GZc1rTV0kOjT+EixMWvcR5K94RV6HY08t/oUXwaddg1CAIAgPl7gBJMBYbS6mUsmezRtOS5tSTxBv6rmXxrzuUuS9S59GikqF/Aj9eSqlox/TGodnm/YLZts+DFhNnlSR5izqeFySuMrRploI5z7lhyyz0SjwUVZrW1QaoJZqaXBu5ZI1BvfEq7FuUPT1PO66DhJ5N07KcNiBTrYXXhS8AND2jS+eyB2SRPDh5rkxndCTrsxL9/sVIrEVJfp/qV+MyrMKXYNI1NiCyDtsSHAEyFJG6h98P2ZJveMrkg4zHV6YAxFJ7DwLmkT3Tt6qVQhJ+h5MK5dyPSzGk6S4uDuFrEbad777FbuqSNvMicXY9gcHF5LPZiNm+HcfHit41yaxg3o1kaZ7s8PqW2W9Jn4W2HxLXAXDDdg5Qd2+A9yhs0kbGpSjh+66k9temuT8uSIWb0cfjqjavUlwi2mAOdg4zHx9yUy0uli4bsHOthZlYXH7jCdEcXVPaptpAWIJ7U7zpbznmk/ENPWuuTVUSn14RcYno3Qy9zTUcatVw+zGljSYmOJvHE3UPxFuo9MMJfzglo8uHrefuQMozqlhXVnaJe7SKbjAht5Dp2GxtO3BWNRp53xjl8Lqc22tOfD4NhSznCmi11SoGVHHtM9oAg6S+17i4XLenmpNRWTSeksjLCWSPjc8qVnaMM17mtAE0uzA+6J7rSTzW0aIwW6zGfqWtPo8+qwnZfTFbTSq1sRRf8AZDzv4OvPvUTym8YaJbNLCKyo/qWtTIKjBH1ioCL7N5zvF1Ts1ThPEq0iGFFUuSkznOHYYDXVL3HaiGg6ufCR47fBW9PX574jhe/JI9DDHpznscqWcsqU61aWt0U50XLhYEawQOLYEczdSSolGUYdcvr2+xzpUyU9jRQ1OkD9GmrRDqjrAkxTAJmw3kT6K0tNFSzCXC/Murw2cbFzg+34g0iKYIOlo1Wm5l0e5wU1Mcpt9zo6mWZY9i7wfTrEsDWB/ZaA0NDGgQLDYSrbtnjCZz/ha+6PV+juNqVqLalRgaXC24kc4O0q7TKUo5kjm3QjGWIss1KQhAEAQELEZXTeSSDJ5FV56aubyyaN84rCKPM8PTpugOHm4SD3qhfVGDxEuU2SmstFNmODpVmFj4IIizoN+RHgPcoU2i1XZKuW6PUymL6ENv1WIaO5w+bSPgtt3udKHitiXKyZzOOhNa2qqwjbs3+asV3JIq6nUPUdsF/0UqCnRZg6x7THE03GweCdYAn7TSTblfnFPVxcpK2HYipbjmMu5PzvF4ypVJBdSZzBBc/wI2Hr4KitkW5S5ky7p6q9m0+8HlBcJex75+9We34O+S1V7i+BZGpcJ4OVbIKbuyadU9xcXD1WVqbF0NsQxy0RT0Vw7T2qVRp8Afktnq7u7MRrrfMcHN2V0m/szUnx/MH4LHxNj+boTRrhnOEdaGbYyhBltRh+y9omPEAH/ZZ2Uy4xginpozfDLjLM3ZWDqgGlwEOYd+YjnxXOu0zg1Ht7mjqxiJ570xx7sVijh6TXPcS0Q0SYaNWm3GTJ8F6Hw6jyqVKRQ1U1ny0Tst+irFVBNQ06Hc6Xu9zbeqsS1kV05KWxdzT5b9GvUtGrF6tN+1S7I8O1MeKqX2xnnCwXKNVKtbVyTqgbgwSHNqC06QQYmJ3N7yufhOWE+S55krY5axgsMQG16cdW8zserd79keWunJFGSg+WfFPE4ltLq30qjiPZfAkjkbzKhupc8Z7fz8glTv3RZkKvR3E1HOqGk8uJ5cuF/RXoS2xUV0L0b6Y9ypzTI8SBfC1vEU3OPkGA+qsVSWeuCO/UUyXuVuIOLqEU6eFqh3A1KZaPENIk/qysV0QTy5fkVbdfOaxBfdnpWR9Dh9Sk4Sq/FFu9ZwY0vJku3mLk3b3Kyqt0XhNP9DnSvamk5LH6lx0UyDE0qwNTDUW04MyWkgyI0wCSfEhR6bTXQnmx5Q1OoqlDEG8m8XSOcEAQBAEAQHCvhGP9poPiFpKuMvmRvGco9GRa2TUiOyxoPMifmopaaDXCJI6ieeWUGN6LkkmJH4XR6KnLS2LpyW4aqBXv6NNG9OoPeonCxdYkyvT7lRmPRjWC2xaeDpBHmOPesKTi8m++MlhlUMgx1K1KuHtH2K3btwAfIcPOVicaLPmjj8BCc6/lf5kxuZY6naphgf3KjTPk4N+JVZ6OtviX6EvnZ/t/U6jP6jfaw1Zv9wH4OKjeifZoy7YvsfFXpQ8/2VXw6s/ms/CTz8yEZ1rsyHXzqu/2MJV8dLWz4kulSR0S7yRn4hLsysxzMe8E9S2m3m4lx9zWqaGmqj1eTD1M38qwd8g6G4qs4VvrbaYBg6W37xBPxWLZ0qLjtz+JHZbanyzf5H0Zw+DBNJnbdd1R3ae7iZcb+5QTslP5uxUby8k+rj2ie0R6Ks7kiVUSZVvxNWvPVtcWMEucATPcABLj3KWqm3U8R6e/86kzVVHMuW+386GfwOSYx9QPrYdxbMhhb2e4ukguOxvyUvwd0H/Thz78Fiep07jzP8jXjC402gNAGwDR8XFY+E1sn8qX3RRdukXdv8z7blWMO72j+8B8GrZeG6t9ZJfz8DD1WmXSL/n3PtuQ4g71f8Tlt/4nUPrYvyNfjaV0gfn/AKbq/wDNH8Tlj/w1v/6fp/yZWvr/AMD5b0cragTU2cD7buBBW9fheohOMt64f1E9dVKLW39jVLvnKCAIAgCAIAgCAIAgCAICLhOtM9a2mOWkk++QtI7udxvLb/adK2HBiDEcgL+8JKCZhSwHYVh3Y3+ELOyPsN8vc4jDy+9Olo57u90QFp5a3fKsG2/jq8ncYZn3G/whbeXH2Nd8vc+hSb90e5Z2r2MbmRcdlrKg+6eBbH5XUVunhZ1JK7pQM4OhBBJGJcZJPbpgxJkwWlsKlZ4VXJ5y0XIeIyisbUHdG8Sz9nWBH7xb6GQqk/CLE8wn+ZKtfVL54fkdMJ0cqvd/WCC0XMGS88OFhCzT4TJzza+F7dzNuvrjHFK5+vY1FCi1jQ1oDWjYBdyMVFYisI5MpOTyzotjAQBAEAQBAEAQBAEAQBAEAQBAEAQBAEAQBAEAQBAEAQBAEAQBAEAQBAEAQBAEAQBAEAQBAEAQBAEAQBAEAQBAEAQBAEAQBAEAQBAEAQBAEAQBAEAQBAEAQBAEAQBAEAQBAEAQBAEAQBAEAQBAEAQBAEAQBAEAQBAEAQBAEAQBAEAQBAEAQBAEAQBAEAQBAEAQBAEAQBAEAQBAEAQBAEAQBAEAQBAEAQBAEAQBAEAQBAEAQBAEAQBAEAQBAEAQBAEAQBAf/9k='),
                                    width: 300,
                                    height: 200,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) => Container(
                                      color: Colors.grey[300],
                                      child: const Center(child: Icon(Icons.image, size: 40, color: Colors.grey)),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                                                const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(width: 6.0, height: 6.0, margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0), decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.blue.withOpacity(0.4))),
                          ],
                        ),
                        
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Share this product',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Column(
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: Colors.blue.shade700,
                                    shape: BoxShape.circle,
                                  ),
                                  child: IconButton(
                                    icon: const Icon(Icons.facebook, color: Colors.white, size: 18),
                                    onPressed: () {},
                                  ),
                                ),
                                const SizedBox(height: 4),
                                const Text('Facebook', style: TextStyle(fontSize: 10)),
                              ],
                            ),
                            Column(
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: Colors.blue.shade400,
                                    shape: BoxShape.circle,
                                  ),
                                  child: IconButton(
                                    icon: const Icon(Icons.alternate_email, color: Colors.white, size: 18),
                                    onPressed: () {},
                                  ),
                                ),
                                const SizedBox(height: 4),
                                const Text('Twitter', style: TextStyle(fontSize: 10)),
                              ],
                            ),
                            Column(
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: Colors.green.shade600,
                                    shape: BoxShape.circle,
                                  ),
                                  child: IconButton(
                                    icon: const Icon(Icons.message, color: Colors.white, size: 18),
                                    onPressed: () {},
                                  ),
                                ),
                                const SizedBox(height: 4),
                                const Text('WhatsApp', style: TextStyle(fontSize: 10)),
                              ],
                            ),
                            Column(
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade600,
                                    shape: BoxShape.circle,
                                  ),
                                  child: IconButton(
                                    icon: const Icon(Icons.link, color: Colors.white, size: 18),
                                    onPressed: () {},
                                  ),
                                ),
                                const SizedBox(height: 4),
                                const Text('Copy Link', style: TextStyle(fontSize: 10)),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCartPage() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shopping Cart'),
        automaticallyImplyLeading: false,
      ),
      body: ListenableBuilder(
        listenable: _cartManager,
        builder: (context, child) {
          return _cartManager.items.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.shopping_cart_outlined, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('Your cart is empty', style: TextStyle(fontSize: 18, color: Colors.grey)),
                    ],
                  ),
                )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: _cartManager.items.length,
                    itemBuilder: (context, index) {
                      final item = _cartManager.items[index];
                      return Card(
                        margin: const EdgeInsets.all(8),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              Container(
                                width: 60,
                                height: 60,
                                color: Colors.grey[300],
                                child: item.image != null && item.image!.isNotEmpty
                                    ? (item.image!.startsWith('data:image/')
                                    ? Image.memory(
                                  base64Decode(item.image!.split(',')[1]),
                                  width: 60,
                                  height: 60,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => const Icon(Icons.image),
                                )
                                    : Image.network(
                                  item.image!,
                                  width: 60,
                                  height: 60,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => const Icon(Icons.image),
                                ))
                                    : const Icon(Icons.image),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                                    // Show current price (effective price)
                                    Text(
                                      PriceUtils.formatPrice(item.effectivePrice),
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue,
                                      ),
                                    ),
                                    // Show original price if there's a discount
                                    if (item.discountPrice > 0 && item.price != item.discountPrice)
                                      Text(
                                        PriceUtils.formatPrice(item.price),
                                        style: TextStyle(
                                          fontSize: 14,
                                          decoration: TextDecoration.lineThrough,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    onPressed: () {
                                      if (item.quantity > 1) {
                                        _cartManager.updateQuantity(item.id, item.quantity - 1);
                                      } else {
                                        _cartManager.removeItem(item.id);
                                      }
                                    },
                                    icon: const Icon(Icons.remove),
                                  ),
                                  Text('${item.quantity}', style: const TextStyle(fontSize: 16)),
                                  IconButton(
                                    onPressed: () {
                                      _cartManager.updateQuantity(item.id, item.quantity + 1);
                                    },
                                    icon: const Icon(Icons.add),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                // Bill Summary Section
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Bill Summary',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Subtotal', style: TextStyle(fontSize: 14, color: Colors.grey)),
                            Text(PriceUtils.formatPrice(_cartManager.subtotal), style: const TextStyle(fontSize: 14, color: Colors.grey)),
                          ],
                        ),
                      ),
                      if (_cartManager.totalDiscount > 0)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Discount', style: TextStyle(fontSize: 14, color: Colors.grey)),
                              Text('-$0.00', style: const TextStyle(fontSize: 14, color: Colors.green)),
                            ],
                          ),
                        ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('GST (18%)', style: TextStyle(fontSize: 14, color: Colors.grey)),
                            Text(PriceUtils.formatPrice(_cartManager.gstAmount), style: const TextStyle(fontSize: 14, color: Colors.grey)),
                          ],
                        ),
                      ),
                      const Divider(thickness: 1),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Total', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
                            Text(PriceUtils.formatPrice(_cartManager.finalTotal), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
        },
      ),
    );
  }

  Widget _buildWishlistPage() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wishlist'),
        automaticallyImplyLeading: false,
      ),
      body: _wishlistManager.items.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite_border, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('Your wishlist is empty', style: TextStyle(fontSize: 18, color: Colors.grey)),
                ],
              ),
            )
          : ListView.builder(
              itemCount: _wishlistManager.items.length,
              itemBuilder: (context, index) {
                final item = _wishlistManager.items[index];
                return Card(
                  margin: const EdgeInsets.all(8),
                  child: ListTile(
                    leading: Container(
                      width: 50,
                      height: 50,
                      color: Colors.grey[300],
                      child: item.image != null && item.image!.isNotEmpty
                          ? (item.image!.startsWith('data:image/')
                          ? Image.memory(
                        base64Decode(item.image!.split(',')[1]),
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => const Icon(Icons.image),
                      )
                          : Image.network(
                        item.image!,
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => const Icon(Icons.image),
                      ))
                          : const Icon(Icons.image),
                    ),
                    title: Text(item.name),
                    subtitle: Text(PriceUtils.formatPrice(item.effectivePrice)),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: () {
                            final cartItem = CartItem(
                              id: item.id,
                              name: item.name,
                              price: item.price,
                              discountPrice: item.discountPrice,
                              image: item.image,
                            );
                            _cartManager.addItem(cartItem);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Added to cart')),
                            );
                          },
                          icon: const Icon(Icons.shopping_cart),
                        ),
                        IconButton(
                          onPressed: () {
                            _wishlistManager.removeItem(item.id);
                          },
                          icon: const Icon(Icons.delete, color: Colors.red),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget _buildProfilePage() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.grey,
                    child: Icon(Icons.person, size: 60, color: Colors.white),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'John Doe',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(250, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      // Refund button action
                    },
                    child: const Text(
                      'Refund',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(height: 15),
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(250, 50),
                      side: const BorderSide(color: Colors.grey),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      // Log Out button action
                    },
                    child: const Text(
                      'Log Out',
                      style: TextStyle(fontSize: 18, color: Colors.black),
                    ),
                  ),
                ],
              ),
            ),          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: _currentPageIndex,
      onTap: _onItemTapped,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Colors.blue,
      unselectedItemColor: Colors.grey,
      items: [
        const BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Badge(
            label: Text('${_cartManager.items.length}'),
            isLabelVisible: _cartManager.items.length > 0,
            child: const Icon(Icons.shopping_cart),
          ),
          label: 'Cart',
        ),
        BottomNavigationBarItem(
          icon: Badge(
            label: Text('${_wishlistManager.items.length}'),
            isLabelVisible: _wishlistManager.items.length > 0,
            child: const Icon(Icons.favorite),
          ),
          label: 'Wishlist',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
    );
  }

}
  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: _currentPageIndex,
      onTap: _onItemTapped,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Colors.blue,
      unselectedItemColor: Colors.grey,
      items: [
        const BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Badge(
            label: Text('${_cartManager.items.length}'),
            isLabelVisible: _cartManager.items.length > 0,
            child: const Icon(Icons.shopping_cart),
          ),
          label: 'Cart',
        ),
        BottomNavigationBarItem(
          icon: Badge(
            label: Text('${_wishlistManager.items.length}'),
            isLabelVisible: _wishlistManager.items.length > 0,
            child: const Icon(Icons.favorite),
          ),
          label: 'Wishlist',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
    );
  }
