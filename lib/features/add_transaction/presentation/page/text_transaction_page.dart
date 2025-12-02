import 'package:fintrack/core/theme/app_colors.dart';
import 'package:fintrack/core/theme/app_text_styles.dart';
import 'package:fintrack/core/utils/size_utils.dart';
import 'package:fintrack/features/add_transaction/presentation/bloc/text_entry_bloc.dart';
import 'package:fintrack/features/add_transaction/presentation/bloc/text_entry_event.dart';
import 'package:fintrack/features/add_transaction/presentation/bloc/text_entry_state.dart';
import 'package:fintrack/features/add_transaction/presentation/page/transaction_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TextTransactionPage extends StatefulWidget {
  const TextTransactionPage({super.key});

  @override
  State<TextTransactionPage> createState() => _TextTransactionPageState();
}

class _TextTransactionPageState extends State<TextTransactionPage> {
  final TextEditingController _textController = TextEditingController();
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _textController.addListener(_handleTextChanged);
  }

  @override
  void dispose() {
    _textController.removeListener(_handleTextChanged);
    _textController.dispose();
    super.dispose();
  }

  void _handleTextChanged() {
    final hasMeaningfulText = _textController.text.trim().isNotEmpty;
    setState(() {
      if (hasMeaningfulText) {
        _errorText = null;
      }
    });
  }

  void _handleSave(BuildContext blocContext) {
    final text = _textController.text.trim();
    if (text.isEmpty) {
      setState(() {
        _errorText = 'Please enter transaction text';
      });
      return;
    }
    blocContext.read<TextEntryBloc>().add(SubmitTextRequested(text));
  }

  @override
  Widget build(BuildContext context) {
    final h = SizeUtils.height(context);
    final w = SizeUtils.width(context);
    final hasError = _errorText != null && _errorText!.isNotEmpty;

    return BlocListener<TextEntryBloc, TextEntryState>(
      listenWhen: (previous, current) =>
          current is TextEntrySuccess || current is TextEntryFailure,
      listener: (context, state) {
        if (state is TextEntrySuccess) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  TransactionDetailPage(transaction: state.transaction),
            ),
          );
        } else if (state is TextEntryFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Text(
            'Quick Text Input',
            style: AppTextStyles.body1.copyWith(color: AppColors.white),
          ),
          backgroundColor: AppColors.background,
          iconTheme: const IconThemeData(color: AppColors.white),
        ),
        body: SafeArea(
          top: false,
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: w * 0.05,
                  vertical: h * 0.03,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight,
                  ),
                  child: Column(
                    children: [
                      SizedBox(
                        height: h * 0.5,
                        width: double.infinity,
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.widget,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          padding: EdgeInsets.symmetric(
                            horizontal: w * 0.05,
                            vertical: h * 0.03,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: EdgeInsets.only(bottom: h * 0.01),
                                child: Text(
                                  'Transaction text',
                                  style: AppTextStyles.caption.copyWith(
                                    color: AppColors.grey,
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: TextField(
                                  controller: _textController,
                                  keyboardType: TextInputType.multiline,
                                  textInputAction: TextInputAction.newline,
                                  maxLines: null,
                                  expands: true,
                                  autofocus: true,
                                  cursorColor: AppColors.grey,
                                  style:
                                      const TextStyle(color: AppColors.white),
                                  textAlignVertical: TextAlignVertical.top,
                                  decoration: InputDecoration(
                                    hintText:
                                        'Enter quick transaction text (e.g., Buy coffee 20k techcombank)',
                                    errorText: _errorText,
                                    errorStyle: const TextStyle(
                                      color: Colors.red,
                                    ),
                                    border: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: hasError
                                            ? Colors.red
                                            : AppColors.grey,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: hasError
                                            ? Colors.red
                                            : AppColors.main,
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: hasError
                                            ? Colors.red
                                            : AppColors.grey,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        bottomNavigationBar: BlocBuilder<TextEntryBloc, TextEntryState>(
          builder: (context, state) {
            final isSubmitting = state is TextEntrySubmitting;

            return BottomAppBar(
              color: AppColors.widget,
              child: SizedBox(
                height: h * 0.1,
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.main,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed:
                      isSubmitting ? null : () => _handleSave(context),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'SAVE',
                        style: AppTextStyles.body2,
                      ),
                      if (isSubmitting) ...[
                        const SizedBox(width: 10),
                        const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.white,
                            ),
                          ),
                        ),
                      ],
                    ],
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
