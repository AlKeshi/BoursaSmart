import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'invest_page.dart';

class PortfolioPage extends StatefulWidget {
  const PortfolioPage({Key? key}) : super(key: key);

  @override
  _PortfolioPageState createState() => _PortfolioPageState();
}

class _PortfolioPageState extends State<PortfolioPage> {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  bool _isLoading = true;
  String _username = '';
  Map<String, dynamic> _portfolioData = {};
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadPortfolioData();
  }

  Future<void> _loadPortfolioData() async {
    try {
      final String? accessToken = await _storage.read(key: 'access_token');
      final String? username = await _storage.read(key: 'username');
      final String? portfolioId = await _storage.read(key: 'portfolio_id');

      if (accessToken == null) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Authentication error';
        });
        return;
      }

      setState(() {
        _username = username ?? 'User';
      });

      if (portfolioId == null) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Portfolio ID not found';
        });
        return;
      }

      final response = await http.get(
        Uri.parse(
            'http://127.0.0.1:8000/api/portfolios/$portfolioId/positions/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'JWT $accessToken',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          _portfolioData = json.decode(response.body);
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage =
              'Failed to load portfolio data - Status: ${response.statusCode}';
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
        await _loadPortfolioData();
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

  Future<void> _handleSellStock(
      String symbol, double price, int quantity) async {
    try {
      final String? accessToken = await _storage.read(key: 'access_token');
      final String? portfolioId = await _storage.read(key: 'portfolio_id');

      if (accessToken == null || portfolioId == null) {
        throw Exception('Authentication error');
      }

      final response = await http.post(
        Uri.parse('http://127.0.0.1:8000/api/portfolios/$portfolioId/sell/'),
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
        await _loadPortfolioData();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sale successful')),
        );
      } else {
        throw Exception(json.decode(response.body)['error'] ?? 'Sale failed');
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  void _showTransactionModal(
      BuildContext context, Map<String, dynamic> position, bool isBuy) {
      int quantity = 1;
      final double price = position['current_price']?.toDouble() ?? 0.0;
 
      final double cashBalance = _portfolioData['portfolio_summary']?['cash_balance'] ?? 0.0;
      final int availableShares = position['shares'] ?? 0;


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
            final bool canProceed =
                isBuy ? totalCost <= cashBalance : quantity <= availableShares;

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
                    '${isBuy ? "Buy" : "Sell"} ${position['name']}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Current Price: ${price.toStringAsFixed(3)} TND',
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
                    isBuy
                        ? 'Available Cash: ${cashBalance.toStringAsFixed(3)} TND'
                        : 'Available Shares: $availableShares',
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isBuy ? Colors.green : Colors.red,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: canProceed
                          ? () {
                              Navigator.pop(context);
                              if (isBuy) {
                                _handleBuyStock(
                                  position['symbol'],
                                  price,
                                  quantity,
                                );
                              } else {
                                _handleSellStock(
                                  position['symbol'],
                                  price,
                                  quantity,
                                );
                              }
                            }
                          : null,
                      child: Text(
                        isBuy ? 'Confirm Purchase' : 'Confirm Sale',
                        style: const TextStyle(
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

  Widget _buildStockList() {
    final positions = _portfolioData['positions'] as List<dynamic>? ?? [];

    if (positions.isEmpty) {
      return const Center(
        child: Text(
          'No stocks in portfolio',
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: positions.length,
      itemBuilder: (context, index) {
        final position = positions[index];
        final double returnPercentage = position['return_percentage'] ?? 0.0;
        final bool isPositive = returnPercentage >= 0;
        final int shares = position['shares'] ?? 0;

        return Card(
          color: const Color(0xFF1E1E1E),
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: ExpansionTile(
            title: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        position['name'] ?? 'Unknown',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        position['symbol'] ?? '',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${position['current_price']?.toStringAsFixed(3)} TND',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                    Row(
                      children: [
                        Icon(
                          isPositive
                              ? Icons.arrow_upward
                              : Icons.arrow_downward,
                          color: isPositive ? Colors.green : Colors.red,
                          size: 16,
                        ),
                        Text(
                          '${returnPercentage.toStringAsFixed(2)}%',
                          style: TextStyle(
                            color: isPositive ? Colors.green : Colors.red,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildDetailRow('Shares', shares.toString()),
                    _buildDetailRow(
                      'Average Cost',
                      '${position['avg_cost']?.toStringAsFixed(3)} TND',
                    ),
                    _buildDetailRow(
                      'Total Cost',
                      '${position['total_cost']?.toStringAsFixed(3)} TND',
                    ),
                    _buildDetailRow(
                      'Current Value',
                      '${position['current_value']?.toStringAsFixed(3)} TND',
                    ),
                    _buildDetailRow(
                      'Unrealized Gain/Loss',
                      '${position['unrealized_gain']?.toStringAsFixed(3)} TND',
                      textColor: position['unrealized_gain'] >= 0
                          ? Colors.green
                          : Colors.red,
                    ),
                    const SizedBox(height: 16),
                    // Buy/Sell Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton.icon(
                          icon: const Icon(Icons.add_shopping_cart),
                          label: const Text('Buy'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                          ),
                          onPressed: () {
                            _showTransactionModal(context, position, true);
                          },
                        ),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.sell),
                          label: const Text('Sell'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                          ),
                          onPressed: shares > 0
                              ? () {
                                  _showTransactionModal(
                                      context, position, false);
                                }
                              : null,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? textColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.grey),
          ),
          Text(
            value,
            style: TextStyle(
              color: textColor ?? Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text(
          'My Portfolio',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        backgroundColor: const Color(0xFF1E1E1E),
      ),
      body: RefreshIndicator(
        onRefresh: _loadPortfolioData,
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
                        const SizedBox(height: 16),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'Welcome, $_username',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: _buildSummaryCard(
                                'Total Value',
                                _portfolioData['portfolio_summary']
                                            ?['total_value']
                                        ?.toString() ??
                                    '0.0',
                                Icons.account_balance_wallet,
                                Colors.blueAccent,
                              ),
                            ),
                            Expanded(
                              child: _buildSummaryCard(
                                'Cash Balance',
                                _portfolioData['portfolio_summary']
                                            ?['cash_balance']
                                        ?.toString() ??
                                    '0.0',
                                Icons.money,
                                Colors.greenAccent,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _buildSummaryCard(
                                'Stock Value',
                                _portfolioData['portfolio_summary']
                                            ?['stock_value']
                                        ?.toString() ??
                                    '0.0',
                                Icons.trending_up,
                                Colors.purpleAccent,
                              ),
                            ),
                            Expanded(
                              child: _buildSummaryCard(
                                'Total Gain/Loss',
                                _portfolioData['portfolio_summary']
                                            ?['total_gain']
                                        ?.toString() ??
                                    '0.0',
                                Icons.show_chart,
                                Colors.orangeAccent,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        // Add the new invest button here
                        Row(
                          children: [
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16.0),
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const InvestPage()),
                                    );
                                  },
                                  icon: const Icon(Icons.trending_up),
                                  label: const Text('Invest in New Stocks'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'My Stocks',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildStockList(),
                      ],
                    ),
                  ),
      ),
    );
  }

  Widget _buildSummaryCard(
      String title, String value, IconData icon, Color iconColor) {
    return Card(
      color: const Color(0xFF1E1E1E),
      margin: const EdgeInsets.symmetric(horizontal: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: iconColor),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(color: Colors.grey, fontSize: 14),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '$value TND',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
