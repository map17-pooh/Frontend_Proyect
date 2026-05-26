import 'dart:io';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class PdfService {
  static Future<void> exportarPerfil({
    required BuildContext context,
    required Map<String, dynamic> perfilData,
    String titulo = 'Perfil de Usuario',
  }) async {
    final doc = pw.Document();

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (pw.Context ctx) => [
          _buildHeader(titulo),
          pw.SizedBox(height: 20),
          _buildSection('Información Personal', [
            _buildRow('Nombre', perfilData['nombre']?.toString() ?? ''),
            _buildRow('Email', perfilData['email']?.toString() ?? ''),
            _buildRow('Tipo Documento', perfilData['tipoDocumento']?.toString() ?? ''),
            _buildRow('Número Documento', perfilData['numeroDocumento']?.toString() ?? ''),
            _buildRow('Teléfono', perfilData['telefono']?.toString() ?? ''),
            _buildRow('Dirección', perfilData['direccion']?.toString() ?? ''),
          ]),
          if (perfilData['esMenor14'] == true) ...[
            pw.SizedBox(height: 16),
            _buildSection('Datos del Acudiente', [
              _buildRow('Nombre', perfilData['nombreResponsable']?.toString() ?? ''),
              _buildRow('Teléfono', perfilData['telefonoResponsable']?.toString() ?? ''),
              _buildRow('Parentesco', perfilData['parentesco']?.toString() ?? ''),
            ]),
          ],
          pw.SizedBox(height: 20),
          _buildFooter(),
        ],
      ),
    );

    await _saveAndOpen(context, doc, 'perfil_usuario.pdf');
  }

  static Future<void> exportarFormulario({
    required BuildContext context,
    required String titulo,
    required Map<String, dynamic> datos,
  }) async {
    final doc = pw.Document();

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (pw.Context ctx) => [
          _buildHeader(titulo),
          pw.SizedBox(height: 20),
          _buildSection('Datos del Formulario',
            datos.entries
                .where((e) => e.value != null && e.value.toString().isNotEmpty)
                .map((e) => _buildRow(e.key, e.value.toString()))
                .toList(),
          ),
          pw.SizedBox(height: 20),
          _buildFooter(),
        ],
      ),
    );

    final filename = '${titulo.toLowerCase().replaceAll(' ', '_')}.pdf';
    await _saveAndOpen(context, doc, filename);
  }

  static pw.Widget _buildHeader(String titulo) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: PdfColor.fromHex('#00A99D'),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'PreventApp',
            style: pw.TextStyle(
              fontSize: 22,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.white,
            ),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            titulo,
            style: const pw.TextStyle(fontSize: 16, color: PdfColors.white),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            'Generado: ${DateTime.now().toLocal().toString().split('.').first}',
            style: const pw.TextStyle(fontSize: 10, color: PdfColors.white),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildSection(String title, List<pw.Widget> rows) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          title,
          style: pw.TextStyle(
            fontSize: 14,
            fontWeight: pw.FontWeight.bold,
            color: PdfColor.fromHex('#00A99D'),
          ),
        ),
        pw.Divider(color: PdfColor.fromHex('#00A99D')),
        pw.SizedBox(height: 8),
        ...rows,
      ],
    );
  }

  static pw.Widget _buildRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 160,
            child: pw.Text(
              label,
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11),
            ),
          ),
          pw.Expanded(
            child: pw.Text(value, style: const pw.TextStyle(fontSize: 11)),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildFooter() {
    return pw.Center(
      child: pw.Text(
        'PreventApp © ${DateTime.now().year}',
        style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey),
      ),
    );
  }

  static Future<void> _saveAndOpen(
      BuildContext context, pw.Document doc, String filename) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/$filename');
      await file.writeAsBytes(await doc.save());
      await OpenFile.open(file.path);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al generar PDF: $e')),
        );
      }
    }
  }
}
