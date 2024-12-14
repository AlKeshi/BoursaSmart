// lib/portfolio_page.dart

import 'package:flutter/material.dart';

class PortfolioPage extends StatefulWidget {
  const PortfolioPage({Key? key}) : super(key: key);

  @override
  _PortfolioPageState createState() => _PortfolioPageState();
}

class _PortfolioPageState extends State<PortfolioPage> {
  // Sample data for the portfolio
  final List<PortfolioStock> _portfolioStocks = [
    PortfolioStock(
      name: 'Apple Inc.',
      symbol: 'AAPL',
      quantity: 50,
      currentPrice: 150.00,
      logoPath: 'assets/logos/apple.png',
    ),
    PortfolioStock(
      name: 'Tesla, Inc.',
      symbol: 'TSLA',
      quantity: 20,
      currentPrice: 700.00,
      logoPath: 'assets/logos/tesla.png',
    ),
    PortfolioStock(
      name: 'Amazon.com, Inc.',
      symbol: 'AMZN',
      quantity: 10,
      currentPrice: 3300.00,
      logoPath: 'assets/logos/amazon.png',
    ),
    // Add more stocks as needed
  ];

  // Calculate total portfolio value
  double get _totalPortfolioValue {
    return _portfolioStocks.fold(0.0, (sum, stock) => sum + stock.totalValue);
  }

  // Optional: Method to add a new stock to the portfolio
  void _addStock(PortfolioStock stock) {
    setState(() {
      _portfolioStocks.add(stock);
    });
  }

  // Optional: Method to remove a stock from the portfolio
  void _removeStock(int index) {
    setState(() {
      _portfolioStocks.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212), // Dark background color
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
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: () {
              // Handle adding a new stock (e.g., navigate to an add stock page or show a dialog)
              _showAddStockDialog();
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Portfolio Summary
            _buildPortfolioSummary(),
            const SizedBox(height: 20),

            // Portfolio Stocks List
            Expanded(
              child: _portfolioStocks.isEmpty
                  ? const Center(
                      child: Text(
                        'Your portfolio is empty.',
                        style: TextStyle(color: Colors.white70, fontSize: 16),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _portfolioStocks.length,
                      itemBuilder: (context, index) {
                        final stock = _portfolioStocks[index];
                        return _buildPortfolioStockItem(stock, index);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget to display portfolio summary
  Widget _buildPortfolioSummary() {
    return Card(
      color: const Color(0xFF1E1E1E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            const Icon(Icons.account_balance_wallet, color: Colors.blueAccent),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Total Portfolio Value',
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
                const SizedBox(height: 5),
                Text(
                  '\$${_totalPortfolioValue.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Widget to display each stock item
  Widget _buildPortfolioStockItem(PortfolioStock stock, int index) {
    return Card(
      color: const Color(0xFF1E1E1E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: AssetImage(stock.logoPath),
          backgroundColor: Colors.transparent,
          radius: 25,
        ),
        title: Text(
          stock.name,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          stock.symbol,
          style: const TextStyle(color: Colors.grey),
        ),
        trailing: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '\$${stock.currentPrice.toStringAsFixed(2)}',
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
            Text(
              'Qty: ${stock.quantity}',
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
            Text(
              'Total: \$${stock.totalValue.toStringAsFixed(2)}',
              style: const TextStyle(color: Colors.greenAccent, fontSize: 14),
            ),
          ],
        ),
        onLongPress: () {
          // Handle removing a stock (e.g., show a confirmation dialog)
          _showRemoveStockDialog(index);
        },
        onTap: () {
          // Handle viewing stock details (e.g., navigate to a detailed stock page)
          _navigateToStockDetail(stock);
        },
      ),
    );
  }

  // Optional: Dialog to add a new stock
  void _showAddStockDialog() {
    String name = '';
    String symbol = '';
    int quantity = 0;
    double currentPrice = 0.0;
    String logoPath = 'assets/logos/default.png'; // Default logo

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E1E1E),
          title: const Text(
            'Add New Stock',
            style: TextStyle(color: Colors.white),
          ),
          content: SingleChildScrollView(
            child: Column(
              children: [
                // Stock Name
                TextField(
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Stock Name',
                    labelStyle: TextStyle(color: Colors.grey),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                  ),
                  onChanged: (value) {
                    name = value;
                  },
                ),
                // Stock Symbol
                TextField(
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Symbol',
                    labelStyle: TextStyle(color: Colors.grey),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                  ),
                  onChanged: (value) {
                    symbol = value;
                  },
                ),
                // Quantity
                TextField(
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Quantity',
                    labelStyle: TextStyle(color: Colors.grey),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    quantity = int.tryParse(value) ?? 0;
                  },
                ),
                // Current Price
                TextField(
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Current Price',
                    labelStyle: TextStyle(color: Colors.grey),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                  ),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  onChanged: (value) {
                    currentPrice = double.tryParse(value) ?? 0.0;
                  },
                ),
                // Logo Path (Optional)
                TextField(
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Logo Path',
                    labelStyle: TextStyle(color: Colors.grey),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                  ),
                  onChanged: (value) {
                    logoPath = value.isNotEmpty ? value : 'assets/logos/default.png';
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Cancel', style: TextStyle(color: Colors.white)),
            ),
            TextButton(
              onPressed: () {
                if (name.isNotEmpty && symbol.isNotEmpty && quantity > 0 && currentPrice > 0) {
                  final newStock = PortfolioStock(
                    name: name,
                    symbol: symbol,
                    quantity: quantity,
                    currentPrice: currentPrice,
                    logoPath: logoPath,
                  );
                  _addStock(newStock);
                  Navigator.of(context).pop(); // Close the dialog
                } else {
                  // Show error or validation
                }
              },
              child: const Text('Add', style: TextStyle(color: Colors.blueAccent)),
            ),
          ],
        );
      },
    );
  }

  // Optional: Dialog to confirm removing a stock
  void _showRemoveStockDialog(int index) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E1E1E),
          title: const Text(
            'Remove Stock',
            style: TextStyle(color: Colors.white),
          ),
          content: const Text(
            'Are you sure you want to remove this stock from your portfolio?',
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Cancel', style: TextStyle(color: Colors.white)),
            ),
            TextButton(
              onPressed: () {
                _removeStock(index);
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Remove', style: TextStyle(color: Colors.redAccent)),
            ),
          ],
        );
      },
    );
  }

  // Optional: Navigate to detailed stock page
  void _navigateToStockDetail(PortfolioStock stock) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StockDetailPage(stock: stock),
      ),
    );
  }
}

// Model class for a portfolio stock
class PortfolioStock {
  final String name;
  final String symbol;
  final int quantity;
  final double currentPrice;
  final String logoPath;

  PortfolioStock({
    required this.name,
    required this.symbol,
    required this.quantity,
    required this.currentPrice,
    required this.logoPath,
  });

  double get totalValue => quantity * currentPrice;
}

// Optional: Detailed Stock Page
class StockDetailPage extends StatelessWidget {
  final PortfolioStock stock;

  const StockDetailPage({Key? key, required this.stock}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: Text(stock.name),
        backgroundColor: const Color(0xFF1E1E1E),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Stock Logo
            CircleAvatar(
              backgroundImage: AssetImage(stock.logoPath),
              backgroundColor: Colors.transparent,
              radius: 50,
            ),
            const SizedBox(height: 20),

            // Stock Information
            Text(
              stock.symbol,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              '\$${stock.currentPrice.toStringAsFixed(2)}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Quantity: ${stock.quantity}',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 20),

            // Additional Details or Charts can be added here
            const Text(
              'Detailed information, charts, and analytics about the stock can be displayed here.',
              style: TextStyle(color: Colors.white70),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}