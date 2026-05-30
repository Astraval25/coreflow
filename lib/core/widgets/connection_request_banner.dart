import 'package:coreflow/core/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// A banner widget for displaying connection request status and actions.
///
/// Shows different content based on the connection status:
/// - PENDING: Full requester details with Accept/Reject buttons + WhatsApp/Call
/// - PENDING + awaitingCounterparty: Accepted by current side, waiting for other side
/// - ACCEPTED: Connected badge with option to undo (reject)
/// - REJECTED: Rejected badge with option to undo (accept)
class ConnectionRequestBanner extends StatelessWidget {
  final String connectionStatus;
  final bool isAwaitingCounterpartyAcceptance;
  final String? requesterName;
  final String? requesterPhone;
  final String? requesterEmail;
  final bool isLoading;
  final VoidCallback onAccept;
  final VoidCallback onReject;
  final void Function(String newStatus)? onUndo;

  const ConnectionRequestBanner({
    super.key,
    required this.connectionStatus,
    this.isAwaitingCounterpartyAcceptance = false,
    this.requesterName,
    this.requesterPhone,
    this.requesterEmail,
    this.isLoading = false,
    required this.onAccept,
    required this.onReject,
    this.onUndo,
  });

  @override
  Widget build(BuildContext context) {
    if (connectionStatus == 'PENDING') {
      if (isAwaitingCounterpartyAcceptance) {
        return _buildAwaitingCounterpartyBanner(context);
      }
      return _buildPendingBanner(context);
    } else if (connectionStatus == 'ACCEPTED') {
      return _buildAcceptedBanner(context);
    } else if (connectionStatus == 'REJECTED') {
      return _buildRejectedBanner(context);
    }
    return const SizedBox.shrink();
  }

  Widget _buildPendingBanner(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFCD34D)),
        boxShadow: [
          BoxShadow(
            color: Colors.amber.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF59E0B).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.handshake_outlined,
                  color: Color(0xFFD97706),
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Connection Request',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: LoginColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Wants to connect with you',
                      style: TextStyle(
                        fontSize: 12,
                        color: LoginColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Requester details
          if (requesterName != null && requesterName!.isNotEmpty) ...[
            _infoRow(Icons.business_rounded, requesterName!),
            const SizedBox(height: 6),
          ],
          if (requesterPhone != null && requesterPhone!.isNotEmpty) ...[
            _infoRow(Icons.phone_rounded, requesterPhone!),
            const SizedBox(height: 6),
          ],
          if (requesterEmail != null && requesterEmail!.isNotEmpty) ...[
            _infoRow(Icons.email_outlined, requesterEmail!),
            const SizedBox(height: 6),
          ],

          const SizedBox(height: 10),

          // WhatsApp + Call buttons
          if (requesterPhone != null && requesterPhone!.isNotEmpty)
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _openWhatsApp(requesterPhone!),
                    icon: const Icon(Icons.chat_rounded, size: 18),
                    label: const Text('WhatsApp'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF25D366),
                      side: const BorderSide(color: Color(0xFF25D366)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _makeCall(requesterPhone!),
                    icon: const Icon(Icons.call_rounded, size: 18),
                    label: const Text('Call'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: LoginColors.primary,
                      side: BorderSide(color: LoginColors.primary),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
              ],
            ),

          const SizedBox(height: 12),

          // Accept / Reject buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: isLoading ? null : onReject,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFEE2E2),
                    foregroundColor: const Color(0xFFDC2626),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: isLoading
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text(
                          'Reject',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: isLoading ? null : onAccept,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF16A34A),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: isLoading
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation(Colors.white),
                          ),
                        )
                      : const Text(
                          'Accept',
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

  Widget _buildAwaitingCounterpartyBanner(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF93C5FD)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF2563EB).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.hourglass_top_rounded,
                  color: Color(0xFF1D4ED8),
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Accepted by you. Waiting for other company.',
                  style: TextStyle(
                    color: LoginColors.textPrimary,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          if (requesterPhone != null && requesterPhone!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _openWhatsApp(requesterPhone!),
                    icon: const Icon(Icons.chat_rounded, size: 18),
                    label: const Text('WhatsApp'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF25D366),
                      side: const BorderSide(color: Color(0xFF25D366)),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _makeCall(requesterPhone!),
                    icon: const Icon(Icons.call_rounded, size: 18),
                    label: const Text('Call'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: LoginColors.primary,
                      side: BorderSide(color: LoginColors.primary),
                    ),
                  ),
                ),
              ],
            ),
          ],
          if (onUndo != null) ...[
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: isLoading ? null : () => onUndo!('REJECTED'),
                child: const Text('Cancel acceptance'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAcceptedBanner(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDF4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF86EFAC)),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle_rounded, color: Color(0xFF16A34A), size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Connected',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF166534),
              ),
            ),
          ),
          if (onUndo != null)
            TextButton(
              onPressed: isLoading ? null : () => onUndo!('REJECTED'),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFFDC2626),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              ),
              child: const Text('Disconnect', style: TextStyle(fontSize: 12)),
            ),
        ],
      ),
    );
  }

  Widget _buildRejectedBanner(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFCA5A5)),
      ),
      child: Row(
        children: [
          const Icon(Icons.block_rounded, color: Color(0xFFDC2626), size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Connection Rejected',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF991B1B),
              ),
            ),
          ),
          if (onUndo != null)
            TextButton(
              onPressed: isLoading ? null : () => onUndo!('ACCEPTED'),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF16A34A),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              ),
              child: const Text('Accept', style: TextStyle(fontSize: 12)),
            ),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: LoginColors.textSecondary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 13,
              color: LoginColors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  void _openWhatsApp(String phone) {
    final cleanPhone = phone.replaceAll(RegExp(r'[^0-9+]'), '');
    final whatsappPhone = cleanPhone.startsWith('+') ? cleanPhone.substring(1) : cleanPhone;
    launchUrl(
      Uri.parse('https://wa.me/$whatsappPhone'),
      mode: LaunchMode.externalApplication,
    );
  }

  void _makeCall(String phone) {
    launchUrl(
      Uri.parse('tel:$phone'),
      mode: LaunchMode.externalApplication,
    );
  }
}
