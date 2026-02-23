import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vientri/pages/comunes/login/nuevaPassword/nueva_password_4.dart';
import 'package:vientri/src/models/entidad.dart';

// ignore: must_be_immutable
class NuevaPasswordTres extends StatefulWidget {
  String ruta;
  Entidad entidad;
  String email;
  NuevaPasswordTres({super.key, required this. ruta, required this.entidad, required this.email});

  @override
  State<NuevaPasswordTres> createState() => _NuevaPasswordTresState();
}

class _NuevaPasswordTresState extends State<NuevaPasswordTres> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _repitePasswordController = TextEditingController();
  
  final _passwordText = ''.obs;
  final _repitePasswordText = ''.obs;
  final FocusNode _passwordFocusNode = FocusNode();
  final FocusNode _repitePasswordFocusNode = FocusNode();
  final _passwordIsFocused = false.obs;
  final _repitePasswordIsFocused = false.obs;

  bool _obscurePassword = true;
  bool _obscureRepeatPassword = true;
  bool nuevaPasswordValida = false;
  
  // Password validation states
  bool _hasMinLength = false;
  bool _hasUppercase = false;
  bool _hasLowercase = false;
  bool _hasNumber = false;
  bool _passwordsMatch = false;

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(() {
      _passwordText.value = _passwordController.text;
    });

    _passwordFocusNode.addListener(() {
      _passwordIsFocused.value = _passwordFocusNode.hasFocus;
    });

    _repitePasswordController.addListener(() {
      _repitePasswordText.value = _repitePasswordController.text;
    });

    _repitePasswordFocusNode.addListener(() {
      _repitePasswordIsFocused.value = _repitePasswordFocusNode.hasFocus;
    });

    _passwordController.addListener(_validatePassword);
    _repitePasswordController.addListener(_validatePasswordMatch);
  }

  void _validatePassword() {
    final password = _passwordController.text;
    setState(() {
      _hasMinLength = password.length >= 8;
      _hasUppercase = password.contains(RegExp(r'[A-Z]'));
      _hasLowercase = password.contains(RegExp(r'[a-z]'));
      _hasNumber = password.contains(RegExp(r'[0-9]'));
      
      nuevaPasswordValida = _hasMinLength && _hasUppercase && _hasLowercase && _hasNumber && _passwordsMatch;
    });
    _validatePasswordMatch();
  }

  void _validatePasswordMatch() {
    setState(() {
      _passwordsMatch = _passwordController.text.isNotEmpty && 
                      _repitePasswordController.text.isNotEmpty &&
                      _passwordController.text == _repitePasswordController.text;
      
      nuevaPasswordValida = _hasMinLength && _hasUppercase && _hasLowercase && _hasNumber && _passwordsMatch;
    });
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _repitePasswordController.dispose();
    _passwordFocusNode.dispose();
    _repitePasswordFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: Colors.white,
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                reverse: true,
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildHeader(),
                          const Text(
                            "Restablecer contraseña",
                            style: TextStyle(
                              color: Colors.black87,
                              fontWeight: FontWeight.bold,
                              fontSize: 24,
                            ),
                          ),
                          const SizedBox(height: 30),
                          _inputPassword(),
                          const SizedBox(height: 20),
                          _buildPasswordRequirements(),
                          const SizedBox(height: 20),
                          _inputRepitePassword(),
                          const SizedBox(height: 10),
                          _buildPasswordMatchIndicator(),
                          const Spacer(),
                          _btnAccion(),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(0, 20, 0, 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.black87.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              onPressed: () {
                Navigator.pop(context);
                /*Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) => NuevaPasswordDos(ruta: widget.ruta, entidad: widget.entidad, email: widget.email),
                    transitionsBuilder: (context, animation, secondaryAnimation, child) {
                      const begin = Offset(-1.0, 0.0);
                      const end = Offset.zero;
                      final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: Curves.ease));
                      return SlideTransition(position: animation.drive(tween), child: child);
                    },
                    transitionDuration: const Duration(milliseconds: 400),
                  ),
                );*/
              },
              icon: const Icon(Icons.arrow_back, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  Widget _inputPassword() {
    return Obx(() => Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: _passwordIsFocused.value ? Colors.green : Colors.grey.shade300, width: 1),
        ),
      ),
      child: Row(
        children: [
          const Text(
            'Nueva contraseña',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _passwordController,
              focusNode: _passwordFocusNode,
              obscureText: _obscurePassword,
              textAlign: TextAlign.right,
              decoration: const InputDecoration(
                isDense: true,
                contentPadding: EdgeInsets.zero,
                border: InputBorder.none,
              ),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: Icon(
              _obscurePassword ? Icons.visibility_off : Icons.visibility,
              color: Colors.grey,
              size: 20,
            ),
            onPressed: () {
              setState(() {
                _obscurePassword = !_obscurePassword;
              });
            },
          ),
        ],
      ),
    ));
  }

  Widget _buildPasswordRequirements() {
    return Column(
      children: [
        _buildRequirementItem("Mínimo 8 caracteres", _hasMinLength),
        _buildRequirementItem("Al menos una letra en mayúsculas", _hasUppercase),
        _buildRequirementItem("Al menos una letra en minúsculas", _hasLowercase),
        _buildRequirementItem("Al menos un número", _hasNumber),
      ],
    );
  }

  Widget _buildRequirementItem(String text, bool isValid) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            isValid ? Icons.check : Icons.close,
            color: isValid ? Colors.green : Colors.grey,
            size: 16,
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              fontSize: 14,
              color: isValid ? Colors.green : Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _inputRepitePassword() {
    return Obx(() => Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: _repitePasswordIsFocused.value ? Colors.green : Colors.grey.shade300, width: 1),
        ),
      ),
      child: Row(
        children: [
          const Text(
            'Repetir nueva contraseña',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _repitePasswordController,
              focusNode: _repitePasswordFocusNode,
              obscureText: _obscureRepeatPassword,
              textAlign: TextAlign.right,
              decoration: const InputDecoration(
                isDense: true,
                contentPadding: EdgeInsets.zero,
                border: InputBorder.none,
              ),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: Icon(
              _obscureRepeatPassword ? Icons.visibility_off : Icons.visibility,
              color: Colors.grey,
              size: 20,
            ),
            onPressed: () {
              setState(() {
                _obscureRepeatPassword = !_obscureRepeatPassword;
              });
            },
          ),
        ],
      ),
    ));
  }

  Widget _buildPasswordMatchIndicator() {
    if (_repitePasswordController.text.isEmpty) return const SizedBox.shrink();
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            _passwordsMatch ? Icons.check : Icons.close,
            color: _passwordsMatch ? Colors.green : Colors.grey,
            size: 16,
          ),
          const SizedBox(width: 8),
          Text(
            "Las contraseñas deben coincidir",
            style: TextStyle(
              fontSize: 14,
              color: _passwordsMatch ? Colors.green : Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _btnAccion() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: nuevaPasswordValida 
        ? () {
          Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) => NuevaPasswordCuatro(ruta: widget.ruta, entidad: widget.entidad),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                const begin = Offset(1.0, 0.0);
                const end = Offset.zero;
                final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: Curves.ease));
                return SlideTransition(position: animation.drive(tween), child: child);
              },
              transitionDuration: const Duration(milliseconds: 400),
            ),
          );
        }
        : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: nuevaPasswordValida ? Colors.black87 : const Color.fromARGB(255, 221, 220, 220),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 0,
        ),
        child: const Padding(
          padding: EdgeInsets.symmetric(vertical: 15),
          child: Text(
            'Guardar cambios',
            style: TextStyle(
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }


}