// lib/invest_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class InvestPage extends StatefulWidget {
  const InvestPage({Key? key}) : super(key: key);

  @override
  _InvestPageState createState() => _InvestPageState();
}

class _InvestPageState extends State<InvestPage> {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  bool _isLoading = true;
  List<dynamic> _stocks = [];
  String _errorMessage = '';
  double _cashBalance = 0.0;

  @override
  void initState() {
    super.initState();
    _loadStocks();
    _loadCashBalance();
  }

  Future<void> _loadCashBalance() async {
    try {
      final String? accessToken = await _storage.read(key: 'access_token');
      final String? portfolioId = await _storage.read(key: 'portfolio_id');

      if (accessToken == null || portfolioId == null) return;

      final response = await http.get(
        Uri.parse(
            'http://127.0.0.1:8000/api/portfolios/$portfolioId/positions/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'JWT $accessToken',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _cashBalance =
              data['portfolio_summary']?['cash_balance']?.toDouble() ?? 0.0;
        });
      }
    } catch (e) {
      print('Error loading cash balance: $e');
    }
  }

  Future<void> _loadStocks() async {
    try {
      final String? accessToken = await _storage.read(key: 'access_token');

      if (accessToken == null) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Authentication error';
        });
        return;
      }

      final response = await http.get(
        Uri.parse('http://127.0.0.1:8000/api/stocks/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'JWT $accessToken',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          _stocks = json.decode(response.body);
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage =
              'Failed to load stocks - Status: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error: $e';
      });
    }
  }

  Future<void> _handleBuyStock(
      String symbol, double price, int quantity) async {
    try {
      final String? accessToken = await _storage.read(key: 'access_token');
      final String? portfolioId = await _storage.read(key: 'portfolio_id');

      if (accessToken == null || portfolioId == null) {
        throw Exception('Authentication error');
      }

      final response = await http.post(
        Uri.parse('http://127.0.0.1:8000/api/portfolios/$portfolioId/buy/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'JWT $accessToken',
        },
        body: jsonEncode({
          "symbol": symbol,
          "quantity": quantity,
          "price": price,
        }),
      );

      if (response.statusCode == 200) {
        await _loadCashBalance();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Purchase successful')),
        );
      } else {
        throw Exception(
            json.decode(response.body)['error'] ?? 'Purchase failed');
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  void _showBuyModal(BuildContext context, Map<String, dynamic> stock) {
    int quantity = 1;

    final double price = num.parse(stock['price']).toDouble();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1E1E1E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            final double totalCost = price * quantity;
            final bool canProceed = totalCost <= _cashBalance;

            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 16,
                top: 16,
                left: 16,
                right: 16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Buy ${stock['name']}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Price: ${price.toStringAsFixed(3)} TND',
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline,
                            color: Colors.white),
                        onPressed: quantity > 1
                            ? () => setState(() => quantity--)
                            : null,
                      ),
                      SizedBox(
                        width: 80,
                        child: Text(
                          quantity.toString(),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline,
                            color: Colors.white),
                        onPressed: canProceed
                            ? () => setState(() => quantity++)
                            : null,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Total: ${totalCost.toStringAsFixed(3)} TND',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Available Cash: ${_cashBalance.toStringAsFixed(3)} TND',
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: canProceed
                          ? () {
                              Navigator.pop(context);
                              _handleBuyStock(
                                stock['symbol'],
                                price,
                                quantity,
                              );
                            }
                          : null,
                      child: const Text(
                        'Confirm Purchase',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text(
          'Invest',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        backgroundColor: const Color(0xFF1E1E1E),
      ),
      body: RefreshIndicator(
        onRefresh: _loadStocks,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _errorMessage.isNotEmpty
                ? Center(
                    child: Text(
                      _errorMessage,
                      style: const TextStyle(color: Colors.red),
                    ),
                  )
                : SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Available Stocks',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Cash Balance: ${_cashBalance.toStringAsFixed(3)} TND',
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _stocks.length,
                          itemBuilder: (context, index) {
                            final stock = _stocks[index];
                            return Card(
                              color: const Color(0xFF1E1E1E),
                              margin: const EdgeInsets.symmetric(
                                vertical: 8,
                                horizontal: 16,
                              ),
                              child: ListTile(
                                title: Text(
                                  stock['name'] ?? 'Unknown',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      stock['symbol'] ?? '',
                                      style:
                                          const TextStyle(color: Colors.grey),
                                    ),
                                    Text(
                                      stock['sector'] ?? '',
                                      style: const TextStyle(
                                        color: Colors.grey,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                                trailing: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      '${double.tryParse(stock['price'].toString())?.toStringAsFixed(3)} TND',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    ElevatedButton(
                                      onPressed: () =>
                                          _showBuyModal(context, stock),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green,
                                        minimumSize: const Size(60, 25),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                        ),
                                      ),
                                      child: const Text(
                                        'Buy',
                                        style: TextStyle(fontSize: 12),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
      ),
    );
  }
}
