import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

/// Custom app bar for chat screen
class ChatAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String otherUserName;
  final String? otherUserAvatar;
  final VoidCallback? onAvatarTap;
  final VoidCallback? onInfoTap;

  const ChatAppBar({
    super.key,
    required this.otherUserName,
    this.otherUserAvatar,
    this.onAvatarTap,
    this.onInfoTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: const Color(0xFF1A1A1A),
      elevation: 1,
      shadowColor: Colors.black.withValues(alpha: 0.3),
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back_ios_new,
          color: Color(0xFF4CAF50),
        ),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: GestureDetector(
        onTap: onAvatarTap,
        child: Row(
          children: [
            // User avatar
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFF4CAF50).withValues(alpha: 0.3),
                  width: 2,
                ),
              ),
              child: ClipOval(
                child: otherUserAvatar != null && otherUserAvatar!.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: otherUserAvatar!,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: const Color(0xFF2A2A2A),
                          child: const Icon(
                            Icons.person,
                            color: Color(0xFF9E9E9E),
                            size: 20,
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: const Color(0xFF2A2A2A),
                          child: Text(
                            otherUserName.isNotEmpty 
                                ? otherUserName[0].toUpperCase() 
                                : '?',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
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
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
              ),
            ),
            
            const SizedBox(width: 12),
            
            // User info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    otherUserName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Text(
                    'Online',
                    style: TextStyle(
                      color: Color(0xFF4CAF50),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(
            Icons.videocam,
            color: Color(0xFF9E9E9E),
          ),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Video call coming soon!'),
                backgroundColor: Color(0xFF4CAF50),
              ),
            );
          },
        ),
        IconButton(
          icon: const Icon(
            Icons.phone,
            color: Color(0xFF9E9E9E),
          ),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Voice call coming soon!'),
                backgroundColor: Color(0xFF4CAF50),
              ),
            );
          },
        ),
        IconButton(
          icon: const Icon(
            Icons.more_vert,
            color: Color(0xFF9E9E9E),
          ),
          onPressed: onInfoTap,
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}