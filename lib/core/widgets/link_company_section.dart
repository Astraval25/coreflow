import 'package:coreflow/core/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class LinkCompanySection extends StatefulWidget {
  final bool isLinked;
  final bool isLoading;
  final String? invitationCode;
  final Future<void> Function() onGenerateCode;
  final Future<void> Function() onGetExistingCode;
  final Future<bool> Function(String code) onAcceptCode;

  const LinkCompanySection({
    super.key,
    required this.isLinked,
    required this.isLoading,
    this.invitationCode,
    required this.onGenerateCode,
    required this.onGetExistingCode,
    required this.onAcceptCode,
  });

  @override
  State<LinkCompanySection> createState() => _LinkCompanySectionState();
}

class _LinkCompanySectionState extends State<LinkCompanySection> {
  bool _obscureCode = true;
  bool _showAcceptInput = false;
  final TextEditingController _codeController = TextEditingController();
  bool _isAccepting = false;
  bool _expanded = false;
  bool _headerPressed = false;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isLinked) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Divider(height: 1, thickness: 1, color: LoginColors.border),
          const SizedBox(height: 16),
          _buildCompactHeader(),
          if (_expanded) ...[
            const SizedBox(height: 10),
            _buildExpandedContent(),
          ],

          if (widget.isLoading)
            const Padding(
              padding: EdgeInsets.only(top: 12),
              child: Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCompactHeader() {
    const gold = Color(0xFFD4AF37);
    final goldSoft = gold.withValues(alpha: 0.12);

    return GestureDetector(
      onTapDown: (_) => setState(() => _headerPressed = true),
      onTapUp: (_) => setState(() => _headerPressed = false),
      onTapCancel: () => setState(() => _headerPressed = false),
      onTap: () => setState(() => _expanded = !_expanded),
      child: AnimatedScale(
        duration: Duration(milliseconds: 120),
        scale: _headerPressed ? 0.98 : 1,
        child: AnimatedContainer(
          duration: Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [goldSoft, goldSoft.withValues(alpha: 0.04)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: gold.withValues(alpha: 0.4)),
            boxShadow: _headerPressed
                ? []
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
          ),
          child: Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: gold,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.link_rounded,
                  color: Colors.white,
                  size: 16,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Link Companies',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: LoginColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Share your code or enter a code to link companies.',
                      style: TextStyle(
                        fontSize: 11.5,
                        color: LoginColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              AnimatedContainer(
                duration: Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: gold.withValues(alpha: _expanded ? 0.18 : 0.1),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: gold.withValues(alpha: 0.5)),
                ),
                child: Row(
                  children: [
                    Text(
                      _expanded ? 'Hide' : 'View',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: LoginColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 4),
                    AnimatedRotation(
                      turns: _expanded ? 0.5 : 0,
                      duration: Duration(milliseconds: 180),
                      child: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 16,
                        color: gold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExpandedContent() {
    const gold = Color(0xFFD4AF37);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: LoginColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: gold.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.invitationCode != null) ...[
            _buildCodeDisplayFlat(),
          ] else ...[
            _buildInviteActionsFlat(gold),
          ],
          const SizedBox(height: 10),
          _buildSectionDivider('OR'),
          const SizedBox(height: 10),
          _buildAcceptSectionFlat(gold),
        ],
      ),
    );
  }

  Widget _buildInviteActionsFlat(Color gold) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.qr_code_2_rounded, size: 18, color: gold),
            const SizedBox(width: 8),
            Text(
              'Share a Code',
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: LoginColors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          'Create a new code or fetch an existing one to share.',
          style: TextStyle(fontSize: 11.5, color: LoginColors.textSecondary),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                icon: Icons.add_circle_outline_rounded,
                label: 'New Code',
                onPressed: widget.isLoading
                    ? null
                    : () async {
                        await widget.onGenerateCode();
                      },
                tint: gold,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextButton.icon(
                onPressed: widget.isLoading
                    ? null
                    : () async {
                        await widget.onGetExistingCode();
                      },
                icon: const Icon(Icons.history_rounded, size: 18),
                label:
                    const Text('Use Existing', style: TextStyle(fontSize: 12.5)),
                style: TextButton.styleFrom(
                  foregroundColor: LoginColors.textPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSectionDivider(String label) {
    return Row(
      children: [
        Expanded(
          child: Divider(
            height: 1,
            thickness: 1,
            color: LoginColors.borderLight,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: LoginColors.textTertiary,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Divider(
            height: 1,
            thickness: 1,
            color: LoginColors.borderLight,
          ),
        ),
      ],
    );
  }

  Widget _buildCodeDisplayFlat() {
    final code = widget.invitationCode!;
    const gold = Color(0xFFD4AF37);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: gold,
                borderRadius: BorderRadius.circular(999),
              ),
              child: const Text(
                'INVITE',
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: 0.6,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'Your Invitation Code',
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: LoginColors.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(
              child: Text(
                _obscureCode ? '\u2022' * code.length : code,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: LoginColors.textPrimary,
                  letterSpacing: 4,
                ),
              ),
            ),
            IconButton(
              onPressed: () => _copyCode(code),
              icon: Icon(Icons.copy_rounded, size: 18, color: gold),
              tooltip: 'Copy code',
            ),
            IconButton(
              onPressed: () => setState(() => _obscureCode = !_obscureCode),
              icon: Icon(
                _obscureCode
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                size: 18,
                color: gold,
              ),
              tooltip: _obscureCode ? 'Show code' : 'Hide code',
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Share this code with the other party to link companies',
          style: TextStyle(
            fontSize: 11,
            color: LoginColors.textTertiary,
          ),
        ),
      ],
    );
  }

  Widget _buildAcceptSectionFlat(Color gold) {
    if (!_showAcceptInput) {
      return InkWell(
        onTap: () => setState(() => _showAcceptInput = true),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: gold.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.input_rounded, size: 16, color: gold),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Join with a Code',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: LoginColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Tap to enter a code you received.',
                      style: TextStyle(
                        fontSize: 11.5,
                        color: LoginColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () => setState(() => _showAcceptInput = true),
                child: const Text('Enter'),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Join with a Code',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: LoginColors.textPrimary,
              ),
            ),
            GestureDetector(
              onTap: () => setState(() {
                _showAcceptInput = false;
                _codeController.clear();
              }),
              child: Icon(
                Icons.close,
                size: 18,
                color: LoginColors.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _codeController,
                textCapitalization: TextCapitalization.characters,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 3,
                  color: LoginColors.textPrimary,
                ),
                decoration: InputDecoration(
                  hintText: 'e.g. R8JXBT',
                  hintStyle: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    letterSpacing: 2,
                    color: LoginColors.textTertiary,
                  ),
                  filled: true,
                  fillColor: LoginColors.fieldFill,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: gold.withValues(alpha:0.5)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: gold.withValues(alpha: 0.5)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: gold,
                      width: 1.5,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            SizedBox(
              height: 44,
              child: ElevatedButton(
                onPressed: _isAccepting
                    ? null
                    : () async {
                        final code = _codeController.text.trim();
                        if (code.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              duration: Duration(seconds: 1),
                              content: Text('Please enter a code'),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                          return;
                        }

                        setState(() => _isAccepting = true);
                        final success = await widget.onAcceptCode(code);
                        if (mounted) {
                          setState(() => _isAccepting = false);
                          if (success) {
                            _codeController.clear();
                            setState(() => _showAcceptInput = false);
                          }
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: gold,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                ),
                child: _isAccepting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Submit',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback? onPressed,
    Color? tint,
  }) {
    final color = tint ?? LoginColors.primary;
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(label, style: const TextStyle(fontSize: 12.5)),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(vertical: 10),
        elevation: 0,
      ),
    );
  }

  void _copyCode(String code) {
    Clipboard.setData(ClipboardData(text: code));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: Duration(seconds: 1),
        content: const Text('Code copied to clipboard'),
        backgroundColor: LoginColors.primary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
