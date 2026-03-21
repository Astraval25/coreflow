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
          Text(
            'Link Company',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: LoginColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Share your code or enter a code to link companies',
            style: TextStyle(
              fontSize: 12.5,
              color: LoginColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),

          // Invitation code display
          if (widget.invitationCode != null) ...[
            _buildCodeDisplay(),
            const SizedBox(height: 12),
          ],

          // Action buttons
          if (widget.invitationCode == null) ...[
            Row(
              children: [
                Expanded(
                  child: _buildActionButton(
                    icon: Icons.send_rounded,
                    label: 'Generate Code',
                    onPressed: widget.isLoading ? null : () async {
                      await widget.onGenerateCode();
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildActionButton(
                    icon: Icons.refresh_rounded,
                    label: 'Get Code',
                    onPressed: widget.isLoading ? null : () async {
                      await widget.onGetExistingCode();
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],

          // Accept code section
          _buildAcceptSection(),

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

  Widget _buildCodeDisplay() {
    final code = widget.invitationCode!;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: LoginColors.primary.withOpacity(0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: LoginColors.primary.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Invitation Code',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: LoginColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Text(
                  _obscureCode ? '\u2022' * code.length : code,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: LoginColors.primaryDark,
                    letterSpacing: 4,
                  ),
                ),
              ),
              IconButton(
                icon: Icon(
                  _obscureCode
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  size: 20,
                  color: LoginColors.textSecondary,
                ),
                onPressed: () => setState(() => _obscureCode = !_obscureCode),
                tooltip: _obscureCode ? 'Show code' : 'Hide code',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
              ),
              IconButton(
                icon: Icon(
                  Icons.copy_rounded,
                  size: 20,
                  color: LoginColors.primary,
                ),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: code));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Code copied to clipboard'),
                      backgroundColor: LoginColors.primary,
                      behavior: SnackBarBehavior.floating,
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
                tooltip: 'Copy code',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
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
      ),
    );
  }

  Widget _buildAcceptSection() {
    if (!_showAcceptInput) {
      return SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: () => setState(() => _showAcceptInput = true),
          icon: const Icon(Icons.input_rounded, size: 18),
          label: const Text('Enter Invitation Code'),
          style: OutlinedButton.styleFrom(
            foregroundColor: LoginColors.primaryDark,
            side: BorderSide(color: LoginColors.primary.withOpacity(0.4)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: LoginColors.fieldFill,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: LoginColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Enter Invitation Code',
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
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _codeController,
                  textCapitalization: TextCapitalization.characters,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 3,
                    color: LoginColors.textPrimary,
                  ),
                  decoration: InputDecoration(
                    hintText: 'e.g. R8JXBT',
                    hintStyle: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      letterSpacing: 2,
                      color: LoginColors.textTertiary,
                    ),
                    filled: true,
                    fillColor: LoginColors.surface,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: LoginColors.borderLight),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: LoginColors.borderLight),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: LoginColors.primary,
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: _isAccepting
                      ? null
                      : () async {
                          final code = _codeController.text.trim();
                          if (code.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
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
                    backgroundColor: LoginColors.primary,
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
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback? onPressed,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(label, style: const TextStyle(fontSize: 13)),
      style: ElevatedButton.styleFrom(
        backgroundColor: LoginColors.primary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(vertical: 12),
        elevation: 0,
      ),
    );
  }
}
