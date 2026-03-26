import 'package:flutter/material.dart';
import '../../services/me_service.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  final _service = MeService();
  List _tasks = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final data = await _service.getMyTasks();
    setState(() { _tasks = data; _loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Tareas'),
        backgroundColor: const Color(0xFF7B1FA2),
        foregroundColor: Colors.white,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _tasks.isEmpty
              ? const Center(child: Text('No hay tareas asignadas'))
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: _tasks.length,
                  itemBuilder: (ctx, i) {
                    final t = _tasks[i];
                    final estado = t['status'] ?? t['estado'] ?? 'pendiente';
                    final color = estado == 'entregado' || estado == 'graded'
                        ? Colors.green : Colors.orange;
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: const Color(0xFF7B1FA2).withOpacity(0.1),
                          child: const Icon(Icons.assignment,
                              color: Color(0xFF7B1FA2)),
                        ),
                        title: Text(t['title'] ?? t['titulo'] ?? 'Tarea',
                          style: const TextStyle(
                              fontWeight: FontWeight.w600)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (t['due_date'] != null)
                              Text('Entrega: ${t['due_date']}'),
                            if (t['description'] != null)
                              Text(t['description'],
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 12)),
                          ],
                        ),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(estado.toUpperCase(),
                            style: TextStyle(
                                color: color,
                                fontSize: 10,
                                fontWeight: FontWeight.bold)),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}