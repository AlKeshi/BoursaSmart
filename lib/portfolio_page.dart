import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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
    // Get stored authentication data
    final String? accessToken = await _storage.read(key: 'access_token');
    final String? username = await _storage.read(key: 'username');
    final String? portfolioId = await _storage.read(key: 'portfolio_id');
    
    print('Debug - Access Token: $accessToken');
    print('Debug - Username: $username');
    print('Debug - Portfolio ID: $portfolioId');
    
    if (accessToken == null) {
      print('Debug - No access token found');
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
      print('Debug - No portfolio ID found');
      setState(() {
        _isLoading = false;
        _errorMessage = 'Portfolio ID not found';
      });
      return;
    }

    print('Debug - Making API call to: http://127.0.0.1:8000/api/portfolios/$portfolioId/positions/');
    print('Debug - Headers: ${{'Content-Type': 'application/json', 'Authorization': 'Bearer $accessToken'}}');

    // Make API call with correct portfolio ID
    // keep the AUTHORIZATION FORMAT
    final response = await http.get(
      Uri.parse('http://127.0.0.1:8000/api/portfolios/$portfolioId/positions/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'JWT $accessToken',
      },
    );


    print('Debug - Response Status Code: ${response.statusCode}');
    print('Debug - Response Body: ${response.body}');

    if (response.statusCode == 200) {
      setState(() {
        _portfolioData = json.decode(response.body);
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load portfolio data - Status: ${response.statusCode}';
      });
    }
  } catch (e) {
    print('Debug - Error caught: $e');
    setState(() {
      _isLoading = false;
      _errorMessage = 'Error: $e';
    });
  }
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
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Welcome Text
                        Text(
                          'Welcome, $_username',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Portfolio Summary Cards
                        Row(
                          children: [
                            Expanded(
                              child: _buildSummaryCard(
                                'Total Value',
                                _portfolioData['portfolio_summary']?['total_value']?.toString() ?? '0.0',
                                Icons.account_balance_wallet,
                                Colors.blueAccent,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildSummaryCard(
                                'Cash Balance',
                                _portfolioData['portfolio_summary']?['cash_balance']?.toString() ?? '0.0',
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
                                _portfolioData['portfolio_summary']?['stock_value']?.toString() ?? '0.0',
                                Icons.trending_up,
                                Colors.purpleAccent,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildSummaryCard(
                                'Total Gain/Loss',
                                _portfolioData['portfolio_summary']?['total_gain']?.toString() ?? '0.0',
                                Icons.show_chart,
                                Colors.orangeAccent,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Return Percentage Card
                        Card(
                          color: const Color(0xFF1E1E1E),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Return Percentage',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                ),
                                Text(
                                  '${_portfolioData['portfolio_summary']?['return_percentage']?.toStringAsFixed(2) ?? '0.0'}%',
                                  style: TextStyle(
                                    color: (_portfolioData['portfolio_summary']?['return_percentage'] ?? 0) >= 0
                                        ? Colors.greenAccent
                                        : Colors.redAccent,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
      ),
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon, Color iconColor) {
    return Card(
      color: const Color(0xFF1E1E1E),
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
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
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