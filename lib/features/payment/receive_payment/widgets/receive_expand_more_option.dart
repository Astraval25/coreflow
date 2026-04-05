import 'package:coreflow/core/utils/payment_share_helper.dart';
import 'package:coreflow/domain/model/payment/payment_detail.dart';
import 'package:coreflow/features/payment/receive_payment/viewmodel/receive_payment_detail_view_model.dart';
import 'package:coreflow/core/theme/colors.dart';
import 'package:flutter/material.dart';

class ReceivePaymentBottomPanel extends StatefulWidget {
  final PaymentDetail payment;
  final ReceivePaymentDetailViewModel vm;

  const ReceivePaymentBottomPanel({
    super.key,
    required this.payment,
    required this.vm,
  });

  @override
  State<ReceivePaymentBottomPanel> createState() =>
      _ReceivePaymentBottomPanelState();
}

class _ReceivePaymentBottomPanelState extends State<ReceivePaymentBottomPanel>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animCtrl;
  double _expandedHeight = 0;
  final _expandedKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  List<({String label, IconData icon, String action, Color color})>
  get _statusActions {
    final status = widget.payment.paymentStatus;
    final list =
        <({String label, IconData icon, String action, Color color})>[];

    if (status == 'PENDING') {
      list.add((
        label: 'Mark as Viewed',
        icon: Icons.visibility_rounded,
        action: 'viewed',
        color: Colors.blue.shade600,
      ));
    }
    if (status == 'VIEWED') {
      list.add((
        label: 'Partially Paid',
        icon: Icons.payments_outlined,
        action: 'partially-paid',
        color: Colors.orange.shade700,
      ));
    }
    if (status == 'PAID' || status == 'PARTIALLY_PAID') {
      list.add((
        label: 'Refund',
        icon: Icons.undo_rounded,
        action: 'refund',
        color: Colors.purple.shade600,
      ));
    }
    if (const ['PENDING', 'VIEWED', 'PARTIALLY_PAID'].contains(status)) {
      list.add((
        label: 'Mark Failed',
        icon: Icons.cancel_outlined,
        action: 'failed',
        color: LoginColors.error,
      ));
    }
    return list;
  }

  Future<void> _doStatusAction(String action) async {
    final success = await widget.vm.updateStatus(action);
    if (!success && mounted && widget.vm.statusError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: const Duration(seconds: 2),
          content: Text(widget.vm.statusError!),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _toggle() {
    if (_animCtrl.isAnimating) return;
    if (_animCtrl.value > 0.5) {
      _animCtrl.reverse();
    } else {
      _measureExpandedHeight();
      _animCtrl.forward();
    }
  }

  void _measureExpandedHeight() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final box = _expandedKey.currentContext?.findRenderObject() as RenderBox?;
      if (box != null) _expandedHeight = box.size.height;
    });
  }

  void _onDragUpdate(DragUpdateDetails details) {
    if (_expandedHeight <= 0) _expandedHeight = 150;
    final delta = -details.primaryDelta! / _expandedHeight;
    _animCtrl.value = (_animCtrl.value + delta).clamp(0.0, 1.0);
  }

  void _onDragEnd(DragEndDetails details) {
    final velocity = details.primaryVelocity ?? 0;
    if (velocity < -300) {
      _animCtrl.forward();
    } else if (velocity > 300) {
      _animCtrl.reverse();
    } else if (_animCtrl.value > 0.5) {
      _animCtrl.forward();
    } else {
      _animCtrl.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final actions = _statusActions;

    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: GestureDetector(
        onVerticalDragUpdate: _onDragUpdate,
        onVerticalDragEnd: _onDragEnd,
        child: Material(
          color: LoginColors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          elevation: 8,
          shadowColor: Colors.black26,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Drag handle ──
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 10, bottom: 6),
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: LoginColors.textSecondary.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // ── Main action buttons row ──
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
                child: Row(
                  children: [
                    // Share toggle
                    AnimatedBuilder(
                      animation: _animCtrl,
                      builder: (context, child) => SizedBox(
                        height: 44,
                        child: OutlinedButton.icon(
                          onPressed: _toggle,
                          icon: Icon(
                            _animCtrl.value > 0.5
                                ? Icons.close_rounded
                                : Icons.share_rounded,
                            size: 18,
                          ),
                          label: Text(
                            _animCtrl.value > 0.5 ? 'Close' : 'Share',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: LoginColors.primary,
                            side: BorderSide(
                              color: LoginColors.primary.withValues(alpha: 0.4),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Status action buttons
                    for (final a in actions) ...[
                      const SizedBox(width: 8),
                      Expanded(
                        child: SizedBox(
                          height: 44,
                          child: FilledButton.icon(
                            onPressed: widget.vm.isStatusUpdating
                                ? null
                                : () => _doStatusAction(a.action),
                            icon: widget.vm.isStatusUpdating
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : Icon(a.icon, size: 16),
                            label: Text(
                              a.label,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            style: FilledButton.styleFrom(
                              backgroundColor: a.color,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // ── Expandable share options (live drag) ──
              SizeTransition(
                sizeFactor: CurvedAnimation(
                  parent: _animCtrl,
                  curve: Curves.easeInOut,
                ),
                axisAlignment: -1.0,
                child: Column(
                  key: _expandedKey,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Divider(height: 1, color: LoginColors.borderLight),
                    _ActionTile(
                      icon: Icons.text_fields_rounded,
                      label: 'Share as Text',
                      color: LoginColors.primary,
                      onTap: () {
                        _animCtrl.reverse();
                        PaymentShareHelper.shareText(
                          widget.payment,
                          isSent: false,
                        );
                      },
                    ),
                    Divider(
                      height: 1,
                      indent: 44,
                      color: LoginColors.borderLight,
                    ),
                    _ActionTile(
                      icon: Icons.attachment_rounded,
                      label: 'Share Proof with Text',
                      color:
                          widget.payment.paymentProofFile != null &&
                              widget.payment.paymentProofFile!.isNotEmpty
                          ? LoginColors.primary
                          : LoginColors.textSecondary,
                      onTap: () async {
                        _animCtrl.reverse();
                        final proofFile = widget.payment.paymentProofFile;
                        if (proofFile == null || proofFile.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              duration: Duration(seconds: 2),
                              content: Text('No proof attached to share'),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                          return;
                        }
                        final bytes = await widget.vm.fetchProofBytes();
                        if (bytes == null || bytes.isEmpty) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                duration: Duration(seconds: 2),
                                content: Text('Unable to load proof file'),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          }
                          return;
                        }
                        PaymentShareHelper.shareProofWithText(
                          widget.payment,
                          bytes,
                          isSent: false,
                        );
                      },
                    ),
                    Divider(
                      height: 1,
                      indent: 44,
                      color: LoginColors.borderLight,
                    ),
                    _ActionTile(
                      icon: Icons.picture_as_pdf_rounded,
                      label: 'Share as PDF',
                      color: LoginColors.primary,
                      onTap: () {
                        _animCtrl.reverse();
                        PaymentShareHelper.shareAsPdf(
                          widget.payment,
                          isSent: false,
                        );
                      },
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
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                color: LoginColors.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
