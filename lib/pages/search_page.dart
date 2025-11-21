import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:to_sem_banda/models/search_params.dart';

class SearchPage extends StatefulWidget {
  final ValueNotifier<SearchParams?> searchNotifier;
  final VoidCallback onApply;
  const SearchPage({super.key, required this.searchNotifier, required this.onApply});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _cityController = TextEditingController();
  String? _selectedLevel;
  double _maxDistanceKm = 200.0; // CORREÇÃO 18/11: Distância máxima padrão (valor máximo disponível)
  Set<String> _selectedInstruments = {};
  Set<String> _selectedGenres = {};

  static const List<String> _levelOptions = [
    'Iniciante',
    'Intermediário',
    'Avançado',
    'Profissional',
  ];

  @override
  void dispose() {
    _cityController.dispose();
    super.dispose();
  }

  Future<void> _showMultiSelect(String title, Set<String> options, Set<String> selected, void Function(Set<String>) onSaved) async {
    final temp = {...selected};
    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView(
              shrinkWrap: true,
              children: options.map((o) {
                final sel = temp.contains(o);
                return CheckboxListTile(
                  value: sel,
                  title: Text(o),
                  onChanged: (v) => setState(() => v! ? temp.add(o) : temp.remove(o)),
                );
              }).toList(),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancelar')),
            ElevatedButton(onPressed: () {
              onSaved(temp);
              Navigator.of(context).pop();
            }, child: const Text('Aplicar'))
          ],
        );
      },
    );
  }

  Future<Set<String>> _gatherOptions(String field) async {
    final all = <String>{};
    final snap = await FirebaseFirestore.instance
        .collection('profiles')
        .where(field, isNull: false)
        .limit(500)
        .get();

    for (final doc in snap.docs) {
      final data = doc.data();
      final arr = (data[field] is List) 
          ? (data[field] as List).cast<String>() 
          : <String>[];
      all.addAll(arr);
    }
    return all;
  }

  void _applySearch() {
    final sp = SearchParams(
      city: _cityController.text.trim(),
      level: _selectedLevel,
      instruments: _selectedInstruments,
      genres: _selectedGenres,
      maxDistanceKm: _maxDistanceKm,
    );
    widget.searchNotifier.value = sp;
    // switch to Home tab
    widget.onApply();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buscar'),
        elevation: 0.5,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _cityController,
              decoration: const InputDecoration(labelText: 'Cidade'),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _selectedLevel,
              hint: const Text('Nível'),
              items: _levelOptions.map((l) => DropdownMenuItem(value: l, child: Text(l))).toList(),
              onChanged: (v) => setState(() => _selectedLevel = v),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      final all = await _gatherOptions('instruments');
                      await _showMultiSelect('Instrumentos', all, _selectedInstruments, (s) => setState(() => _selectedInstruments = s));
                    },
                    child: const Text('Instrumentos'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      final all = await _gatherOptions('genres');
                      await _showMultiSelect('Gêneros', all, _selectedGenres, (s) => setState(() => _selectedGenres = s));
                    },
                    child: const Text('Gêneros'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text('Distância máxima: ${_maxDistanceKm.round()} km'),
            Slider(value: _maxDistanceKm, min: 1, max: 200, divisions: 39, label: _maxDistanceKm.round().toString(), onChanged: (v) => setState(() => _maxDistanceKm = v)),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: ElevatedButton(onPressed: _applySearch, child: const Text('Buscar'))),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(child: SingleChildScrollView(child: _buildSummary())),
          ],
        ),
      ),
    );
  }

  Widget _buildSummary() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Resumo da busca:', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Text('Cidade: ${_cityController.text.isEmpty ? '-' : _cityController.text}'),
        Text('Nível: ${_selectedLevel ?? '-'}'),
        Text('Instrumentos: ${_selectedInstruments.isEmpty ? '-' : _selectedInstruments.join(', ')}'),
        Text('Gêneros: ${_selectedGenres.isEmpty ? '-' : _selectedGenres.join(', ')}'),
        Text('Distância máxima: ${_maxDistanceKm.round()} km'),
      ],
    );
  }
}
