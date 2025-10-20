import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kalkulator Gaji',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const SalaryCalculatorScreen(),
    );
  }
}

class SalaryCalculatorScreen extends StatefulWidget {
  const SalaryCalculatorScreen({super.key});

  @override
  State<SalaryCalculatorScreen> createState() => _SalaryCalculatorScreenState();
}

class _SalaryCalculatorScreenState extends State<SalaryCalculatorScreen> {
  final double grossIncome = 17000000;
  final double bpjsKesehatanPercentage = 0.01;
  final double bpjsKetenagakerjaanPercentage = 0.02;
  final double biayaJabatanPercentage = 0.05;
  final double maxBiayaJabatan = 500000;

  // PTKP constants (K/3 - Menikah, 3 anak)
  final double ptkpWp = 54000000;
  final double ptkpMenikah = 4500000;
  final double ptkpAnak = 4500000;
  final int jumlahAnak = 3;

  double bpjsKesehatan = 0;
  double bpjsKetenagakerjaan = 0;
  double biayaJabatan = 0;
  double pph21Month = 0;
  double takeHomePay = 0;

  @override
  void initState() {
    super.initState();
    _calculate();
  }

  void _calculate() {
    bpjsKesehatan = grossIncome * bpjsKesehatanPercentage;
    bpjsKetenagakerjaan = grossIncome * bpjsKetenagakerjaanPercentage;

    double biayaJabatanCalculated = grossIncome * biayaJabatanPercentage;
    biayaJabatan = biayaJabatanCalculated > maxBiayaJabatan ? maxBiayaJabatan : biayaJabatanCalculated;

    double totalDeductionsForNeto = bpjsKesehatan + bpjsKetenagakerjaan + biayaJabatan;
    double netoMonth = grossIncome - totalDeductionsForNeto;
    double netoYear = netoMonth * 12;

    double totalPtkp = ptkpWp + ptkpMenikah + (ptkpAnak * jumlahAnak);

    double pkp = netoYear - totalPtkp;
    if (pkp < 0) pkp = 0;

    double pph21Year = 0;
    if (pkp > 0) {
      if (pkp <= 60000000) {
        pph21Year = pkp * 0.05;
      } else if (pkp <= 250000000) {
        pph21Year = (60000000 * 0.05) + ((pkp - 60000000) * 0.15);
      } else if (pkp <= 500000000) {
        pph21Year = (60000000 * 0.05) + (190000000 * 0.15) + ((pkp - 250000000) * 0.25);
      } else if (pkp <= 5000000000) {
        pph21Year = (60000000 * 0.05) + (190000000 * 0.15) + (250000000 * 0.25) + ((pkp - 500000000) * 0.30);
      } else {
        pph21Year = (60000000 * 0.05) + (190000000 * 0.15) + (250000000 * 0.25) + (4500000000 * 0.30) + ((pkp - 5000000000) * 0.35);
      }
    }

    pph21Month = pph21Year / 12;

    takeHomePay = grossIncome - bpjsKesehatan - bpjsKetenagakerjaan - pph21Month;
  }

  String _formatCurrency(double amount) {
    final format = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    return format.format(amount);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Perhitungan Gaji Tuan Agus'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text(
                  'Rincian Gaji (Skema Gross)',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                _buildInfoRow('Penghasilan Bruto', _formatCurrency(grossIncome)),
                const Divider(),
                const SizedBox(height: 10),
                const Text(
                  'Potongan:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                _buildInfoRow('BPJS Kesehatan (1%)', _formatCurrency(bpjsKesehatan)),
                _buildInfoRow('BPJS Ketenagakerjaan (2%)', _formatCurrency(bpjsKetenagakerjaan)),
                _buildInfoRow('Pajak PPh 21', _formatCurrency(pph21Month)),
                const Divider(),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Take Home Pay',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        _formatCurrency(takeHomePay),
                        style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(label, style: const TextStyle(fontSize: 16)),
          Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
