/*
 * FLauncher
 * Copyright (C) 2024 LeanBitLab
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <https://www.gnu.org/licenses/>.
 */

import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:flauncher/flauncher_channel.dart';
import 'package:provider/provider.dart';
import 'package:flauncher/providers/settings_service.dart';

class LTvLauncherAboutDialog extends StatelessWidget {
  final PackageInfo packageInfo;

  const LTvLauncherAboutDialog({
    Key? key,
    required this.packageInfo,
  }) : super(key: key);

  Color _hexToColor(String hex) => Color(int.parse('FF$hex', radix: 16));

  Future<void> _openOfficialLink(BuildContext context, _OfficialLink link) async {
    final opened = await FLauncherChannel().openUrl(link.url);
    if (!opened && context.mounted) {
      await showDialog<void>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('No se pudo abrir el enlace'),
          content: Text('No hay una aplicación compatible para abrir ${link.title}.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cerrar'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final settingsService = context.watch<SettingsService>();
    final accentColor = _hexToColor(settingsService.accentColorHex);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 940,
          maxHeight: MediaQuery.sizeOf(context).height * .9,
        ),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: const Color(0xFF101116),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(.14)),
            boxShadow: const [
              BoxShadow(color: Colors.black54, blurRadius: 24, spreadRadius: 2),
            ],
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth >= 680;
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _AboutHeader(packageInfo: packageInfo),
                    const SizedBox(height: 20),
                    if (isWide)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _sectionTitle,
                          const SizedBox(height: 8),
                          _wideLinksLayout(context, accentColor),
                        ],
                      )
                    else
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _sectionTitle,
                          const SizedBox(height: 8),
                          _narrowLinksLayout(context, accentColor),
                        ],
                      ),
                    const SizedBox(height: 18),
                    _CommunityCard(accentColor: accentColor),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 28, vertical: 8),
                        child: Text('Cerrar'),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _wideLinksLayout(BuildContext context, Color accentColor) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _LinkSection(
            accentColor: accentColor,
            links: _officialLinks.take(2).toList(),
            onOpen: (link) => _openOfficialLink(context, link),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _LinkSection(
            accentColor: accentColor,
            links: _officialLinks.skip(2).toList(),
            onOpen: (link) => _openOfficialLink(context, link),
          ),
        ),
      ],
    );
  }

  Widget _narrowLinksLayout(BuildContext context, Color accentColor) {
    return _LinkSection(
      accentColor: accentColor,
      links: _officialLinks,
      onOpen: (link) => _openOfficialLink(context, link),
    );
  }
}

class _AboutHeader extends StatelessWidget {
  final PackageInfo packageInfo;

  const _AboutHeader({required this.packageInfo});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.asset(
            'assets/icon.png',
            height: 76,
            width: 76,
            fit: BoxFit.contain,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'CLICK TV LAUNCHER',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'v${packageInfo.version} (${packageInfo.buildNumber})',
                style: const TextStyle(color: Colors.white60, fontSize: 13),
              ),
              const SizedBox(height: 6),
              const Text(
                'Elige un enlace oficial con las flechas y pulsa OK.',
                style: TextStyle(color: Colors.white70, fontSize: 13),
              ),
              const SizedBox(height: 6),
              const Text(
                'Personalizado por CLICK TV DIGITAL · Licencia GPLv3',
                style: TextStyle(color: Colors.white54, fontSize: 11),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _LinkSection extends StatelessWidget {
  final Color accentColor;
  final List<_OfficialLink> links;
  final ValueChanged<_OfficialLink> onOpen;

  const _LinkSection({
    required this.accentColor,
    required this.links,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...links.map(
          (link) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _AboutButton(
              key: ValueKey(link.url),
              link: link,
              accentColor: accentColor,
              autofocus: link == _officialLinks.first,
              onPressed: () => onOpen(link),
            ),
          ),
        ),
      ],
    );
  }
}

const _sectionTitle = Text(
  'ENLACES OFICIALES',
  style: TextStyle(
    color: Colors.white60,
    fontSize: 11,
    fontWeight: FontWeight.bold,
    letterSpacing: 1,
  ),
);

class _CommunityCard extends StatelessWidget {
  final Color accentColor;

  const _CommunityCard({required this.accentColor});

  @override
  Widget build(BuildContext context) {
    return _AboutButton(
      link: const _OfficialLink(
        icon: Icons.code,
        title: 'Repositorio de GitHub',
        description: 'Código fuente y licencias del proyecto',
        url: 'https://github.com/clicktvdigital/CLICK-TV-LAUNCHER',
      ),
      accentColor: accentColor,
      onPressed: () => FLauncherChannel().openUrl(
        'https://github.com/clicktvdigital/CLICK-TV-LAUNCHER',
      ),
    );
  }
}

class _AboutButton extends StatefulWidget {
  final _OfficialLink link;
  final Color accentColor;
  final VoidCallback onPressed;
  final bool autofocus;

  const _AboutButton({
    super.key,
    required this.link,
    required this.accentColor,
    required this.onPressed,
    this.autofocus = false,
  });

  @override
  State<_AboutButton> createState() => _AboutButtonState();
}

class _AboutButtonState extends State<_AboutButton> {
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    return Actions(
      actions: <Type, Action<Intent>>{
        ActivateIntent: CallbackAction<ActivateIntent>(onInvoke: (_) => widget.onPressed()),
        ButtonActivateIntent: CallbackAction<ButtonActivateIntent>(onInvoke: (_) => widget.onPressed()),
      },
      child: Focus(
        autofocus: widget.autofocus,
        onFocusChange: (hasFocus) {
          setState(() => _focused = hasFocus);
          if (hasFocus) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                Scrollable.ensureVisible(
                  context,
                  duration: const Duration(milliseconds: 150),
                  alignment: .25,
                );
              }
            });
          }
        },
        child: GestureDetector(
          onTap: widget.onPressed,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 100),
            constraints: const BoxConstraints(minHeight: 72),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: _focused ? widget.accentColor.withOpacity(.22) : Colors.white.withOpacity(.06),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _focused ? Colors.white : Colors.white.withOpacity(.08),
                width: _focused ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  widget.link.icon,
                  size: 26,
                  color: _focused ? Colors.white : Colors.white70,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.link.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: _focused ? FontWeight.bold : FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        widget.link.description,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.white70, fontSize: 11),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        widget.link.url,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.white38, fontSize: 9),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(Icons.open_in_new, size: 16, color: _focused ? Colors.white70 : Colors.white38),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _OfficialLink {
  final IconData icon;
  final String title;
  final String description;
  final String url;

  const _OfficialLink({
    required this.icon,
    required this.title,
    required this.description,
    required this.url,
  });
}

const _officialLinks = <_OfficialLink>[
  _OfficialLink(
    icon: Icons.storefront,
    title: 'Tienda online',
    description: 'Productos y novedades de CLICK TV',
    url: 'https://click-tv-streaming.vercel.app',
  ),
  _OfficialLink(
    icon: Icons.live_tv,
    title: 'TV en vivo',
    description: 'Canal oficial de televisión en vivo',
    url: 'https://t.me/clicktvgo',
  ),
  _OfficialLink(
    icon: Icons.play_circle_fill,
    title: 'Streaming',
    description: 'Contenido y streaming de CLICK TV',
    url: 'https://t.me/click_tv_streaming',
  ),
  _OfficialLink(
    icon: Icons.send,
    title: 'Contacto directo · Telegram',
    description: 'Escríbenos directamente por Telegram',
    url: 'https://t.me/clicktvdigital',
  ),
];
