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
  bool showLoading = true;
  final String apiKey = 'U8W30VOC0IC296VF'; // Replace with your Alpha Vantage API key

  @override
  void initState() {
    super.initState();
    fetchKLineData();
  }

  void fetchKLineData() async {
    final String symbol = 'TSLA'; // Replace with your desired stock symbol
    final String function = 'TIME_SERIES_DAILY';
    final String url =
        'https://www.alphavantage.co/query?function=$function&symbol=$symbol&apikey=$apiKey';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final timeSeries = jsonData['Time Series (Daily)'];
        if (timeSeries != null) {
          List<KLineEntity> data = [];
          timeSeries.forEach((date, values) {
            data.add(KLineEntity.fromCustom(
              open: double.parse(values['1. open']),
              high: double.parse(values['2. high']),
              low: double.parse(values['3. low']),
              close: double.parse(values['4. close']),
              vol: double.parse(values['5. volume']),
              time: DateTime.parse(date).millisecondsSinceEpoch,
            ));
          });
          data = data.reversed.toList(); // Ensure data is in ascending order
          setState(() {
            datas = data;
            DataUtil.calculate(datas!); // Calculate indicators
            showLoading = false;
          });
        } else {
          throw Exception('No time series data found');
        }
      } else {
        throw Exception('Failed to fetch data');
      }
    } catch (e) {
      print('Error fetching data: $e');
      setState(() => showLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      body: Center(
        child: showLoading
            ? CircularProgressIndicator()
            : datas != null
                ? KChartWidget(
                    datas!,
                    ChartStyle(),
                    ChartColors(),
                    isLine: false,
                    mainState: MainState.MA,
                    secondaryState: SecondaryState.MACD,
                    volHidden: false,
                    timeFormat: TimeFormat.YEAR_MONTH_DAY,
                    isTrendLine: false,
                  )
                : Text('No data available'),
      ),
    );
  }
}