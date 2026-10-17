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
  static const _titular = 'Richard Ontaneda';
  static const _correo = 'clicktvdigital@gmail.com';

  String _datosQr(_MetodoDonativo metodo) {
    if (metodo.tipo == _TipoDonativo.enlace) return metodo.enlace;
    if (metodo.tipo == _TipoDonativo.pendiente) return '';
    final identificador = metodo.tipo == _TipoDonativo.deuna
        ? 'Número Deuna!: ${metodo.numero}'
        : 'Cuenta de ahorros: ${metodo.numero}';
    return 'CLICK TV DIGITAL\n${metodo.titulo}\n$identificador\n'
        'Titular: $_titular\nCorreo: $_correo';
  }

  @override
  Widget build(BuildContext context) {
    final metodo = _metodos[_seleccion];
    final datosQr = _datosQr(metodo);
    final pantalla = MediaQuery.of(context).size;
    final ancho = pantalla.width > 900 ? 900.0 : pantalla.width * 0.96;
    final qrSize = pantalla.height > 650 ? 235.0 : 200.0;

    return Dialog(
      backgroundColor: const Color(0xFF0D1422),
      insetPadding: const EdgeInsets.all(12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: ancho, maxHeight: pantalla.height * .92),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite, color: Color(0xFFF23573), size: 27),
                  SizedBox(width: 10),
                  Flexible(
                    child: Text('APOYA CLICK TV LAUNCHER',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white, fontSize: 22,
                        fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              const Text('by CLICK TV DIGITAL · Aportes voluntarios',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70, fontSize: 14)),
              const SizedBox(height: 18),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 9,
                runSpacing: 9,
                children: List.generate(_metodos.length, (indice) {
                  final opcion = _metodos[indice];
                  final activa = indice == _seleccion;
                  return SizedBox(
                    width: 155,
                    child: OutlinedButton(
                      autofocus: indice == 0,
                      onPressed: () => setState(() => _seleccion = indice),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.fromLTRB(6, 9, 6, 6),
                        backgroundColor: activa
                          ? opcion.color.withOpacity(.18)
                          : const Color(0xFF1D2939),
                        side: BorderSide(color: activa ? opcion.color : Colors.white30,
                          width: activa ? 2 : 1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            height: 54,
                            padding: const EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(7),
                            ),
                            child: Image.asset(
                              'assets/donaciones/logos/${opcion.logo}.jpg',
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) =>
                                  Text(opcion.titulo,
                                    style: const TextStyle(color: Colors.black,
                                      fontSize: 12)),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(opcion.titulo,
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white, fontSize: 13)),
                        ],
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF182337),
                  border: Border.all(color: metodo.color.withOpacity(.8)),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  children: [
                    Text(metodo.titulo,
                      style: const TextStyle(color: Colors.white,
                        fontSize: 22, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 8),
                    if (metodo.tipo == _TipoDonativo.banco) ...[
                      const Text('Cuenta de ahorros',
                        style: TextStyle(color: Colors.white70)),
                      SelectableText(metodo.numero,
                        style: const TextStyle(color: Colors.white,
                          fontSize: 24, fontWeight: FontWeight.bold)),
                    ],
                    if (metodo.tipo == _TipoDonativo.deuna) ...[
                      const Text('Número Deuna!',
                        style: TextStyle(color: Colors.white70)),
                      SelectableText(metodo.numero,
                        style: const TextStyle(color: Colors.white,
                          fontSize: 24, fontWeight: FontWeight.bold)),
                    ],
                    if (metodo.tipo == _TipoDonativo.banco ||
                        metodo.tipo == _TipoDonativo.deuna) ...[
                      const SizedBox(height: 5),
                      const Text('Titular: $_titular',
                        style: TextStyle(color: Colors.white, fontSize: 16)),
                    ],
                    const SizedBox(height: 6),
                    const SelectableText('Contacto: $_correo',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white70, fontSize: 15)),
                    const SizedBox(height: 13),
                    if (datosQr.isNotEmpty) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: QrImageView(
                          data: datosQr,
                          version: QrVersions.auto,
                          size: qrSize,
                          padding: EdgeInsets.zero,
                          backgroundColor: Colors.white,
                          eyeStyle: const QrEyeStyle(
                            eyeShape: QrEyeShape.square, color: Colors.black),
                          dataModuleStyle: const QrDataModuleStyle(
                            dataModuleShape: QrDataModuleShape.square,
                            color: Colors.black),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        metodo.tipo == _TipoDonativo.enlace
                          ? 'Escanea desde tu celular para abrir el enlace de pago.'
                          : 'QR informativo: escanea para consultar los datos y '
                            'realiza la transferencia manualmente en tu banco o Deuna.',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white70, fontSize: 13)),
                      if (metodo.tipo == _TipoDonativo.enlace) ...[
                        const SizedBox(height: 10),
                        SelectableText(metodo.enlace,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.white70, fontSize: 12)),
                        TextButton.icon(
                          onPressed: () => FLauncherChannel().openUrl(metodo.enlace),
                          icon: const Icon(Icons.open_in_browser),
                          label: const Text('Abrir enlace de pago'),
                        ),
                      ],
                    ] else ...[
                      const Icon(Icons.info_outline, color: Colors.amber, size: 32),
                      const SizedBox(height: 9),
                      const Text('Enlace de donación pendiente de confirmar. '
                        'No hay QR de pago disponible para este método.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white70, fontSize: 14)),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 12),
              const Text('No compartas claves, PIN ni códigos de seguridad. '
                  'Los QR bancarios son informativos y no autorizan transferencias.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white60, fontSize: 12)),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.center,
                child: TextButton.icon(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                  label: const Text('Cerrar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
