import 'dart:async';
import 'dart:io';
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
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';

class VoiceTransactionPage extends StatefulWidget {
  const VoiceTransactionPage({super.key});

  @override
  State<VoiceTransactionPage> createState() => _VoiceTransactionPageState();
}

class _VoiceTransactionPageState extends State<VoiceTransactionPage> {
  final Random _random = Random();
  final List<double> _waveformHeights =
      List<double>.filled(36, 6); // placeholder bars

  final AudioRecorder _recorder = AudioRecorder();
  StreamSubscription<Amplitude>? _amplitudeSubscription;

  bool _isRecording = false;
  bool _hasVoiceInput = false;
  String _languageCode = 'en-US';
  String _capturedTranscript = '';
  String? _audioFilePath;
  String? _recordingFilePath;
  String? _lastErrorMessage;

  static const double _silenceThresholdDb = -45;

  @override
  void dispose() {
    _amplitudeSubscription?.cancel();
    _recorder.dispose();
    super.dispose();
  }

  Future<bool> _ensureMicrophonePermission() async {
    final hasPermission = await _recorder.hasPermission();
    if (hasPermission) return true;

    final status = await Permission.microphone.request();
    return status.isGranted;
  }

  Future<void> _startRecording() async {
    if (!await _ensureMicrophonePermission()) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Microphone permission is required to record audio.'),
        ),
      );
      return;
    }

    try {
      final directory = await getTemporaryDirectory();
      final filePath =
          '${directory.path}/voice_${DateTime.now().millisecondsSinceEpoch}.m4a';

      await _recorder.start(
        const RecordConfig(
          encoder: AudioEncoder.aacLc,
          bitRate: 128000,
          sampleRate: 44100,
        ),
        path: filePath,
      );
      _listenToAmplitude();
      _flattenWaveform();
      setState(() {
        _isRecording = true;
        _capturedTranscript = '';
        _audioFilePath = null;
        _hasVoiceInput = false;
        _recordingFilePath = filePath;
        _lastErrorMessage = null;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to start recording: $e')),
      );
    }
  }

  Future<void> _stopRecording(BuildContext blocContext) async {
    _amplitudeSubscription?.cancel();
    _hasVoiceInput = false;

    try {
      final stopPath = await _recorder.stop();
      final resolvedPath = stopPath?.isNotEmpty == true
          ? stopPath
          : _recordingFilePath;
      _flattenWaveform();
      if (!mounted) return;
      setState(() {
        _isRecording = false;
        _audioFilePath = resolvedPath;
      });

      if (resolvedPath == null ||
          resolvedPath.isEmpty ||
          !File(resolvedPath).existsSync()) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No audio captured. Please record again.'),
          ),
        );
        return;
      }

      _captureTranscriptFromVoice();
      _submitTranscript(blocContext);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isRecording = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to stop recording: $e')),
      );
    }
  }

  void _listenToAmplitude() {
    _amplitudeSubscription?.cancel();
    _amplitudeSubscription = _recorder
        .onAmplitudeChanged(const Duration(milliseconds: 140))
        .listen((amp) {
      if (!mounted) return;
      final hasVoice = amp.current > _silenceThresholdDb;
      if (hasVoice != _hasVoiceInput) {
        setState(() {
          _hasVoiceInput = hasVoice;
        });
        if (!hasVoice) {
          _flattenWaveform();
        }
      }
      if (hasVoice) {
        _updateWaveformFromAmplitude(amp.current);
      }
    });
  }

  void _flattenWaveform() {
    if (!mounted) return;
    setState(() {
      for (var i = 0; i < _waveformHeights.length; i++) {
        _waveformHeights[i] = 6;
      }
    });
  }

  void _resetVisualState() {
    if (!mounted) return;
    _flattenWaveform();
    setState(() {
      _isRecording = false;
      _hasVoiceInput = false;
      _audioFilePath = null;
      _recordingFilePath = null;
      _lastErrorMessage = null;
    });
  }

  void _updateWaveformFromAmplitude(double levelDb) {
    if (!_isRecording || !_hasVoiceInput || !mounted) return;
    final normalized = ((levelDb + 60) / 60).clamp(0.0, 1.0);

    setState(() {
      for (var i = 0; i < _waveformHeights.length; i++) {
        final base = 12 + (_random.nextDouble() * 26 * normalized);
        final dynamicPulse = _random.nextDouble() * 64 * normalized;
        _waveformHeights[i] = 8 + base + dynamicPulse;
      }
    });
  }

  void _captureTranscriptFromVoice() {
    if (_capturedTranscript.trim().isNotEmpty) return;
    _capturedTranscript = 'Voice input captured in $_languageCode';
  }

  Future<void> _toggleRecording(
    BuildContext blocContext,
    bool isUploading,
  ) async {
    if (isUploading) return;
    if (_isRecording) {
      await _stopRecording(blocContext);
    } else {
      blocContext.read<VoiceEntryBloc>().add(VoiceEntryReset());
      await _startRecording();
    }
  }

  void _submitTranscript(BuildContext blocContext) {
    final transcript = _capturedTranscript.trim();
    final audioPath = _audioFilePath;
    if (audioPath == null || audioPath.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No audio captured. Please record again.'),
        ),
      );
      return;
    }
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
            audioPath: audioPath,
          ),
        );
    setState(() {
      _lastErrorMessage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final double h = SizeUtils.height(context);
    final double w = SizeUtils.width(context);

    return BlocListener<VoiceEntryBloc, VoiceEntryState>(
      listener: (context, state) {
        if (state is VoiceEntrySuccess) {
          _resetVisualState();
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  TransactionDetailPage(transaction: state.transaction),
            ),
          ).then((_) {
            if (mounted) {
              context.read<VoiceEntryBloc>().add(VoiceEntryReset());
            }
          });
        } else if (state is VoiceEntryFailure) {
          _resetVisualState();
          setState(() {
            _lastErrorMessage = state.message;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
          context.read<VoiceEntryBloc>().add(VoiceEntryReset());
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
      builder: (context, state) {
        final bool isUploading = state is VoiceEntryUploading;
        final bool showError =
            _lastErrorMessage != null && !isUploading;
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
                  const SizedBox(height: 16),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(28),
                      child: Center(
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 240),
                          child: _isRecording && _hasVoiceInput && !isUploading
                              ? _ActiveWaveform(
                                  heights: _waveformHeights,
                                )
                              : const _IdleWaveform(),
                        ),
                      ),
                    ),
                  ),
                  if (showError) ...[
                    const SizedBox(height: 8),
                    Text(
                      _lastErrorMessage ?? '',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.grey,
                      ),
                    ),
                  ],
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
        final String label = isUploading
            ? 'Uploading your audio...'
            : _isRecording
                ? 'Tap to stop'
                : 'Tap to start recording';
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
                onTap: isUploading ? null : () => _toggleRecording(context, isUploading),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  height: 84,
                  width: 84,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color:
                        isUploading ? AppColors.main.withOpacity(0.65) : AppColors.main,
                    boxShadow: [
                      if (!isUploading)
                        BoxShadow(
                          color:
                              AppColors.main.withOpacity(_isRecording ? 0.45 : 0.28),
                          blurRadius: _isRecording ? 30 : 16,
                          spreadRadius: _isRecording ? 6 : 2,
                        ),
                    ],
                  ),
                  child: Center(
                    child: Icon(
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
    return LayoutBuilder(
      builder: (context, constraints) {
        const double barWidth = 6;
        const double horizontalMargin = 3;
        final double totalBarWidth = barWidth + (horizontalMargin * 2);
        final int computedBars =
            (constraints.maxWidth / totalBarWidth).floor();
        final int barCount = computedBars > 0 ? computedBars.clamp(1, 48) : 1;

        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            barCount,
            (index) => Container(
              margin: const EdgeInsets.symmetric(horizontal: horizontalMargin),
              width: barWidth,
              height: 3,
              decoration: BoxDecoration(
                color: AppColors.main.withOpacity(0.22),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ActiveWaveform extends StatelessWidget {
  const _ActiveWaveform({required this.heights});

  final List<double> heights;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const double barWidth = 6;
        const double horizontalMargin = 3;
        final double totalBarWidth = barWidth + (horizontalMargin * 2);
        final int computedBars =
            (constraints.maxWidth / totalBarWidth).floor();
        final int barCount = computedBars > 0
            ? computedBars.clamp(1, heights.length)
            : 1;
        final visibleHeights = heights.take(barCount).toList();

        return SizedBox(
          height: 140,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ...visibleHeights.map(
                (value) => AnimatedContainer(
                  duration: const Duration(milliseconds: 120),
                  margin:
                      const EdgeInsets.symmetric(horizontal: horizontalMargin),
                  width: barWidth,
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
      },
    );
  }
}
