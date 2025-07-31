import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../domain/entities/match_entity.dart';

/// Widget for displaying individual match items in the matches list
class MatchListItem extends StatelessWidget {
  final MatchEntity match;
  final String currentUserId;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  const MatchListItem({
    super.key,
    required this.match,
    required this.currentUserId,
    required this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final otherUserName = match.getOtherUserName(currentUserId);
    final otherUserImage = match.getOtherUserProfileImage(currentUserId);
    final hasLastMessage = match.lastMessageText != null;
    final isCurrentUserLastSender = match.didCurrentUserSendLastMessage(currentUserId);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: match.hasUnreadMessages 
              ? const Color(0xFF4CAF50).withValues(alpha: 0.3)
              : Colors.transparent,
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Profile image with online indicator
                Stack(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: match.hasUnreadMessages 
                              ? const Color(0xFF4CAF50)
                              : const Color(0xFF424242),
                          width: 2,
                        ),
                      ),
                      child: ClipOval(
                        child: otherUserImage != null
                            ? CachedNetworkImage(
                                imageUrl: otherUserImage,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Container(
                                  color: const Color(0xFF2A2A2A),
                                  child: const Icon(
                                    Icons.person,
                                    color: Color(0xFF9E9E9E),
                                    size: 30,
                                  ),
                                ),
                                errorWidget: (context, url, error) => Container(
                                  color: const Color(0xFF2A2A2A),
                                  child: const Icon(
                                    Icons.person,
                                    color: Color(0xFF9E9E9E),
                                    size: 30,
                                  ),
                                ),
                              )
                            : Container(
                                color: const Color(0xFF2A2A2A),
                                child: const Icon(
                                  Icons.person,
                                  color: Color(0xFF9E9E9E),
                                  size: 30,
                                ),
                              ),
                      ),
                    ),
                    // Online indicator (simulated)
                    if (match.isActive)
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
                              color: const Color(0xFF1A1A1A),
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                
                const SizedBox(width: 16),
                
                // Message content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name and time
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              otherUserName,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: match.hasUnreadMessages 
                                    ? FontWeight.w600 
                                    : FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (hasLastMessage)
                            Text(
                              match.getFormattedLastMessageTime(),
                              style: TextStyle(
                                color: match.hasUnreadMessages 
                                    ? const Color(0xFF4CAF50)
                                    : const Color(0xFF9E9E9E),
                                fontSize: 12,
                                fontWeight: match.hasUnreadMessages 
                                    ? FontWeight.w600 
                                    : FontWeight.normal,
                              ),
                            ),
                        ],
                      ),
                      
                      const SizedBox(height: 4),
                      
                      // Last message preview
                      Row(
                        children: [
                          // "You:" prefix if current user sent the message
                          if (hasLastMessage && isCurrentUserLastSender)
                            const Text(
                              'You: ',
                              style: TextStyle(
                                color: Color(0xFF9E9E9E),
                                fontSize: 14,
                              ),
                            ),
                          
                          Expanded(
                            child: Text(
                              hasLastMessage 
                                  ? match.lastMessageText!
                                  : 'You matched ${_getMatchTimeText()}',
                              style: TextStyle(
                                color: match.hasUnreadMessages 
                                    ? const Color(0xFFE0E0E0)
                                    : const Color(0xFF9E9E9E),
                                fontSize: 14,
                                fontWeight: match.hasUnreadMessages 
                                    ? FontWeight.w500 
                                    : FontWeight.normal,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          
                          // Unread indicator
                          if (match.hasUnreadMessages)
                            Container(
                              width: 8,
                              height: 8,
                              margin: const EdgeInsets.only(left: 8),
                              decoration: const BoxDecoration(
                                color: Color(0xFF4CAF50),
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Action indicator
                const Icon(
                  Icons.chevron_right,
                  color: Color(0xFF424242),
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getMatchTimeText() {
    final now = DateTime.now();
    final difference = now.difference(match.matchedAt);
    
    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} minutes ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hours ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${(difference.inDays / 7).floor()} weeks ago';
    }
  }
}