import 'package:brgy_bagbag/db_helper.dart';
import 'package:brgy_bagbag/functions.dart';
import 'package:brgy_bagbag/models/resident.dart';
import 'package:brgy_bagbag/widgets/column_separated.dart';
import 'package:brgy_bagbag/widgets/row_separated.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

class DashboardPageView extends StatefulWidget {
  const DashboardPageView({
    super.key,
    this.isPortrait = false,
    this.drawer,
  });

  final bool isPortrait;
  final Widget? drawer;

  @override
  State<DashboardPageView> createState() => _DashboardPageViewState();
}

class _DashboardPageViewState extends State<DashboardPageView> {
  int totalResidents = 0;
  // int infants = 0;
  int children = 0;
  int teens = 0;
  int adults = 0;
  int seniorCitizens = 0;

  final int _touchedIndex = -1;

  @override
  void initState() {
    super.initState();
    _fetchResidentsData();
  }

  Future<void> _fetchResidentsData() async {
    final QuerySnapshot<Resident> snapshot = await residentsCollection.get();

    // int infants = 0;
    int children = 0;
    int teens = 0;
    int adults = 0;
    int seniorCitizens = 0;

    final DateTime now = DateTime.now();

    for (var doc in snapshot.docs) {
      Resident resident = doc.data();
      int age = now.year - resident.birthday.toDate().year;

      // if (age < 2) {
      //   // infants++;
      // } else
      if (age > 0 && age <= 12) {
        children++;
      } else if (age >= 13 && age <= 19) {
        teens++;
      } else if (age >= 20 && age <= 59) {
        adults++;
      } else if (age >= 60) {
        seniorCitizens++;
      }
    }

    setState(() {
      totalResidents = snapshot.size;
      // infants = infants;
      this.children = children;
      this.teens = teens;
      this.adults = adults;
      this.seniorCitizens = seniorCitizens;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(child: widget.drawer),
      appBar: AppBar(
        leading: widget.isPortrait ? null : const Icon(TablerIcons.dashboard),
        title: const Text('Dashboard'),
        actions: [
          ElevatedButton(
            onPressed: () => showExportDialog(context),
            child: const Text('Export Data'),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildSummaryCard(),
              const SizedBox(height: 20),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildPieChart(),
                  const SizedBox(width: 20),
                  _buildLegend(),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard() {
    return SizedBox(
      width: double.infinity,
      child: widget.isPortrait
          ? ColumnSeparated(
              spacing: 16,
              mainAxisSize: MainAxisSize.min,
              children: [
                ResidentCard(icon: TablerIcons.users, color: Theme.of(context).colorScheme.onSurface, label: 'Total Residents', count: totalResidents),
                // ResidentCard(icon: TablerIcons.baby_carriage, color: Colors.blue, label: 'Infants', count: infants),
                ResidentCard(icon: TablerIcons.baby_bottle, color: Colors.green, label: 'Children', count: children),
                ResidentCard(icon: TablerIcons.man, color: Colors.yellow, label: 'Teens', count: teens),
                ResidentCard(icon: TablerIcons.man, color: Colors.orange, label: 'Adult', count: adults),
                ResidentCard(icon: TablerIcons.old, color: Colors.red, label: 'Senior Citizen', count: seniorCitizens),
              ],
            )
          : ColumnSeparated(
              spacing: 16,
              mainAxisSize: MainAxisSize.min,
              children: [
                RowSeparated(
                  spacing: 16,
                  children: [
                    Expanded(child: ResidentCard(icon: TablerIcons.users, color: Theme.of(context).colorScheme.onSurface, label: 'Total Residents', count: totalResidents)),
                    // ResidentCard(icon: TablerIcons.baby_carriage, color: Colors.blue, label: 'Infants', count: infants),
                    Expanded(child: ResidentCard(icon: TablerIcons.baby_bottle, color: Colors.green, label: 'Children', count: children)),
                    Expanded(child: ResidentCard(icon: TablerIcons.man, color: Colors.yellow, label: 'Teens', count: teens)),
                  ],
                ),
                RowSeparated(
                  spacing: 16,
                  children: [
                    Expanded(child: ResidentCard(icon: TablerIcons.man, color: Colors.orange, label: 'Adult', count: adults)),
                    Expanded(child: ResidentCard(icon: TablerIcons.old, color: Colors.red, label: 'Senior Citizen', count: seniorCitizens)),
                  ],
                ),
              ],
            ),
    );
  }

  Widget _buildPieChart() {
    return SizedBox.square(
      dimension: widget.isPortrait ? 200 : 500,
      child: PieChart(
        PieChartData(
          pieTouchData: PieTouchData(
              // touchCallback: (FlTouchEvent event, pieTouchResponse) {
              //   setState(() {
              //     if (!event.isInterestedForInteractions || pieTouchResponse == null || pieTouchResponse.touchedSection == null) {
              //       _touchedIndex = -1;
              //       return;
              //     }
              //     _touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
              //   });
              // },
              ),
          sections: _buildPieChartSections(),
          sectionsSpace: 2,
          centerSpaceRadius: widget.isPortrait ? 20 : 100,
        ),
      ),
    );
  }

  List<PieChartSectionData> _buildPieChartSections() {
    if (totalResidents == 0) return [];

    const radius = 50.0;
    const enlargedRadius = 60.0;

    return [
      // PieChartSectionData(
      //   color: Colors.blue,
      //   value: infants.toDouble(),
      //   title: '${_calculatePercentage(infants)}%',
      //   radius: _touchedIndex == 0 ? enlargedRadius : radius,
      //   titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
      // ),
      PieChartSectionData(
        color: Colors.green,
        value: children.toDouble(),
        title: '${_calculatePercentage(children)}%',
        radius: _touchedIndex == 1 ? enlargedRadius : radius,
        titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
      ),
      PieChartSectionData(
        color: Colors.yellow,
        value: teens.toDouble(),
        title: '${_calculatePercentage(teens)}%',
        radius: _touchedIndex == 2 ? enlargedRadius : radius,
        titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
      ),
      PieChartSectionData(
        color: Colors.orange,
        value: adults.toDouble(),
        title: '${_calculatePercentage(adults)}%',
        radius: _touchedIndex == 3 ? enlargedRadius : radius,
        titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
      ),
      PieChartSectionData(
        color: Colors.red,
        value: seniorCitizens.toDouble(),
        title: '${_calculatePercentage(seniorCitizens)}%',
        radius: _touchedIndex == 4 ? enlargedRadius : radius,
        titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
      ),
    ];
  }

  String _calculatePercentage(int count) {
    if (totalResidents == 0) return '0';
    final percentage = (count / totalResidents) * 100;
    return percentage.toStringAsFixed(1);
  }

  Widget _buildLegend() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // _buildLegendItem('Infants', Colors.blue),
        _buildLegendItem('Children', Colors.green),
        _buildLegendItem('Teens', Colors.yellow),
        _buildLegendItem('Adults', Colors.orange),
        _buildLegendItem('Senior Citizens', Colors.red),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 20,
          height: 20,
          color: color,
        ),
        const SizedBox(width: 8),
        Text(label),
      ],
    );
  }
}

class ResidentCard extends StatelessWidget {
  const ResidentCard({
    super.key,
    required this.icon,
    required this.color,
    required this.label,
    required this.count,
  });

  final IconData icon;
  final String label;
  final Color color;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 150,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).colorScheme.secondaryContainer),
        borderRadius: BorderRadius.circular(8),
      ),
      child: RowSeparated(
        spacing: 16,
        children: [
          Expanded(
            child: ColumnSeparated(
              spacing: 16,
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  icon,
                  size: 40,
                  color: color,
                ),
                Text(
                  label,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          Text(
            count.toString(),
            style: const TextStyle(
              fontSize: 50,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
