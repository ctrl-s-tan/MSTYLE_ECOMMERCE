import 'package:flutter/material.dart';
import 'supabase_client.dart';

const Color _primary   = Color(0xFF1a1a1a);
const Color _accent    = Color(0xFF2c3e50);
const Color _gold      = Color(0xFFd4af37);
const Color _goldLight = Color(0xFFF4D03F);
const Color _textLight = Color(0xFF6c757d);
const Color _bg        = Color(0xFFF8F9FA);
const Color _border    = Color(0xFFE9ECEF);

const _premiumGrad = LinearGradient(
  begin: Alignment.topLeft, end: Alignment.bottomRight,
  colors: [_primary, _accent],
);
const _goldGrad = LinearGradient(
  begin: Alignment.topLeft, end: Alignment.bottomRight,
  colors: [_gold, _goldLight],
);

// ─── SellerMessagesPage ───────────────────────────────────────────────────────
class SellerMessagesPage extends StatefulWidget {
  final String sellerEmail;
  const SellerMessagesPage({super.key, required this.sellerEmail});
  @override
  State<SellerMessagesPage> createState() => _SellerMessagesPageState();
}

class _SellerMessagesPageState extends State<SellerMessagesPage> {
  bool _loading = true;
  List<Map<String, dynamic>> _conversations = [];

  @override
  void initState() {
    super.initState();
    _fetchConversations();
  }

  Future<void> _fetchConversations() async {
    setState(() => _loading = true);
    try {
      final data = await supabase
          .from('messages')
          .select('id, buyer_email, message, created_at, is_read, sender')
          .eq('seller_email', widget.sellerEmail)
          .order('created_at', ascending: false);

      // Group by buyer_email — keep only the latest message per buyer
      final Map<String, Map<String, dynamic>> grouped = {};
      for (final row in List<Map<String, dynamic>>.from(data as List)) {
        final buyer = row['buyer_email'] as String? ?? '';
        if (!grouped.containsKey(buyer)) {
          grouped[buyer] = row;
        }
      }
      if (mounted) setState(() { _conversations = grouped.values.toList(); _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: CustomScrollView(slivers: [
        SliverAppBar(
          pinned: true,
          backgroundColor: _primary,
          elevation: 6,
          titleSpacing: 16,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          title: ShaderMask(
            shaderCallback: (b) => _goldGrad.createShader(b),
            child: const Text('Messages',
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
          ),
        ),
        if (_loading)
          const SliverFillRemaining(
            child: Center(child: CircularProgressIndicator(color: _gold)))
        else if (_conversations.isEmpty)
          SliverFillRemaining(child: _emptyState())
        else
          SliverPadding(
            padding: const EdgeInsets.only(top: 12),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (_, i) => _conversationTile(_conversations[i]),
                childCount: _conversations.length,
              ),
            ),
          ),
      ]),
    );
  }

  Widget _conversationTile(Map<String, dynamic> conv) {
    final buyer   = conv['buyer_email'] as String? ?? '';
    final message = conv['message'] as String? ?? '';
    final sender  = conv['sender'] as String? ?? '';
    final isRead  = conv['is_read'] as bool? ?? true;
    final unread  = sender == 'buyer' && !isRead;
    final dateStr = conv['created_at'] as String?;
    final date    = dateStr != null
        ? DateTime.tryParse(dateStr)?.toLocal().toString().split(' ')[0] ?? ''
        : '';

    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(
        builder: (_) => _SellerChatPage(
          sellerEmail: widget.sellerEmail,
          buyerEmail: buyer,
        ),
      )).then((_) => _fetchConversations()),
      child: Container(
        margin: const EdgeInsets.fromLTRB(12, 0, 12, 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
          border: unread ? Border.all(color: _gold.withOpacity(0.4), width: 1.5) : null,
        ),
        child: Row(children: [
          // Avatar
          Container(
            width: 46, height: 46,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: _premiumGrad,
              boxShadow: [BoxShadow(color: _primary.withOpacity(0.2), blurRadius: 8)],
            ),
            child: Center(
              child: Text(
                buyer.isNotEmpty ? buyer[0].toUpperCase() : 'B',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 18),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Content
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Expanded(child: Text(
                buyer,
                style: TextStyle(
                  color: _accent,
                  fontWeight: unread ? FontWeight.w800 : FontWeight.w600,
                  fontSize: 13),
                maxLines: 1, overflow: TextOverflow.ellipsis)),
              Text(date, style: const TextStyle(color: _textLight, fontSize: 10)),
            ]),
            const SizedBox(height: 4),
            Text(
              message,
              style: TextStyle(
                color: unread ? _accent : _textLight,
                fontSize: 12,
                fontWeight: unread ? FontWeight.w600 : FontWeight.w400),
              maxLines: 1, overflow: TextOverflow.ellipsis),
          ])),
          if (unread) ...[
            const SizedBox(width: 8),
            Container(
              width: 10, height: 10,
              decoration: const BoxDecoration(color: _gold, shape: BoxShape.circle),
            ),
          ],
        ]),
      ),
    );
  }

  Widget _emptyState() => Center(
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      const Icon(Icons.chat_bubble_outline, size: 72, color: _border),
      const SizedBox(height: 16),
      const Text('No Messages Yet',
        style: TextStyle(color: _accent, fontSize: 18, fontWeight: FontWeight.w700)),
      const SizedBox(height: 8),
      const Text('Your conversations with buyers will appear here.',
        style: TextStyle(color: _textLight, fontSize: 13), textAlign: TextAlign.center),
    ]),
  );
}

// ─── Seller Chat Page ─────────────────────────────────────────────────────────
class _SellerChatPage extends StatefulWidget {
  final String sellerEmail;
  final String buyerEmail;

  const _SellerChatPage({required this.sellerEmail, required this.buyerEmail});

  @override
  State<_SellerChatPage> createState() => _SellerChatPageState();
}

class _SellerChatPageState extends State<_SellerChatPage> {
  final _msgCtrl    = TextEditingController();
  final _scrollCtrl = ScrollController();
  bool _loading     = true;
  bool _sending     = false;
  List<Map<String, dynamic>> _messages = [];

  @override
  void initState() {
    super.initState();
    _fetchMessages();
  }

  @override
  void dispose() {
    _msgCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  Future<void> _fetchMessages() async {
    setState(() => _loading = true);
    try {
      final data = await supabase
          .from('messages')
          .select()
          .eq('seller_email', widget.sellerEmail)
          .eq('buyer_email', widget.buyerEmail)
          .order('created_at', ascending: true);

      // Mark unread messages from buyer as read
      await supabase
          .from('messages')
          .update({'is_read': true})
          .eq('seller_email', widget.sellerEmail)
          .eq('buyer_email', widget.buyerEmail)
          .eq('sender', 'buyer')
          .eq('is_read', false);

      if (mounted) {
        setState(() { _messages = List<Map<String, dynamic>>.from(data as List); _loading = false; });
        _scrollToBottom();
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _sendMessage() async {
    final text = _msgCtrl.text.trim();
    if (text.isEmpty || _sending) return;
    setState(() => _sending = true);
    try {
      await supabase.from('messages').insert({
        'buyer_email':  widget.buyerEmail,
        'seller_email': widget.sellerEmail,
        'message':      text,
        'sender':       'seller',
        'is_read':      false,
        'created_at':   DateTime.now().toIso8601String(),
      });
      _msgCtrl.clear();
      await _fetchMessages();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Failed to send message. Please try again.'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ));
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _primary,
        elevation: 4,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(children: [
          Container(
            width: 32, height: 32,
            decoration: const BoxDecoration(shape: BoxShape.circle, gradient: _premiumGrad),
            child: Center(child: Text(
              widget.buyerEmail.isNotEmpty ? widget.buyerEmail[0].toUpperCase() : 'B',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 14),
            )),
          ),
          const SizedBox(width: 10),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(widget.buyerEmail,
              style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700),
              maxLines: 1, overflow: TextOverflow.ellipsis),
            const Text('Buyer', style: TextStyle(color: Colors.white54, fontSize: 10)),
          ])),
        ]),
      ),
      body: Column(children: [
        // Messages list
        Expanded(child: _loading
          ? const Center(child: CircularProgressIndicator(color: _gold))
          : _messages.isEmpty
            ? const Center(child: Text('No messages yet. Say hello!',
                style: TextStyle(color: _textLight, fontSize: 13)))
            : ListView.builder(
                controller: _scrollCtrl,
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
                itemCount: _messages.length,
                itemBuilder: (_, i) => _messageBubble(_messages[i]),
              ),
        ),
        // Input bar
        _inputBar(),
      ]),
    );
  }

  Widget _messageBubble(Map<String, dynamic> msg) {
    final isMine  = (msg['sender'] as String? ?? '') == 'seller';
    final text    = msg['message'] as String? ?? '';
    final dateStr = msg['created_at'] as String?;
    final time    = dateStr != null
        ? TimeOfDay.fromDateTime(DateTime.tryParse(dateStr)?.toLocal() ?? DateTime.now())
            .format(context)
        : '';

    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.72),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          gradient: isMine ? _premiumGrad : null,
          color: isMine ? null : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft:     const Radius.circular(16),
            topRight:    const Radius.circular(16),
            bottomLeft:  Radius.circular(isMine ? 16 : 4),
            bottomRight: Radius.circular(isMine ? 4 : 16),
          ),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 6, offset: const Offset(0, 2))],
        ),
        child: Column(crossAxisAlignment: isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start, children: [
          Text(text, style: TextStyle(
            color: isMine ? Colors.white : _accent,
            fontSize: 13, height: 1.4)),
          const SizedBox(height: 4),
          Text(time, style: TextStyle(
            color: isMine ? Colors.white54 : _textLight,
            fontSize: 9)),
        ]),
      ),
    );
  }

  Widget _inputBar() => Container(
    padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
    decoration: BoxDecoration(
      color: Colors.white,
      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 12, offset: const Offset(0, -3))],
    ),
    child: SafeArea(
      top: false,
      child: Row(children: [
        Expanded(child: TextField(
          controller: _msgCtrl,
          maxLines: null,
          textInputAction: TextInputAction.send,
          onSubmitted: (_) => _sendMessage(),
          style: const TextStyle(color: _accent, fontSize: 14),
          decoration: InputDecoration(
            hintText: 'Type a message...',
            hintStyle: const TextStyle(color: _textLight, fontSize: 13),
            filled: true, fillColor: _bg,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(24),
              borderSide: BorderSide(color: _border)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(24),
              borderSide: const BorderSide(color: _gold, width: 2)),
          ),
        )),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: _sendMessage,
          child: Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              gradient: _premiumGrad,
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: _primary.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 3))],
            ),
            child: _sending
              ? const Padding(
                  padding: EdgeInsets.all(12),
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : const Icon(Icons.send_rounded, color: Colors.white, size: 20),
          ),
        ),
      ]),
    ),
  );
}
