import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/profile_service.dart';
import '../services/api_service.dart';

class ProfilePage extends StatefulWidget {
  final UserModel user;
  const ProfilePage({super.key, required this.user});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late int    _age;
  late String _gender;
  late String _academicLevel;
  late bool   _partTime;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _age           = widget.user.age;
    _gender        = widget.user.gender;
    _academicLevel = widget.user.academicLevel;
    _partTime      = widget.user.partTimeJob == 1;
  }

  Future<void> _save() async {
    setState(() => _isSaving = true);
    try {
      await ProfileService.update(
        studentId:     widget.user.id,
        age:           _age,
        gender:        _gender,
        academicLevel: _academicLevel,
        partTimeJob:   _partTime ? 1 : 0,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('✅ Profil güncellendi!'),
        backgroundColor: Color(0xFF22C55E),
        behavior: SnackBarBehavior.floating,
      ));
      // Güncel user'ı bir önceki sayfaya geri döndür
      Navigator.pop(context, UserModel(
        id:            widget.user.id,
        email:         widget.user.email,
        age:           _age,
        gender:        _gender,
        academicLevel: _academicLevel,
        partTimeJob:   _partTime ? 1 : 0,
      ));
    } on ApiException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(e.message),
        backgroundColor: const Color(0xFFEF4444),
        behavior: SnackBarBehavior.floating,
      ));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F0F1A),
        elevation: 0,
        title: const Text('👤 Profil',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white54),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _sectionTitle('📧 Hesap'),
            _readonlyField('Email', widget.user.email, Icons.email_outlined),
            const SizedBox(height: 20),

            _sectionTitle('🎓 Kişisel Bilgiler'),
            _label('Yaş: $_age'),
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: const Color(0xFF4F8EF7),
                thumbColor: const Color(0xFF4F8EF7),
                inactiveTrackColor: const Color(0xFF2A2A3E),
              ),
              child: Slider(
                value: _age.toDouble(), min: 15, max: 60, divisions: 45,
                onChanged: (v) => setState(() => _age = v.toInt()),
              ),
            ),
            const SizedBox(height: 12),

            _label('Cinsiyet'),
            const SizedBox(height: 6),
            _segmented(
              values: ['Male', 'Female', 'Other'],
              labels: ['Erkek', 'Kadın', 'Diğer'],
              selected: _gender,
              onChanged: (v) => setState(() => _gender = v),
            ),
            const SizedBox(height: 16),

            _label('Akademik Seviye'),
            const SizedBox(height: 6),
            _segmented(
              values: ['Undergraduate', 'Postgraduate'],
              labels: ['🎓 Lisans', '📚 Lisansüstü'],
              selected: _academicLevel,
              onChanged: (v) => setState(() => _academicLevel = v),
            ),
            const SizedBox(height: 20),

            _sectionTitle('💼 Çalışma Durumu'),
            _switchRow('Part-time iş çalışıyor musun?', _partTime,
                    (v) => setState(() => _partTime = v)),
            const SizedBox(height: 32),

            SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4F8EF7),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                child: _isSaving
                    ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5)
                    : const Text('💾 Değişiklikleri Kaydet',
                    style: TextStyle(color: Colors.white, fontSize: 16,
                        fontWeight: FontWeight.w700)),
              ),
            ),
            const SizedBox(height: 16),

            TextButton(
              onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
              child: const Text('Çıkış Yap',
                  style: TextStyle(color: Colors.white38, fontSize: 14)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String t) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Row(children: [
      Container(width: 3, height: 16, color: const Color(0xFF4F8EF7),
          margin: const EdgeInsets.only(right: 10)),
      Text(t, style: const TextStyle(color: Color(0xFF4F8EF7),
          fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 1.2)),
    ]),
  );

  Widget _readonlyField(String label, String value, IconData icon) => TextField(
    enabled: false,
    controller: TextEditingController(text: value),
    style: const TextStyle(color: Colors.white54),
    decoration: InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white38),
      prefixIcon: Icon(icon, color: Colors.white24, size: 20),
      filled: true, fillColor: const Color(0xFF1A1A2E),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.06))),
      disabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.06))),
    ),
  );

  Widget _label(String t) => Text(t,
      style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 13));

  Widget _segmented({
    required List<String> values, required List<String> labels,
    required String selected, required ValueChanged<String> onChanged,
  }) => Row(children: List.generate(values.length, (i) {
    final sel = selected == values[i];
    return Expanded(child: GestureDetector(
      onTap: () => onChanged(values[i]),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: EdgeInsets.only(right: i < values.length - 1 ? 8 : 0),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: sel ? const Color(0xFF4F8EF7) : const Color(0xFF1A1A2E),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: sel
              ? const Color(0xFF4F8EF7) : Colors.white.withOpacity(0.1)),
        ),
        child: Text(labels[i], textAlign: TextAlign.center,
            style: TextStyle(color: sel ? Colors.white : Colors.white38,
                fontSize: 13, fontWeight: sel ? FontWeight.w700 : FontWeight.normal)),
      ),
    ));
  }));

  Widget _switchRow(String label, bool value, ValueChanged<bool> onChanged) =>
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(color: const Color(0xFF1A1A2E),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white.withOpacity(0.06))),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Expanded(child: Text(label,
              style: const TextStyle(color: Colors.white70, fontSize: 13))),
          Switch(value: value, onChanged: onChanged, activeColor: const Color(0xFF4F8EF7)),
        ]),
      );
}