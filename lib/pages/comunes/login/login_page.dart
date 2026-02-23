// ignore_for_file: unused_element, deprecated_member_use
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:vientri/constants/app_colors.dart';
import 'package:vientri/pages/comunes/login/login_controller.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final Color principal = const Color.fromARGB(255, 17, 17, 17);
  final Color accentColor = const Color.fromARGB(255, 255, 147, 7);
  final LoginController con = LoginController();
  bool _isVisible = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: principal,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isDesktop = constraints.maxWidth >= 900;

          return isDesktop
              ? _buildDesktopLayout()
              : _buildMobileLayout();
        },
      ),
    );
  }

  /* -------------------- DESKTOP -------------------- */

  Widget _buildDesktopLayout() {
    return Row(
      children: [
        Expanded(
          child: _buildBrandSection(),
        ),
        Expanded(
          child: Center(
            child: _buildLoginCard(maxWidth: 420),
          ),
        ),
      ],
    );
  }

  /* -------------------- MOBILE -------------------- */

  Widget _buildMobileLayout() {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 120),
            _buildLogo(),
            const SizedBox(height: 80),
            _buildLoginCard(),
          ],
        ),
      ),
    );
  }

  /* -------------------- BRAND -------------------- */

  Widget _buildBrandSection() {
    return Container(
      padding: const EdgeInsets.all(48),
      alignment: Alignment.center,
      child: _buildLogo(),
    );
  }

  Widget _buildLogo() {
    return RichText(
      text: TextSpan(
        text: 'VIENTR',
        style: const TextStyle(
          fontSize: 64,
          color: Colors.white,
          fontWeight: FontWeight.w300,
          letterSpacing: 2,
        ),
        children: [
          TextSpan(
            text: 'I',
            style: TextStyle(
              color: accentColor,
              fontWeight: FontWeight.w300,
            ),
          ),
        ],
      ),
    );
  }

  /* -------------------- CARD -------------------- */

  Widget _buildLoginCard({double maxWidth = double.infinity}) {
    return Container(
      constraints: BoxConstraints(maxWidth: maxWidth),
      margin: const EdgeInsets.all(24),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 30,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildUserField(),
          _buildPasswordField(),
          const SizedBox(height: 10),
          _buildLoginButton(),
        ],
      ),
    );
  }

  /* -------------------- FIELDS -------------------- */

  Widget _buildUserField() {
    return _inputContainer(
      child: TextField(
        controller: con.userController,
        decoration: InputDecoration(
          hintText: 'Usuario',
          hintStyle: TextStyle(
            color: AppColors.semantics.text.secondary
          ),
          prefixIcon: Icon(Icons.person_outlined),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildPasswordField() {
    return _inputContainer(
      child: TextField(
        controller: con.passwordController,
        obscureText: !_isVisible,
        decoration: InputDecoration(
          hintText: 'Contraseña',
          hintStyle: TextStyle(
            color: AppColors.semantics.text.secondary,
          ),
          prefixIcon: const Icon(Icons.lock_outline),
          suffixIcon: IconButton(
            icon: Icon(
              _isVisible
                  ? CupertinoIcons.eye_fill
                  : CupertinoIcons.eye_slash_fill,
              color: _isVisible ? accentColor : Colors.grey,
            ),
            onPressed: () {
              setState(() => _isVisible = !_isVisible);
            },
          ),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _inputContainer({required Widget child}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: child,
    );
  }

  /* -------------------- BUTTON -------------------- */

  Widget _buildLoginButton() {
    return GestureDetector(
      onTap: () => con.iniciarSesion(context),
      child: Container(
        margin: const EdgeInsets.only(top: 20),
        height: 52,
        decoration: BoxDecoration(
          color: principal,
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Center(
          child: Text(
            'Iniciar sesión',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
