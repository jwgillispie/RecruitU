import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/chat_entity.dart';

/// List item widget for displaying a chat in the chat list
class ChatListItem extends StatelessWidget {
  final ChatEntity chat;
  final String currentUserId;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const ChatListItem({
    super.key,
    required this.chat,
    required this.currentUserId,
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final otherUserName = chat.getOtherParticipantName(currentUserId);
    final otherUserAvatar = chat.getOtherParticipantAvatar(currentUserId);
    final unreadCount = chat.getUnreadCount(currentUserId);
    final hasUnread = chat.hasUnreadMessages(currentUserId);
    final lastMessagePreview = chat.getLastMessagePreview();

    return InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      splashColor: const Color(0xFF4CAF50).withValues(alpha: 0.1),
      highlightColor: const Color(0xFF4CAF50).withValues(alpha: 0.05),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: hasUnread 
              ? const Color(0xFF1A1A1A).withValues(alpha: 0.8)
              : Colors.transparent,
          border: hasUnread
              ? Border(
                  left: BorderSide(
                    color: const Color(0xFF4CAF50),
                    width: 3,
                  ),
                )
              : null,
        ),
        child: Row(
          children: [
            // User avatar
            Stack(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: hasUnread
                          ? const Color(0xFF4CAF50)
                          : const Color(0xFF333333),
                      width: 2,
                    ),
                  ),
                  child: ClipOval(
                    child: otherUserAvatar != null && otherUserAvatar.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: otherUserAvatar,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              color: const Color(0xFF2A2A2A),
                              child: const Icon(
                                Icons.person,
                                color: Color(0xFF9E9E9E),
                                size: 24,
                              ),
                            ),
                            errorWidget: (context, url, error) => Container(
                              color: const Color(0xFF2A2A2A),
                              child: Center(
                                child: Text(
                                  otherUserName.isNotEmpty 
                                      ? otherUserName[0].toUpperCase() 
                                      : '?',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          )
                        : Container(
                            color: const Color(0xFF4CAF50),
                            child: Center(
                              child: Text(
                                otherUserName.isNotEmpty 
                                    ? otherUserName[0].toUpperCase() 
                                    : '?',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                  ),
                ),
                
                // Online indicator (placeholder - would need real presence data)
                Positioned(
                  bottom: 2,
                  right: 2,
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: const Color(0xFF4CAF50),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFF0A0A0A),
                        width: 2,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(width: 16),
            
            // Chat info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name and timestamp row
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          otherUserName,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: hasUnread 
                                ? FontWeight.w600 
                                : FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      
                      const SizedBox(width: 8),
                      
                      Text(
                        _formatTimestamp(chat.updatedAt),
                        style: TextStyle(
                          color: hasUnread 
                              ? const Color(0xFF4CAF50)
                              : const Color(0xFF9E9E9E),
                          fontSize: 12,
                          fontWeight: hasUnread 
                              ? FontWeight.w600 
                              : FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 4),
                  
                  // Last message and unread count row
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          lastMessagePreview,
                          style: TextStyle(
                            color: hasUnread 
                                ? const Color(0xFFE0E0E0)
                                : const Color(0xFF9E9E9E),
                            fontSize: 14,
                            fontWeight: hasUnread 
                                ? FontWeight.w500 
                                : FontWeight.w400,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      
                      const SizedBox(width: 8),
                      
                      // Unread count badge
                      if (hasUnread)
                        Container(
                          constraints: const BoxConstraints(
                            minWidth: 20,
                            minHeight: 20,
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF4CAF50), Color(0xFF2E7D32)],
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: Text(
                              unreadCount > 99 ? '99+' : unreadCount.toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(timestamp.year, timestamp.month, timestamp.day);

    if (messageDate == today) {
      return DateFormat('HH:mm').format(timestamp);
    } else if (messageDate == today.subtract(const Duration(days: 1))) {
      return 'Yesterday';
    } else if (now.difference(timestamp).inDays < 7) {
      return DateFormat('E').format(timestamp);
    } else if (now.difference(timestamp).inDays < 365) {
      return DateFormat('MMM d').format(timestamp);
    } else {
      return DateFormat('M/d/yy').format(timestamp);
    }
  }
}