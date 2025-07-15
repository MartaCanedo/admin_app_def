import 'package:flutter/material.dart';
import '../models/all_subject_model.dart';
import '../controllers/all_subject_controller.dart';

class DisciplinasPage extends StatefulWidget {
  const DisciplinasPage({super.key});

  @override
  State<DisciplinasPage> createState() => _DisciplinasPageState();
}

class _DisciplinasPageState extends State<DisciplinasPage> {
  final AllSubjectController _controller = AllSubjectController();
  List<AllSubjectModel> _subjects = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadSubjects();
  }

  Future<void> _loadSubjects() async {
    setState(() => _loading = true);
    _subjects = await _controller.getAllSubjects();
    setState(() => _loading = false);
  }

  void _showSubjectDialog({AllSubjectModel? subject}) {
    final TextEditingController _nameController =
        TextEditingController(text: subject?.name ?? '');

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.grey.shade900,
        title: Text(
          subject == null ? 'Nova Disciplina' : 'Editar Disciplina',
          style: const TextStyle(color: Colors.white),
        ),
        content: TextField(
          controller: _nameController,
          decoration: const InputDecoration(
            labelText: 'Nome da Disciplina',
            labelStyle: TextStyle(color: Colors.white70),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white24),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.blue),
            ),
          ),
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar', style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              final name = _nameController.text.trim();
              if (name.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Nome não pode estar vazio'),
                    backgroundColor: Colors.redAccent,
                  ),
                );
                return;
              }
              final nameExists = _subjects.any((s) =>
                  s.name.toLowerCase() == name.toLowerCase() &&
                  s.id != subject?.id);
              if (nameExists) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Já existe uma disciplina com esse nome'),
                    backgroundColor: Colors.redAccent,
                  ),
                );
                return;
              }
              if (subject == null) {
                await _controller.createSubject(name);
              } else {
                final canEdit = await _controller.updateSubject(subject.id, subject.name, name);
                if(canEdit){
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Disciplina atualizada com sucesso'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }else{
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Não foi possível atualizar a disciplina, em uso em algum curso ou nome vazio'),
                      backgroundColor: Colors.redAccent,
                    ),
                  );
                }
              }
              Navigator.pop(context);
              await _loadSubjects();
            },
            child: Text(subject == null ? 'Criar' : 'Atualizar'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(AllSubjectModel subject) async {
    final canDelete = await _controller.deleteSubjectIfUnused(subject);

    if (canDelete) {
      await _loadSubjects();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Disciplina eliminada com sucesso')),
      );
    } else {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text('Não é possível eliminar'),
          content: Text('Esta disciplina ainda está em uso em pelo menos um curso.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildListTile(AllSubjectModel subject) {
    return Card(
      color: Colors.grey.shade900,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        title: Text(
          subject.name,
          style: const TextStyle(color: Colors.white),
        ),
        trailing: PopupMenuButton<String>(
          color: Colors.grey.shade900,
          icon: const Icon(Icons.more_vert, color: Colors.white),
          onSelected: (value) {
            if (value == 'edit') {
              _showSubjectDialog(subject: subject);
            } else if (value == 'delete') {
              _confirmDelete(subject);
            }
          },
          itemBuilder: (BuildContext context) => [
            const PopupMenuItem<String>(
              value: 'edit',
              child: Text('Editar', style: TextStyle(color: Colors.white)),
            ),
            const PopupMenuItem<String>(
              value: 'delete',
              child: Text('Eliminar', style: TextStyle(color: Colors.redAccent)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade800,
      appBar: AppBar(
        backgroundColor: Colors.grey.shade900,
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 20),
        title: const Text('Disciplinas'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showSubjectDialog(),
        child: const Icon(Icons.add),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _subjects.isEmpty
              ? const Center(
                  child: Text('Nenhuma disciplina encontrada.',
                      style: TextStyle(color: Colors.white70)),
                )
              : ListView(
                  children: _subjects.map(_buildListTile).toList(),
                ),
    );
  }
}
