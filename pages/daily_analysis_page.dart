import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../models/daily_record_model.dart';
import '../models/prediction_model.dart';
import '../services/prediction_service.dart';
import '../services/api_service.dart';

class DailyAnalysisPage extends StatefulWidget {
  final UserModel user;
  const DailyAnalysisPage({super.key, required this.user});

  @override
  State<DailyAnalysisPage> createState() => _DailyAnalysisPageState();
}

class _DailyAnalysisPageState extends State<DailyAnalysisPage> {
  // Form değerleri
  double _studyHours        = 4.0;
  double _selfStudyHours    = 2.0;
  double _onlineHours       = 1.0;
  double _sleepHours        = 7.0;
  double _socialMediaHours  = 2.0;
  double _gamingHours       = 0.0;
  double _exerciseMinutes   = 30.0;
  double _caffeineIntake    = 100.0;
  double _mentalHealth      = 7.0;
  String _internetQuality   = 'Average';
  bool   _upcomingDeadline  = false;
  // 🔥 Kafein — içecek sayaçları
  static const Map<String, int> _caffeinePerDrink = {
    'Espresso':       63,
    'Filtre Kahve':   95,
    'Türk Kahvesi':   50,
    'Çay':            40,
    'Enerji İçeceği': 80,
    'Kolalı İçecek':  35,
  };
  final Map<String, int> _drinkCount = {
    'Espresso':       0,
    'Filtre Kahve':   0,
    'Türk Kahvesi':   0,
    'Çay':            0,
    'Enerji İçeceği': 0,
    'Kolalı İçecek':  0,
  };

  int get _totalCaffeine => _drinkCount.entries
      .fold(0, (sum, e) => sum + e.value * (_caffeinePerDrink[e.key] ?? 0));
  bool             _isLoading  = false;
  PredictionModel? _result;

  Future<void> _analyze() async {
    setState(() { _isLoading = true; _result = null; });

    final input = DailyInputModel(
      studyHours:          _studyHours,
      selfStudyHours:      _selfStudyHours,
      onlineClassesHours:  _onlineHours,
      sleepHours:          _sleepHours,
      socialMediaHours:    _socialMediaHours,
      gamingHours:         _gamingHours,
      exerciseMinutes:     _exerciseMinutes.toInt(),
      caffeineIntakeMg:    _caffeineIntake.toInt(),
      mentalHealthScore:   _mentalHealth.toInt(),
      internetQuality:     _internetQuality,
      upcomingDeadline:    _upcomingDeadline ? 1 : 0,
    );

    try {
      final result = await PredictionService.predict(input, widget.user);
      setState(() => _result = result);
    } on ApiException catch (e) {
      _snack(e.message, error: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _snack(String msg, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: error ? const Color(0xFFEF4444) : const Color(0xFF22C55E),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F0F1A),
        elevation: 0,
        title: const Text('📊 Günlük Analiz',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline, color: Colors.white54),
            onPressed: () => Navigator.pushNamed(context, '/profile', arguments: widget.user),
          ),
          IconButton(
            icon: const Icon(Icons.bar_chart, color: Colors.white54),
            onPressed: () => Navigator.pushNamed(context, '/weekly', arguments: widget.user),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _sectionTitle('📚 Çalışma Saatleri'),
            _sliderTile('Toplam Çalışma', _studyHours, 0, 16,
                    (v) => setState(() => _studyHours = v), unit: 'sa'),
            _sliderTile('Bireysel Çalışma', _selfStudyHours, 0, 12,
                    (v) => setState(() => _selfStudyHours = v), unit: 'sa'),
            _sliderTile('Ders', _onlineHours, 0, 12,
                    (v) => setState(() => _onlineHours = v), unit: 'sa'),

            _sectionTitle('🌙 Yaşam Dengesi'),
            _sliderTile('Uyku', _sleepHours, 0, 12,
                    (v) => setState(() => _sleepHours = v), unit: 'sa'),
            _sliderTile('Sosyal Medya', _socialMediaHours, 0, 10,
                    (v) => setState(() => _socialMediaHours = v), unit: 'sa'),
            _sliderTile('Oyun', _gamingHours, 0, 10,
                    (v) => setState(() => _gamingHours = v), unit: 'sa'),

            _sectionTitle('💪 Sağlık & Odak'),
            _sliderTile('Egzersiz', _exerciseMinutes, 0, 180,
                    (v) => setState(() => _exerciseMinutes = v), unit: 'dk', divisions: 36),
            _caffeineSelector(),
            _sliderTile('Ruh Hali', _mentalHealth, 1, 10,
                    (v) => setState(() => _mentalHealth = v), divisions: 9),

            _sectionTitle('🌐 Ortam & Bağlam'),
            _internetSelector(),
            const SizedBox(height: 12),
            _deadlineToggle(),
            const SizedBox(height: 28),

            // Analiz Butonu
            SizedBox(
              height: 54,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _analyze,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4F8EF7),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5)
                    : const Text('🚀 Analizi Başlat',
                    style: TextStyle(color: Colors.white, fontSize: 17,
                        fontWeight: FontWeight.w700)),
              ),
            ),

            // Sonuçlar
            if (_result != null) ...[
              const SizedBox(height: 32),
              _buildResults(_result!),
            ],
          ],
        ),
      ),
    );
  }
// ── Kafein Seçici ─────────────────────────────────

  Widget _caffeineSelector() => Container(
    margin: const EdgeInsets.only(bottom: 10),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: const Color(0xFF1A1A2E),
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: Colors.white.withOpacity(0.06)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Text('☕ Kafeinli İçecekler',
              style: TextStyle(color: Colors.white70, fontSize: 13)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF4F8EF7).withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text('Toplam: $_totalCaffeine mg',
                style: const TextStyle(color: Color(0xFF4F8EF7),
                    fontSize: 12, fontWeight: FontWeight.w700)),
          ),
        ]),
        const SizedBox(height: 12),
        ..._caffeinePerDrink.keys.map((drink) => _drinkCounter(drink)),
      ],
    ),
  );

  Widget _drinkCounter(String drink) {
    final icons = {
      'Espresso':       '☕',
      'Filtre Kahve':   '🍵',
      'Türk Kahvesi':   '☕',
      'Çay':            '🍵',
      'Enerji İçeceği': '⚡',
      'Kolalı İçecek':  '🥤',
    };
    final count = _drinkCount[drink]!;
    final mg    = _caffeinePerDrink[drink]!;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(children: [
        Text(icons[drink] ?? '☕', style: const TextStyle(fontSize: 16)),
        const SizedBox(width: 8),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(drink, style: const TextStyle(color: Colors.white70, fontSize: 12)),
            Text('~$mg mg / bardak',
                style: const TextStyle(color: Colors.white38, fontSize: 10)),
          ]),
        ),
        // Azalt
        GestureDetector(
          onTap: count > 0
              ? () => setState(() => _drinkCount[drink] = count - 1)
              : null,
          child: Container(
            width: 30, height: 30,
            decoration: BoxDecoration(
              color: count > 0
                  ? const Color(0xFF4F8EF7).withOpacity(0.15)
                  : Colors.white.withOpacity(0.04),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.remove, size: 16,
                color: count > 0 ? const Color(0xFF4F8EF7) : Colors.white24),
          ),
        ),
        // Sayı
        SizedBox(
          width: 32,
          child: Text('$count',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: count > 0 ? Colors.white : Colors.white38,
                  fontSize: 14,
                  fontWeight: FontWeight.w700)),
        ),
        // Artır
        GestureDetector(
          onTap: () => setState(() => _drinkCount[drink] = count + 1),
          child: Container(
            width: 30, height: 30,
            decoration: BoxDecoration(
              color: const Color(0xFF4F8EF7).withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.add, size: 16, color: Color(0xFF4F8EF7)),
          ),
        ),
      ]),
    );
  }
  // ── Sonuç Paneli ─────────────────────────────────

  Widget _buildResults(PredictionModel r) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      const Divider(color: Color(0xFF2A2A3E), thickness: 1),
      const SizedBox(height: 16),
      const Text('✨ Analiz Sonuçları',
          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
      const SizedBox(height: 16),

      // Tükenmişlik Rozeti
      _burnoutBadge(r.burnoutRisk, r.burnoutConfidence),
      const SizedBox(height: 16),

      // 3 Metrik Kart
      Row(children: [
        Expanded(child: _metricCard('Sınav Tahmini', '${r.predictedScore.toStringAsFixed(1)}',
            '/100', const Color(0xFF4F8EF7), '🎓')),
        const SizedBox(width: 10),
        Expanded(child: _metricCard('Verimlilik', '${r.productivityScore.toStringAsFixed(1)}',
            '/100', const Color(0xFFa855f7), '⚡')),
        const SizedBox(width: 10),
        Expanded(child: _metricCard('Odak', '${r.focusIndex.toStringAsFixed(1)}',
            '/100', const Color(0xFF06b6d4), '🎯')),
      ]),
      const SizedBox(height: 20),

      // Öneriler
      _sectionTitle('💡 Kişisel Öneriler'),
      ..._generateTips(r),
    ],
  );

  Widget _burnoutBadge(String risk, double confidence) {
    final configs = {
      'Low':    (const Color(0xFF22c55e), '🟢', 'Düşük Risk'),
      'Medium': (const Color(0xFFf59e0b), '🟡', 'Orta Risk'),
      'High':   (const Color(0xFFef4444), '🔴', 'Yüksek Risk'),
    };
    final c = configs[risk] ?? (Colors.grey, '⚪', risk);
    final color = c.$1; final dot = c.$2; final label = c.$3;
    final pct   = (confidence * 100).toInt();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.4), width: 1.5),
      ),
      child: Column(children: [
        Text(dot, style: const TextStyle(fontSize: 36)),
        const SizedBox(height: 6),
        Text(label, style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.w800)),
        Text('Tükenmişlik Riski', style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12)),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(99),
          child: LinearProgressIndicator(
            value: confidence,
            backgroundColor: const Color(0xFF1A1A2E),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 8,
          ),
        ),
        const SizedBox(height: 4),
        Text('Model güveni: %$pct',
            style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 11)),
      ]),
    );
  }

  Widget _metricCard(String label, String value, String unit, Color color, String icon) =>
      Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(children: [
          Text(icon, style: const TextStyle(fontSize: 22)),
          const SizedBox(height: 4),
          RichText(text: TextSpan(children: [
            TextSpan(text: value,
                style: TextStyle(color: color, fontSize: 22, fontWeight: FontWeight.w800)),
            TextSpan(text: unit,
                style: const TextStyle(color: Colors.white38, fontSize: 11)),
          ])),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(color: Colors.white38, fontSize: 10),
              textAlign: TextAlign.center),
        ]),
      );

  List<Widget> _generateTips(PredictionModel r) {
    final tips = <String>[];
    if (_sleepHours < 6) tips.add('😴 Uyku süren 6 saatin altında. 7-9 saat önerilir.');
    if (_sleepHours > 9) tips.add('🛌 Fazla uyku yorgunluğa yol açabilir.');
    if (r.burnoutRisk == 'High') tips.add('🔥 Yüksek tükenmişlik riski! Mola ver, nefes egzersizleri dene.');
    if (r.burnoutRisk == 'Medium') tips.add('⚠️ Orta tükenmişlik. Hobine zaman ayır.');
    if (_socialMediaHours > 4) tips.add('📱 Sosyal medyada çok zaman geçiriyorsun. Pomodoro dene.');
    if (_exerciseMinutes < 20) tips.add('🏃 Yeterince hareket etmedin. 20 dk yürüyüş faydalı.');
    if (_mentalHealth <= 4) tips.add('💙 Ruh halin düşük. Güvendiğin biriyle konuş.');
    if (_caffeineIntake > 400) tips.add('☕ Kafein çok yüksek. Öğleden sonra kahveden kaçın.');
    if (r.focusIndex < 50) tips.add('🎯 Odak indeksin düşük. Dağıtıcı unsurları kapat.');
    if (tips.isEmpty) tips.add('🌟 Harika! Dengeli bir gün geçirdin.');

    return tips.map((t) => Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF4F8EF7).withOpacity(0.2)),
      ),
      child: Text(t, style: const TextStyle(color: Colors.white70, fontSize: 13)),
    )).toList();
  }

  // ── Form Widgets ─────────────────────────────────

  Widget _sectionTitle(String title) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 14),
    child: Row(children: [
      Container(width: 3, height: 16, color: const Color(0xFF4F8EF7),
          margin: const EdgeInsets.only(right: 10)),
      Text(title, style: const TextStyle(color: Color(0xFF4F8EF7),
          fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 1.2)),
    ]),
  );

  Widget _sliderTile(String label, double value, double min, double max,
      ValueChanged<double> onChanged, {String unit = '', int divisions = 0}) =>
      Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A2E),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withOpacity(0.06)),
        ),
        child: Column(children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(label, style: const TextStyle(color: Colors.white70, fontSize: 13)),
            Text('${value.toStringAsFixed(unit == 'dk' || unit == 'mg' ? 0 : 1)} $unit',
                style: const TextStyle(color: Color(0xFF4F8EF7),
                    fontSize: 13, fontWeight: FontWeight.w700)),
          ]),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: const Color(0xFF4F8EF7),
              thumbColor: const Color(0xFF4F8EF7),
              inactiveTrackColor: const Color(0xFF2A2A3E),
              overlayColor: const Color(0xFF4F8EF7).withOpacity(0.1),
              trackHeight: 3,
            ),
            child: Slider(
              value: value, min: min, max: max,
              divisions: divisions > 0 ? divisions : ((max - min) * 2).toInt(),
              onChanged: onChanged,
            ),
          ),
        ]),
      );

  Widget _internetSelector() => Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
    decoration: BoxDecoration(
      color: const Color(0xFF1A1A2E),
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: Colors.white.withOpacity(0.06)),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text('İnternet Kalitesi',
            style: TextStyle(color: Colors.white70, fontSize: 13)),
        DropdownButton<String>(
          value: _internetQuality,
          dropdownColor: const Color(0xFF1A1A2E),
          underline: const SizedBox(),
          style: const TextStyle(color: Colors.white),
          items: const [
            DropdownMenuItem(value: 'Poor',    child: Text('🔴 Zayıf')),
            DropdownMenuItem(value: 'Average', child: Text('🟡 Orta')),
            DropdownMenuItem(value: 'Good',    child: Text('🟢 İyi')),
          ],
          onChanged: (v) => setState(() => _internetQuality = v!),
        ),
      ],
    ),
  );

  Widget _deadlineToggle() => Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    decoration: BoxDecoration(
      color: const Color(0xFF1A1A2E),
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: Colors.white.withOpacity(0.06)),
    ),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      const Text('Yaklaşan Teslim Tarihi',
          style: TextStyle(color: Colors.white70, fontSize: 13)),
      Switch(
        value: _upcomingDeadline,
        onChanged: (v) => setState(() => _upcomingDeadline = v),
        activeColor: const Color(0xFF4F8EF7),
      ),
    ]),
  );
}