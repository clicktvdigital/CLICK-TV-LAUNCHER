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

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flauncher/flauncher_channel.dart';

// Modificaciones de interfaz de donativos: CLICK TV DIGITAL, 2026.
// Conservar las licencias y avisos de terceros del repositorio.

enum _TipoDonativo { banco, deuna, enlace, pendiente }

class _MetodoDonativo {
  final String titulo;
  final String logo;
  final _TipoDonativo tipo;
  final String numero;
  final String enlace;
  final Color color;

  const _MetodoDonativo({
    required this.titulo,
    required this.logo,
    required this.tipo,
    this.numero = '',
    this.enlace = '',
    required this.color,
  });
}

const List<_MetodoDonativo> _metodos = [
  _MetodoDonativo(
    titulo: 'Banco Pichincha', logo: 'pichincha',
    tipo: _TipoDonativo.banco, numero: '2205375908',
    color: Color(0xFFF5CC12),
  ),
  _MetodoDonativo(
    titulo: 'Banco Guayaquil', logo: 'guayaquil',
    tipo: _TipoDonativo.banco, numero: '0013647475',
    color: Color(0xFFD91777),
  ),
  _MetodoDonativo(
    titulo: 'Produbanco', logo: 'produbanco',
    tipo: _TipoDonativo.banco, numero: '12009308674',
    color: Color(0xFF2C9146),
  ),
  _MetodoDonativo(
    titulo: 'Banco del Pacífico', logo: 'pacifico',
    tipo: _TipoDonativo.banco, numero: '1062494589',
    color: Color(0xFF138FD2),
  ),
  _MetodoDonativo(
    titulo: 'Deuna!', logo: 'deuna',
    tipo: _TipoDonativo.deuna, numero: '7701517809',
    color: Color(0xFF9D53BE),
  ),
  _MetodoDonativo(
    titulo: 'PayPhone', logo: 'payphone',
    tipo: _TipoDonativo.enlace,
    enlace: 'https://ppls.me/izAAuu8fptGHF6uZBV9L4Q',
    color: Color(0xFFFF8420),
  ),
  _MetodoDonativo(
    titulo: 'PayPal', logo: 'paypal',
    tipo: _TipoDonativo.enlace,
    enlace: 'https://www.paypal.com/ncp/payment/NKS3NQA6Q2Q5N',
    color: Color(0xFF188BEE),
  ),
  _MetodoDonativo(
    titulo: 'Binance', logo: 'binance',
    tipo: _TipoDonativo.pendiente,
    color: Color(0xFFF1C433),
  ),
  _MetodoDonativo(
    titulo: 'GitHub Sponsors', logo: 'github_sponsors',
    tipo: _TipoDonativo.pendiente,
    color: Color(0xFFD82481),
  ),
  _MetodoDonativo(
    titulo: 'Patreon', logo: 'patreon',
    tipo: _TipoDonativo.pendiente,
    color: Color(0xFFFF6B34),
  ),
];

class DonateDialog extends StatefulWidget {
  const DonateDialog({Key? key}) : super(key: key);

  @override
  State<DonateDialog> createState() => _DonateDialogState();
}

class _DonateDialogState extends State<DonateDialog> {
  int _seleccion = 0;
  String? _aporteSeleccionado;
  static const _titular = 'Richard Ontaneda';
  static const _correo = 'clicktvdigital@gmail.com';

  static const _aportesUnicos = <String>[
    '☕ INVÍTAME UN CAFECITO · \$1 USD',
    '🫔 INVÍTAME UN TAMALITO LOJANO CON CAFÉ · \$3 USD',
    '🍲 INVÍTAME UN ENCEBOLLADO · \$5 USD',
  ];

  static const _patrociniosMensuales = <String>[
    '💙 AMIGO DE CLICK TV · \$2 USD/mes',
    '💚 PROTECTOR DE CLICK TV · \$5 USD/mes',
    '💜 ALIADO DE CLICK TV · \$10 USD/mes',
  ];

  String _datosQr(_MetodoDonativo metodo) {
    if (metodo.tipo == _TipoDonativo.enlace) return metodo.enlace;
    if (metodo.tipo == _TipoDonativo.pendiente) return '';
    final identificador = metodo.tipo == _TipoDonativo.deuna
        ? 'Número Deuna!: ${metodo.numero}'
        : 'Cuenta de ahorros: ${metodo.numero}';
    return 'CLICK TV DIGITAL\n${metodo.titulo}\n$identificador\n'
        'Titular: $_titular\nCorreo: $_correo';
  }

  late final List<FocusNode> _metodoNodes = List.generate(
    _metodos.length, (i) => FocusNode(debugLabel: 'donativo-metodo-$i'));
  late final List<FocusNode> _aporteNodes = List.generate(
    6, (i) => FocusNode(debugLabel: 'donativo-aporte-$i'));
  final _qrNode = FocusNode(debugLabel: 'donativo-qr');
  final _ampliarNode = FocusNode(debugLabel: 'donativo-ampliar');
  final _enlaceNode = FocusNode(debugLabel: 'donativo-enlace');
  final _volverNode = FocusNode(debugLabel: 'donativo-volver');
  final _cerrarNode = FocusNode(debugLabel: 'donativo-cerrar');
  final _detalleScroll = ScrollController();
  bool _enDetalle = false;

  List<FocusNode> get _detalleNodes => [
    if (_datosQr(_metodos[_seleccion]).isNotEmpty) _qrNode,
    if (_datosQr(_metodos[_seleccion]).isNotEmpty) _ampliarNode,
    if (_metodos[_seleccion].tipo == _TipoDonativo.enlace) _enlaceNode,
    ..._aporteNodes,
    _volverNode,
  ];

  @override
  void dispose() {
    for (final node in [..._metodoNodes, ..._aporteNodes, _qrNode,
        _ampliarNode, _enlaceNode, _volverNode, _cerrarNode]) {
      node.dispose();
    }
    _detalleScroll.dispose();
    super.dispose();
  }

  void _mostrarFoco(FocusNode node, bool enfocado) {
    if (!enfocado) return;
    if (_detalleNodes.contains(node) && !_enDetalle) {
      setState(() => _enDetalle = true);
    } else if (_metodoNodes.contains(node) && _enDetalle) {
      // Pointer and Tab traversal must obey the same Back behavior as D-pad.
      setState(() => _enDetalle = false);
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final context = node.context;
      if (mounted && node.hasFocus && context != null && context.mounted) {
        Scrollable.ensureVisible(context, alignment: .5, duration: Duration.zero);
      }
    });
  }

  void _enfocar(FocusNode node) {
    node.requestFocus();
    _mostrarFoco(node, true);
  }

  void _volverAMetodos() {
    setState(() => _enDetalle = false);
    _enfocar(_metodoNodes[_seleccion]);
  }

  void _seleccionar(int indice) {
    setState(() {
      _seleccion = indice;
      _enDetalle = true;
    });
    if (_detalleScroll.hasClients) _detalleScroll.jumpTo(0);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _enfocar(_detalleNodes.first);
    });
  }

  KeyEventResult _navegar(FocusNode _, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }
    final key = event.logicalKey;
    if (key == LogicalKeyboardKey.escape || key == LogicalKeyboardKey.goBack ||
        key == LogicalKeyboardKey.gameButtonB) {
      if (_enDetalle) {
        _volverAMetodos();
      } else {
        Navigator.of(context).pop();
      }
      return KeyEventResult.handled;
    }
    final up = key == LogicalKeyboardKey.arrowUp;
    final down = key == LogicalKeyboardKey.arrowDown;
    final left = key == LogicalKeyboardKey.arrowLeft;
    final right = key == LogicalKeyboardKey.arrowRight;
    if (!up && !down && !left && !right) return KeyEventResult.ignored;

    final metodo = _metodoNodes.indexWhere((node) => node.hasFocus);
    if (metodo >= 0) {
      if (right) {
        _seleccionar(metodo);
      } else if ((up || left) && metodo > 0) {
        _enfocar(_metodoNodes[metodo - 1]);
      } else if (down && metodo < _metodos.length - 1) {
        _enfocar(_metodoNodes[metodo + 1]);
      } else {
        _enfocar(_cerrarNode);
      }
    } else if (_cerrarNode.hasFocus) {
      if (up || right) {
        _enfocar(_detalleNodes.last);
      } else {
        _volverAMetodos();
      }
    } else {
      final nodes = _detalleNodes;
      final index = nodes.indexWhere((node) => node.hasFocus);
      if (left || (up && index <= 0)) {
        _volverAMetodos();
      } else if (up) {
        _enfocar(nodes[index - 1]);
      } else if (index >= 0 && index < nodes.length - 1) {
        _enfocar(nodes[index + 1]);
      } else {
        _enfocar(_cerrarNode);
      }
    }
    return KeyEventResult.handled;
  }

  Widget _botonMetodo(int indice, {required bool compacto}) {
    final opcion = _metodos[indice];
    final activa = indice == _seleccion;
    final node = _metodoNodes[indice];
    return SizedBox(
      width: compacto ? double.infinity : 155,
      child: OutlinedButton(
        key: ValueKey('donativo-metodo-$indice'),
        focusNode: node,
        autofocus: indice == 0,
        onFocusChange: (value) => _mostrarFoco(node, value),
        onPressed: () => _seleccionar(indice),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          foregroundColor: Colors.white,
          backgroundColor: activa ? opcion.color.withOpacity(.18) : const Color(0xFF1D2939),
          side: BorderSide(color: activa ? opcion.color : Colors.white30, width: activa ? 2 : 1),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ).copyWith(
          overlayColor: WidgetStateProperty.resolveWith((states) =>
            states.contains(WidgetState.focused) ? Colors.white24 : null),
        ),
        child: Row(children: [
          Container(
            width: 42, height: 34,
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(5)),
            child: Image.asset('assets/donaciones/logos/${opcion.logo}.jpg',
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => const Icon(Icons.account_balance, color: Colors.black)),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(opcion.titulo, style: const TextStyle(fontSize: 13))),
        ]),
      ),
    );
  }

  Widget _opcionApoyo(String texto) {
    final index = [..._aportesUnicos, ..._patrociniosMensuales].indexOf(texto);
    final node = _aporteNodes[index];
    final seleccionada = texto == _aporteSeleccionado;
    return OutlinedButton(
      key: ValueKey('donativo-aporte-$index'),
      focusNode: node,
      onFocusChange: (value) => _mostrarFoco(node, value),
      onPressed: () => setState(() => _aporteSeleccionado = texto),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        backgroundColor: seleccionada ? const Color(0xFF254D42) : const Color(0xFF16243A),
        side: BorderSide(color: seleccionada ? Colors.lightGreenAccent : Colors.white24,
          width: seleccionada ? 2 : 1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
      ),
      child: Text(texto, textAlign: TextAlign.center,
        style: const TextStyle(color: Colors.white, fontSize: 11)),
    );
  }

  Widget _accionesYDatos(_MetodoDonativo metodo) {
    final datosQr = _datosQr(metodo);
    return Column(mainAxisSize: MainAxisSize.min, children: [
      Text(metodo.titulo, key: const ValueKey('donativo-titulo-metodo'),
        textAlign: TextAlign.center,
        style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700)),
      const SizedBox(height: 8),
      if (metodo.tipo == _TipoDonativo.banco || metodo.tipo == _TipoDonativo.deuna) ...[
        Text(metodo.tipo == _TipoDonativo.banco ? 'Cuenta de ahorros' : 'Número Deuna!',
          style: const TextStyle(color: Colors.white70)),
        Text(metodo.numero, style: const TextStyle(color: Colors.white,
          fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 5),
        const Text('Titular: $_titular', style: TextStyle(color: Colors.white, fontSize: 16)),
      ],
      const SizedBox(height: 6),
      const Text('Contacto: $_correo', textAlign: TextAlign.center,
        style: TextStyle(color: Colors.white70, fontSize: 15)),
      const SizedBox(height: 8),
      if (datosQr.isNotEmpty) ...[
        Text(metodo.tipo == _TipoDonativo.enlace
          ? 'Escanea desde tu celular para abrir el enlace de pago.'
          : 'QR informativo: escanea para consultar los datos y '
            'realiza la transferencia manualmente en tu banco o Deuna.',
          textAlign: TextAlign.center, style: const TextStyle(color: Colors.white70, fontSize: 13)),
        TextButton.icon(
          key: const ValueKey('donativo-ampliar'),
          focusNode: _ampliarNode,
          onFocusChange: (value) => _mostrarFoco(_ampliarNode, value),
          onPressed: () => _verQrAmpliado(metodo, _ampliarNode),
          icon: const Icon(Icons.zoom_in), label: const Text('Ver QR ampliado')),
        if (metodo.tipo == _TipoDonativo.enlace) ...[
          Text(metodo.enlace, textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white70, fontSize: 12)),
          TextButton.icon(
            key: const ValueKey('donativo-enlace'),
            focusNode: _enlaceNode,
            onFocusChange: (value) => _mostrarFoco(_enlaceNode, value),
            onPressed: () => FLauncherChannel().openUrl(metodo.enlace),
            icon: const Icon(Icons.open_in_browser), label: const Text('Abrir enlace de pago')),
        ],
      ] else ...[
        const Icon(Icons.info_outline, color: Colors.amber, size: 32),
        const SizedBox(height: 9),
        const Text('Enlace de donación pendiente de confirmar. '
          'No hay QR de pago disponible para este método.',
          textAlign: TextAlign.center, style: TextStyle(color: Colors.white70, fontSize: 14)),
      ],
      const SizedBox(height: 12),
      _nivelesApoyo(),
      const SizedBox(height: 8),
      _avisoSeguridad(),
      TextButton.icon(
        key: const ValueKey('donativo-volver'),
        focusNode: _volverNode,
        onFocusChange: (value) => _mostrarFoco(_volverNode, value),
        onPressed: _volverAMetodos,
        icon: const Icon(Icons.arrow_back), label: const Text('Volver a métodos de pago')),
    ]);
  }

  Widget _qr(_MetodoDonativo metodo, double size) {
    return SizedBox.square(
      dimension: size,
      child: OutlinedButton(
        key: const ValueKey('donativo-qr'),
        focusNode: _qrNode,
        onFocusChange: (value) => _mostrarFoco(_qrNode, value),
        onPressed: () => _verQrAmpliado(metodo, _qrNode),
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.zero,
          minimumSize: Size.zero,
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ).copyWith(
          overlayColor: const WidgetStatePropertyAll(Colors.transparent),
          side: WidgetStateProperty.resolveWith((states) => BorderSide(
            color: states.contains(WidgetState.focused) ? metodo.color : Colors.white,
            width: states.contains(WidgetState.focused) ? 4 : 1)),
        ),
        child: Semantics(label: 'Código QR de ${metodo.titulo}. OK para ampliar.',
          child: _imagenQr(_datosQr(metodo), size)),
      ),
    );
  }

  Widget _detalleMetodo(_MetodoDonativo metodo, {required bool horizontal, required double viewportHeight}) {
    return Container(
      key: const ValueKey('donativo-detalle'),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: const Color(0xFF182337),
        border: Border.all(color: metodo.color.withOpacity(.8)),
        borderRadius: BorderRadius.circular(14)),
      child: LayoutBuilder(builder: (context, constraints) {
        final hasQr = _datosQr(metodo).isNotEmpty;
        if (horizontal) {
          final qrSize = math.min(280.0,
            math.min(constraints.maxWidth * .44, constraints.maxHeight));
          return Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Expanded(child: SingleChildScrollView(
              key: const ValueKey('donativo-scroll-detalle'),
              controller: _detalleScroll,
              child: _accionesYDatos(metodo))),
            if (hasQr) ...[
              const SizedBox(width: 12),
              Center(child: _qr(metodo, qrSize)),
            ],
          ]);
        }
        final qrSize = math.min(260.0,
          math.min(constraints.maxWidth, math.max(1.0, viewportHeight - 24)));
        return Column(mainAxisSize: MainAxisSize.min, children: [
          if (hasQr) ...[_qr(metodo, qrSize), const SizedBox(height: 12)],
          _accionesYDatos(metodo),
        ]);
      }),
    );
  }

  Future<void> _verQrAmpliado(_MetodoDonativo metodo, FocusNode origen) async {
    await showDialog<void>(context: context, builder: (_) => _QrAmpliadoDialog(
      metodo: metodo.titulo, datosQr: _datosQr(metodo), color: metodo.color));
    if (mounted) _enfocar(origen);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_enDetalle,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _volverAMetodos();
      },
      child: Shortcuts(
        shortcuts: const {
          SingleActivator(LogicalKeyboardKey.select): ActivateIntent(),
          SingleActivator(LogicalKeyboardKey.enter): ActivateIntent(),
          SingleActivator(LogicalKeyboardKey.numpadEnter): ActivateIntent(),
          SingleActivator(LogicalKeyboardKey.gameButtonA): ActivateIntent(),
        },
        child: FocusTraversalGroup(
          policy: WidgetOrderTraversalPolicy(),
          child: Focus(
            canRequestFocus: false, skipTraversal: true, onKeyEvent: _navegar,
            child: SafeArea(
              child: Dialog(
                backgroundColor: const Color(0xFF0D1422),
                insetPadding: const EdgeInsets.all(12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1100),
                  child: LayoutBuilder(builder: (context, constraints) {
                    final horizontal = constraints.maxWidth >= 720;
                    return Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(mainAxisSize: MainAxisSize.min, children: [
                        _encabezado(),
                        const SizedBox(height: 8),
                        Flexible(child: LayoutBuilder(builder: (context, body) {
                          final metodo = _metodos[_seleccion];
                          if (horizontal) {
                            return Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                              SizedBox(width: 210, child: Container(
                                decoration: BoxDecoration(color: const Color(0xFF121D2E),
                                  borderRadius: BorderRadius.circular(12)),
                                padding: const EdgeInsets.all(8),
                                child: SingleChildScrollView(
                                  key: const ValueKey('donativo-scroll-metodos'),
                                  child: Column(children: List.generate(_metodos.length,
                                    (i) => Padding(padding: const EdgeInsets.only(bottom: 6),
                                      child: _botonMetodo(i, compacto: true)))),
                                ),
                              )),
                              const SizedBox(width: 12),
                              Expanded(child: _detalleMetodo(metodo, horizontal: true,
                                viewportHeight: body.maxHeight)),
                            ]);
                          }
                          return SingleChildScrollView(
                            key: const ValueKey('donativo-scroll-compacto'),
                            controller: _detalleScroll,
                            child: Column(mainAxisSize: MainAxisSize.min, children: [
                              Wrap(alignment: WrapAlignment.center, spacing: 8, runSpacing: 8,
                                children: List.generate(_metodos.length,
                                  (i) => _botonMetodo(i, compacto: false))),
                              const SizedBox(height: 12),
                              _detalleMetodo(metodo, horizontal: false, viewportHeight: body.maxHeight),
                            ]),
                          );
                        })),
                        TextButton.icon(
                          key: const ValueKey('donativo-cerrar'),
                          focusNode: _cerrarNode,
                          onFocusChange: (value) => _mostrarFoco(_cerrarNode, value),
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.close), label: const Text('Cerrar')),
                      ]),
                    );
                  }),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
  Widget _nivelesApoyo() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
      decoration: BoxDecoration(
        color: const Color(0xFF111E31),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        children: [
          const Text(
            'APORTES VOLUNTARIOS SUGERIDOS',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 6,
            runSpacing: 5,
            children: _aportesUnicos.map(_opcionApoyo).toList(),
          ),
          const SizedBox(height: 7),
          const Text(
            'PATROCINIOS MENSUALES SUGERIDOS',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white70, fontSize: 11),
          ),
          const SizedBox(height: 4),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 6,
            runSpacing: 5,
            children: _patrociniosMensuales.map(_opcionApoyo).toList(),
          ),
          if (_aporteSeleccionado != null) ...[
            const SizedBox(height: 5),
            Text(
              'Sugerencia seleccionada: $_aporteSeleccionado',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.lightGreenAccent, fontSize: 11),
            ),
          ],
          const SizedBox(height: 4),
          const Text(
            'El monto es voluntario. Elige el importe al pagar; aquí no se activa un cobro automático.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white60, fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _encabezado() {
    return const Column(
      children: [
        Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite, color: Color(0xFFF23573), size: 27),
                  SizedBox(width: 10),
                  Flexible(
                    child: Text(
                      'APOYA CLICK TV LAUNCHER',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 5),
              Text(
                'by CLICK TV DIGITAL · Aportes voluntarios',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ],
          );
  }

  Widget _avisoSeguridad() {
    return const Text(
      'No compartas claves, PIN ni códigos de seguridad. '
      'Los QR bancarios son informativos y no autorizan transferencias.',
      textAlign: TextAlign.center,
      style: TextStyle(color: Colors.white60, fontSize: 12),
    );
  }

}

// A square image owns its quiet zone; decorations and focus never cover it.
Widget _imagenQr(String data, double size) => QrImageView(
  data: data,
  version: QrVersions.auto,
  size: size,
  padding: EdgeInsets.all(size * .14),
  backgroundColor: Colors.white,
  eyeStyle: const QrEyeStyle(eyeShape: QrEyeShape.square, color: Colors.black),
  dataModuleStyle: const QrDataModuleStyle(
    dataModuleShape: QrDataModuleShape.square, color: Colors.black),
);

class _QrAmpliadoDialog extends StatelessWidget {
  final String metodo;
  final String datosQr;
  final Color color;

  const _QrAmpliadoDialog({
    required this.metodo,
    required this.datosQr,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      shortcuts: const {
        SingleActivator(LogicalKeyboardKey.select): ActivateIntent(),
        SingleActivator(LogicalKeyboardKey.enter): ActivateIntent(),
        SingleActivator(LogicalKeyboardKey.gameButtonA): ActivateIntent(),
      },
      child: SafeArea(
      child: Dialog(
        backgroundColor: Colors.black,
        insetPadding: const EdgeInsets.all(12),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Text('QR ampliado · $metodo', textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 20,
                  fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Flexible(child: LayoutBuilder(builder: (context, constraints) {
                // Actual remaining space after text and footer layout, including
                // text scaling. No guessed header heights or nested scrolling.
                final size = math.min(constraints.maxWidth, constraints.maxHeight);
                return Center(child: SizedBox.square(
                  key: const ValueKey('donativo-qr-ampliado'),
                  dimension: size,
                  child: DecoratedBox(
                    decoration: BoxDecoration(color: Colors.white,
                      border: Border.all(color: color, width: 3)),
                    child: Padding(padding: const EdgeInsets.all(4),
                      child: _imagenQr(datosQr, math.max(1.0, size - 8))),
                  ),
                ));
              })),
              const SizedBox(height: 8),
              const Text('Pulsa ATRÁS para volver',
                style: TextStyle(color: Colors.white70, fontSize: 14)),
              TextButton.icon(
                key: const ValueKey('donativo-qr-volver'),
                autofocus: true,
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.arrow_back), label: const Text('Volver')),
            ]),
          ),
        ),
      ),
      ),
    );
  }
}
