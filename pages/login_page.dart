import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Login
  final _loginEmailCtrl    = TextEditingController();
  final _loginPasswordCtrl = TextEditingController();
  bool _obscureLogin       = true;

  // Register
  final _regEmailCtrl    = TextEditingController();
  final _regPasswordCtrl = TextEditingController();
  int    _regAge         = 20;
  String _regGender      = 'Male';
  String _regAcademic    = 'Undergraduate';
  bool   _regPartTime    = false;
  bool   _obscureReg     = true;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _loginEmailCtrl.dispose();
    _loginPasswordCtrl.dispose();
    _regEmailCtrl.dispose();
    _regPasswordCtrl.dispose();
    super.dispose();
  }

  void _snack(String msg, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: error ? const Color(0xFFEF4444) : const Color(0xFF22C55E),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
  }

  Future<void> _login() async {
    if (_loginEmailCtrl.text.isEmpty || _loginPasswordCtrl.text.isEmpty) {
      _snack('Email ve şifre gerekli', error: true);
      return;
    }
    setState(() => _isLoading = true);
    try {
      final user = await AuthService.login(
        _loginEmailCtrl.text.trim(),
        _loginPasswordCtrl.text,
      );
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/daily', arguments: user);
    } on ApiException catch (e) {
      _snack(e.message, error: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _register() async {
    if (_regEmailCtrl.text.isEmpty || _regPasswordCtrl.text.isEmpty) {
      _snack('Email ve şifre gerekli', error: true);
      return;
    }
    setState(() => _isLoading = true);
    try {
      await AuthService.register(
        email:         _regEmailCtrl.text.trim(),
        password:      _regPasswordCtrl.text,
        age:           _regAge,
        gender:        _regGender,
        academicLevel: _regAcademic,
        partTimeJob:   _regPartTime ? 1 : 0,
      );
      if (!mounted) return;
      _snack('Kayıt başarılı! Giriş yapabilirsiniz.');
      _tabController.animateTo(0);
    } on ApiException catch (e) {
      _snack(e.message, error: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              _buildHeader(),
              const SizedBox(height: 36),
              _buildTabBar(),
              const SizedBox(height: 28),
              SizedBox(
                height: _tabController.index == 0 ? 280 : 560,
                child: TabBarView(
                  controller: _tabController,
                  children: [_buildLoginForm(), _buildRegisterForm()],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() => Row(children: [
    Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF4F8EF7).withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF4F8EF7).withOpacity(0.3)),
      ),
      child: const Text('🎓', style: TextStyle(fontSize: 28)),
    ),
    const SizedBox(width: 16),
    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('EduBoost AI',
          style: TextStyle(color: Colors.white, fontSize: 24,
              fontWeight: FontWeight.w800, letterSpacing: -0.5)),
      Text('Akademik performansını keşfet',
          style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 13)),
    ]),
  ]);

  Widget _buildTabBar() => Container(
    decoration: BoxDecoration(
      color: const Color(0xFF1A1A2E),
      borderRadius: BorderRadius.circular(14),
    ),
    child: TabBar(
      controller: _tabController,
      onTap: (_) => setState(() {}),
      indicator: BoxDecoration(
        color: const Color(0xFF4F8EF7),
        borderRadius: BorderRadius.circular(12),
      ),
      indicatorSize: TabBarIndicatorSize.tab,
      labelColor: Colors.white,
      unselectedLabelColor: Colors.white38,
      labelStyle: const TextStyle(fontWeight: FontWeight.w700),
      tabs: const [Tab(text: 'Giriş Yap'), Tab(text: 'Kayıt Ol')],
    ),
  );

  Widget _buildLoginForm() => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      _textField(_loginEmailCtrl, 'Email', Icons.email_outlined,
          keyboard: TextInputType.emailAddress),
      const SizedBox(height: 16),
      _textField(_loginPasswordCtrl, 'Şifre', Icons.lock_outline,
          obscure: _obscureLogin,
          onToggle: () => setState(() => _obscureLogin = !_obscureLogin)),
      const SizedBox(height: 32),
      _primaryBtn('Giriş Yap', _login),
    ],
  );

  Widget _buildRegisterForm() => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      _textField(_regEmailCtrl, 'Email', Icons.email_outlined,
          keyboard: TextInputType.emailAddress),
      const SizedBox(height: 12),
      _textField(_regPasswordCtrl, 'Şifre', Icons.lock_outline,
          obscure: _obscureReg,
          onToggle: () => setState(() => _obscureReg = !_obscureReg)),
      const SizedBox(height: 16),

      // Yaş
      _label('Yaş: $_regAge'),
      SliderTheme(
        data: SliderTheme.of(context).copyWith(
          activeTrackColor: const Color(0xFF4F8EF7),
          thumbColor: const Color(0xFF4F8EF7),
          inactiveTrackColor: const Color(0xFF2A2A3E),
        ),
        child: Slider(
          value: _regAge.toDouble(), min: 15, max: 40, divisions: 25,
          onChanged: (v) => setState(() => _regAge = v.toInt()),
        ),
      ),

      // Cinsiyet
      _label('Cinsiyet'),
      const SizedBox(height: 6),
      _segmented(
        values: ['Male', 'Female', 'Other'],
        labels: ['Erkek', 'Kadın', 'Diğer'],
        selected: _regGender,
        onChanged: (v) => setState(() => _regGender = v),
      ),
      const SizedBox(height: 12),

      // Akademik Seviye
      _label('Akademik Seviye'),
      const SizedBox(height: 6),
      _segmented(
        values: ['Undergraduate', 'Postgraduate'],
        labels: ['Lisans', 'Lisansüstü'],
        selected: _regAcademic,
        onChanged: (v) => setState(() => _regAcademic = v),
      ),
      const SizedBox(height: 12),

      // Part-time
      _switchRow('Part-time iş', _regPartTime,
              (v) => setState(() => _regPartTime = v)),
      const SizedBox(height: 24),
      _primaryBtn('Kayıt Ol', _register),
    ],
  );

  // ── Reusable widgets ─────────────────────────────

  Widget _textField(
      TextEditingController ctrl, String label, IconData icon, {
        TextInputType? keyboard, bool obscure = false, VoidCallback? onToggle,
      }) => TextField(
    controller: ctrl, obscureText: obscure, keyboardType: keyboard,
    style: const TextStyle(color: Colors.white),
    decoration: InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
      prefixIcon: Icon(icon, color: const Color(0xFF4F8EF7), size: 20),
      suffixIcon: onToggle != null
          ? IconButton(
          icon: Icon(obscure ? Icons.visibility_off : Icons.visibility,
              color: Colors.white38, size: 20),
          onPressed: onToggle)
          : null,
      filled: true, fillColor: const Color(0xFF1A1A2E),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.1))),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.1))),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF4F8EF7), width: 1.5)),
    ),
  );

  Widget _label(String t) => Padding(
    padding: const EdgeInsets.only(bottom: 2),
    child: Text(t, style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 13)),
  );

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
            border: Border.all(color: Colors.white.withOpacity(0.1))),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 14)),
          Switch(value: value, onChanged: onChanged, activeColor: const Color(0xFF4F8EF7)),
        ]),
      );

  Widget _primaryBtn(String label, VoidCallback onPressed) => SizedBox(
    height: 52,
    child: ElevatedButton(
      onPressed: _isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF4F8EF7),
        disabledBackgroundColor: const Color(0xFF4F8EF7).withOpacity(0.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        elevation: 0,
      ),
      child: _isLoading
          ? const SizedBox(width: 22, height: 22,
          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
          : Text(label, style: const TextStyle(color: Colors.white,
          fontSize: 16, fontWeight: FontWeight.w700)),
    ),
  );
}