import 'dart:math' as math;

import 'package:coreflow/core/theme/colors.dart';
import 'package:flutter/material.dart';

class TopCenterMessagePopupLink {
  final String label;
  final VoidCallback onTap;

  const TopCenterMessagePopupLink({required this.label, required this.onTap});
}

class TopCenterMessagePopup {
  static OverlayEntry? _activeEntry;

  static void show({
    required BuildContext context,
    required String message,
    String title = 'Action Required',
    List<TopCenterMessagePopupLink> links = const [],
    IconData icon = Icons.warning_amber_rounded,
  }) {
    dismiss();

    final overlay = Overlay.of(context, rootOverlay: true);
    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (overlayContext) {
        final media = MediaQuery.of(overlayContext);
        final top = media.padding.top + 8;
        return Positioned(
          left: 10,
          right: 10,
          top: top,
          child: Align(
            alignment: Alignment.topCenter,
            child: _TopCenterMessageCard(
              title: title,
              message: message,
              icon: icon,
              links: links,
              onClose: dismiss,
            ),
          ),
        );
      },
    );

    _activeEntry = entry;
    overlay.insert(entry);
  }

  static void dismiss() {
    _activeEntry?.remove();
    _activeEntry = null;
  }
}

class _TopCenterMessageCard extends StatefulWidget {
  final String title;
  final String message;
  final IconData icon;
  final List<TopCenterMessagePopupLink> links;
  final VoidCallback onClose;

  const _TopCenterMessageCard({
    required this.title,
    required this.message,
    required this.icon,
    required this.links,
    required this.onClose,
  });

  @override
  State<_TopCenterMessageCard> createState() => _TopCenterMessageCardState();
}

class _TopCenterMessageCardState extends State<_TopCenterMessageCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final firstLink = widget.links.isNotEmpty ? widget.links.first : null;
    final hiddenCount = math.max(0, widget.links.length - 1);

    return Material(
      color: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 460),
        decoration: BoxDecoration(
          color: LoginColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: LoginColors.borderLight),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 14,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 10, 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Icon(widget.icon, size: 18, color: Colors.orange),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          style: TextStyle(
                            color: LoginColors.textPrimary,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          widget.message,
                          style: TextStyle(
                            color: LoginColors.textSecondary,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  InkWell(
                    onTap: widget.onClose,
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.all(2),
                      child: Icon(
                        Icons.close_rounded,
                        size: 18,
                        color: LoginColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
              if (firstLink != null) ...[
                const SizedBox(height: 8),
                _PopupLinkTile(link: firstLink, onClose: widget.onClose),
              ],
              if (_expanded && widget.links.length > 1) ...[
                const SizedBox(height: 6),
                for (final link in widget.links.skip(1))
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: _PopupLinkTile(link: link, onClose: widget.onClose),
                  ),
              ],
              if (widget.links.length > 1) ...[
                const SizedBox(height: 2),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: () => setState(() => _expanded = !_expanded),
                    style: TextButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(0, 30),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    icon: Icon(
                      _expanded
                          ? Icons.expand_less_rounded
                          : Icons.expand_more_rounded,
                      size: 16,
                    ),
                    label: Text(
                      _expanded
                          ? 'Show less'
                          : 'Show ${hiddenCount.toString()} more payment${hiddenCount == 1 ? '' : 's'}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _PopupLinkTile extends StatelessWidget {
  final TopCenterMessagePopupLink link;
  final VoidCallback onClose;

  const _PopupLinkTile({required this.link, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        onClose();
        link.onTap();
      },
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        child: Row(
          children: [
            Icon(Icons.link_rounded, size: 14, color: LoginColors.primary),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                link.label,
                style: TextStyle(
                  color: LoginColors.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  decoration: TextDecoration.underline,
                  decorationColor: LoginColors.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
