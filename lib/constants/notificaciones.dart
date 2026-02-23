import 'package:flutter/material.dart';
import 'dart:async';

class NotificationData {
  final String id;
  final IconData icon;
  final Color iconColor;
  final String text;
  final VoidCallback? onUndo;
  final VoidCallback? onExpired;
  final DateTime timestamp;
  final Duration duration;

  NotificationData({
    required this.id,
    required this.icon,
    required this.iconColor,
    required this.text,
    this.onUndo,
    this.onExpired,
    DateTime? timestamp,
    this.duration = const Duration(seconds: 3),
  }) : timestamp = timestamp ?? DateTime.now();
}

class NotificationManager extends ChangeNotifier {
  static final NotificationManager _instance = NotificationManager._internal();
  factory NotificationManager() => _instance;
  NotificationManager._internal();

  final List<NotificationData> _notifications = [];
  List<NotificationData> get notifications => List.unmodifiable(_notifications);


  void showNotification({
    required IconData icon,
    required Color iconColor,
    required String text,
    VoidCallback? onUndo,
    VoidCallback? onExpired,
    Duration duration = const Duration(seconds: 3),
  }) {
    final notification = NotificationData(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      icon: icon,
      iconColor: iconColor,
      text: text,
      onUndo: onUndo,
      onExpired: onExpired,
      duration: duration,
    );

    _notifications.add(notification);
    notifyListeners();
  }

  void removeNotification(String id) {
    _notifications.removeWhere((notification) => notification.id == id);
    notifyListeners();
  }

  void clear() {
    _notifications.clear();
    notifyListeners();
  }
}

class NotificationOverlay extends StatelessWidget {
  const NotificationOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 10,
      left: 0,
      right: 0,
      child: AnimatedBuilder(
        animation: NotificationManager(),
        builder: (context, child) {
          final notifications = NotificationManager().notifications;
          
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: notifications.asMap().entries.map((entry) {
              final index = entry.key;
              final notification = entry.value;
              
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                margin: EdgeInsets.only(
                  bottom: index == notifications.length - 1 ? 20 : 8,
                  left: 30,
                  right: 30,
                ),
                child: NotificationCard(
                  key: ValueKey(notification.id),
                  notification: notification,
                  index: index,
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}

class NotificationCard extends StatefulWidget {
  final NotificationData notification;
  final int index;

  const NotificationCard({
    super.key,
    required this.notification,
    required this.index,
  });

  @override
  State<NotificationCard> createState() => _NotificationCardState();
}

class _NotificationCardState extends State<NotificationCard>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _progressController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  Timer? _autoRemoveTimer;
  bool _wasUndone = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _progressController = AnimationController(
      duration: widget.notification.duration,
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
        begin: const Offset(0, 1),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
        reverseCurve: Curves.ease
      )
    );

    _fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _animationController.forward();
    _progressController.forward();
    _autoRemoveTimer = Timer(widget.notification.duration, _dismissNotification);

  }

  @override
  void dispose() {
    _animationController.dispose();
    _progressController.dispose();
    _autoRemoveTimer?.cancel();
    super.dispose();
  }

  void _dismissNotification() {
  _animationController.reverse().then((_) {
    NotificationManager().removeNotification(widget.notification.id);
    if (!_wasUndone && widget.notification.onExpired != null) {
      widget.notification.onExpired!(); // Solo si no se deshizo
    }
  });
}


  @override
  Widget build(BuildContext context) {

    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          constraints: const BoxConstraints(
            minHeight: 50,
            maxHeight: 60,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFF2D2D2D),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Contenido de la notificación
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Row(
                    children: [
                      Icon(
                        widget.notification.icon,
                        color: widget.notification.iconColor,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          widget.notification.text,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            decoration: TextDecoration.none,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (widget.notification.onUndo != null) ...[
                        const SizedBox(width: 12),
                        GestureDetector(
                          onTap: () {
                            _wasUndone = true;
                            widget.notification.onUndo?.call();
                            _dismissNotification();
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white12,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              'Deshacer',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                decoration: TextDecoration.none,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Widget principal que incluye el overlay
class NotificationWrapper extends StatelessWidget {
  final Widget child;

  const NotificationWrapper({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        const NotificationOverlay(),
      ],
    );
  }
}

// Funciones de utilidad para mostrar notificaciones comunes
class NotificationHelper {
  static void showSuccess(String message, {VoidCallback? onUndo, Duration? duration}) {
    NotificationManager().showNotification(
      icon: Icons.check_circle_outline_rounded,
      iconColor: Colors.green,
      text: message,
      onUndo: onUndo,
      duration: duration ?? const Duration(seconds: 4),
    );
  }

  static void showError(
    String message, {
    VoidCallback? onUndo,
    VoidCallback? onExpired,
    Duration? duration,
  }) {
    NotificationManager().showNotification(
      icon: Icons.delete_outline_rounded,
      iconColor: Colors.red,
      text: message,
      onUndo: onUndo,
      onExpired: onExpired,
      duration: duration ?? const Duration(seconds: 6),
    );
  }

  static void showWarning(String message, {VoidCallback? onUndo, Duration? duration}) {
    NotificationManager().showNotification(
      icon: Icons.warning_outlined,
      iconColor: Colors.orange,
      text: message,
      onUndo: onUndo,
      duration: duration ?? const Duration(seconds: 5),
    );
  }

  static void showInfo(String message, {VoidCallback? onUndo, Duration? duration}) {
    NotificationManager().showNotification(
      icon: Icons.info_outlined,
      iconColor: Colors.blue,
      text: message,
      onUndo: onUndo,
      duration: duration ?? const Duration(seconds: 3),
    );
  }
}