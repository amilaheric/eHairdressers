import 'dart:async';
import 'package:flutter/material.dart';
import 'package:ehairdressers_mobile/providers/chat_provider.dart';
import 'package:ehairdressers_mobile/screens/chat_list_screen.dart';
import 'package:ehairdressers_mobile/services/signalr_service.dart';
import 'package:ehairdressers_mobile/utils/chat_notification_helper.dart';
import 'package:provider/provider.dart';

class FloatingChatBubble extends StatefulWidget {
  final int userId;

  const FloatingChatBubble({
    Key? key,
    required this.userId,
  }) : super(key: key);

  @override
  State<FloatingChatBubble> createState() => _FloatingChatBubbleState();
}

class _FloatingChatBubbleState extends State<FloatingChatBubble>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  final SignalRService _signalRService = SignalRService();
  StreamSubscription<int>? _unreadCountSubscription;
  int _unreadCount = 0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.9,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _loadUnreadCount();
    _listenForUnreadUpdates();
  }

  Future<void> _loadUnreadCount() async {
    try {
      final count = await context
          .read<ChatProvider>()
          .getUnreadMessageCount(widget.userId);
      if (mounted) {
        setState(() {
          _unreadCount = count;
        });
      }
    } catch (_) {
      // Leave the badge as-is if this fails - not worth surfacing an error
      // for a background count refresh.
    }
  }

  Future<void> _listenForUnreadUpdates() async {
    if (!_signalRService.isConnected) {
      try {
        await _signalRService.initializeConnection();
      } catch (_) {
        return;
      }
    }
    _unreadCountSubscription = _signalRService.unreadCountStream.listen((count) {
      if (mounted) {
        setState(() {
          _unreadCount = count;
        });
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _unreadCountSubscription?.cancel();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    setState(() {
      _isPressed = true;
    });
    _animationController.forward();
  }

  void _onTapUp(TapUpDetails details) {
    setState(() {
      _isPressed = false;
    });
    _animationController.reverse();
  }

  void _onTapCancel() {
    setState(() {
      _isPressed = false;
    });
    _animationController.reverse();
  }

  void _openChat() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ChatListScreen(userId: widget.userId),
      ),
    );
    _loadUnreadCount();
  }

  void _showChatInfo() {
    ChatNotificationHelper.showChatInfo(context);
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 20,
      right: 20,
      child: GestureDetector(
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
        onTap: _openChat,
        onLongPress: _showChatInfo,
        child: AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.orange,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Center(
                      child: Icon(
                        Icons.chat,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    if (_unreadCount > 0)
                      Positioned(
                        top: -4,
                        right: -4,
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                          constraints: BoxConstraints(minWidth: 18, minHeight: 18),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(9),
                            border: Border.all(color: Colors.white, width: 1.5),
                          ),
                          child: Text(
                            _unreadCount > 99 ? '99+' : '$_unreadCount',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
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
    );
  }
}
