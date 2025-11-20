import 'package:flutter/material.dart';
import 'package:mobi_core/mobi_core.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class DocumentsScreen extends StatefulWidget {
  const DocumentsScreen({super.key});

  @override
  State<DocumentsScreen> createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends State<DocumentsScreen> {
  final _imagePicker = ImagePicker();
  bool _isLoading = false;

  // Document status (TODO: Load from API)
  final Map<String, String> _documentStatus = {
    'cnh': 'pending', // pending, approved, rejected
    'vehicle_registration': 'approved',
    'insurance': 'pending',
    'profile_photo': 'approved',
  };

  Future<void> _pickAndUploadDocument(String documentType) async {
    try {
      final image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() => _isLoading = true);

        // TODO: Upload document to API
        await Future.delayed(const Duration(seconds: 2));

        if (mounted) {
          setState(() {
            _documentStatus[documentType] = 'pending';
            _isLoading = false;
          });

          CustomSnackbar.showSuccess(
            context,
            'Documento enviado com sucesso! Aguarde aprovação.',
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        CustomSnackbar.showError(
          context,
          'Erro ao enviar documento. Tente novamente.',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meus Documentos'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Card(
                  color: Colors.blue,
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Documentos Obrigatórios',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Envie todos os documentos para começar a dirigir. '
                          'Os documentos serão revisados em até 24 horas.',
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // CNH
                _DocumentTile(
                  title: 'Carteira Nacional de Habilitação (CNH)',
                  subtitle: 'Foto da CNH frente e verso',
                  status: _documentStatus['cnh']!,
                  onUpload: () => _pickAndUploadDocument('cnh'),
                ),

                // Vehicle Registration
                _DocumentTile(
                  title: 'Documento do Veículo (CRLV)',
                  subtitle: 'Certificado de Registro e Licenciamento',
                  status: _documentStatus['vehicle_registration']!,
                  onUpload: () => _pickAndUploadDocument('vehicle_registration'),
                ),

                // Insurance
                _DocumentTile(
                  title: 'Seguro do Veículo',
                  subtitle: 'Apólice de seguro vigente',
                  status: _documentStatus['insurance']!,
                  onUpload: () => _pickAndUploadDocument('insurance'),
                ),

                // Profile Photo
                _DocumentTile(
                  title: 'Foto de Perfil',
                  subtitle: 'Foto de rosto clara e recente',
                  status: _documentStatus['profile_photo']!,
                  onUpload: () => _pickAndUploadDocument('profile_photo'),
                ),

                const SizedBox(height: 16),

                // Legend
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Legenda',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _LegendRow(
                          color: Colors.orange,
                          icon: Icons.hourglass_empty,
                          text: 'Aguardando aprovação',
                        ),
                        _LegendRow(
                          color: Colors.green,
                          icon: Icons.check_circle,
                          text: 'Aprovado',
                        ),
                        _LegendRow(
                          color: Colors.red,
                          icon: Icons.cancel,
                          text: 'Rejeitado - reenviar',
                        ),
                        _LegendRow(
                          color: Colors.grey,
                          icon: Icons.cloud_upload,
                          text: 'Não enviado',
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

class _DocumentTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final String status;
  final VoidCallback onUpload;

  const _DocumentTile({
    required this.title,
    required this.subtitle,
    required this.status,
    required this.onUpload,
  });

  IconData _getStatusIcon() {
    switch (status) {
      case 'pending':
        return Icons.hourglass_empty;
      case 'approved':
        return Icons.check_circle;
      case 'rejected':
        return Icons.cancel;
      default:
        return Icons.cloud_upload;
    }
  }

  Color _getStatusColor() {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText() {
    switch (status) {
      case 'pending':
        return 'Em análise';
      case 'approved':
        return 'Aprovado';
      case 'rejected':
        return 'Rejeitado';
      default:
        return 'Não enviado';
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor();

    return Card(
      child: ListTile(
        leading: Icon(_getStatusIcon(), color: statusColor, size: 32),
        title: Text(title),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(subtitle),
            const SizedBox(height: 4),
            Text(
              _getStatusText(),
              style: TextStyle(
                color: statusColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        trailing: status != 'approved'
            ? IconButton(
                icon: const Icon(Icons.upload_file),
                onPressed: onUpload,
              )
            : null,
        isThreeLine: true,
      ),
    );
  }
}

class _LegendRow extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String text;

  const _LegendRow({
    required this.color,
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Text(text),
        ],
      ),
    );
  }
}
