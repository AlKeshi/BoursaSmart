import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:k_chart/flutter_k_chart.dart';
import 'package:k_chart/k_chart_widget.dart';

class CandlestickChart extends StatefulWidget {
  const CandlestickChart({super.key});

  @override
  _CandlestickChartState createState() => _CandlestickChartState();
}

class _CandlestickChartState extends State<CandlestickChart> {
  List<KLineEntity>? datas;
  List<DepthEntity>? _bids, _asks;
  bool showLoading = true;

  final MainState _mainState = MainState.MA; // Main view state (e.g., MA)
  final SecondaryState _secondaryState = SecondaryState.MACD; // Subview state (e.g., MACD)
  bool isLine = false; // Whether to display as a line chart
  final ChartStyle chartStyle = ChartStyle(); // Chart styling
  final ChartColors chartColors = ChartColors(); // Chart color styling
  final List<int> maDayList = [5,10,20];
  @override
  void initState() {
    super.initState();
    fetchKLineData();
    fetchDepthData();
  }

  // Fetch K-Line data
  void fetchKLineData() async {
    try {
      var url = Uri.parse(
          'https://api.huobi.pro/market/history/kline?period=1day&size=300&symbol=btcusdt'); // Replace with actual data source
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        List list = jsonData['data'];
        setState(() {
          datas = list
              .map((item) => KLineEntity.fromJson(item))
              .toList()
              .reversed
              .toList();
          DataUtil.calculate(datas!, maDayList); // Calculate MA
          showLoading = false;
        });
      } else {
        setState(() => showLoading = false);
        throw Exception('Failed to fetch K-Line data');
      }
    } catch (e) {
      print('Error fetching K-Line data: $e');
      setState(() => showLoading = false);
    }
  }

  // Fetch Depth Chart data
  void fetchDepthData() async {
    try {
      var url = Uri.parse('https://api.example.com/depth'); // Replace with actual API
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        Map tick = jsonData['tick'];
        var bids = tick['bids']
            .map((item) => DepthEntity(item[0], item[1]))
            .toList()
            .cast<DepthEntity>();
        var asks = tick['asks']
            .map((item) => DepthEntity(item[0], item[1]))
            .toList()
            .cast<DepthEntity>();
        initDepth(bids, asks);
      }
    } catch (e) {
      print('Error fetching Depth Chart data: $e');
    }
  }

  void initDepth(List<DepthEntity> bids, List<DepthEntity> asks) {
    _bids = [];
    _asks = [];
    double amount = 0.0;

    // Sort and calculate cumulative volume for bids
    bids.sort((a, b) => a.price.compareTo(b.price));
    for (var item in bids.reversed) {
      amount += item.vol;
      item.vol = amount;
      _bids!.insert(0, item);
    }

    amount = 0.0;

    // Sort and calculate cumulative volume for asks
    asks.sort((a, b) => a.price.compareTo(b.price));
    for (var item in asks) {
      amount += item.vol;
      item.vol = amount;
      _asks!.add(item);
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF17212F),
      child: SingleChildScrollView(
        child: Column(
          children: [
            // K-Line Chart
            SizedBox(
              height: 450,
              width: double.infinity,
              child: Stack(
                children: [
                  if (datas != null)
                    KChartWidget(
                      datas!,
                      chartStyle,
                      chartColors,
                      isLine: isLine,
                      mainState: _mainState,
                      secondaryState: _secondaryState,
                      fixedLength: 2,
                      timeFormat: TimeFormat.YEAR_MONTH_DAY,
                      onLoadMore: (bool isEnd) {
                        if (!isEnd) {
                          print("Load more K-Line data...");
                          // Add functionality to fetch more data if needed
                        }
                      },
                      maDayList: [5, 10, 20], // Match DataUtil.calculate's maDayList
                                                                                                                                           
                      volHidden: false,
                      showNowPrice: true,
                      isOnDrag: (isDragging) {
                        print(isDragging
                            ? "Dragging the chart..."
                            : "Drag released.");
                      },
                      onSecondaryTap: () {
                        print("Secondary chart tapped.");
                      },
                      isTrendLine: false,
                      xFrontPadding: 100,
                    ),
                  if (showLoading)
                    const Center(child: CircularProgressIndicator()),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Depth Chart
            if (_bids != null && _asks != null)
              SizedBox(
                height: 230,
                width: double.infinity,
                child: DepthChart(_bids!, _asks!, chartColors),
              ),
          ],
        ),
      ),
    );
  }
}