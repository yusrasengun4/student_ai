import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/user_model.dart';
import '../models/weekly_stats_model.dart';
import '../models/daily_record_model.dart';
import '../services/prediction_service.dart';
import '../services/api_service.dart';

class WeeklyReportPage extends StatefulWidget {
  final UserModel user;
  const WeeklyReportPage({super.key, required this.user});

  @override
  State<WeeklyReportPage> createState() => _WeeklyReportPageState();
}

class _WeeklyReportPageState extends State<WeeklyReportPage> {
  WeeklyStatsModel? _stats;
  bool    _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final stats = await PredictionService.getWeeklyStats(widget.user.id);
      setState(() => _stats = stats);
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Color _burnoutColor(String risk) {
    switch (risk) {
      case 'High':   return const Color(0xFFEF4444);
      case 'Medium': return const Color(0xFFF59E0B);
      default:       return const Color(0xFF22C55E);
    }
  }

  int _burnoutLevel(String risk) {
    switch (risk) {
      case 'High':   return 3;
      case 'Medium': return 2;
      default:       return 1;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F0F1A),
        elevation: 0,
        title: const Text('📊 Haftalık Rapor',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white54),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white54),
            onPressed: _load,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF4F8EF7)))
          : _error != null ? _buildError()
          : _stats == null  ? _buildEmpty()
          : _buildContent(_stats!),
    );
  }

  Widget _buildError() => Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
    const Text('❌', style: TextStyle(fontSize: 48)),
    const SizedBox(height: 12),
    Text(_error!, style: const TextStyle(color: Colors.white54)),
    const SizedBox(height: 16),
    ElevatedButton(onPressed: _load,
        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4F8EF7)),
        child: const Text('Tekrar Dene')),
  ]));

  Widget _buildEmpty() => const Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
    Text('📭', style: TextStyle(fontSize: 48)),
    SizedBox(height: 12),
    Text('Henüz yeterli veri yok.', style: TextStyle(color: Colors.white54, fontSize: 16)),
    SizedBox(height: 8),
    Text('Günlük analiz yaparak veri biriktir.',
        style: TextStyle(color: Colors.white38, fontSize: 13)),
  ]));

  Widget _buildContent(WeeklyStatsModel s) {
    final records = s.records;
    return RefreshIndicator(
      onRefresh: _load,
      color: const Color(0xFF4F8EF7),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _sectionTitle('📈 Haftalık Özet'),
            Row(children: [
              Expanded(child: _summaryCard('Ort. Puan',
                  s.avgScore.toStringAsFixed(1), '/100', const Color(0xFF4F8EF7), '🎓')),
              const SizedBox(width: 10),
              Expanded(child: _summaryCard('Verimlilik',
                  s.avgProductivity.toStringAsFixed(1), '/100', const Color(0xFFa855f7), '⚡')),
              const SizedBox(width: 10),
              Expanded(child: _summaryCard('Odak',
                  s.avgFocus.toStringAsFixed(1), '/100', const Color(0xFF06b6d4), '🎯')),
            ]),
            const SizedBox(height: 12),
            _trendCard(s.scoreTrend, s.mostCommonBurnout, s.highBurnoutDays),
            const SizedBox(height: 28),

            _sectionTitle('📉 Performans Trendi'),
            _buildLineChart(records),
            const SizedBox(height: 28),

            _sectionTitle('🔥 Tükenmişlik Takibi'),
            _buildBurnoutChart(records),
            const SizedBox(height: 28),

            _sectionTitle('🧠 Haftalık Analiz'),
            _buildInsights(s),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _trendCard(double trend, String mostCommon, int highDays) {
    final isUp  = trend >= 0;
    final color = isUp ? const Color(0xFF22C55E) : const Color(0xFFEF4444);
    final sign  = isUp ? '+' : '';
    return Row(children: [
      Expanded(child: _infoCard(
        icon: isUp ? '📈' : '📉', title: 'Puan Trendi',
        value: '$sign${trend.toStringAsFixed(1)}', subtitle: 'dünden bugüne', color: color,
      )),
      const SizedBox(width: 10),
      Expanded(child: _infoCard(
        icon: highDays >= 3 ? '🔴' : highDays >= 1 ? '🟡' : '🟢',
        title: 'Yüksek Risk',
        value: '$highDays gün', subtitle: 'bu hafta',
        color: _burnoutColor(highDays >= 3 ? 'High' : highDays >= 1 ? 'Medium' : 'Low'),
      )),
    ]);
  }

  Widget _infoCard({
    required String icon, required String title,
    required String value, required String subtitle, required Color color,
  }) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: color.withOpacity(0.08),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: color.withOpacity(0.3)),
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(icon, style: const TextStyle(fontSize: 20)),
      const SizedBox(height: 8),
      Text(value, style: TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.w800)),
      Text(subtitle, style: const TextStyle(color: Colors.white38, fontSize: 11)),
      const SizedBox(height: 2),
      Text(title, style: const TextStyle(color: Colors.white54, fontSize: 12)),
    ]),
  );

  // 🔥 Tip hatası düzeltildi — açık tip belirtildi
  Widget _buildLineChart(List<DailyRecordModel> records) => Container(
    height: 220,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: const Color(0xFF1A1A2E),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: Colors.white.withOpacity(0.06)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          _legendDot(const Color(0xFF4F8EF7), 'Puan'),
          const SizedBox(width: 12),
          _legendDot(const Color(0xFFa855f7), 'Verimlilik'),
          const SizedBox(width: 12),
          _legendDot(const Color(0xFF06b6d4), 'Odak'),
        ]),
        const SizedBox(height: 12),
        Expanded(
          child: LineChart(LineChartData(
            gridData: FlGridData(
              show: true, drawVerticalLine: false,
              getDrawingHorizontalLine: (_) =>
                  FlLine(color: Colors.white.withOpacity(0.05), strokeWidth: 1),
            ),
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(sideTitles: SideTitles(
                showTitles: true, reservedSize: 36,
                getTitlesWidget: (v, _) => Text(v.toInt().toString(),
                    style: const TextStyle(color: Colors.white38, fontSize: 10)),
              )),
              bottomTitles: AxisTitles(sideTitles: SideTitles(
                showTitles: true, reservedSize: 24,
                getTitlesWidget: (v, _) {
                  final i = v.toInt();
                  if (i < 0 || i >= records.length) return const SizedBox();
                  final parts = records[i].date.split('-');
                  return Text('${parts[2]}/${parts[1]}',
                      style: const TextStyle(color: Colors.white38, fontSize: 9));
                },
              )),
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles:   const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            borderData: FlBorderData(show: false),
            lineBarsData: [
              _lineData(records.map((DailyRecordModel r) => r.predictedScore).toList(),    const Color(0xFF4F8EF7)),
              _lineData(records.map((DailyRecordModel r) => r.productivityScore).toList(), const Color(0xFFa855f7)),
              _lineData(records.map((DailyRecordModel r) => r.focusIndex).toList(),        const Color(0xFF06b6d4)),
            ],
          )),
        ),
      ],
    ),
  );

  Widget _legendDot(Color color, String label) => Row(children: [
    Container(width: 8, height: 8,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
    const SizedBox(width: 4),
    Text(label, style: const TextStyle(color: Colors.white38, fontSize: 11)),
  ]);

  LineChartBarData _lineData(List<double> values, Color color) => LineChartBarData(
    spots: values.asMap().entries
        .map((e) => FlSpot(e.key.toDouble(), e.value))
        .toList(),
    isCurved: true, color: color, barWidth: 2.5,
    dotData: FlDotData(getDotPainter: (_, __, ___, ____) =>
        FlDotCirclePainter(radius: 3, color: color, strokeWidth: 0)),
    belowBarData: BarAreaData(show: true, color: color.withOpacity(0.06)),
  );

  // 🔥 Tip hatası düzeltildi
  Widget _buildBurnoutChart(List<DailyRecordModel> records) => Container(
    height: 180,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: const Color(0xFF1A1A2E),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: Colors.white.withOpacity(0.06)),
    ),
    child: BarChart(BarChartData(
      alignment: BarChartAlignment.spaceAround,
      maxY: 3.5,
      gridData: const FlGridData(show: false),
      borderData: FlBorderData(show: false),
      titlesData: FlTitlesData(
        bottomTitles: AxisTitles(sideTitles: SideTitles(
          showTitles: true, reservedSize: 24,
          getTitlesWidget: (v, _) {
            final i = v.toInt();
            if (i < 0 || i >= records.length) return const SizedBox();
            final parts = records[i].date.split('-');
            return Text('${parts[2]}/${parts[1]}',
                style: const TextStyle(color: Colors.white38, fontSize: 9));
          },
        )),
        leftTitles:  const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles:   const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      barGroups: records.asMap().entries.map((MapEntry<int, DailyRecordModel> e) {
        final color = _burnoutColor(e.value.burnoutRisk);
        return BarChartGroupData(x: e.key, barRods: [
          BarChartRodData(
            toY: _burnoutLevel(e.value.burnoutRisk).toDouble(),
            color: color, width: 22,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
          ),
        ]);
      }).toList(),
    )),
  );

  Widget _buildInsights(WeeklyStatsModel s) {
    final insights = <({String icon, Color color, String title, String body})>[];

    if (s.avgFocus < s.avgProductivity) {
      insights.add((icon: '🎯', color: const Color(0xFF4F8EF7),
      title: 'Odak Analizi',
      body: 'Verimliliğin yüksek ama odaklanma süren kısa. Deep Work seansları dene.'));
    } else {
      insights.add((icon: '🌟', color: const Color(0xFF22C55E),
      title: 'Odak Analizi',
      body: 'Odaklanma becerin verimliliğini besliyor. Bu disiplini koru.'));
    }

    if (s.highBurnoutDays >= 3) {
      insights.add((icon: '⚠️', color: const Color(0xFFEF4444),
      title: 'Kritik Uyarı',
      body: 'Bu hafta ${s.highBurnoutDays} gün yüksek tükenmişlik yaşadın. Programını hafifletmelisin.'));
    }

    if (s.scoreTrend > 0) {
      insights.add((icon: '📈', color: const Color(0xFF22C55E),
      title: 'Gelişim',
      body: 'Düne göre +${s.scoreTrend.toStringAsFixed(1)} puan artışı. Yükseliş devam ediyor!'));
    } else if (s.scoreTrend < 0) {
      insights.add((icon: '📉', color: const Color(0xFFF59E0B),
      title: 'Dikkat',
      body: 'Dünden ${s.scoreTrend.toStringAsFixed(1)} puan düştün. Uyku ve molana dikkat et.'));
    }

    if (insights.isEmpty) {
      insights.add((icon: '✅', color: const Color(0xFF22C55E),
      title: 'Harika Hafta',
      body: 'Dengeli ve istikrarlı bir hafta geçirdin. Böyle devam et!'));
    }

    return Column(children: insights.map((ins) => Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ins.color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ins.color.withOpacity(0.25)),
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(ins.icon, style: const TextStyle(fontSize: 24)),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(ins.title, style: TextStyle(color: ins.color,
              fontSize: 13, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text(ins.body, style: const TextStyle(color: Colors.white70, fontSize: 13)),
        ])),
      ]),
    )).toList());
  }

  Widget _sectionTitle(String title) => Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: Row(children: [
      Container(width: 3, height: 16, color: const Color(0xFF4F8EF7),
          margin: const EdgeInsets.only(right: 10)),
      Text(title, style: const TextStyle(color: Color(0xFF4F8EF7),
          fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 1.2)),
    ]),
  );

  Widget _summaryCard(String label, String value, String unit, Color color, String icon) =>
      Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(children: [
          Text(icon, style: const TextStyle(fontSize: 20)),
          const SizedBox(height: 6),
          RichText(text: TextSpan(children: [
            TextSpan(text: value, style: TextStyle(color: color,
                fontSize: 20, fontWeight: FontWeight.w800)),
            TextSpan(text: unit,
                style: const TextStyle(color: Colors.white38, fontSize: 10)),
          ])),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(color: Colors.white38, fontSize: 10),
              textAlign: TextAlign.center),
        ]),
      );
}