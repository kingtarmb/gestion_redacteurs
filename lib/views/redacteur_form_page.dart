import 'package:flutter/material.dart';

import '../controllers/redacteur_controller.dart';
import '../models/redacteur.dart';

class RedacteurFormPage extends StatefulWidget {
  const RedacteurFormPage({super.key, this.redacteur});

  final Redacteur? redacteur;

  @override
  State<RedacteurFormPage> createState() => _RedacteurFormPageState();
}

class _RedacteurFormPageState extends State<RedacteurFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nom = TextEditingController();
  final _prenom = TextEditingController();
  final _email = TextEditingController();
  final _specialite = TextEditingController();
  final _telephone = TextEditingController();
  final _controller = RedacteurController();
  bool _actif = true;
  bool _saving = false;

  bool get isEdit => widget.redacteur != null;

  @override
  void initState() {
    super.initState();
    final r = widget.redacteur;
    if (r != null) {
      _nom.text = r.nom;
      _prenom.text = r.prenom;
      _email.text = r.email;
      _specialite.text = r.specialite;
      _telephone.text = r.telephone;
      _actif = r.actif;
    }
  }

  @override
  void dispose() {
    _nom.dispose();
    _prenom.dispose();
    _email.dispose();
    _specialite.dispose();
    _telephone.dispose();
    super.dispose();
  }

  String? _required(String? v) =>
      v == null || v.trim().isEmpty ? 'Champ obligatoire' : null;

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      if (isEdit) {
        await _controller.modifierRedacteur(
          widget.redacteur!.copyWith(
            nom: _nom.text,
            prenom: _prenom.text,
            email: _email.text,
            specialite: _specialite.text,
            telephone: _telephone.text,
            actif: _actif,
          ),
        );
      } else {
        await _controller.ajouterRedacteur(
          nom: _nom.text,
          prenom: _prenom.text,
          email: _email.text,
          specialite: _specialite.text,
          telephone: _telephone.text,
        );
      }
      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Enregistrement impossible : $e')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Modifier le rédacteur' : 'Ajouter un rédacteur'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              isEdit ? 'Informations du rédacteur' : 'Nouveau rédacteur',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _prenom,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Prénom',
                prefixIcon: Icon(Icons.person_outline),
              ),
              validator: _required,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _nom,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Nom',
                prefixIcon: Icon(Icons.badge_outlined),
              ),
              validator: _required,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'E-mail',
                prefixIcon: Icon(Icons.email_outlined),
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Champ obligatoire';
                if (!v.contains('@')) return 'E-mail invalide';
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _telephone,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Téléphone',
                prefixIcon: Icon(Icons.phone_outlined),
              ),
              validator: _required,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _specialite,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Spécialité',
                prefixIcon: Icon(Icons.article_outlined),
                hintText: 'Ex. Politique, Économie, Sport...',
              ),
              validator: _required,
            ),
            const SizedBox(height: 12),
            SwitchListTile.adaptive(
              value: _actif,
              onChanged: (v) => setState(() => _actif = v),
              title: const Text('Rédacteur actif'),
              subtitle: const Text('Visible comme membre actif de l’équipe'),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 52,
              child: FilledButton.icon(
                onPressed: _saving ? null : _save,
                icon: _saving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save_outlined),
                label: Text(isEdit ? 'Enregistrer les modifications' : 'Ajouter'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
