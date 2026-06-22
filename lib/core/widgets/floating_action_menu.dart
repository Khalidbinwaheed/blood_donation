import 'package:flutter/material.dart';

class FloatingActionMenuItem {
  const FloatingActionMenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;
}

class FloatingActionMenu extends StatefulWidget {
  const FloatingActionMenu({
    super.key,
    required this.items,
    this.primaryIcon = Icons.add,
  });

  final List<FloatingActionMenuItem> items;
  final IconData primaryIcon;

  @override
  State<FloatingActionMenu> createState() => _FloatingActionMenuState();
}

class _FloatingActionMenuState extends State<FloatingActionMenu>
    with SingleTickerProviderStateMixin {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        ...widget.items.reversed.map((item) {
          final index = widget.items.indexOf(item);
          return AnimatedSlide(
            duration: Duration(milliseconds: 160 + index * 40),
            offset: _expanded ? Offset.zero : const Offset(0, 0.25),
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 160),
              opacity: _expanded ? 1 : 0,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DecoratedBox(
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.78),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 7,
                        ),
                        child: Text(
                          item.label,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    FloatingActionButton.small(
                      heroTag: item.label,
                      backgroundColor:
                          item.color ?? Theme.of(context).colorScheme.primary,
                      onPressed: item.onTap,
                      child: Icon(item.icon),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
        FloatingActionButton(
          heroTag: 'floating_action_menu_primary',
          onPressed: () => setState(() => _expanded = !_expanded),
          child: Icon(_expanded ? Icons.close : widget.primaryIcon),
        ),
      ],
    );
  }
}
