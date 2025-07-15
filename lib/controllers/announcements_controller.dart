import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';

import '../models/announcement_model.dart';

class AnnouncementsController {
  final _firestore = FirebaseFirestore.instance;

  Stream<List<Announcement>> streamAnnouncements() {
  return _firestore.collection('announcements').snapshots().map((snapshot) {
    try {
      return snapshot.docs.map((doc) {
        return Announcement.fromMap(doc.data(), doc.id);
      }).toList();
    } catch (e) {
      print('Erro ao mapear anúncios: $e');
      return [];
    }
  });
}

  /// Criar novo anúncio 
  Future<void> createAnnouncement({
  required String title,
  required String message,
  required RecipientType recipient,
  required List<PlatformFile> files,
}) async {
  final fileData = <Map<String, dynamic>>[];
  print('Ficheiros recebidos: ${files.map((f) => f.name)}');
  for (final file in files) {
    if (file.path != null) {
      print('Ficheiro ${file.name} convertido com sucesso');
      final bytes = await File(file.path!).readAsBytes();
      final base64 = base64Encode(bytes);
      fileData.add({
        'name': file.name,
        'bytesBase64': base64,
      });
    }
  }

  final announcement = Announcement(
    id: '',
    title: title,
    message: message,
    recipient: recipient,
    files: fileData,
  );

  await _firestore.collection('announcements').add(announcement.toMap());
}

  /// Ler todos os anúncios
  Future<List<Announcement>> getAnnouncements() async {
    final snapshot = await _firestore.collection('announcements').get();
    return snapshot.docs.map((doc) {
      return Announcement.fromMap(doc.data(), doc.id);
    }).toList();
  }

  ///  Obter um anúncio específico por ID
  Future<Announcement?> getAnnouncementById(String id) async {
    final doc = await _firestore.collection('announcements').doc(id).get();
    if (doc.exists) {
      return Announcement.fromMap(doc.data()!, doc.id);
    }
    return null;
  }

  // Buscar todos os anuncios por recipiente
  // como usar: await controller.getAllDocumentsByRecipient('professores');
  Future<List<Announcement>> getAllDocumentsByRecipient(String recipientType) async {
  try {
    final snapshot = await _firestore
        .collection('announcements')
        .where('recipient', isEqualTo: recipientType)
        .get();

    return snapshot.docs.map((doc) {
        return Announcement.fromMap(doc.data(), doc.id);
      }).toList();
    } catch (e) {
      print('Erro ao buscar anúncios por recipient: $e');
      return [];
    }
  }

  /// Atualizar um anúncio
  Future<void> updateAnnouncement({
    required String id,
    required String title,
    required String message,
    required RecipientType recipient,
    List<PlatformFile>? newFiles,
  }) async {
    final encodedFiles = <Map<String, dynamic>>[];

    if (newFiles != null) {
      for (final file in newFiles) {
        if (file.bytes != null) {
          encodedFiles.add({
            'name': file.name,
            'base64': base64Encode(file.bytes!),
            'extension': file.extension,
            'size': file.size,
          });
        }
      }
    }

    final Map<String, dynamic> updateData = {
      'title': title,
      'message': message,
      'recipient': recipient.name,
    };

    if (encodedFiles.isNotEmpty) {
      updateData['files'] = encodedFiles;
    }

    await _firestore.collection('announcements').doc(id).update(updateData);
  }

  /// Eliminar um anúncio
  Future<void> deleteAnnouncement(Announcement announcement) async {
    await _firestore.collection('announcements').doc(announcement.id).delete();
  }
}
