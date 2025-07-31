import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Message input widget for sending messages in chat
class MessageInput extends StatefulWidget {
  final Function(String) onSendMessage;
  final VoidCallback? onSendImage;
  final VoidCallback? onSendVideo;
  final VoidCallback? onSendAudio;
  final VoidCallback? onSendFile;

  const MessageInput({
    super.key,
    required this.onSendMessage,
    this.onSendImage,
    this.onSendVideo,
    this.onSendAudio,
    this.onSendFile,
  });

  @override
  State<MessageInput> createState() => _MessageInputState();
}

class _MessageInputState extends State<MessageInput>
    with TickerProviderStateMixin {
  late TextEditingController _textController;
  late FocusNode _focusNode;
  late AnimationController _sendButtonController;
  late Animation<double> _sendButtonAnimation;
  
  bool _hasText = false;
  bool _showAttachments = false;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController();
    _focusNode = FocusNode();
    
    _sendButtonController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    _sendButtonAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _sendButtonController,
      curve: Curves.easeInOut,
    ));

    _textController.addListener(_onTextChanged);
    _focusNode.addListener(_onFocusChanged);
  }

  void _onTextChanged() {
    final hasText = _textController.text.trim().isNotEmpty;
    if (hasText != _hasText) {
      setState(() {
        _hasText = hasText;
      });
      
      if (hasText) {
        _sendButtonController.forward();
      } else {
        _sendButtonController.reverse();
      }
    }
  }

  void _onFocusChanged() {
    if (_focusNode.hasFocus && _showAttachments) {
      setState(() {
        _showAttachments = false;
      });
    }
  }

  void _sendMessage() {
    final text = _textController.text.trim();
    if (text.isNotEmpty) {
      widget.onSendMessage(text);
      _textController.clear();
      HapticFeedback.lightImpact();
    }
  }

  void _toggleAttachments() {
    setState(() {
      _showAttachments = !_showAttachments;
    });
    
    if (_showAttachments) {
      _focusNode.unfocus();
    }
    
    HapticFeedback.lightImpact();
  }

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    _sendButtonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        border: Border(
          top: BorderSide(
            color: const Color(0xFF333333),
            width: 0.5,
          ),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Attachments panel
          if (_showAttachments) _buildAttachmentsPanel(),
          
          // Message input row
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                // Attachment button
                GestureDetector(
                  onTap: _toggleAttachments,
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: _showAttachments 
                          ? const Color(0xFF4CAF50)
                          : const Color(0xFF2A2A2A),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _showAttachments ? Icons.close : Icons.add,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
                
                const SizedBox(width: 12),
                
                // Text input
                Expanded(
                  child: Container(
                    constraints: const BoxConstraints(
                      minHeight: 36,
                      maxHeight: 120,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2A2A2A),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _focusNode.hasFocus 
                            ? const Color(0xFF4CAF50)
                            : Colors.transparent,
                        width: 1,
                      ),
                    ),
                    child: TextField(
                      controller: _textController,
                      focusNode: _focusNode,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                      decoration: const InputDecoration(
                        hintText: 'Type a message...',
                        hintStyle: TextStyle(
                          color: Color(0xFF9E9E9E),
                          fontSize: 16,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                      ),
                      textCapitalization: TextCapitalization.sentences,
                      maxLines: null,
                      keyboardType: TextInputType.multiline,
                      textInputAction: TextInputAction.newline,
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                ),
                
                const SizedBox(width: 12),
                
                // Send button
                AnimatedBuilder(
                  animation: _sendButtonAnimation,
                  builder: (context, child) {
                    return GestureDetector(
                      onTap: _hasText ? _sendMessage : null,
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          gradient: _hasText
                              ? const LinearGradient(
                                  colors: [Color(0xFF4CAF50), Color(0xFF2E7D32)],
                                )
                              : null,
                          color: _hasText ? null : const Color(0xFF333333),
                          shape: BoxShape.circle,
                        ),
                        child: Transform.scale(
                          scale: _sendButtonAnimation.value * 0.3 + 0.7,
                          child: Icon(
                            Icons.send,
                            color: _hasText ? Colors.white : const Color(0xFF9E9E9E),
                            size: 18,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttachmentsPanel() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildAttachmentButton(
            icon: Icons.photo_camera,
            label: 'Camera',
            color: const Color(0xFF2196F3),
            onTap: () {
              _toggleAttachments();
              widget.onSendImage?.call();
            },
          ),
          _buildAttachmentButton(
            icon: Icons.photo_library,
            label: 'Gallery',
            color: const Color(0xFF9C27B0),
            onTap: () {
              _toggleAttachments();
              widget.onSendImage?.call();
            },
          ),
          _buildAttachmentButton(
            icon: Icons.videocam,
            label: 'Video',
            color: const Color(0xFFFF5722),
            onTap: () {
              _toggleAttachments();
              widget.onSendVideo?.call();
            },
          ),
          _buildAttachmentButton(
            icon: Icons.mic,
            label: 'Audio',
            color: const Color(0xFF4CAF50),
            onTap: () {
              _toggleAttachments();
              widget.onSendAudio?.call();
            },
          ),
          _buildAttachmentButton(
            icon: Icons.attach_file,
            label: 'File',
            color: const Color(0xFF607D8B),
            onTap: () {
              _toggleAttachments();
              widget.onSendFile?.call();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAttachmentButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF9E9E9E),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}