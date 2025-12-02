import 'dart:math';

import 'package:fintrack/core/theme/app_colors.dart';
import 'package:fintrack/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';

class FloatingMenuFab extends StatefulWidget {
  const FloatingMenuFab({
    super.key,
    required this.onAddRegular,
    required this.onQuickAdd,
    required this.onVoiceInput,
  });

  final VoidCallback onAddRegular;
  final VoidCallback onQuickAdd;
  final VoidCallback onVoiceInput;

  @override
  State<FloatingMenuFab> createState() => _FloatingMenuFabState();
}

class _FloatingMenuFabState extends State<FloatingMenuFab>
    with SingleTickerProviderStateMixin {
  final GlobalKey _fabKey = GlobalKey();

  late final AnimationController _controller = AnimationController(
    duration: const Duration(milliseconds: 260),
    vsync: this,
  );

  late final Animation<double> _menuAnimation = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeOutCubic,
    reverseCurve: Curves.easeInCubic,
  );

  OverlayEntry? _overlayEntry;
  bool _isOpen = false;

  @override
  void dispose() {
    _controller.dispose();
    _removeOverlay();
    super.dispose();
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _toggleMenu() {
    if (_isOpen) {
      _closeMenu();
    } else {
      _openMenu();
    }
  }

  void _openMenu() {
    _overlayEntry ??= _buildOverlay();
    Overlay.of(context)?.insert(_overlayEntry!);
    setState(() {
      _isOpen = true;
    });
    _controller.forward(from: 0);
  }

  Future<void> _closeMenu() async {
    if (!_isOpen) return;
    await _controller.reverse();
    _removeOverlay();
    if (mounted) {
      setState(() {
        _isOpen = false;
      });
    }
  }

  OverlayEntry _buildOverlay() {
    final renderBox = _fabKey.currentContext?.findRenderObject() as RenderBox?;
    final fabSize = renderBox?.size ?? const Size(64, 64);
    final fabOffset = renderBox?.localToGlobal(Offset.zero) ?? Offset.zero;
    final center = fabOffset + Offset(fabSize.width / 2, fabSize.height / 2);

    return OverlayEntry(
      builder: (context) {
        return Material(
          color: Colors.transparent,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned.fill(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: _closeMenu,
                  child: Container(
                    color: AppColors.background.withOpacity(0.55),
                  ),
                ),
              ),
              Positioned.fill(
                child: AnimatedBuilder(
                  animation: _menuAnimation,
                  builder: (context, _) {
                    const double radius = 100;
                    final double resolvedRadius = radius * _menuAnimation.value;
                    final double fabDiameter = fabSize.width;
                    final double backgroundTop =
                        center.dy - resolvedRadius - 12; // behind mini FABs

                    return Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Positioned(
                          left: center.dx - 150,
                          top: backgroundTop,
                          child: Opacity(
                            opacity: _menuAnimation.value,
                            child: Container(
                              width: 300,
                              height: 72,
                              decoration: BoxDecoration(
                                color: AppColors.widget,
                                borderRadius: BorderRadius.circular(40),
                              ),
                            ),
                          ),
                        ),
                        ..._buildMenuItems(
                          center: center,
                          radius: resolvedRadius,
                          diameter: fabDiameter,
                        ),
                        Positioned(
                          left: center.dx - fabSize.width / 2,
                          top: center.dy - fabSize.height / 2,
                          child: _buildMainButton(
                            isClose: true,
                            onTap: _closeMenu,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  List<Widget> _buildMenuItems({
    required Offset center,
    required double radius,
    required double diameter,
  }) {
    final items = <_MenuItemData>[
      _MenuItemData(
        angle: -120,
        label: 'Add Regular',
        icon: Icons.edit,
        onTap: () {
          _closeMenu();
          widget.onAddRegular();
        },
      ),
      _MenuItemData(
        angle: -90,
        label: 'Quick Add',
        icon: Icons.flash_on,
        onTap: () {
          _closeMenu();
          widget.onQuickAdd();
        },
      ),
      _MenuItemData(
        angle: -60,
        label: 'Voice Input',
        icon: Icons.mic,
        onTap: () {
          _closeMenu();
          widget.onVoiceInput();
        },
      ),
    ];

    return items.map((item) {
      final double radians = item.angle * (pi / 180);
      final offset = Offset(
        radius * cos(radians),
        radius * sin(radians),
      );

      return Positioned(
        left: center.dx + offset.dx - diameter / 2,
        top: center.dy + offset.dy - diameter / 2,
        child: Transform.scale(
          scale: _menuAnimation.value,
          alignment: Alignment.center,
          child: _MenuButton(
            icon: item.icon,
            label: item.label,
            onTap: item.onTap,
          ),
        ),
      );
    }).toList();
  }

  Widget _buildMainButton({
    Key? buttonKey,
    required VoidCallback onTap,
    bool isClose = false,
  }) {
    return FloatingActionButton(
      key: buttonKey,
      heroTag: isClose ? 'overlay-menu-fab' : 'main-menu-fab',
      backgroundColor: AppColors.main,
      shape: const CircleBorder(),
      elevation: 6,
      onPressed: onTap,
      child: Icon(
        isClose ? Icons.close : Icons.add,
        color: AppColors.white,
        size: 30,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: _isOpen,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 120),
        opacity: _isOpen ? 0 : 1,
        child: _buildMainButton(
          buttonKey: _fabKey,
          onTap: _toggleMenu,
          isClose: false,
        ),
      ),
    );
  }
}

class _MenuButton extends StatelessWidget {
  const _MenuButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          color: AppColors.widget,
          shape: const CircleBorder(),
          elevation: 2,
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            customBorder: const CircleBorder(),
            splashColor: AppColors.white.withOpacity(0.24),
            child: SizedBox(
              height: 56,
              width: 56,
              child: Center(
                child: Icon(
                  icon,
                  color: AppColors.white,
                  size: 26,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: AppTextStyles.body2.copyWith(color: AppColors.white),
        ),
      ],
    );
  }
}

class _MenuItemData {
  _MenuItemData({
    required this.angle,
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final double angle;
  final String label;
  final IconData icon;
  final VoidCallback onTap;
}
