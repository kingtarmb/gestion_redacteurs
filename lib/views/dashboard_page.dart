
import 'package:flutter/material.dart';

import '../controllers/redacteur_controller.dart';
import '../models/redacteur.dart';
import '../services/auth_service.dart';
import 'redacteur_form_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final _controller = RedacteurController();
  final _search = TextEditingController();
  List<Redacteur> _items = [];
  bool _loading = true;
  String _filter = 'Tous';

  @override
  void initState() {
    super.initState();
    _search.addListener(_refresh);
    _load();
  }

  @override
  void dispose() {
    _search.removeListener(_refresh);
    _search.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final data = await _controller.getLocal();
    if (!mounted) return;
    setState(() {
      _items = data;
      _loading = false;
    });
  }

  void _refresh() => setState(() {});

  List<Redacteur> get _filtered {
    final q = _search.text.trim().toLowerCase();
    return _items.where((r) {
      final statusOk = _filter == 'Tous' ||
          (_filter == 'Actifs' && r.actif) ||
          (_filter == 'Inactifs' && !r.actif);
      final text = '${r.nom} ${r.prenom} ${r.email} ${r.specialite}'.toLowerCase();
      return statusOk && (q.isEmpty || text.contains(q));
    }).toList();
  }

  Future<void> _add() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const RedacteurFormPage(),
      ),
    );
    await _load();
  }

  Future<void> _edit(Redacteur r) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RedacteurFormPage(redacteur: r),
      ),
    );
    await _load();
  }

  Future<void> _delete(Redacteur r) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer le rédacteur ?'),
        content: Text('Cette action supprimera ${r.nomComplet}.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
    if (ok == true) {
      await _controller.supprimerRedacteur(r.id);
      await _load();
    }
  }

  Future<void> _sync() async {
    try {
      final count = await _controller.synchroniser();
      await _load();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$count rédacteur(s) synchronisé(s).')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Synchronisation impossible : $e')),
      );
    }
  }

  Future<void> _logout() async {
    try {
      await AuthService().signOut();
    } catch (_) {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const DashboardPage()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;
    final active = _items.where((e) => e.actif).length;
    final inactive = _items.length - active;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Magazine Infos'),
        actions: [
          IconButton(
            tooltip: 'Synchroniser',
            onPressed: _sync,
            icon: const Icon(Icons.sync),
          ),
          PopupMenuButton<String>(
            onSelected: (v) {
              if (v == 'logout') _logout();
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'logout', child: Text('Se déconnecter')),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _add,
        icon: const Icon(Icons.add),
        label: const Text('Nouveau rédacteur'),
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'Tableau de bord',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _StatCard(
                  label: 'Total',
                  value: '${_items.length}',
                  icon: Icons.groups_2_outlined,
                ),
                _StatCard(
                  label: 'Actifs',
                  value: '$active',
                  icon: Icons.check_circle_outline,
                ),
                _StatCard(
                  label: 'Inactifs',
                  value: '$inactive',
                  icon: Icons.pause_circle_outline,
                ),
              ],
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _search,
              decoration: InputDecoration(
                hintText: 'Rechercher par nom, e-mail, spécialité...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _search.text.isEmpty
                    ? null
                    : IconButton(
                        onPressed: _search.clear,
                        icon: const Icon(Icons.clear),
                      ),
              ),
            ),
            const SizedBox(height: 12),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'Tous', label: Text('Tous')),
                ButtonSegment(value: 'Actifs', label: Text('Actifs')),
                ButtonSegment(value: 'Inactifs', label: Text('Inactifs')),
              ],
              selected: {_filter},
              onSelectionChanged: (v) => setState(() => _filter = v.first),
            ),
            const SizedBox(height: 14),
            if (_loading)
              const Padding(
                padding: EdgeInsets.all(40),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (filtered.isEmpty)
              const Padding(
                padding: EdgeInsets.all(40),
                child: Center(
                  child: Text(
                    'Aucun rédacteur trouvé.\nAjoutez votre premier rédacteur.',
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            else
              ...filtered.map(
                (r) => Card(
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 8,
                    ),
                    leading: CircleAvatar(
                      child: Text(
                        r.nomComplet.isEmpty
                            ? '?'
                            : r.nomComplet.characters.first.toUpperCase(),
                      ),
                    ),
                    title: Text(
                      r.nomComplet,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text('${r.specialite}\n${r.email}'),
                    isThreeLine: true,
                    trailing: Wrap(
                      children: [
                        IconButton(
                          tooltip: 'Modifier',
                          onPressed: () => _edit(r),
                          icon: const Icon(Icons.edit_outlined),
                        ),
                        IconButton(
                          tooltip: 'Supprimer',
                          onPressed: () => _delete(r),
                          icon: const Icon(Icons.delete_outline),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 160,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 30),
              const SizedBox(height: 10),
              Text(value, style: Theme.of(context).textTheme.headlineMedium),
              Text(label),
            ],
          ),
        ),
      ),
    );
  }
}
