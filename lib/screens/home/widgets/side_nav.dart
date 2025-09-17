import 'package:flutter/material.dart';

class SideNav extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onSelect;
  const SideNav({
    super.key,
    required this.selectedIndex,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final items = <_NavItem>[
      const _NavItem(
        IconData(0xe871, fontFamily: 'MaterialIcons'),
        'Dashboard',
      ),
      const _NavItem(
        IconData(0xe16c, fontFamily: 'MaterialIcons'),
        'Supermarkets',
      ),
      const _NavItem(IconData(0xe1db, fontFamily: 'MaterialIcons'), 'Products'),
      const _NavItem(IconData(0xe7fb, fontFamily: 'MaterialIcons'), 'Users'),
      const _NavItem(IconData(0xe06f, fontFamily: 'MaterialIcons'), 'Reports'),
      const _NavItem(IconData(0xe8b8, fontFamily: 'MaterialIcons'), 'Settings'),
    ];

    return Container(
      width: 240,
      color: const Color(0xFF1F2937),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
              child: Row(
                children: const [
                  CircleAvatar(
                    radius: 14,
                    backgroundColor: Color(0xFF10B981),
                    child: Icon(
                      Icons.qr_code_scanner,
                      size: 16,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(width: 12),
                  Text(
                    'Admin App',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: items.length,
                separatorBuilder: (_, __) => const SizedBox(height: 4),
                itemBuilder: (context, index) {
                  final isSelected = index == selectedIndex;
                  return _SideTile(
                    icon: items[index].icon,
                    label: items[index].label,
                    selected: isSelected,
                    onTap: () => onSelect(index),
                  );
                },
              ),
            ),
            const Divider(color: Color(0xFF374151), height: 1),
            _SideTile(
              icon: Icons.logout,
              label: 'Logout',
              selected: false,
              onTap: () => onSelect(-1),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _SideTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _SideTile({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bg = selected ? const Color(0xFF111827) : Colors.transparent;
    final fg = selected ? Colors.white : const Color(0xFF9CA3AF);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Container(
          height: 44,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              Icon(icon, color: fg, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: fg,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
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

class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem(this.icon, this.label);
}
