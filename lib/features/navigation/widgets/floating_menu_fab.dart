import 'dart:math';

import 'package:equatable/equatable.dart';
import 'package:fintrack/core/theme/app_colors.dart';
import 'package:fintrack/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FloatingMenuState extends Equatable {
  const FloatingMenuState({required this.isOpen});

  final bool isOpen;

  @override
  List<Object> get props => [isOpen];
}

class FloatingMenuCubit extends Cubit<FloatingMenuState> {
  FloatingMenuCubit() : super(const FloatingMenuState(isOpen: false));

  void toggleMenu() {
    state.isOpen ? closeMenu() : openMenu();
  }

  void openMenu() {
    if (!state.isOpen) emit(const FloatingMenuState(isOpen: true));
  }

  void closeMenu() {
    if (state.isOpen) emit(const FloatingMenuState(isOpen: false));
  }
}

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

  late final FloatingMenuCubit _menuCubit;
  late final AnimationController _controller;
  late final Animation<double> _menuAnimation;

  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();
    _menuCubit = FloatingMenuCubit();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 260),
      vsync: this,
    );
    _menuAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );
  }

  @override
  void dispose() {
    _removeOverlay();
    _controller.dispose();
    _menuCubit.close();
    super.dispose();
  }

  Future<void> _handleStateChange(FloatingMenuState state) async {
    if (state.isOpen) {
      _insertOverlay();
      await _controller.forward(from: 0);
    } else {
      await _controller.reverse();
      _removeOverlay();
    }
  }

  void _insertOverlay() {
    if (_overlayEntry != null) return;
    final overlay = Overlay.of(context);
    if (overlay == null) return;

    final anchor = _resolveAnchor();
    _overlayEntry = OverlayEntry(
      builder: (overlayContext) => BlocProvider.value(
        value: _menuCubit,
        child: _RadialMenuOverlay(
          anchor: anchor,
          animation: _menuAnimation,
          onAddRegular: widget.onAddRegular,
          onQuickAdd: widget.onQuickAdd,
          onVoiceInput: widget.onVoiceInput,
          onClose: _menuCubit.closeMenu,
        ),
      ),
    );
    overlay.insert(_overlayEntry!);
  }

  _FabAnchor _resolveAnchor() {
    final renderBox = _fabKey.currentContext?.findRenderObject() as RenderBox?;
    final Size size = renderBox?.size ?? const Size(56, 56);
    final Offset offset = renderBox?.localToGlobal(Offset.zero) ?? Offset.zero;

    return _FabAnchor(
      center: offset + Offset(size.width / 2, size.height / 2),
      size: size,
    );
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _menuCubit,
      child: BlocListener<FloatingMenuCubit, FloatingMenuState>(
        listenWhen: (previous, current) => previous.isOpen != current.isOpen,
        listener: (context, state) => _handleStateChange(state),
        child: BlocBuilder<FloatingMenuCubit, FloatingMenuState>(
          builder: (context, state) {
            return IgnorePointer(
              ignoring: state.isOpen,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 140),
                opacity: state.isOpen ? 0 : 1,
                child: FloatingActionButton(
                  key: _fabKey,
                  heroTag: 'floating-menu-fab',
                  backgroundColor: AppColors.main,
                  shape: const CircleBorder(),
                  elevation: 6,
                  onPressed: context.read<FloatingMenuCubit>().toggleMenu,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 160),
                    transitionBuilder: (child, animation) {
                      return FadeTransition(
                        opacity: animation,
                        child: ScaleTransition(
                          scale: Tween<double>(begin: 0.9, end: 1.0)
                              .animate(animation),
                          child: child,
                        ),
                      );
                    },
                    child: Icon(
                      state.isOpen ? Icons.close : Icons.add,
                      key: ValueKey<bool>(state.isOpen),
                      color: AppColors.white,
                      size: 30,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _RadialMenuOverlay extends StatelessWidget {
  const _RadialMenuOverlay({
    required this.anchor,
    required this.animation,
    required this.onAddRegular,
    required this.onQuickAdd,
    required this.onVoiceInput,
    required this.onClose,
  });

  final _FabAnchor anchor;
  final Animation<double> animation;
  final VoidCallback onAddRegular;
  final VoidCallback onQuickAdd;
  final VoidCallback onVoiceInput;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final double scrimBottom =
        (mediaQuery.size.height * 0.08) + mediaQuery.viewPadding.bottom;

    final double baseRadius = max(anchor.size.width * 2.2, 112);
    final double elevatedRadius = max(anchor.size.width * 2.6, 136);

    final items = <_RadialMenuItem>[
      _RadialMenuItem(
        angleDeg: -130,
        radius: baseRadius,
        label: 'Add Regular',
        icon: Icons.edit_outlined,
        onTap: () {
          onClose();
          onAddRegular();
        },
      ),
      _RadialMenuItem(
        angleDeg: -90,
        radius: elevatedRadius,
        label: 'Quick Add',
        icon: Icons.flash_on_outlined,
        onTap: () {
          onClose();
          onQuickAdd();
        },
      ),
      _RadialMenuItem(
        angleDeg: -50,
        radius: baseRadius,
        label: 'Voice Input',
        icon: Icons.mic_none_outlined,
        onTap: () {
          onClose();
          onVoiceInput();
        },
      ),
    ];

    return Material(
      color: AppColors.background.withOpacity(0),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            bottom: scrimBottom,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onClose,
              child: Container(
                color: AppColors.background.withOpacity(0.6),
              ),
            ),
          ),
          ...items.map(
            (item) => _RadialActionButton(
              anchor: anchor,
              animation: animation,
              item: item,
              diameter: anchor.size.width,
            ),
          ),
          Positioned(
            left: anchor.center.dx - anchor.size.width / 2,
            top: anchor.center.dy - anchor.size.height / 2,
            child: FadeTransition(
              opacity: animation,
              child: ScaleTransition(
                scale: Tween<double>(begin: 0.9, end: 1.0).animate(animation),
                child: FloatingActionButton(
                  heroTag: 'floating-menu-fab-overlay',
                  backgroundColor: AppColors.main,
                  shape: const CircleBorder(),
                  elevation: 10,
                  onPressed: onClose,
                  child: const Icon(
                    Icons.close,
                    color: AppColors.background,
                    size: 30,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RadialActionButton extends StatelessWidget {
  const _RadialActionButton({
    required this.anchor,
    required this.animation,
    required this.item,
    required this.diameter,
  });

  final _FabAnchor anchor;
  final Animation<double> animation;
  final _RadialMenuItem item;
  final double diameter;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final double radians = item.angleDeg * (pi / 180);
        final double effectiveRadius = item.radius * animation.value;
        final Offset offset = Offset(
          cos(radians) * effectiveRadius,
          sin(radians) * effectiveRadius,
        );
        final double slide = 12 * (1 - animation.value);

        return Positioned(
          left: anchor.center.dx + offset.dx - diameter / 2,
          top: anchor.center.dy + offset.dy - diameter / 2,
          child: Opacity(
            opacity: animation.value,
            child: Transform.translate(
              offset: Offset(0, slide),
              child: child,
            ),
          ),
        );
      },
      child: _MenuActionButton(
        label: item.label,
        icon: item.icon,
        onTap: item.onTap,
        diameter: diameter,
      ),
    );
  }
}

class _MenuActionButton extends StatelessWidget {
  const _MenuActionButton({
    required this.label,
    required this.icon,
    required this.onTap,
    required this.diameter,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final double diameter;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          color: AppColors.main,
          shape: const CircleBorder(),
          elevation: 6,
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            customBorder: const CircleBorder(),
            splashColor: AppColors.widget.withOpacity(0.18),
            child: SizedBox(
              height: diameter,
              width: diameter,
              child: Icon(
                icon,
                color: AppColors.background,
                size: 24,
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: AppColors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _RadialMenuItem {
  _RadialMenuItem({
    required this.angleDeg,
    required this.radius,
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final double angleDeg;
  final double radius;
  final String label;
  final IconData icon;
  final VoidCallback onTap;
}

class _FabAnchor {
  const _FabAnchor({required this.center, required this.size});

  final Offset center;
  final Size size;
}
