import 'package:coreflow/core/theme/colors.dart';
import 'package:flutter/material.dart';

class TopMessageLink {
  final String label;
  final String? meta;
  final VoidCallback onTap;

  const TopMessageLink({required this.label, this.meta, required this.onTap});
}

class TopMessagePopup {
  static OverlayEntry? _entry;

  static void show({
    required BuildContext context,
    required String message,
    String title = 'Message',
    List<TopMessageLink> links = const [],
    IconData icon = Icons.info_outline_rounded,
  }) {
    hide();
    final overlay = Overlay.of(context, rootOverlay: true);
    _entry = OverlayEntry(
      builder: (overlayContext) {
        final top = MediaQuery.of(overlayContext).padding.top + 8;
        return Positioned(
          top: top,
          left: 12,
          right: 12,
          child: Align(
            alignment: Alignment.topCenter,
            child: Dismissible(
              key: const ValueKey('top_message_popup'),
              direction: DismissDirection.up,
              onDismissed: (_) => hide(),
              child: _TopMessageCard(
                title: title,
                message: message,
                icon: icon,
                links: links,
                onClose: hide,
              ),
            ),
          ),
        );
      },
    );
    overlay.insert(_entry!);
  }

  static void hide() {
    _entry?.remove();
    _entry = null;
  }
}

class _TopMessageCard extends StatefulWidget {
  final String title;
  final String message;
  final IconData icon;
  final List<TopMessageLink> links;
  final VoidCallback onClose;

  const _TopMessageCard({
    required this.title,
    required this.message,
    required this.icon,
    required this.links,
    required this.onClose,
  });

  @override
  State<_TopMessageCard> createState() => _TopMessageCardState();
}

class _TopMessageCardState extends State<_TopMessageCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final visibleLinks = _expanded
        ? widget.links
        : widget.links.take(1).toList();
    final hiddenCount = widget.links.length - visibleLinks.length;

    return Material(
      color: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 460),
        decoration: BoxDecoration(
          color: LoginColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: LoginColors.borderLight),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 12,
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
                    child: Icon(
                      widget.icon,
                      size: 18,
                      color: LoginColors.primary,
                    ),
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
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.message,
                          style: TextStyle(
                            color: LoginColors.textSecondary,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  InkWell(
                    onTap: widget.onClose,
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.all(2),
                      child: Icon(
                        Icons.close_rounded,
                        color: LoginColors.textSecondary,
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ),
              if (visibleLinks.isNotEmpty) ...[
                const SizedBox(height: 8),
                for (final link in visibleLinks)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        InkWell(
                          onTap: () {
                            widget.onClose();
                            link.onTap();
                          },
                          borderRadius: BorderRadius.circular(8),
                          child: Text(
                            link.label,
                            style: TextStyle(
                              color: LoginColors.primary,
                              decoration: TextDecoration.underline,
                              decorationColor: LoginColors.primary,
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        if (link.meta != null && link.meta!.trim().isNotEmpty)
                          Text(
                            ' | ${link.meta!}',
                            style: TextStyle(
                              color: LoginColors.textSecondary,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                      ],
                    ),
                  ),
              ],
              if (hiddenCount > 0)
                TextButton.icon(
                  onPressed: () => setState(() => _expanded = !_expanded),
                  style: TextButton.styleFrom(
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
                    _expanded ? 'Show less' : 'Show $hiddenCount more',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
