// company_detail_page.dart

import 'package:flutter/material.dart';
import 'models/company.dart';

class CompanyDetailPage extends StatelessWidget {
  final Company company;

  const CompanyDetailPage({Key? key, required this.company}) : super(key: key);

  Widget buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Expanded(
              flex: 2,
              child: Text(
                '$label:',
                style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
              )),
          Expanded(
              flex: 3,
              child: Text(
                value,
                style: const TextStyle(color: Colors.white),
              )),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: Text(company.stockName),
        backgroundColor: const Color(0xFF1E1E1E),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildDetailRow('ISIN', company.isin),
            buildDetailRow('Status', company.status),
            buildDetailRow('Achat (Ask Price)', company.ask.toString()),
            buildDetailRow('Ord.A (Ask Orders)', company.askOrd.toString()),
            buildDetailRow('Qté.A (Ask Quantity)', company.askQty.toString()),
            buildDetailRow('Vente (Bid Price)', company.bid.toString()),
            buildDetailRow('Ord.V (Bid Orders)', company.bidOrd.toString()),
            buildDetailRow('Qté.V (Bid Quantity)', company.bidQty.toString()),
            buildDetailRow('Cours de référence (Closing Price)', company.close.toString()),
            buildDetailRow('Dernier (Last Price)', company.last.toString()),
            buildDetailRow('Var % (Change Percentage)', '${company.change.toStringAsFixed(2)}%'),
            buildDetailRow('Dern Qté (Last Quantity)', company.trVolume.toString()),
            buildDetailRow('Qté (Volume)', company.volume.toString()),
            buildDetailRow('Capit (Market Capitalization)', company.caps.toString()),
            buildDetailRow('P.Haut (Highest Price)', company.high.toString()),
            buildDetailRow('P.Bas (Lowest Price)', company.low.toString()),
            buildDetailRow('Heure (Time)', company.time),
          ],
        ),
      ),
    );
  }
}