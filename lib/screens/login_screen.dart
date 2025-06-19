import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String _pin = '';

  void _addDigit(int digit) {
    if (_pin.length < 6) {
      setState(() {
        _pin += digit.toString();
        if (_pin.length == 6) {
          _authenticate();
        }
      });
    }
  }

  void _deleteDigit() {
    if (_pin.isNotEmpty) {
      setState(() {
        _pin = _pin.substring(0, _pin.length - 1);
      });
    }
  }

  Widget _buildNumberButton(int number) {
    return Container(
      margin: const EdgeInsets.all(8),
      width: 70,
      height: 70,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _addDigit(number),
          borderRadius: BorderRadius.circular(35),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: const Color(0xFF00E5FF).withOpacity(0.3),
                width: 2,
              ),
              borderRadius: BorderRadius.circular(35),
            ),
            child: Center(
              child: Text(
                number.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDeleteButton() {
    return Container(
      margin: const EdgeInsets.all(8),
      width: 70,
      height: 70,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _deleteDigit,
          borderRadius: BorderRadius.circular(35),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: const Color(0xFF00E5FF).withOpacity(0.3),
                width: 2,
              ),
              borderRadius: BorderRadius.circular(35),
            ),
            child: const Center(
              child: Icon(
                Icons.backspace_outlined,
                color: Color(0xFF00E5FF),
                size: 24,
              ),
            ),
          ),
        ),
      ),
    );
  }
  final LocalAuthentication _localAuth = LocalAuthentication();
  bool _isFirstTime = true;
  bool _isConfirming = false;
  String _tempPin = '';
  bool _showError = false;

  @override
  void initState() {
    super.initState();
    _checkFirstTime();
  }

  Future<void> _checkFirstTime() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isFirstTime = prefs.getString('pin') == null;
    });
  }

  Future<void> _authenticate() async {
    if (_pin.length != 6) return;

    final prefs = await SharedPreferences.getInstance();
    
    if (_isFirstTime) {
      if (!_isConfirming) {
        _tempPin = _pin;
        setState(() {
          _isConfirming = true;
          _pin = '';
        });
        return;
      } else {
        if (_tempPin == _pin) {
          await prefs.setString('pin', _pin);
          _navigateToHome();
        } else {
          setState(() {
            _isConfirming = false;
            _showError = true;
            _pin = '';
          });
        }
      }
    } else {
      final storedPin = prefs.getString('pin');
      if (storedPin == _pin) {
        _navigateToHome();
      } else {
        setState(() {
          _showError = true;
          _pin = '';
        });
      }
    }
  }

  Future<void> _resetPin() async {
    bool canCheckBiometrics = await _localAuth.canCheckBiometrics;
    if (!canCheckBiometrics) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Biometric authentication not available')),
      );
      return;
    }

    try {
      bool didAuthenticate = await _localAuth.authenticate(
        localizedReason: 'Please authenticate to reset PIN',
        options: const AuthenticationOptions(biometricOnly: true),
      );

      if (didAuthenticate) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('pin');
        setState(() {
          _isFirstTime = true;
          _isConfirming = false;
          if (_showError) {
            _showError = false;
          }
          _pin = '';
        });
      }
    } on PlatformException {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Authentication failed')),
      );
    }
  }

  void _navigateToHome() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const HomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.background,
              Theme.of(context).colorScheme.surface,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.games,
                  size: 80,
                  color: Color(0xFF00E5FF),
                ),
                const SizedBox(height: 24),
                Text(
                  _isFirstTime
                      ? _isConfirming
                          ? 'Confirm Your PIN'
                          : 'Create Security PIN'
                      : 'Welcome Back, Player!',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  _isFirstTime
                      ? _isConfirming
                          ? 'Re-enter the same PIN to confirm'
                          : 'Choose a 6-digit PIN to secure your game accounts'
                      : 'Enter your PIN to access your game vault',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: _showError ? Colors.red : null,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (_showError)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      _isFirstTime
                          ? 'PINs do not match. Try again.'
                          : 'Incorrect PIN. Try again.',
                      style: TextStyle(color: Colors.red[400], fontSize: 14),
                    ),
                  ),
                const SizedBox(height: 40),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    6,
                    (index) => Container(
                      width: 40,
                      height: 50,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _showError
                              ? Colors.red
                              : _pin.length > index
                                  ? const Color(0xFF00E5FF)
                                  : const Color(0xFF00E5FF).withOpacity(0.3),
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: _pin.length > index
                            ? Icon(
                                Icons.circle,
                                size: 12,
                                color: _showError
                                    ? Colors.red
                                    : const Color(0xFF00E5FF),
                              )
                            : null,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                Column(
                  children: [
                    for (var i = 0; i < 3; i++)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          for (var j = 1; j <= 3; j++)
                            _buildNumberButton((i * 3) + j),
                        ],
                      ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildNumberButton(0),
                        _buildDeleteButton(),
                      ],
                    ),
                  ],
                ),
                if (!_isFirstTime)
                  TextButton(
                    onPressed: _resetPin,
                    child: const Text(
                      'Reset PIN',
                      style: TextStyle(color: Color(0xFF00E5FF)),
                    ),
                  ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }


}
