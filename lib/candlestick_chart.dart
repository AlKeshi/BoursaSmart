import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:k_chart/flutter_k_chart.dart';
import 'package:k_chart/utils/data_util.dart';
import 'dart:math';

class CandlestickChart extends StatefulWidget {
  final String stockName;

  const CandlestickChart(this.stockName, {Key? key}) : super(key: key);

  @override
  _CandlestickChartState createState() => _CandlestickChartState();
}

class _CandlestickChartState extends State<CandlestickChart> {
  List<KLineEntity> _data = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    final symbol = widget.stockName;
    final url = Uri.parse(
        'https://data.irbe7.com/api/data/history?symbol=$symbol&resolution=1D&from=0&to=1731974400000&countback=330');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);

        if (jsonData is Map && jsonData.containsKey('t')) {
          final Map<DateTime, Map<String, double>> aggregatedData = {};

          for (int i = 0; i < jsonData['t'].length; i++) {
            final date =
                DateTime.fromMillisecondsSinceEpoch(jsonData['t'][i] * 1000)
                    .toLocal();
            final day = DateTime(date.year, date.month, date.day);

            if (!aggregatedData.containsKey(day)) {
              aggregatedData[day] = {
                'open': jsonData['o'][i],
                'high': jsonData['h'][i],
                'low': jsonData['l'][i],
                'close': jsonData['c'][i],
              };
            } else {
              aggregatedData[day]!['high'] =
                  max(aggregatedData[day]!['high']!, jsonData['h'][i]);
              aggregatedData[day]!['low'] =
                  min(aggregatedData[day]!['low']!, jsonData['l'][i]);
              aggregatedData[day]!['close'] = jsonData['c'][i];
            }
          }

          final List<KLineEntity> data = aggregatedData.entries.map((entry) {
            final day = entry.key;
            final ohlc = entry.value;
            return KLineEntity.fromCustom(
              time: day.millisecondsSinceEpoch,
              open: ohlc['open']!,
              high: ohlc['high']!,
              low: ohlc['low']!,
              close: ohlc['close']!,
              vol: 0,
            );
          }).toList();

          DataUtil.calculate(data);

          setState(() {
            _data = data;
            _isLoading = false;
          });
        } else {
          setState(() {
            _errorMessage = 'Invalid response format.';
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _errorMessage = 'Error: HTTP ${response.statusCode}';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.stockName),
        backgroundColor: const Color(0xFF1E1E1E),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.white),
                  ),
                )
              : _data.isEmpty
                  ? const Center(
                      child: Text(
                        'No data available.',
                        style: TextStyle(color: Colors.white),
                      ),
                    )
                  : KChartWidget(
                      _data,
                      ChartStyle(),
                      ChartColors(),
                      isLine: false,
                      mainState: MainState.MA,
                      secondaryState: SecondaryState.MACD,
                      volHidden: true,
                      timeFormat: TimeFormat.YEAR_MONTH_DAY,
                      showNowPrice: true,
                      isTrendLine: false,
                    ),
    );
  }
}