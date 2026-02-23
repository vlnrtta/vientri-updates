import 'package:vientri/components/key_value_table/key_value_table.dart';
import 'package:vientri/components/solid_button/solid_button.dart';
import 'package:vientri/components/subtle_button/subtle_button.dart';
import 'package:vientri/constants/app_colors.dart';
import 'package:vientri/constants/app_shadows.dart';
import 'package:flutter/material.dart';

class BottomSheetComponent extends StatelessWidget {
  final List<KeyValueItem> items;
  final VoidCallback? onAddItem;
  final VoidCallback? onSendToCheckout;
  final bool showAddItemButton;
  final bool showSendToCheckoutButton;

  const BottomSheetComponent({
    super.key,
    required this.items,
    this.onAddItem,
    this.onSendToCheckout,
    this.showAddItemButton = true,
    this.showSendToCheckoutButton = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: AppColors.semantics.surface.page,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: AppShadows.elementFocusShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. KeyValueTable
          KeyValueTable(items: items),

          // Si hay al menos un botón, agregamos separación
          if (showAddItemButton || showSendToCheckoutButton)
            const SizedBox(height: 12.0),

          // SubtleButton opcional
          if (showAddItemButton) ...[
            SubtleButton(
              onPressed: onAddItem,
              text: 'Añadir artículo',
              leftIcon: Icons.add,
              type: SubtleButtonType.brand,
              width: SubtleButtonWidth.wrap,
            ),
            if (showSendToCheckoutButton) const SizedBox(height: 8.0),
          ],

          // SolidButton opcional
          if (showSendToCheckoutButton)
            SolidButton(
              onPressed: onSendToCheckout,
              text: 'Enviar a caja',
              leftIcon: Icons.send_outlined,
              type: SolidButtonType.primary,
              width: SolidButtonWidth.full,
            ),
        ],
      ),
    );
  }
}
