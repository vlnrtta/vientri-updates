import 'package:flutter/material.dart';
import 'package:vientri/constants/app_colors.dart';
import 'package:vientri/constants/app_fontsize.dart';

class ProfileComponent extends StatelessWidget {
  final String userName;
  final String userRole;
  final String? photoUrl;
  final VoidCallback? onTap; // ¡NUEVO PARÁMETRO!

  const ProfileComponent({
    super.key,
    required this.userName,
    required this.userRole,
    this.photoUrl,
    this.onTap, // Inicializa el nuevo parámetro
  });

  @override
  Widget build(BuildContext context) {

    // Envolvemos el contenido en un GestureDetector para el onTap
    return GestureDetector(
      onTap: onTap, // Pasamos la función onTap aquí
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildProfileImage(Fontsize()),
          SizedBox(width: 8.0),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                userName,
                style: TextStyle(
                  fontSize: Fontsize.body,
                  fontWeight: FontWeight.w400,
                  color: AppColors.semantics.text.body,
                ),
              ),
              Text(
                userRole,
                style: TextStyle(
                  fontSize: Fontsize.body,
                  fontWeight: FontWeight.w400,
                  color: AppColors.semantics.text.secondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProfileImage(Fontsize fontSize) {
    if (photoUrl != null && photoUrl!.isNotEmpty) {
      return ClipOval(
        child: Image.network(
          photoUrl!,
          width: 40.0,
          height: 40.0,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return _buildInitialAvatar(fontSize);
          },
        ),
      );
    } else {
      return _buildInitialAvatar(fontSize);
    }
  }

  Widget _buildInitialAvatar(Fontsize fontSize) {
    String initial = userName.isNotEmpty ? userName[0].toUpperCase() : '';
    return Container(
      width: 40.0,
      height: 40.0,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.brand.c950,
      ),
      child: Center(
        child: Text(
          initial,
          style: TextStyle(
            fontSize: Fontsize.h2,
            fontWeight: FontWeight.w400,
            color: AppColors.semantics.text.onAction,
          ),
        ),
      ),
    );
  }
}