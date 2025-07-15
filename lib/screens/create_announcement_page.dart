import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

import '../models/announcement_model.dart';
import '../controllers/announcements_controller.dart';

class CreateAnnouncementPage extends StatefulWidget {
  const CreateAnnouncementPage({Key? key}) : super(key: key);

  @override
  State<CreateAnnouncementPage> createState() => _CreateAnnouncementPageState();
}

class _CreateAnnouncementPageState extends State<CreateAnnouncementPage> {
  final List<Announcement> announcements = [];

  void _openAnnouncementDialog() {
    final titleController = TextEditingController();
    final messageController = TextEditingController();
    List<PlatformFile> attachedFiles = [];
    RecipientType selectedRecipient = RecipientType.todos;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              backgroundColor: Colors.grey[800],
              child: Container(
                padding: EdgeInsets.all(24),
                width: 600,
                height: 500,
                child: Column(
                  children: [
                    Text(
                      'Novo Anúncio',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 12),
                    TextField(
                      controller: titleController,
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Título',
                        labelStyle: TextStyle(color: Colors.white70),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white54),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                      ),
                    ),
                    SizedBox(height: 12),
                    TextField(
                      controller: messageController,
                      maxLines: 3,
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Mensagem',
                        labelStyle: TextStyle(color: Colors.white70),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white54),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                      ),
                    ),
                    SizedBox(height: 12),
                    Row(
                      children: [
                        Text(
                          'Destinatário:',
                          style: TextStyle(color: Colors.white),
                        ),
                        SizedBox(width: 16),
                        DropdownButton<RecipientType>(
                          dropdownColor: Colors.grey[800],
                          value: selectedRecipient,
                          onChanged: (value) {
                            if (value != null) {
                              setStateDialog(() {
                                selectedRecipient = value;
                              });
                            }
                          },
                          items: [
                            DropdownMenuItem(
                              value: RecipientType.todos,
                              child: Text(
                                'Todos',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                            DropdownMenuItem(
                              value: RecipientType.professores,
                              child: Text(
                                'Professores',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[700],
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () async {
                        FilePickerResult? result = await FilePicker.platform
                            .pickFiles(allowMultiple: true);
                        if (result != null) {
                          setStateDialog(() {
                            attachedFiles = result.files;
                          });
                        }
                      },
                      child: Text('Anexar Ficheiros'),
                    ),
                    if (attachedFiles.isNotEmpty) ...[
                      SizedBox(height: 10),
                      Text(
                        'Ficheiros Anexados:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Expanded(
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: attachedFiles.length,
                          itemBuilder: (context, index) {
                            final file = attachedFiles[index];
                            return ListTile(
                              title: Text(
                                file.name,
                                style: TextStyle(color: Colors.white),
                              ),
                              trailing: IconButton(
                                icon: Icon(
                                  Icons.remove_circle,
                                  color: Colors.redAccent,
                                ),
                                onPressed: () {
                                  setStateDialog(() {
                                    attachedFiles.removeAt(index);
                                  });
                                },
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                    Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: Text(
                            'Cancelar',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        SizedBox(width: 8),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey[700],
                            foregroundColor: Colors.white,
                          ),
                          onPressed: () async {
                            final title = titleController.text;
                            final message = messageController.text;

                            if (title.isEmpty || message.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Título e mensagem são obrigatórios!'),
                                ),
                              );
                              return;
                            }

                            try {
                              await AnnouncementsController().createAnnouncement(
                                title: title,
                                message: message,
                                recipient: selectedRecipient,
                                files: attachedFiles,
                              );

                              Navigator.of(context).pop();

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Anúncio "$title" criado com sucesso!'),
                                ),
                              );
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Erro ao criar anúncio: $e'),
                                ),
                              );
                            }
                          },
                          child: Text('Criar'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[800],
      appBar: AppBar(
        title: const Text('Anúncios'),
        backgroundColor: Colors.grey[900],
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: SizedBox(
            width: 600,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[700],
                    foregroundColor: Colors.white,
                  ),
                  onPressed: _openAnnouncementDialog,
                  child: Text('Novo Anúncio'),
                ),
                SizedBox(height: 24),
                Text(
                  'Anúncios Criados:',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 12),
                Expanded(
                child: StreamBuilder<List<Announcement>>(
                  stream: AnnouncementsController().streamAnnouncements(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      return Center(child: Text('Erro ao carregar anúncios.'));
                    }

                    final announcements = snapshot.data ?? [];

                    if (announcements.isEmpty) {
                      return Text(
                        'Nenhum anúncio criado ainda.',
                        style: TextStyle(color: Colors.white70),
                      );
                    }

                    return ListView.builder(
                      itemCount: announcements.length,
                      itemBuilder: (context, index) {
                        final a = announcements[index];
                        return Card(
                          color: Colors.grey[700],
                          margin: EdgeInsets.symmetric(vertical: 8),
                          child: ListTile(
                            title: Text(
                              a.title,
                              style: TextStyle(color: Colors.white),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  a.message,
                                  style: TextStyle(color: Colors.white70),
                                ),
                                Text(
                                  'Para: ${a.recipient == RecipientType.todos ? 'Todos' : 'Professores'}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.white60,
                                  ),
                                ),
                                if (a.files.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Text(
                                      'Ficheiros: ${a.files.map((f) => f['name']).join(', ')}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.white60,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
