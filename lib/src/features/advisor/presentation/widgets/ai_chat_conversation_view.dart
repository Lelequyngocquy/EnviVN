import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';

import '../../../../common/constants/colors.dart';
import '../../../../core/domain/entities/app_location_entity.dart';
import '../../../../core/domain/entities/model_download_state.dart';
import '../../../../core/presentation/widgets/app_icon.dart';
import '../../../../core/presentation/widgets/app_text.dart';
import '../../../air_quality/domain/entities/air_quality_entity.dart';
import '../../../details/domain/entities/details_entity.dart';
import '../cubits/advisor_chat_cubit.dart';
import '../cubits/advisor_chat_state.dart';

class AiChatConversationView extends StatefulWidget {
  final AppLocationEntity location;
  final DetailsEntity weather;
  final AirQualityEntity airQuality;

  const AiChatConversationView({
    super.key,
    required this.location,
    required this.weather,
    required this.airQuality,
  });

  @override
  State<AiChatConversationView> createState() => _AiChatConversationViewState();
}

class _AiChatConversationViewState extends State<AiChatConversationView> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendMessage() {
    final text = _textController.text.trim();
    if (text.isEmpty) return;
    _textController.clear();
    context.read<AdvisorChatCubit>().sendMessage(text);
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AdvisorChatCubit, AdvisorChatState>(
      listener: (context, state) {
        if (state.messages.isNotEmpty) {
          _scrollToBottom();
        }
      },
      builder: (context, state) {
        final dState = state.downloadState;

        if (dState.status != ModelDownloadStatus.ready) {
          return _ModelDownloadCard(
            downloadState: dState,
            onStartDownload: () =>
                context.read<AdvisorChatCubit>().startDownload(),
            onPauseDownload: () =>
                context.read<AdvisorChatCubit>().pauseDownload(),
            onResumeDownload: () =>
                context.read<AdvisorChatCubit>().resumeDownload(),
            onCancelDownload: () =>
                context.read<AdvisorChatCubit>().cancelDownload(),
          );
        }

        return Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.only(top: 8, bottom: 8),
                itemCount: state.messages.length,
                itemBuilder: (context, index) {
                  final message = state.messages[index];
                  return _MessageBubble(message: message);
                },
              ),
            ),
            if (state.suggestedQuestions.isNotEmpty && !state.isStreaming) ...[
              SizedBox(
                height: 38,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  itemCount: state.suggestedQuestions.length,
                  separatorBuilder: (_, _) => const Gap(8),
                  itemBuilder: (context, index) {
                    final question = state.suggestedQuestions[index];
                    return _SuggestedQuestionChip(
                      question: question,
                      onTap: () {
                        context.read<AdvisorChatCubit>().sendMessage(question);
                        _scrollToBottom();
                      },
                    );
                  },
                ),
              ),
              const Gap(10),
            ],
            _InputBar(
              controller: _textController,
              isStreaming: state.isStreaming,
              onSend: _sendMessage,
            ),
          ],
        );
      },
    );
  }
}

class _ModelDownloadCard extends StatelessWidget {
  final ModelDownloadState downloadState;
  final VoidCallback onStartDownload;
  final VoidCallback onPauseDownload;
  final VoidCallback onResumeDownload;
  final VoidCallback onCancelDownload;

  const _ModelDownloadCard({
    required this.downloadState,
    required this.onStartDownload,
    required this.onPauseDownload,
    required this.onResumeDownload,
    required this.onCancelDownload,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: UIColors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: UIColors.primary.withOpacity(0.25),
          width: 1.2,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: UIColors.primary.withOpacity(0.16),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const AppIcon(
                  Icons.auto_awesome,
                  size: 24,
                  color: UIColors.primary,
                ),
              ),
              const Gap(12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const AppText.bold(
                      'Gói trí tuệ nhân tạo Gemma 2B',
                      size: 14.5,
                      color: UIColors.textPrimary,
                    ),
                    const Gap(2),
                    Row(
                      children: const [
                        AppIcon(
                          Icons.security_rounded,
                          size: 12,
                          color: UIColors.primary,
                        ),
                        Gap(4),
                        AppText.regular(
                          '100% On-device • Bảo mật tuyệt đối',
                          size: 11,
                          color: UIColors.textSecondary,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Gap(14),
          const AppText.regular(
            'Gói AI Gemma 2 2B chạy trực tiếp trên thiết bị của bạn. Sau khi cài đặt, mô hình sẽ phản hồi tức thì mọi câu hỏi chuyên sâu về môi trường, thời tiết và cảnh báo sức khỏe mà không cần kết nối máy chủ.',
            size: 12,
            color: UIColors.textSecondary,
            height: 1.45,
          ),
          const Gap(16),
          if (downloadState.isDownloading || downloadState.isPaused) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: downloadState.progress > 0
                    ? downloadState.progress
                    : null,
                minHeight: 8,
                backgroundColor: UIColors.white.withOpacity(0.12),
                valueColor: const AlwaysStoppedAnimation<Color>(
                  UIColors.primary,
                ),
              ),
            ),
            const Gap(10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                AppText.medium(
                  downloadState.isPaused
                      ? 'Đã tạm dừng (${downloadState.formattedDownloadedSize} / ${downloadState.formattedTotalSize})'
                      : '${downloadState.formattedProgress} • ${downloadState.formattedDownloadedSize} / ${downloadState.formattedTotalSize}',
                  size: 11.5,
                  color: UIColors.textPrimary,
                ),
                if (downloadState.isDownloading)
                  AppText.bold(
                    downloadState.formattedSpeed,
                    size: 11.5,
                    color: UIColors.primary,
                  ),
              ],
            ),
            const Gap(14),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: downloadState.isPaused
                        ? onResumeDownload
                        : onPauseDownload,
                    icon: Icon(
                      downloadState.isPaused
                          ? Icons.play_arrow_rounded
                          : Icons.pause_rounded,
                      size: 18,
                    ),
                    label: Text(
                      downloadState.isPaused ? 'Tiếp tục' : 'Tạm dừng',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: UIColors.white.withOpacity(0.12),
                      foregroundColor: UIColors.textPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
                const Gap(10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onCancelDownload,
                    icon: const Icon(Icons.close_rounded, size: 18),
                    label: const Text('Hủy bỏ'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: UIColors.textSecondary,
                      side: BorderSide(color: UIColors.white.withOpacity(0.2)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ] else if (downloadState.status ==
              ModelDownloadStatus.checkingDisk) ...[
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: UIColors.primary,
                      ),
                    ),
                    Gap(10),
                    AppText.regular(
                      'Đang kiểm tra dung lượng bộ nhớ trống...',
                      size: 12,
                      color: UIColors.textSecondary,
                    ),
                  ],
                ),
              ),
            ),
          ] else if (downloadState.status == ModelDownloadStatus.verifying) ...[
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: UIColors.primary,
                      ),
                    ),
                    Gap(10),
                    AppText.regular(
                      'Đang xác thực và cấu hình gói mô hình...',
                      size: 12,
                      color: UIColors.primary,
                    ),
                  ],
                ),
              ),
            ),
          ] else ...[
            if (downloadState.hasError) ...[
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.redAccent.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.redAccent.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.error_outline_rounded,
                      size: 16,
                      color: Colors.redAccent,
                    ),
                    const Gap(8),
                    Expanded(
                      child: AppText.regular(
                        downloadState.errorMessage ?? 'Lỗi không xác định',
                        size: 11.5,
                        color: Colors.redAccent,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: onStartDownload,
                icon: const Icon(Icons.cloud_download_rounded, size: 20),
                label: const Text(
                  'Tải gói AI On-Device (~1.3 GB)',
                  style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: UIColors.primary,
                  foregroundColor: UIColors.bg,
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final ChatMessageItem message;

  const _MessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: isUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            Container(
              margin: const EdgeInsets.only(right: 8, top: 2),
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: UIColors.primary.withOpacity(0.18),
                shape: BoxShape.circle,
                border: Border.all(
                  color: UIColors.primary.withOpacity(0.35),
                  width: 1,
                ),
              ),
              child: const AppIcon(
                Icons.auto_awesome,
                size: 14,
                color: UIColors.primary,
              ),
            ),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isUser
                    ? UIColors.primary.withOpacity(0.20)
                    : UIColors.white.withOpacity(0.07),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: Radius.circular(isUser ? 18 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 18),
                ),
                border: Border.all(
                  color: isUser
                      ? UIColors.primary.withOpacity(0.40)
                      : UIColors.white.withOpacity(0.12),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: isUser
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
                children: [
                  if (!isUser) ...[
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        AppText.bold(
                          'Cố vấn AI Gemma',
                          size: 11,
                          color: UIColors.primary,
                        ),
                      ],
                    ),
                    const Gap(4),
                  ],
                  if (message.text.isEmpty && message.isStreaming)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        SizedBox(
                          width: 12,
                          height: 12,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: UIColors.primary,
                          ),
                        ),
                        Gap(8),
                        AppText.regular(
                          'Đang suy luận on-device...',
                          size: 12,
                          color: UIColors.textSecondary,
                        ),
                      ],
                    )
                  else
                    AppText.regular(
                      message.text,
                      size: 13,
                      color: UIColors.textPrimary,
                      height: 1.45,
                    ),
                ],
              ),
            ),
          ),
          if (isUser) ...[
            Container(
              margin: const EdgeInsets.only(left: 8, top: 2),
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: UIColors.white.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.person_rounded,
                size: 14,
                color: UIColors.textPrimary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SuggestedQuestionChip extends StatelessWidget {
  final String question;
  final VoidCallback onTap;

  const _SuggestedQuestionChip({required this.question, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: UIColors.white.withOpacity(0.06),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: UIColors.white.withOpacity(0.14)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.chat_bubble_outline_rounded,
              size: 13,
              color: UIColors.primary,
            ),
            const Gap(6),
            AppText.regular(question, size: 11.5, color: UIColors.textPrimary),
          ],
        ),
      ),
    );
  }
}

class _InputBar extends StatelessWidget {
  final TextEditingController controller;
  final bool isStreaming;
  final VoidCallback onSend;

  const _InputBar({
    required this.controller,
    required this.isStreaming,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: UIColors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: UIColors.white.withOpacity(0.14), width: 1),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              enabled: !isStreaming,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => onSend(),
              style: const TextStyle(color: UIColors.textPrimary, fontSize: 13),
              decoration: const InputDecoration(
                hintText: 'Hỏi về không khí, chạy bộ, ngập úng...',
                hintStyle: TextStyle(
                  color: UIColors.textSecondary,
                  fontSize: 12.5,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 6,
                  vertical: 8,
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: isStreaming ? null : onSend,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isStreaming
                    ? UIColors.white.withOpacity(0.12)
                    : UIColors.primary,
                shape: BoxShape.circle,
              ),
              child: isStreaming
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: UIColors.textSecondary,
                      ),
                    )
                  : const Icon(
                      Icons.arrow_upward_rounded,
                      size: 16,
                      color: UIColors.bg,
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
