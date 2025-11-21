
import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/profile_provider.dart';
import '../utils/debouncer.dart';
import 'package:path/path.dart' as p;
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';
import '../widgets/app_loading_overlay.dart';

// Sanitização de texto para campos de entrada
String sanitizeText(String input) {
  // Remove espaços extras, limita quebras de linha a uma, remove caracteres perigosos básicos
  var sanitized = input.trim();
  sanitized = sanitized.replaceAll(RegExp(r'\s*\n{2,}\s*'), '\n'); // no máximo uma quebra entre parágrafos
  sanitized = sanitized.replaceAll(RegExp(r'[\u0000-\u001F\u007F]'), ''); // remove chars de controle
  // Adicione mais regras se necessário
  return sanitized;
}

/// Top-level function for image compression in isolate (must be outside class)
Future<String?> _compressImageIsolate(Map<String, dynamic> params) async {
  try {
    final String sourcePath = params['sourcePath'] as String;
    final String targetPath = params['targetPath'] as String;
    final int quality = params['quality'] as int;
    final int minWidth = params['minWidth'] as int;
    final int minHeight = params['minHeight'] as int;
    
    final compressed = await FlutterImageCompress.compressAndGetFile(
      sourcePath,
      targetPath,
      quality: quality,
      minWidth: minWidth,
      minHeight: minHeight,
    );
    
    return compressed?.path;
  } catch (e) {
    debugPrint('Erro na compressão de imagem (isolate): $e');
    return null;
  }
}

/// Tema claro personalizado com paleta de cores definida
class AppThemeData {
  static final Color primaryColor = AppColors.primary;
  static final Color secondaryColor = AppColors.accent;
  static const Color backgroundColor = Color(0xFFFFFFFF); // Branco
  static const Color surfaceColor = Color(0xFFF5F5F5); // Cinza claro
  static const Color textPrimary = Color(0xFF212121); // Texto principal
  static const Color textSecondary = Color(0xFF616161); // Texto secundário
  
  static ThemeData get lightTheme {
    return ThemeData(
      primaryColor: primaryColor,
      scaffoldBackgroundColor: backgroundColor,
      colorScheme: ColorScheme.light(
        primary: primaryColor,
        secondary: secondaryColor,
        surface: surfaceColor,
        background: backgroundColor,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      cardTheme: const CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
        color: backgroundColor,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: surfaceColor,
        deleteIconColor: textSecondary,
        labelStyle: const TextStyle(color: textPrimary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      textTheme: const TextTheme(
        headlineMedium: TextStyle(color: textPrimary, fontWeight: FontWeight.bold, fontSize: 20),
        titleLarge: TextStyle(color: textPrimary, fontWeight: FontWeight.bold, fontSize: 18),
        titleMedium: TextStyle(color: textPrimary, fontWeight: FontWeight.w600, fontSize: 16),
        bodyLarge: TextStyle(color: textPrimary, fontSize: 16),
        bodyMedium: TextStyle(color: textSecondary, fontSize: 14),
      ),
    );
  }
}

class PostPage extends ConsumerStatefulWidget {
  const PostPage({super.key});

  @override
  ConsumerState<PostPage> createState() => _PostPageState();
}

class _PostPageState extends ConsumerState<PostPage> {
  final _formKey = GlobalKey<FormState>();

  // Section 1
  String _postType = 'musician'; // 'musician' = "Tô sem banda", 'band' = "Minha banda tá precisando"

  // Section 2
  // controller removed; instruments handled as multi-select
  // reuse the same instrument & genre options as EditProfile for consistency
  static const List<String> _instrumentOptions = [
    'Violão', 'Guitarra', 'Baixo', 'Contrabaixo', 'Viola', 'Violino', 'Cello',
    'Bateria', 'Percussão', 'Cajón', 'Timbau', 'Congas', 'Bongô',
    'Piano', 'Teclado', 'Órgão', 'Synthesizer', 'Fender Rhodes',
    'Saxofone', 'Flauta', 'Clarinet', 'Trompete', 'Trombone', 'Voz (cantor)',
    'DJ', 'Produção', 'Harmônica', 'Ukulele'
  ];

  static const List<String> _genreOptions = [
    'Rock', 'Pop', 'Jazz', 'Blues', 'Funk', 'Soul', 'R&B', 'Reggae', 'MPB', 'Sertanejo',
    'Forró', 'Axé', 'Hip-Hop', 'Rap', 'Eletrônica', 'House', 'Indie', 'Metal', 'Samba', 'Gospel'
  ];

  late Set<String> _selectedInstruments = {};
  late Set<String> _selectedGenres = {};
  
  // Musicians seeking options (for bands)
  static const List<String> _musicianTypeOptions = [
    'Pianista',
    'Violonista',
    'Violoncelista',
    'Contrabaixista',
    'Harpista',
    'Guitarrista',
    'Baixista elétrico',
    'Baterista',
    'Percussionista',
    'Saxofonista',
    'Trompetista',
    'Trombonista',
    'Flautista',
    'Clarinetista',
    'Oboísta',
    'Fagotista',
    'Tubista',
    'Trompista',
    'Violinista',
    'Violista',
    'Gaitista',
    'Acordeonista',
    'Sanfoneiro',
    'Bandolinista',
    'Banjoísta',
    'Ukulelista',
    'Sitarista',
    'Shamisenista',
    'Kotoísta',
    'Erhuísta',
    'Pipaísta',
    'Guzhenguista',
    'Berimbauísta',
    'Violão de 7 cordas',
    'Viola caipira',
    'Viola de 10 cordas',
    'Cavacoísta',
    'Pandeirista',
    'Tamborimzeira',
    'Cuíquista',
    'Marimbista',
    'Vibrafonista',
    'Xilofonista',
    'Glockenspielista',
    'Timpanista',
    'Zabumbeiro',
    'Alfaiate',
    'Organista',
    'Tecladista',
    'Thereminista',
    'Ondas Martenotista',
    'Outro',
  ];
  
  late Set<String> _seekingMusicians = {};

  // Level options (mirror EditProfilePage)
  static const List<String> _levelOptions = [
    'Iniciante',
    'Intermediário',
    'Avançado',
    'Profissional',
  ];
  static const List<String> _bandLevelOptions = [
    'Em formação',
    'Ativa (ensaios regulares)',
    'Procurando membros',
    'Em turnê',
    'Em hiato',
  ];

  String _level = 'Intermediário'; // default

  // removed legacy style options

  // Section 3
  final _cityController = TextEditingController();
  double _maxDistanceKm = 20;

  // Section 4
  final _messageController = TextEditingController();

  // Section 5 & 6
  String? _photoLocalPath;
  String? _photoUrl;
  final _youtubeController = TextEditingController();

  bool _isSaving = false;

  // helpers
  final ImagePicker _picker = ImagePicker();

  // Multi-select pickers (instrument & genre) copied/adapted from EditProfilePage
  Future<void> _showInstrumentPicker() async {
    final allOptions = List<String>.from(_instrumentOptions);
    for (final s in _selectedInstruments) {
      if (!allOptions.contains(s)) allOptions.add(s);
    }

    final tempSelected = {..._selectedInstruments};
    String search = '';
    final TextEditingController addController = TextEditingController();

    await showDialog<void>(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setStateDialog) {
          final filtered = allOptions.where((e) => e.toLowerCase().contains(search.toLowerCase())).toList()..sort((a,b)=>a.compareTo(b));
          return AlertDialog(
            title: Text('Selecionar instrumentos'),
            content: SizedBox(
              width: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(decoration: const InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'Pesquisar...'), onChanged: (v)=> setStateDialog(()=> search = v)),
                  SizedBox(height: 8),
                  // Selection count indicator
                  Text(
                    '${tempSelected.length}/$maxInstruments selecionados',
                    style: TextStyle(fontSize: 12, color: AppThemeData.textSecondary),
                  ),
                  SizedBox(height: 8),
                  Expanded(
                    child: Scrollbar(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: filtered.length,
                        itemBuilder: (context, idx) {
                          final item = filtered[idx];
                          final selected = tempSelected.contains(item);
                          final canSelect = tempSelected.length < maxInstruments || selected;
                          
                          return CheckboxListTile(
                            value: selected,
                            title: Text(item),
                            enabled: canSelect,
                            onChanged: (v) {
                              if (v! && !selected && tempSelected.length >= maxInstruments) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Máximo de $maxInstruments instrumentos'),
                                    backgroundColor: Colors.red,
                                    duration: const Duration(seconds: 2),
                                  ),
                                );
                                return;
                              }
                              setStateDialog(()=> v ? tempSelected.add(item) : tempSelected.remove(item));
                            },
                          );
                        },
                      ),
                    ),
                  ),
                  SizedBox(height: 8),
                  Row(children: [
                    Expanded(child: TextField(controller: addController, decoration: const InputDecoration(hintText: 'Adicionar instrumento personalizado'))),
                    IconButton(icon: Icon(Icons.add), onPressed: (){
                      final v = addController.text.trim();
                      if (v.isNotEmpty) {
                        if (!allOptions.contains(v)) allOptions.add(v);
                        setStateDialog(() { tempSelected.add(v); addController.clear(); });
                      }
                    })
                  ])
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: ()=> Navigator.of(context).pop(), child: Text('Cancelar')),
              ElevatedButton(onPressed: (){
                setState(()=> _selectedInstruments = tempSelected);
                Navigator.of(context).pop();
              }, child: Text('Salvar')),
            ],
          );
        });
      }
    );
  }

  Future<void> _showGenrePicker() async {
    final allOptions = List<String>.from(_genreOptions);
    for (final s in _selectedGenres) {
      if (!allOptions.contains(s)) allOptions.add(s);
    }

    final tempSelected = {..._selectedGenres};
    String search = '';
    final TextEditingController addController = TextEditingController();

    await showDialog<void>(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setStateDialog) {
          final filtered = allOptions.where((e) => e.toLowerCase().contains(search.toLowerCase())).toList()..sort((a,b)=>a.compareTo(b));
          return AlertDialog(
            title: Text('Selecionar gêneros'),
            content: SizedBox(
              width: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(decoration: const InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'Pesquisar...'), onChanged: (v)=> setStateDialog(()=> search = v)),
                  SizedBox(height: 8),
                  // Selection count indicator
                  Text(
                    '${tempSelected.length}/$maxGenres selecionados',
                    style: TextStyle(fontSize: 12, color: AppThemeData.textSecondary),
                  ),
                  SizedBox(height: 8),
                  Expanded(
                    child: Scrollbar(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: filtered.length,
                        itemBuilder: (context, idx) {
                          final item = filtered[idx];
                          final selected = tempSelected.contains(item);
                          final canSelect = tempSelected.length < maxGenres || selected;
                          
                          return CheckboxListTile(
                            value: selected,
                            title: Text(item),
                            enabled: canSelect,
                            onChanged: (v) {
                              if (v! && !selected && tempSelected.length >= maxGenres) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Máximo de $maxGenres gêneros'),
                                    backgroundColor: Colors.red,
                                    duration: const Duration(seconds: 2),
                                  ),
                                );
                                return;
                              }
                              setStateDialog(()=> v ? tempSelected.add(item) : tempSelected.remove(item));
                            },
                          );
                        },
                      ),
                    ),
                  ),
                  SizedBox(height: 8),
                  Row(children: [
                    Expanded(child: TextField(controller: addController, decoration: const InputDecoration(hintText: 'Adicionar gênero personalizado'))),
                    IconButton(icon: Icon(Icons.add), onPressed: (){
                      final v = addController.text.trim();
                      if (v.isNotEmpty) {
                        if (!allOptions.contains(v)) allOptions.add(v);
                        setStateDialog(() { tempSelected.add(v); addController.clear(); });
                      }
                    })
                  ])
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: ()=> Navigator.of(context).pop(), child: Text('Cancelar')),
              ElevatedButton(onPressed: (){
                setState(()=> _selectedGenres = tempSelected);
                Navigator.of(context).pop();
              }, child: Text('Salvar')),
            ],
          );
        });
      }
    );
  }

  Future<void> _showSeekingMusiciansPicker() async {
    final allOptions = List<String>.from(_musicianTypeOptions);
    for (final s in _seekingMusicians) {
      if (!allOptions.contains(s)) allOptions.add(s);
    }

    final tempSelected = {..._seekingMusicians};
    String search = '';
    final TextEditingController addController = TextEditingController();

    await showDialog<void>(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setStateDialog) {
          final filtered = allOptions.where((e) => e.toLowerCase().contains(search.toLowerCase())).toList()..sort((a,b)=>a.compareTo(b));
          return AlertDialog(
            title: Text('Músicos Procurados'),
            content: SizedBox(
              width: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(decoration: const InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'Pesquisar...'), onChanged: (v)=> setStateDialog(()=> search = v)),
                  SizedBox(height: 8),
                  // Selection count indicator
                  Text(
                    '${tempSelected.length}/$maxSeekingMusicians selecionados',
                    style: TextStyle(fontSize: 12, color: AppThemeData.textSecondary),
                  ),
                  SizedBox(height: 8),
                  Expanded(
                    child: Scrollbar(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: filtered.length,
                        itemBuilder: (context, idx) {
                          final item = filtered[idx];
                          final selected = tempSelected.contains(item);
                          final canSelect = tempSelected.length < maxSeekingMusicians || selected;
                          
                          return CheckboxListTile(
                            value: selected,
                            title: Text(item),
                            enabled: canSelect,
                            onChanged: (v) {
                              if (v! && !selected && tempSelected.length >= maxSeekingMusicians) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Máximo de $maxSeekingMusicians tipos de músicos'),
                                    backgroundColor: Colors.red,
                                    duration: const Duration(seconds: 2),
                                  ),
                                );
                                return;
                              }
                              setStateDialog(()=> v ? tempSelected.add(item) : tempSelected.remove(item));
                            },
                          );
                        },
                      ),
                    ),
                  ),
                  SizedBox(height: 8),
                  Row(children: [
                    Expanded(child: TextField(controller: addController, decoration: const InputDecoration(hintText: 'Adicionar tipo personalizado'))),
                    IconButton(icon: Icon(Icons.add), onPressed: (){
                      final v = addController.text.trim();
                      if (v.isNotEmpty) {
                        if (!allOptions.contains(v)) allOptions.add(v);
                        setStateDialog(() { tempSelected.add(v); addController.clear(); });
                      }
                    })
                  ])
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: ()=> Navigator.of(context).pop(), child: Text('Cancelar')),
              ElevatedButton(onPressed: (){
                setState(()=> _seekingMusicians = tempSelected);
                Navigator.of(context).pop();
              }, child: Text('Salvar')),
            ],
          );
        });
      }
    );
  }

  String? _name;
  String? _profilePhotoUrl;
  /// Helper para extrair ID do vídeo do YouTube de diferentes formatos de URL
  String? _extractYoutubeVideoId(String url) {
    final patterns = [
      RegExp(r'(?:youtube\.com\/watch\?v=|youtu\.be\/)([^&\?\/]+)'),
      RegExp(r'youtube\.com\/embed\/([^&\?\/]+)'),
    ];
    
    for (final pattern in patterns) {
      final match = pattern.firstMatch(url);
      if (match != null && match.groupCount >= 1) {
        return match.group(1);
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppThemeData.lightTheme;

    return Theme(
      data: theme,
      child: AppLoadingOverlay(
        isLoading: _isSaving,
        child: Scaffold(
          backgroundColor: AppThemeData.backgroundColor,
          appBar: AppBar(
            title: Text('Publicar um post'),
            elevation: 0,
          ),
          body: Stack(
            children: [
              SafeArea(
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // Barra de progresso linear no topo
                      if (_isSaving)
                        LinearProgressIndicator(
                          backgroundColor: Color(0xFFE0E0E0),
                          valueColor: AlwaysStoppedAnimation<Color>(AppThemeData.primaryColor),
                        ),
                      // Conteúdo scrollável
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Header com perfil do usuário
                              Card(
                                elevation: 1,
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 32,
                                        backgroundColor: AppThemeData.primaryColor.withValues(alpha: 0.1),
                                        backgroundImage: (_profilePhotoUrl != null && _profilePhotoUrl!.isNotEmpty) 
                                            ? _createImageProvider(_profilePhotoUrl!) 
                                            : null,
                                        child: (_profilePhotoUrl == null || _profilePhotoUrl!.isEmpty) 
                                            ? Icon(Icons.person, size: 32, color: AppThemeData.primaryColor) 
                                            : null,
                                      ),
                                      SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              _name ?? 'Carregando...',
                                              style: theme.textTheme.titleLarge,
                                            ),
                                            SizedBox(height: 4),
                                            Text(
                                              'Criando seu post',
                                              style: theme.textTheme.bodyMedium,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            
                            SizedBox(height: 16),

                            // Card: O que você busca
                            Card(
                              elevation: 2,
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: AppThemeData.secondaryColor.withValues(alpha: 0.1),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Icon(
                                            Icons.search,
                                            color: AppThemeData.secondaryColor,
                                            size: 24,
                                          ),
                                        ),
                                        SizedBox(width: 12),
                                        Text('O que você busca?', style: theme.textTheme.titleLarge),
                                      ],
                                    ),
                                    SizedBox(height: 12),
                                    ListTile(
                                      contentPadding: EdgeInsets.zero,
                                      leading: Radio<String>(
                                        value: 'musician',
                                        groupValue: _seeking,
                                        onChanged: (v) => setState(() => _seeking = (_seeking == v ? null : v)),
                                        activeColor: AppThemeData.primaryColor,
                                      ),
                                      title: Text('Músico'),
                                      subtitle: Text('Procuro um músico para tocar junto'),
                                      onTap: () => setState(() => _seeking = (_seeking == 'musician' ? null : 'musician')),
                                    ),
                                    ListTile(
                                      contentPadding: EdgeInsets.zero,
                                      leading: Radio<String>(
                                        value: 'band',
                                        groupValue: _seeking,
                                        onChanged: (v) => setState(() => _seeking = (_seeking == v ? null : v)),
                                        activeColor: AppThemeData.primaryColor,
                                      ),
                                      title: Text('Banda'),
                                      subtitle: Text('Procuro uma banda para me juntar'),
                                      onTap: () => setState(() => _seeking = (_seeking == 'band' ? null : 'band')),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            SizedBox(height: 16),

                            // Card: Instrumentos (com ícone 🎸)
                            Card(
                              elevation: 2,
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: AppThemeData.primaryColor.withValues(alpha: 0.1),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Text('🎸', style: TextStyle(fontSize: 24)),
                                        ),
                                        SizedBox(width: 12),
                                        Text(
                                          _postType == 'musician' 
                                            ? 'Meus instrumentos' 
                                            : 'Instrumentos que procuramos',
                                          style: theme.textTheme.titleLarge,
                                        ),
                                      ],
                                    ),
                                      SizedBox(height: 12),
                                      AnimatedSwitcher(
                                        duration: const Duration(milliseconds: 300),
                                        child: Wrap(
                                          key: ValueKey(_selectedInstruments.length),
                                          spacing: 8,
                                          runSpacing: 8,
                                          children: [
                                            ..._selectedInstruments.map((i) => Chip(
                                              label: Text(i),
                                              deleteIcon: Icon(Icons.close, size: 18),
                                              onDeleted: () => setState(() => _selectedInstruments.remove(i)),
                                              backgroundColor: AppThemeData.primaryColor.withValues(alpha: 0.1),
                                              labelStyle: TextStyle(color: AppThemeData.primaryColor),
                                            )),
                                            ActionChip(
                                              label: Text('+ Adicionar'),
                                              onPressed: _showInstrumentPicker,
                                              backgroundColor: AppThemeData.surfaceColor,
                                            ),
                                          ],
                                        ),
                                      ),
                                      if (_selectedInstruments.isEmpty)
                                        Padding(
                                          padding: const EdgeInsets.symmetric(vertical: 8),
                                          child: Text(
                                            'Selecione pelo menos um instrumento',
                                            style: theme.textTheme.bodyMedium?.copyWith(
                                              color: Colors.orange.shade700,
                                            ),
                                          ),
                                        ),
                                  ],
                                ),
                              ),
                            ),

                            SizedBox(height: 16),

                            // Card: Gêneros musicais (com ícone 🎵)
                            Card(
                              elevation: 2,
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: AppThemeData.secondaryColor.withValues(alpha: 0.1),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Text('🎵', style: TextStyle(fontSize: 24)),
                                        ),
                                        SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text('Gêneros Musicais', style: theme.textTheme.titleLarge),
                                              Text(
                                                'Máximo 3 gêneros',
                                                style: theme.textTheme.bodyMedium?.copyWith(fontSize: 12),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 12),
                                    AnimatedSwitcher(
                                      duration: const Duration(milliseconds: 300),
                                      child: Wrap(
                                        key: ValueKey(_selectedGenres.length),
                                        spacing: 8,
                                        runSpacing: 8,
                                        children: [
                                          ..._selectedGenres.map((g) => Chip(
                                            label: Text(g),
                                            deleteIcon: Icon(Icons.close, size: 18),
                                            onDeleted: () => setState(() => _selectedGenres.remove(g)),
                                            backgroundColor: AppThemeData.secondaryColor.withValues(alpha: 0.1),
                                            labelStyle: TextStyle(color: AppThemeData.secondaryColor),
                                          )),
                                          if (_selectedGenres.length < 3)
                                            ActionChip(
                                              label: Text('+ Adicionar'),
                                              onPressed: _showGenrePicker,
                                              backgroundColor: AppThemeData.surfaceColor,
                                            ),
                                        ],
                                      ),
                                    ),
                                    // Tooltip animado para validação dinâmica
                                    if (_selectedGenres.length > 3)
                                      AnimatedOpacity(
                                        opacity: 1.0,
                                        duration: const Duration(milliseconds: 300),
                                        child: Container(
                                          margin: const EdgeInsets.only(top: 12),
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: AppColors.warning.withValues(alpha: 0.1),
                                            borderRadius: BorderRadius.circular(8),
                                            border: Border.all(
                                              color: AppColors.warning,
                                              width: 1,
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.warning_amber_rounded,
                                                color: AppColors.warning,
                                                size: 20,
                                              ),
                                              SizedBox(width: 8),
                                              Expanded(
                                                child: Text(
                                                  'Você selecionou ${_selectedGenres.length} gêneros. Remova ${_selectedGenres.length - 3} antes de publicar.',
                                                  style: AppTypography.captionLight.copyWith(
                                                    color: AppColors.warning,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),

                            SizedBox(height: 16),

                            // Músicos procurados (only for bands)
                            if (_postType == 'band')
                              Card(
                                elevation: 2,
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: AppThemeData.primaryColor.withValues(alpha: 0.1),
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Text('👥', style: TextStyle(fontSize: 24)),
                                          ),
                                          SizedBox(width: 12),
                                          Text('Músicos Procurados', style: theme.textTheme.titleLarge),
                                        ],
                                      ),
                                      SizedBox(height: 12),
                                      Wrap(
                                        spacing: 8,
                                        runSpacing: 8,
                                        children: [
                                          ..._seekingMusicians.map((m) => Chip(
                                            label: Text(m),
                                            deleteIcon: Icon(Icons.close, size: 18),
                                            onDeleted: () => setState(() => _seekingMusicians.remove(m)),
                                          )),
                                          ActionChip(
                                            label: Text('+ Adicionar'),
                                            onPressed: _showSeekingMusiciansPicker,
                                            backgroundColor: AppThemeData.surfaceColor,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                            SizedBox(height: 16),

                            // Nível
                            Card(
                              elevation: 2,
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Nível', style: theme.textTheme.titleMedium),
                                    SizedBox(height: 8),
                                    Builder(builder: (context) {
                                      final options = (_seeking == 'band') ? _bandLevelOptions : _levelOptions;
                                      final String? dropdownValue = (options.contains(_level)) ? _level : null;
                                      return DropdownButtonFormField<String>(
                                        initialValue: dropdownValue,
                                        decoration: InputDecoration(
                                          labelText: 'Selecione o nível',
                                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                          filled: true,
                                          fillColor: AppThemeData.surfaceColor,
                                        ),
                                        items: options.map((o) => DropdownMenuItem(value: o, child: Text(o))).toList(),
                                        onChanged: (v) => setState(() => _level = v ?? ''),
                                      );
                                    }),
                                  ],
                                ),
                              ),
                            ),

                            SizedBox(height: 16),

                            // Card: Localização (com ícone 📍)
                            Card(
                              elevation: 2,
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: Colors.red.withValues(alpha: 0.1),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Text('📍', style: TextStyle(fontSize: 24)),
                                        ),
                                        SizedBox(width: 12),
                                        Text('Localização', style: theme.textTheme.titleLarge),
                                      ],
                                    ),
                                    SizedBox(height: 12),
                                    Material(
                                      elevation: 1,
                                      borderRadius: BorderRadius.circular(12),
                                      child: TextField(
                                        controller: _locationSearchController,
                                        decoration: InputDecoration(
                                          hintText: 'Buscar endereço do ensaio/vaga...',
                                          hintStyle: TextStyle(color: AppThemeData.textSecondary.withValues(alpha: 0.6)),
                                          prefixIcon: Icon(Icons.search, color: AppThemeData.primaryColor),
                          suffixIcon: _isSearchingLocation
                              ? Padding(
                                  padding: EdgeInsets.all(12.0),
                                  child: SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(AppThemeData.primaryColor),
                                    ),
                                  ),
                                )
                              : _locationSearchController.text.isNotEmpty
                                  ? IconButton(
                                      icon: Icon(Icons.clear),
                                      color: AppThemeData.textSecondary,
                                      onPressed: () {
                                        setState(() {
                                          _locationSearchController.clear();
                                          _locationSuggestions = [];
                                          _showLocationSuggestions = false;
                                          _selectedLocation = null;
                                          _cityController.clear();
                                          _fetchedCity = null;
                                          _fetchedState = null;
                                          _locationValidated = false;
                                        });
                                      },
                                    )
                                  : _locationValidated
                                      ? Icon(Icons.check_circle, color: Colors.green)
                                      : null,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: AppThemeData.surfaceColor,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        ),
                        onChanged: (value) {
                          setState(() {
                            _selectedLocation = null;
                            _locationValidated = false;
                            _showLocationSuggestions = value.length >= 3;
                          });
                          
                          // Debounce search with reusable Debouncer utility
                          if (value.length >= 3) {
                            _searchDebounce.run(() async {
                              setState(() => _isSearchingLocation = true);
                              
                              try {
                                final query = Uri.encodeComponent('$value, Brasil');
                                final uri = Uri.parse('https://nominatim.openstreetmap.org/search?q=$query&format=json&limit=5&addressdetails=1');
                                final response = await http.get(uri, headers: {'User-Agent': 'to_sem_banda_app'});
                                
                                if (response.statusCode == 200) {
                                  final data = json.decode(response.body);
                                  if (data is List) {
                                    setState(() {
                                      _locationSuggestions = data.map((item) {
                                        return {
                                          'display_name': item['display_name'].toString(),
                                          'lat': double.tryParse(item['lat'].toString()) ?? 0.0,
                                          'lon': double.tryParse(item['lon'].toString()) ?? 0.0,
                                          'city': item['address']?['city'] ?? item['address']?['town'] ?? item['address']?['village'] ?? '',
                                          'neighbourhood': item['address']?['neighbourhood'] ?? item['address']?['suburb'] ?? '',
                                          'state': item['address']?['state'] ?? '',
                                        };
                                      }).toList();
                                    });
                                  }
                                }
                              } catch (e) {
                                debugPrint('Erro ao buscar localização: $e');
                              } finally {
                                if (mounted) setState(() => _isSearchingLocation = false);
                              }
                            });
                          } else {
                            setState(() {
                              _locationSuggestions = [];
                              _showLocationSuggestions = false;
                            });
                          }
                        },
                      ),
                    ),
                    
                    // Location validation feedback
                    if (_locationValidated)
                      Padding(
                        padding: const EdgeInsets.only(top: 8, left: 4),
                        child: Row(
                          children: [
                            Icon(Icons.check_circle, color: Colors.green, size: 16),
                            SizedBox(width: 6),
                            Text(
                              'Localização validada: ${_fetchedCity ?? ""}',
                              style: const TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ),
                    if (!_locationValidated && _locationSearchController.text.length >= 3 && !_isSearchingLocation && _locationSuggestions.isEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 8, left: 4),
                        child: Row(
                          children: [
                            Icon(Icons.info_outline, color: Colors.orange, size: 16),
                            SizedBox(width: 6),
                            Text(
                              'Nenhum resultado encontrado. Tente outro endereço.',
                              style: TextStyle(color: Colors.orange, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    
                                    // Location suggestions
                                    if (_showLocationSuggestions && _locationSuggestions.isNotEmpty)
                                      Container(
                                        margin: const EdgeInsets.only(top: 12),
                                        constraints: const BoxConstraints(maxHeight: 200),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(color: AppThemeData.primaryColor.withValues(alpha: 0.3)),
                                          boxShadow: [
                                            BoxShadow(
                                              color: AppThemeData.primaryColor.withValues(alpha: 0.1),
                                              blurRadius: 8,
                                              offset: const Offset(0, 4),
                                            ),
                                          ],
                                        ),
                                        child: ListView.separated(
                                          shrinkWrap: true,
                                          padding: const EdgeInsets.symmetric(vertical: 8),
                                          itemCount: _locationSuggestions.length,
                                          separatorBuilder: (context, index) => Divider(height: 1),
                                          itemBuilder: (context, index) {
                                            final suggestion = _locationSuggestions[index];
                                            return ListTile(
                                              leading: Icon(Icons.location_on, color: AppThemeData.primaryColor),
                                              title: Text(
                                                suggestion['display_name'],
                                                style: const TextStyle(fontSize: 14, color: AppThemeData.textPrimary),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                              onTap: () {
                                final lat = suggestion['lat'];
                                final lon = suggestion['lon'];
                                final city = suggestion['city'];
                                final state = suggestion['state'];
                                
                                setState(() {
                                  _locationSearchController.text = suggestion['display_name'];
                                  _selectedLocation = LatLng(lat, lon);
                                  _showLocationSuggestions = false;
                                  _locationSuggestions = [];
                                  _cityController.text = city;
                                  _fetchedCity = city;
                                  _fetchedState = state;
                                  _locationValidated = true;
                                });
                                
                                debugPrint('PostPage: localização selecionada: $city, lat=$lat, lng=$lon');
                                              },
                                            );
                                          },
                                        ),
                                      ),
                                    
                                    // Validated location display
                                    if (_locationValidated)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 12.0),
                                        child: Container(
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: Colors.green.shade50,
                                            borderRadius: BorderRadius.circular(8),
                                            border: Border.all(color: Colors.green.shade300),
                                          ),
                                          child: Row(
                                            children: [
                                              Icon(Icons.check_circle, color: Colors.green.shade700, size: 20),
                                              SizedBox(width: 8),
                                              Expanded(
                                                child: Text(
                                                  '${_fetchedCity ?? ''} - ${_fetchedState ?? ''}',
                                                  style: TextStyle(fontSize: 13, color: Colors.green.shade900, fontWeight: FontWeight.w600),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    
                                    // Warning when location not selected
                                    if (!_locationValidated && _locationSearchController.text.isEmpty)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 12.0),
                                        child: Container(
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: Colors.orange.shade50,
                                            borderRadius: BorderRadius.circular(8),
                                            border: Border.all(color: Colors.orange.shade300),
                                          ),
                                          child: Row(
                                            children: [
                                              Icon(Icons.info_outline, color: Colors.orange.shade700, size: 20),
                                              SizedBox(width: 8),
                                              Expanded(
                                                child: Text(
                                                  'Digite o endereço do ensaio/vaga e selecione uma opção da lista',
                                                  style: TextStyle(fontSize: 12, color: Colors.orange.shade900),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    
                                    SizedBox(height: 16),
                                    
                                    // Slider de distância
                                    Text(
                                      'Ensaios em até ${_maxDistanceKm.toInt()} km desta localização',
                                      style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                                    ),
                                    SliderTheme(
                                      data: SliderThemeData(
                                        activeTrackColor: AppThemeData.primaryColor,
                                        inactiveTrackColor: AppThemeData.primaryColor.withValues(alpha: 0.2),
                                        thumbColor: AppThemeData.primaryColor,
                                        overlayColor: AppThemeData.primaryColor.withValues(alpha: 0.2),
                                        valueIndicatorColor: AppThemeData.primaryColor,
                                      ),
                                      child: Slider(
                                        min: 5,
                                        max: 80,
                                        divisions: 15,
                                        value: _maxDistanceKm,
                                        label: '${_maxDistanceKm.toInt()} km',
                                        onChanged: (v) => setState(() => _maxDistanceKm = v),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            SizedBox(height: 16),

                            // Card: Mensagem
                            Card(
                              elevation: 2,
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: AppThemeData.secondaryColor.withValues(alpha: 0.1),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Icon(Icons.message, color: AppThemeData.secondaryColor, size: 24),
                                        ),
                                        SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text('Mensagem', style: theme.textTheme.titleLarge),
                                              Text('Máximo 240 caracteres', style: theme.textTheme.bodyMedium?.copyWith(fontSize: 12)),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 12),
                                    TextFormField(
                                      controller: _messageController,
                                      maxLength: 240,
                                      minLines: 3,
                                      maxLines: 6,
                                      style: TextStyle(color: AppThemeData.textPrimary),
                                      decoration: InputDecoration(
                                        hintText: 'Escreva uma mensagem curta sobre a vaga/procura...',
                                        hintStyle: TextStyle(color: AppThemeData.textSecondary.withValues(alpha: 0.6)),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(8),
                                          borderSide: const BorderSide(color: AppThemeData.surfaceColor),
                                        ),
                                        filled: true,
                                        fillColor: AppThemeData.surfaceColor,
                                      ),
                                      validator: (v) => (v == null || v.trim().isEmpty) ? 'Escreva uma mensagem' : null,
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            SizedBox(height: 16),

                            // Card: Foto
                            Card(
                              elevation: 2,
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: AppThemeData.primaryColor.withValues(alpha: 0.1),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Icon(Icons.photo_camera, color: AppThemeData.primaryColor, size: 24),
                                        ),
                                        SizedBox(width: 12),
                                        Text('Foto (opcional)', style: theme.textTheme.titleLarge),
                                      ],
                                    ),
                                    SizedBox(height: 12),
                                    GestureDetector(
                                      onTap: _pickPhoto,
                                      child: Container(
                                        width: double.infinity,
                                        height: 180,
                                        decoration: BoxDecoration(
                                          color: AppThemeData.surfaceColor,
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(color: AppThemeData.primaryColor.withValues(alpha: 0.3), width: 2),
                                        ),
                                        child: _photoLocalPath != null 
                                          ? ClipRRect(
                                              borderRadius: BorderRadius.circular(10),
                                              child: Image.file(File(_photoLocalPath!), fit: BoxFit.cover),
                                            )
                                          : Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Icon(Icons.add_a_photo, size: 48, color: AppThemeData.textSecondary.withValues(alpha: 0.5)),
                                                SizedBox(height: 8),
                                                Text('Toque para adicionar foto', style: theme.textTheme.bodyMedium),
                                              ],
                                            ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            SizedBox(height: 16),

                            // Card: YouTube com pré-visualização
                            Card(
                              elevation: 2,
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: Colors.red.withValues(alpha: 0.1),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Icon(Icons.play_circle_fill, color: Colors.red, size: 24),
                                        ),
                                        SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text('YouTube', style: theme.textTheme.titleLarge),
                                              Text('Adicione um vídeo (opcional)', style: theme.textTheme.bodyMedium?.copyWith(fontSize: 12)),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 12),
                                    TextFormField(
                                      controller: _youtubeController,
                                      style: TextStyle(color: AppThemeData.textPrimary),
                                      decoration: InputDecoration(
                                        hintText: 'https://youtu.be/...',
                                        hintStyle: TextStyle(color: AppThemeData.textSecondary.withValues(alpha: 0.6)),
                                        prefixIcon: Icon(Icons.link, color: AppThemeData.primaryColor),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        filled: true,
                                        fillColor: AppThemeData.surfaceColor,
                                      ),
                                      onChanged: (_) => setState(() {}),
                                    ),
                                    // Pré-visualização do thumbnail do YouTube
                                    if (_youtubeController.text.isNotEmpty)
                                      Builder(
                                        builder: (context) {
                                          final videoId = _extractYoutubeVideoId(_youtubeController.text);
                                          if (videoId != null) {
                                            return Padding(
                                              padding: const EdgeInsets.only(top: 12),
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.circular(8),
                                                  border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                                                ),
                                                child: ClipRRect(
                                                  borderRadius: BorderRadius.circular(8),
                                                  child: Stack(
                                                    alignment: Alignment.center,
                                                    children: [
                                                      CachedNetworkImage(
                                                        imageUrl: 'https://img.youtube.com/vi/$videoId/hqdefault.jpg',
                                                        width: double.infinity,
                                                        height: 150,
                                                        fit: BoxFit.cover,
                                                        memCacheWidth: 640,
                                                        memCacheHeight: 360,
                                                        placeholder: (context, url) => Container(
                                                          height: 150,
                                                          color: AppThemeData.surfaceColor,
                                                          child: const Center(child: CircularProgressIndicator()),
                                                        ),
                                                        errorWidget: (context, url, error) => Container(
                                                          height: 150,
                                                          color: AppThemeData.surfaceColor,
                                                          child: const Center(
                                                            child: Icon(Icons.error_outline, color: Colors.red, size: 48),
                                                          ),
                                                        ),
                                                      ),
                                                      Container(
                                                        padding: const EdgeInsets.all(12),
                                                        decoration: BoxDecoration(
                                                          color: Colors.black.withValues(alpha: 0.6),
                                                          shape: BoxShape.circle,
                                                        ),
                                                        child: Icon(Icons.play_arrow, color: Colors.white, size: 40),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            );
                                          }
                                          return const SizedBox.shrink();
                                        },
                                      ),
                                  ],
                                ),
                              ),
                            ),

                            // Espaço extra para o botão fixo não sobrepor conteúdo
                            SizedBox(height: 100),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Botão fixo no rodapé
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(16),
                child: SafeArea(
                  top: false,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ElevatedButton.icon(
                        onPressed: _isSaving ? null : _publish,
                        icon: _isSaving
                            ? SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : Icon(Icons.send_rounded),
                        label: Text(_isSaving ? 'PUBLICANDO...' : 'PUBLICAR AGORA'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.5),
                          minimumSize: const Size(double.infinity, 56),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 8,
                          shadowColor: AppColors.primary.withValues(alpha: 0.4),
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Sua vaga fica no ar por 30 dias e você recebe notificações',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(fontSize: 12),
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
