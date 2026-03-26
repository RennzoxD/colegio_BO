import 'package:flutter/material.dart';
import '../../services/admin_service.dart';

class SectionsScreen extends StatefulWidget {
  const SectionsScreen({super.key});

  @override
  State<SectionsScreen> createState() => _SectionsScreenState();
}

class _SectionsScreenState extends State<SectionsScreen> {
  final _service = AdminService();
  List _sections = [];
  List _courses  = [];
  bool _loading  = true;
  String? _nivelFiltro;
  int _year = DateTime.now().year;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final res = await _service.getSections(
        year: _year, nivel: _nivelFiltro);
    final courses = await _service.getCourses();
    setState(() {
      _loading  = false;
      _sections = res['success'] ? res['sections'] : [];
      _courses  = courses;
    });
  }

  Color _nivelColor(String? nivel) => switch (nivel) {
    'inicial'    => Colors.orange,
    'primaria'   => Colors.blue,
    'secundaria' => Colors.green,
    _            => Colors.grey,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Secciones'),
        backgroundColor: const Color(0xFFF57C00),
        foregroundColor: Colors.white,
        actions: [
          PopupMenuButton<int>(
            icon: const Icon(Icons.calendar_today),
            onSelected: (y) { setState(() => _year = y); _load(); },
            itemBuilder: (_) => [2024, 2025, 2026].map((y) =>
                PopupMenuItem(value: y, child: Text('$y'))).toList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateDialog(context),
        backgroundColor: const Color(0xFFF57C00),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Column(
        children: [
          // Filtro nivel
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                const Text('Nivel: ',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(width: 8),
                DropdownButton<String?>(
                  value: _nivelFiltro,
                  hint: const Text('Todos'),
                  items: const [
                    DropdownMenuItem(value: null,
                        child: Text('Todos')),
                    DropdownMenuItem(value: 'inicial',
                        child: Text('Inicial')),
                    DropdownMenuItem(value: 'primaria',
                        child: Text('Primaria')),
                    DropdownMenuItem(value: 'secundaria',
                        child: Text('Secundaria')),
                  ],
                  onChanged: (v) {
                    setState(() => _nivelFiltro = v);
                    _load();
                  },
                ),
                const Spacer(),
                Text('Año: $_year',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          // Stats
          if (!_loading)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  _StatChip(
                      '${_sections.length}', 'Secciones',
                      const Color(0xFFF57C00)),
                  const SizedBox(width: 8),
                  _StatChip(
                    '${_sections.fold(0, (s, sec) => s + (sec['estudiantes_count'] ?? 0) as int)}',
                    'Estudiantes', Colors.blue),
                ],
              ),
            ),
          const SizedBox(height: 8),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _sections.isEmpty
                    ? const Center(
                        child: Text('No hay secciones'))
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12),
                        itemCount: _sections.length,
                        itemBuilder: (ctx, i) {
                          final s = _sections[i];
                          final nivel = s['nivel'] ?? '';
                          final color = _nivelColor(nivel);
                          final course = s['course'];
                          final courseName =
                              course?['nombre'] ?? s['curso'] ?? '';
                          final paralelo = s['paralelo'] ?? '';
                          final alumnos =
                              s['estudiantes_count'] ?? 0;
                          final turno = s['turno'] ?? '';
                          final estado = s['estado'] ?? 'ACTIVA';

                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(12)),
                            child: InkWell(
                              borderRadius:
                                  BorderRadius.circular(12),
                              onTap: () => _showDetail(
                                  context, s),
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      backgroundColor:
                                          color.withOpacity(0.15),
                                      child: Text(
                                        paralelo.isNotEmpty
                                            ? paralelo[0]
                                                .toUpperCase()
                                            : 'S',
                                        style: TextStyle(
                                            color: color,
                                            fontWeight:
                                                FontWeight.bold),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment
                                                .start,
                                        children: [
                                          Text(
                                            '$courseName $paralelo',
                                            style: const TextStyle(
                                                fontWeight:
                                                    FontWeight.bold,
                                                fontSize: 15)),
                                          Text(
                                            '${nivel.toUpperCase()} • $turno',
                                            style: TextStyle(
                                                color: Colors
                                                    .grey[600],
                                                fontSize: 12)),
                                        ],
                                      ),
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Text('$alumnos alumnos',
                                          style: const TextStyle(
                                              fontWeight:
                                                  FontWeight.bold)),
                                        Container(
                                          padding: const EdgeInsets
                                              .symmetric(
                                              horizontal: 6,
                                              vertical: 2),
                                          decoration: BoxDecoration(
                                            color: estado == 'ACTIVA'
                                                ? Colors.green[50]
                                                : Colors.grey[100],
                                            borderRadius:
                                                BorderRadius
                                                    .circular(6),
                                          ),
                                          child: Text(estado,
                                            style: TextStyle(
                                                fontSize: 11,
                                                color: estado ==
                                                        'ACTIVA'
                                                    ? Colors.green
                                                    : Colors.grey,
                                                fontWeight:
                                                    FontWeight
                                                        .bold)),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  void _showDetail(BuildContext context,
      Map<String, dynamic> section) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => _SectionDetailSheet(
          section: section, service: _service),
    );
  }

  void _showCreateDialog(BuildContext context) {
    if (_courses.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('No hay cursos disponibles')));
      return;
    }

    Map<String, dynamic>? selectedCourse;
    final paralelo = TextEditingController();
    final aula     = TextEditingController();
    String turno   = 'Mañana';
    String estado  = 'ACTIVA';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSt) => AlertDialog(
          title: const Text('Nueva Sección'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<Map<String, dynamic>>(
                  decoration: const InputDecoration(
                      labelText: 'Curso *'),
                  items: _courses.map((c) =>
                    DropdownMenuItem<Map<String, dynamic>>(
                      value: Map<String, dynamic>.from(c),
                      child: Text(
                          '${c['nombre'] ?? ''} (${c['nivel'] ?? ''})'),
                    )).toList(),
                  onChanged: (v) =>
                      setSt(() => selectedCourse = v),
                ),
                TextField(controller: paralelo,
                  decoration: const InputDecoration(
                      labelText: 'Paralelo * (A, B, C...)')),
                TextField(controller: aula,
                  decoration: const InputDecoration(
                      labelText: 'Aula')),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: turno,
                  decoration: const InputDecoration(
                      labelText: 'Turno'),
                  items: const [
                    DropdownMenuItem(
                        value: 'Mañana', child: Text('Mañana')),
                    DropdownMenuItem(
                        value: 'Tarde', child: Text('Tarde')),
                    DropdownMenuItem(
                        value: 'Noche', child: Text('Noche')),
                  ],
                  onChanged: (v) => setSt(() => turno = v!),
                ),
                DropdownButtonFormField<String>(
                  value: estado,
                  decoration: const InputDecoration(
                      labelText: 'Estado'),
                  items: const [
                    DropdownMenuItem(
                        value: 'ACTIVA', child: Text('Activa')),
                    DropdownMenuItem(
                        value: 'CERRADA', child: Text('Cerrada')),
                  ],
                  onChanged: (v) => setSt(() => estado = v!),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancelar')),
            ElevatedButton(
              onPressed: () async {
                if (selectedCourse == null ||
                    paralelo.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Completa curso y paralelo')));
                  return;
                }
                final result = await _service.createSection({
                  'year':      _year,
                  'course_id': selectedCourse!['id'],
                  'paralelo':  paralelo.text.trim().toUpperCase(),
                  'turno':     turno,
                  'aula':      aula.text.trim(),
                  'estado':    estado,
                });
                if (result['success'] && ctx.mounted) {
                  Navigator.pop(ctx);
                  _load();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('✅ Sección creada'),
                        backgroundColor: Colors.green));
                } else if (ctx.mounted) {
                  ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
                      content:
                          Text(result['message'] ?? 'Error'),
                      backgroundColor: Colors.red));
                }
              },
              child: const Text('Crear')),
          ],
        ),
      ),
    );
  }
}

class _SectionDetailSheet extends StatefulWidget {
  final Map<String, dynamic> section;
  final AdminService service;
  const _SectionDetailSheet(
      {required this.section, required this.service});

  @override
  State<_SectionDetailSheet> createState() =>
      _SectionDetailSheetState();
}

class _SectionDetailSheetState
    extends State<_SectionDetailSheet> {
  List _students = [];
  bool _loading  = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final data = await widget.service
        .getSectionStudents(widget.section['id']);
    setState(() { _students = data; _loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.section;
    final course = s['course'];
    final title =
        '${course?['nombre'] ?? s['curso'] ?? ''} ${s['paralelo'] ?? ''}';

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      maxChildSize: 0.95,
      minChildSize: 0.4,
      expand: false,
      builder: (_, ctrl) => Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Color(0xFFF57C00),
              borderRadius: BorderRadius.vertical(
                  top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                const Icon(Icons.class_,
                    color: Colors.white),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(title,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16)),
                ),
                Text(
                  '${s['estudiantes_count'] ?? 0} alumnos',
                  style: const TextStyle(
                      color: Colors.white70)),
              ],
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(
                    child: CircularProgressIndicator())
                : _students.isEmpty
                    ? const Center(
                        child: Text(
                            'No hay estudiantes inscritos'))
                    : ListView.builder(
                        controller: ctrl,
                        itemCount: _students.length,
                        itemBuilder: (ctx, i) {
                          final st = _students[i];
                          final nombre =
                              '${st['nombres'] ?? ''} ${st['apellidos'] ?? ''}'
                                  .trim();
                          return ListTile(
                            leading: CircleAvatar(
                              child: Text(
                                nombre.isNotEmpty
                                    ? nombre[0].toUpperCase()
                                    : '?'),
                            ),
                            title: Text(nombre,
                              style: const TextStyle(
                                  fontWeight:
                                      FontWeight.w600)),
                            subtitle: Text(
                                st['codigo'] ?? ''),
                            trailing: Text(
                              st['estado_matricula'] ?? '',
                              style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey[600])),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String value;
  final String label;
  final Color color;
  const _StatChip(this.value, this.label, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Text(value,
            style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 16)),
          const SizedBox(width: 4),
          Text(label,
            style:
                TextStyle(color: color, fontSize: 12)),
        ],
      ),
    );
  }
}