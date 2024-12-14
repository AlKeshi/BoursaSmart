import 'dart:convert';
import 'package:boursa/home_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'candlestick_chart.dart';


class ExplorePage extends StatefulWidget {
  const ExplorePage({Key? key}) : super(key: key);

  @override
  _ExplorePageState createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  List<dynamic> companies = [];
  bool isLoading = true;
  String _searchQuery = '';
  Widget? _currentPage;

  @override
  void initState() {
    super.initState();
    fetchCompanies();
  }

  Future<void> fetchCompanies() async {
    final url = Uri.parse(
        'https://cors-anywhere.herokuapp.com/http://www.bvmt.com.tn/rest_api/rest/market/groups/11,12,52,95,99');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          companies = data['markets'];
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load data from server')),
        );
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load data: $e')),
      );
    }
  }

  List<dynamic> get _filteredCompanies {
    if (_searchQuery.isEmpty) {
      return companies;
    } else {
      return companies
          .where((company) {
            final referentiel = company['referentiel'] ?? {};
            final stockName = referentiel['stockName'] ?? '';
            return stockName.toLowerCase().contains(_searchQuery.toLowerCase());
          })
          .toList();
    }
  }

  void _showCandlestickChart(String stockName) {
    setState(() {
      _currentPage = CandlestickChart(stockName);
    });
  }

  @override
  Widget build(BuildContext context) {
    return _currentPage != null
        ? _currentPage!
        : Scaffold(
            backgroundColor: const Color(0xFF121212),
            appBar: AppBar(
              title: const Text(
                'Explore Companies',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              backgroundColor: const Color(0xFF1E1E1E),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  // Navigate back to HomePage
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const HomePage()),
                    (route) => false,
                  );
                },
              ),
            ),
            body: isLoading
                ? const Center(child: CircularProgressIndicator())
                : companies.isEmpty
                    ? const Center(
                        child: Text(
                          'No data available',
                          style: TextStyle(color: Colors.white),
                        ),
                      )
                    : Column(
                        children: [
                          // Search Bar
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            child: TextField(
                              onChanged: (value) {
                                setState(() {
                                  _searchQuery = value;
                                });
                              },
                              decoration: InputDecoration(
                                hintText: 'Search Companies',
                                hintStyle:
                                    const TextStyle(color: Colors.grey),
                                prefixIcon: const Icon(
                                  Icons.search,
                                  color: Colors.grey,
                                ),
                                filled: true,
                                fillColor: const Color(0xFF2C2C2C),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                          // Expanded ListView
                          Expanded(
                            child: _filteredCompanies.isNotEmpty
                                ? ListView.builder(
                                    itemCount: _filteredCompanies.length,
                                    itemBuilder: (context, index) {
                                      final company =
                                          _filteredCompanies[index];
                                      final referentiel =
                                          company['referentiel'] ?? {};
                                      final stockName =
                                          referentiel['stockName'] ?? 'N/A';
                                      final lastPrice =
                                          company['last'] ?? 0.0;
                                      final change =
                                          company['change'] ?? 0.0;

                                      return GestureDetector(
                                        onTap: () =>
                                            _showCandlestickChart(stockName),
                                        child: CompanyCard(
                                          stockName: stockName,
                                          lastPrice: lastPrice,
                                          change: change,
                                        ),
                                      );
                                    },
                                  )
                                : const Center(
                                    child: Text(
                                      'No companies found.',
                                      style:
                                          TextStyle(color: Colors.white),
                                    ),
                                  ),
                          ),
                        ],
                      ),
          );
  }
}

// Widget for each Company Card with Logo and Animated Change Indicator
class CompanyCard extends StatelessWidget {
  final String stockName;
  final double lastPrice;
  final double change;

  const CompanyCard({
    Key? key,
    required this.stockName,
    required this.lastPrice,
    required this.change,
  }) : super(key: key);

  Color getChangeColor(double change) {
    if (change > 0) {
      return Colors.greenAccent;
    } else if (change < 0) {
      return Colors.redAccent;
    } else {
      return Colors.grey;
    }
  }

  IconData getChangeIcon(double change) {
    if (change > 0) {
      return Icons.arrow_upward;
    } else if (change < 0) {
      return Icons.arrow_downward;
    } else {
      return Icons.horizontal_rule;
    }
  }

  @override
  Widget build(BuildContext context) {
    Color changeColor = getChangeColor(change);
    IconData changeIcon = getChangeIcon(change);

    return Card(
      color: const Color(0xFF1E1E1E),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: AssetImage(
              'assets/logos/${stockName.toLowerCase().replaceAll(' ', '_')}.png'),
          backgroundColor: Colors.transparent,
        ),
        title: Text(
          stockName,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          'Price: ${lastPrice.toStringAsFixed(3)} TND',
          style: const TextStyle(color: Colors.grey),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return ScaleTransition(scale: animation, child: child);
              },
              child: Icon(
                changeIcon,
                key: ValueKey<IconData>(changeIcon),
                color: changeColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              '${change.toStringAsFixed(2)}%',
              style: TextStyle(
                color: changeColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}