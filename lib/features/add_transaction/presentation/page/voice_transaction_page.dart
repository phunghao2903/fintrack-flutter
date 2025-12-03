import 'dart:async';
import 'dart:math';

import 'package:fintrack/core/theme/app_colors.dart';
import 'package:fintrack/core/theme/app_text_styles.dart';
import 'package:fintrack/core/utils/size_utils.dart';
import 'package:fintrack/features/add_transaction/presentation/bloc/voice_entry_bloc.dart';
import 'package:fintrack/features/add_transaction/presentation/bloc/voice_entry_event.dart';
import 'package:fintrack/features/add_transaction/presentation/bloc/voice_entry_state.dart';
import 'package:fintrack/features/add_transaction/presentation/page/transaction_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class VoiceTransactionPage extends StatefulWidget {
  const VoiceTransactionPage({super.key});

  @override
  State<VoiceTransactionPage> createState() => _VoiceTransactionPageState();
}

class _VoiceTransactionPageState extends State<VoiceTransactionPage> {
  final Random _random = Random();
  final List<double> _waveformHeights =
      List<double>.filled(36, 6); // placeholder bars

  Timer? _waveformTimer;
  bool _isRecording = false;
  String _languageCode = 'en-US';
  String _capturedTranscript = '';

  @override
  void dispose() {
    _waveformTimer?.cancel();
    super.dispose();
  }

  void _startRecording() {
    setState(() {
      _isRecording = true;
      _capturedTranscript = '';
    });
    _resetWaveform();
    _waveformTimer?.cancel();
    _waveformTimer = Timer.periodic(
      const Duration(milliseconds: 140),
      _updateWaveform,
    );
  }

  void _stopRecording(BuildContext blocContext) {
    _waveformTimer?.cancel();
    _resetWaveform();
    setState(() {
      _isRecording = false;
    });
    _captureTranscriptFromVoice();
    _submitTranscript(blocContext);
  }

  void _resetWaveform() {
    for (var i = 0; i < _waveformHeights.length; i++) {
      _waveformHeights[i] = 6;
    }
  }

  void _captureTranscriptFromVoice() {
    if (_capturedTranscript.trim().isNotEmpty) return;
    _capturedTranscript = 'Voice input captured in $_languageCode';
  }

  void _updateWaveform(Timer _) {
    if (!_isRecording) return;
    setState(() {
      for (var i = 0; i < _waveformHeights.length; i++) {
        final base = _random.nextDouble() * 32;
        final dynamicPulse = _random.nextDouble() * 56;
        _waveformHeights[i] = 10 + base + dynamicPulse;
      }
    });
  }

  void _toggleRecording(BuildContext blocContext, bool isUploading) {
    if (isUploading) return;
    if (_isRecording) {
      _stopRecording(blocContext);
    } else {
      _startRecording();
    }
  }

  void _submitTranscript(BuildContext blocContext) {
    final transcript = _capturedTranscript.trim();
    if (transcript.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No transcript captured. Please record again.'),
        ),
      );
      return;
    }
    blocContext.read<VoiceEntryBloc>().add(
          UploadVoiceRequested(
            transcript: transcript,
            languageCode: _languageCode,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final double h = SizeUtils.height(context);
    final double w = SizeUtils.width(context);

    return BlocListener<VoiceEntryBloc, VoiceEntryState>(
      listenWhen: (previous, current) =>
          current is VoiceEntrySuccess || current is VoiceEntryFailure,
      listener: (context, state) {
        if (state is VoiceEntrySuccess) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  TransactionDetailPage(transaction: state.transaction),
            ),
          );
        } else if (state is VoiceEntryFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context),
                const SizedBox(height: 20),
                Text(
                  'Language',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.grey,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                _buildLanguageSelector(),
                const SizedBox(height: 24),
                _buildWaveformArea(h, w),
                const Spacer(),
              ],
            ),
          ),
        ),
        bottomNavigationBar: _buildBottomCTA(),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        _CircleIconButton(
          icon: Icons.close,
          onTap: () => Navigator.pop(context),
        ),
        const Spacer(),
        Text(
          'Voice Input',
          style: AppTextStyles.heading2.copyWith(
            color: AppColors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
        const Spacer(),
        _CircleIconButton(
          icon: Icons.info_outline,
          onTap: () {},
          background: AppColors.widget,
          iconColor: AppColors.white,
        ),
      ],
    );
  }

  Widget _buildLanguageSelector() {
    return Row(
      children: [
        Expanded(
          child: _LanguageChip(
            label: 'English',
            flag: '🇺🇸',
            selected: _languageCode == 'en-US',
            onTap: () => setState(() => _languageCode = 'en-US'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _LanguageChip(
            label: 'Vietnamese',
            flag: '🇻🇳',
            selected: _languageCode == 'vi-VN',
            onTap: () => setState(() => _languageCode = 'vi-VN'),
          ),
        ),
      ],
    );
  }

  Widget _buildWaveformArea(double h, double w) {
    final double waveformHeight = h * 0.32;

    return BlocBuilder<VoiceEntryBloc, VoiceEntryState>(
      buildWhen: (previous, current) => current is VoiceEntryUploading,
      builder: (context, state) {
        final bool isUploading = state is VoiceEntryUploading;
        return Container(
          height: waveformHeight,
          width: w,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          decoration: BoxDecoration(
            color: AppColors.widget,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: AppColors.main.withOpacity(0.35),
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.background.withOpacity(0.65),
                blurRadius: 20,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.main.withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.graphic_eq,
                          color: AppColors.main,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _isRecording
                                  ? 'Listening to your note'
                                  : 'Ready for your voice',
                              style: AppTextStyles.body1.copyWith(
                                color: AppColors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _isRecording
                                  ? 'Speak naturally, we will build the transaction'
                                  : 'Tap the mic to start recording',
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.main.withOpacity(0.14),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: _isRecording
                                    ? AppColors.main
                                    : AppColors.grey,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              _isRecording ? 'Recording' : 'Idle',
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (isUploading) const SizedBox(width: 12),
                      if (isUploading)
                        const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.4,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.main,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  Expanded(
                    child: Center(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 240),
                        child: _isRecording
                            ? _ActiveWaveform(
                                heights: _waveformHeights,
                              )
                            : const _IdleWaveform(),
                      ),
                    ),
                  ),
                ],
              ),
              if (isUploading)
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.background.withOpacity(0.55),
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: const Center(
                    child: SizedBox(
                      height: 26,
                      width: 26,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.main,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBottomCTA() {
    return BlocBuilder<VoiceEntryBloc, VoiceEntryState>(
      builder: (context, state) {
        final bool isUploading = state is VoiceEntryUploading;
        final String label =
            _isRecording ? 'Tap to stop' : 'Tap to start recording';
        final IconData icon = _isRecording ? Icons.stop : Icons.mic;

        return SafeArea(
          minimum: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _isRecording
                    ? 'Recording in $_languageCode'
                    : 'Voice-powered transaction',
                style: AppTextStyles.body1.copyWith(
                  color: AppColors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: () => _toggleRecording(context, isUploading),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  height: 84,
                  width: 84,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.main,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.main
                            .withOpacity(_isRecording ? 0.45 : 0.28),
                        blurRadius: _isRecording ? 30 : 16,
                        spreadRadius: _isRecording ? 6 : 2,
                      ),
                    ],
                  ),
                  child: Center(
                    child: isUploading
                        ? const SizedBox(
                            height: 28,
                            width: 28,
                            child: CircularProgressIndicator(
                              strokeWidth: 3,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppColors.background,
                              ),
                            ),
                          )
                        : Icon(
                            icon,
                            color: AppColors.background,
                            size: 34,
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.grey,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _LanguageChip extends StatelessWidget {
  const _LanguageChip({
    required this.label,
    required this.flag,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final String flag;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.main.withOpacity(selected ? 0.18 : 0.05),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: selected
                ? AppColors.main
                : AppColors.widget.withOpacity(0.6),
          ),
          boxShadow: [
            if (selected)
              BoxShadow(
                color: AppColors.main.withOpacity(0.35),
                blurRadius: 18,
                offset: const Offset(0, 10),
              ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              flag,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: AppTextStyles.body1.copyWith(
                color: selected ? AppColors.background : AppColors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({
    required this.icon,
    required this.onTap,
    this.background,
    this.iconColor,
  });

  final IconData icon;
  final VoidCallback onTap;
  final Color? background;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: background ?? AppColors.widget,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.background.withOpacity(0.7),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Icon(icon, color: iconColor ?? AppColors.white),
      ),
    );
  }
}

class _IdleWaveform extends StatelessWidget {
  const _IdleWaveform();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        32,
        (index) => Container(
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: 8,
          height: 3,
          decoration: BoxDecoration(
            color: AppColors.main.withOpacity(0.22),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    );
  }
}

class _ActiveWaveform extends StatelessWidget {
  const _ActiveWaveform({required this.heights});

  final List<double> heights;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 140,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ...heights.map(
            (value) => AnimatedContainer(
              duration: const Duration(milliseconds: 120),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: 6,
              height: value.clamp(12, 120),
              decoration: BoxDecoration(
                color: AppColors.main,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
