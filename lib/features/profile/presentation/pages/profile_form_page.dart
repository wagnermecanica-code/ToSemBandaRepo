
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import '../../domain/entities/profile_entity.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/profile_providers.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import '../../domain/repositories/profile_repository.dart';
import '../../../../widgets/app_loading_overlay.dart';



// Sanitização de texto para campos de entrada
String sanitizeText(String input) {
  var sanitized = input.trim();
  sanitized = sanitized.replaceAll(RegExp(r'\s*\n{2,}\s*'), '\n');
  sanitized = sanitized.replaceAll(RegExp(r'[\u0000-\u001F\u007F]'), '');
  return sanitized;
}

/// Página para adicionar ou editar um perfil
/// Nova arquitetura: salva em profiles/{profileId}
class ProfileFormPage extends ConsumerStatefulWidget {
  final Profile? profile; // null = criar novo, preenchido = editar

  const ProfileFormPage({super.key, this.profile});

  @override
  ConsumerState<ProfileFormPage> createState() => _ProfileFormPageState();
}

class _ProfileFormPageState extends ConsumerState<ProfileFormPage> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late AnimationController _animationController;

  late TextEditingController _nameController;
  late TextEditingController _bioController;
  late TextEditingController _youtubeController;
  late TextEditingController _cityController;
  late TextEditingController _ageController;
  late TextEditingController _levelController;
  
  bool _isBand = false;
  Set<String> _selectedInstruments = {};
  Set<String> _selectedGenres = {};
  bool _isSaving = false;
  bool _isFetchingLocation = false;
  double? _latitude;
  double? _longitude;
  
  // Foto de perfil
  File? _selectedImage;
  String? _existingPhotoUrl;
  bool _isUploadingPhoto = false;

  static const List<String> _instrumentOptions = [
    'Violão', 'Guitarra', 'Baixo', 'Bateria', 'Teclado', 'Piano',
    'Saxofone', 'Flauta', 'Trompete', 'Voz (cantor)', 'DJ', 'Percussão',
  ];

  static const List<String> _genreOptions = [
    'Rock', 'Pop', 'Jazz', 'Blues', 'Funk', 'Soul', 'MPB', 'Sertanejo',
    'Forró', 'Hip-Hop', 'Eletrônica', 'Metal', 'Indie', 'Gospel',
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.profile?.name);
    _bioController = TextEditingController(text: widget.profile?.bio);
    _youtubeController = TextEditingController(text: widget.profile?.youtubeLink);
    _cityController = TextEditingController(text: widget.profile?.city);
    _ageController = TextEditingController(text: widget.profile?.age?.toString());
    _levelController = TextEditingController(text: widget.profile?.level);
    _isBand = widget.profile?.isBand ?? false;
    _selectedInstruments = widget.profile?.instruments.toSet() ?? {};
    _selectedGenres = widget.profile?.genres.toSet() ?? {};
    _latitude = widget.profile?.latitude;
    _longitude = widget.profile?.longitude;
    _existingPhotoUrl = widget.profile?.photoUrl;
    
    // Buscar localização se estiver criando novo perfil
    if (widget.profile == null) {
      _fetchLocation();
    }
    // Exemplo de uso do perfil ativo com Riverpod
    // final profileState = ref.read(profileProvider);
    // final activeProfile = profileState.value?.activeProfile;
    
    // Animação para entrada suave
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    )..forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _nameController.dispose();
    _bioController.dispose();
    _youtubeController.dispose();
    _cityController.dispose();
    _ageController.dispose();
    _levelController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      
      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(child: Text('Erro ao selecionar imagem: $e')),
              ],
            ),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<String?> _uploadPhoto() async {
    if (_selectedImage == null) {
      return _existingPhotoUrl; // Mantém foto existente
    }

    setState(() => _isUploadingPhoto = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return null;

      // Comprimir imagem
      final compressedBytes = await FlutterImageCompress.compressWithFile(
        _selectedImage!.path,
        minWidth: 800,
        minHeight: 800,
        quality: 85,
      );

      if (compressedBytes == null) {
        throw Exception('Erro ao comprimir imagem');
      }

      // Upload para Firebase Storage
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('profile_photos')
          .child('${user.uid}_${DateTime.now().millisecondsSinceEpoch}.jpg');

      await storageRef.putData(compressedBytes);
      final downloadUrl = await storageRef.getDownloadURL();

      // Deletar foto antiga se existir e for diferente
      if (_existingPhotoUrl != null && _existingPhotoUrl!.isNotEmpty) {
        try {
          final oldRef = FirebaseStorage.instance.refFromURL(_existingPhotoUrl!);
          await oldRef.delete();
        } catch (e) {
        }
      }

      return downloadUrl;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(child: Text('Erro ao fazer upload da foto: $e')),
              ],
            ),
            backgroundColor: AppColors.error,
          ),
        );
      }
      return null;
    } finally {
      if (mounted) setState(() => _isUploadingPhoto = false);
    }
  }

  String? _validateYouTubeUrl(String? url) {
    if (url == null || url.trim().isEmpty) return null; // Opcional
    
    final trimmed = url.trim();
    final youtubePattern = RegExp(
      r'^(https?://)?(www\.)?(youtube\.com/watch\?v=|youtu\.be/)[a-zA-Z0-9_-]{11}',
    );
    
    if (!youtubePattern.hasMatch(trimmed)) {
      return 'URL inválida. Use formato: youtu.be/ID ou youtube.com/watch?v=ID';
    }
    return null;
  }

  Future<void> _fetchLocation() async {
    setState(() => _isFetchingLocation = true);
    
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Serviço de localização desabilitado');
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Permissão de localização negada');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Permissão de localização negada permanentemente');
      }

      final position = await Geolocator.getCurrentPosition();
      if (mounted) {
        setState(() {
          _latitude = position.latitude;
          _longitude = position.longitude;
        });
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                const Text('Localização obtida com sucesso!'),
              ],
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao buscar localização: $e'),
            backgroundColor: AppColors.error,
            action: SnackBarAction(
              label: 'Tentar novamente',
              textColor: Colors.white,
              onPressed: _fetchLocation,
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isFetchingLocation = false);
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    // Validar campos obrigatórios
    if (_cityController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error, color: Colors.white),
              const SizedBox(width: 12),
              const Text('Cidade é obrigatória'),
            ],
          ),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (_latitude == null || _longitude == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Localização não encontrada. Tente novamente.'),
          backgroundColor: AppColors.error,
          action: SnackBarAction(
            label: 'Buscar',
            textColor: Colors.white,
            onPressed: _fetchLocation,
          ),
        ),
      );
      return;
    }

    // Validar instrumentos (obrigatório para músicos)
    if (!_isBand && _selectedInstruments.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error, color: Colors.white),
              const SizedBox(width: 12),
              const Text('Músicos devem selecionar ao menos 1 instrumento'),
            ],
          ),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    // Validar idade mínima
    if (_ageController.text.trim().isNotEmpty) {
      final age = int.tryParse(_ageController.text.trim());
      if (age == null || age < 13 || age > 120) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 12),
                const Text('Idade inválida (mínimo 13 anos)'),
              ],
            ),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }
    }

    // Validar URL do YouTube
    final youtubeError = _validateYouTubeUrl(_youtubeController.text);
    if (youtubeError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(child: Text(youtubeError)),
            ],
          ),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      // Upload da foto se houver
      final photoUrl = await _uploadPhoto();
      

      // Use o ProfileRepository via Riverpod
      final profileRepository = ref.read(profileRepositoryProvider);

      final newProfile = Profile(
        profileId: widget.profile?.profileId,
        uid: user.uid, // Garante que o campo uid seja salvo
        name: sanitizeText(_nameController.text),
        isBand: _isBand,
        photoUrl: photoUrl,
        city: sanitizeText(_cityController.text),
        location: GeoPoint(_latitude!, _longitude!),
        instruments: _selectedInstruments.map(sanitizeText).toList(),
        genres: _selectedGenres.map(sanitizeText).toList(),
        level: _levelController.text.trim().isNotEmpty ? sanitizeText(_levelController.text) : null,
        age: _ageController.text.trim().isNotEmpty ? int.tryParse(sanitizeText(_ageController.text)) : null,
        bio: _bioController.text.trim().isNotEmpty ? sanitizeText(_bioController.text) : null,
        youtubeLink: _youtubeController.text.trim().isNotEmpty ? sanitizeText(_youtubeController.text) : null,
      );

      await profileRepository.updateProfile(newProfile);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(child: Text(
                  widget.profile == null
                    ? 'Perfil criado com sucesso!'
                    : 'Perfil atualizado com sucesso!'
                )),
              ],
            ),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
        // SEMPRE retorna o profileId (String) para garantir atualização correta
        Navigator.pop(context, newProfile.profileId);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(child: Text('Erro ao salvar: $e')),
              ],
            ),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _showInstrumentPicker() {
    final tempSelected = {..._selectedInstruments};
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Selecionar Instrumentos'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView(
              shrinkWrap: true,
              children: _instrumentOptions.map((instrument) {
                final isSelected = tempSelected.contains(instrument);
                return CheckboxListTile(
                  value: isSelected,
                  title: Text(instrument),
                  activeColor: AppColors.primary,
                  onChanged: (checked) {
                    setDialogState(() {
                      if (checked!) {
                        tempSelected.add(instrument);
                      } else {
                        tempSelected.remove(instrument);
                      }
                    });
                  },
                );
              }).toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() => _selectedInstruments = tempSelected);
                Navigator.pop(context);
              },
              child: const Text('Confirmar'),
            ),
          ],
        ),
      ),
    );
  }

  void _showGenrePicker() {
    final tempSelected = {..._selectedGenres};
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Selecionar Gêneros'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView(
              shrinkWrap: true,
              children: _genreOptions.map((genre) {
                final isSelected = tempSelected.contains(genre);
                return CheckboxListTile(
                  value: isSelected,
                  title: Text(genre),
                  activeColor: AppColors.accent,
                  onChanged: (checked) {
                    setDialogState(() {
                      if (checked!) {
                        tempSelected.add(genre);
                      } else {
                        tempSelected.remove(genre);
                      }
                    });
                  },
                );
              }).toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.accent),
              onPressed: () {
                setState(() => _selectedGenres = tempSelected);
                Navigator.pop(context);
              },
              child: const Text('Confirmar'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppLoadingOverlay(
      isLoading: _isSaving,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text(widget.profile == null ? 'Novo Perfil' : 'Editar Perfil'),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
        ),
        body: Stack(
          children: [
            if (_isSaving)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: LinearProgressIndicator(
                  backgroundColor: AppColors.surface,
                  color: AppColors.primary,
                ),
              ),
            Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Card: Foto de Perfil
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          Text(
                            'Foto de Perfil',
                            style: AppTypography.titleLarge,
                          ),
                          const SizedBox(height: 16),
                          GestureDetector(
                            onTap: _isUploadingPhoto ? null : _pickImage,
                            child: Stack(
                              children: [
                                Container(
                                  width: 140,
                                  height: 140,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: AppColors.primary,
                                      width: 3,
                                    ),
                                  color: AppColors.surface,
                                  image: _selectedImage != null
                                      ? DecorationImage(
                                          image: FileImage(_selectedImage!),
                                          fit: BoxFit.cover,
                                        )
                                      : _existingPhotoUrl != null
                                          ? DecorationImage(
                                              image: CachedNetworkImageProvider(_existingPhotoUrl!),
                                              fit: BoxFit.cover,
                                            )
                                          : null,
                                ),
                                child: (_selectedImage == null && _existingPhotoUrl == null)
                                    ? Icon(
                                        Icons.person,
                                        size: 60,
                                        color: AppColors.textSecondary,
                                      )
                                    : null,
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 2,
                                    ),
                                  ),
                                  child: _isUploadingPhoto
                                      ? const SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                          ),
                                        )
                                      : const Icon(
                                          Icons.camera_alt,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Toque para ${_selectedImage != null || _existingPhotoUrl != null ? 'alterar' : 'adicionar'} foto',
                          style: AppTypography.captionLight.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Card: Nome e Tipo
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Informações Básicas',
                              style: AppTypography.titleLarge,
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.error.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'Obrigatório',
                                style: TextStyle(
                                  color: AppColors.error,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _nameController,
                          decoration: InputDecoration(
                            labelText: 'Nome *',
                            prefixIcon: Icon(Icons.person_outline, color: AppColors.primary),
                            filled: true,
                            fillColor: AppColors.surface,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          validator: (v) => (v == null || v.trim().isEmpty) 
                              ? 'Informe o nome' 
                              : null,
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<bool>(
                          value: _isBand,
                          decoration: InputDecoration(
                            labelText: 'Tipo',
                            prefixIcon: Icon(Icons.people_outline, color: AppColors.primary),
                            filled: true,
                            fillColor: AppColors.surface,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          items: const [
                            DropdownMenuItem(value: false, child: Text('Músico')),
                            DropdownMenuItem(value: true, child: Text('Banda')),
                          ],
                          onChanged: (val) => setState(() => _isBand = val!),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _cityController,
                          decoration: InputDecoration(
                            labelText: 'Cidade *',
                            prefixIcon: Icon(Icons.location_city, color: AppColors.primary),
                            filled: true,
                            fillColor: AppColors.surface,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          validator: (v) => (v == null || v.trim().isEmpty) 
                              ? 'Informe a cidade' 
                              : null,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _ageController,
                                decoration: InputDecoration(
                                  labelText: 'Idade',
                                  prefixIcon: Icon(Icons.cake_outlined, color: AppColors.primary),
                                  filled: true,
                                  fillColor: AppColors.surface,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                                keyboardType: TextInputType.number,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                value: _levelController.text.isEmpty ? null : _levelController.text,
                                decoration: InputDecoration(
                                  labelText: 'Nível',
                                  prefixIcon: Icon(Icons.trending_up, color: AppColors.primary),
                                  filled: true,
                                  fillColor: AppColors.surface,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                                items: const [
                                  DropdownMenuItem(value: 'Iniciante', child: Text('Iniciante')),
                                  DropdownMenuItem(value: 'Intermediário', child: Text('Intermediário')),
                                  DropdownMenuItem(value: 'Avançado', child: Text('Avançado')),
                                ],
                                onChanged: (val) => setState(() => _levelController.text = val ?? ''),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Indicador de localização
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: _latitude != null && _longitude != null
                                ? Colors.green.withValues(alpha: 0.1)
                                : AppColors.error.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: _latitude != null && _longitude != null
                                  ? Colors.green
                                  : AppColors.error,
                              width: 1,
                            ),
                          ),
                          child: _isFetchingLocation
                              ? Row(
                                  children: [
                                    SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      'Obtendo sua localização...',
                                      style: AppTypography.bodyLight.copyWith(
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                )
                              : _latitude != null && _longitude != null
                                  ? Row(
                                      children: [
                                        Icon(Icons.check_circle, size: 24, color: Colors.green),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Localização obtida com sucesso',
                                                style: AppTypography.bodyLight.copyWith(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.green,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                'Lat: ${_latitude!.toStringAsFixed(6)}, Lng: ${_longitude!.toStringAsFixed(6)}',
                                                style: AppTypography.captionLight.copyWith(
                                                  color: Colors.green.shade700,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        IconButton(
                                          icon: Icon(Icons.refresh, color: Colors.green),
                                          onPressed: _fetchLocation,
                                          tooltip: 'Atualizar localização',
                                        ),
                                      ],
                                    )
                                  : Row(
                                      children: [
                                        Icon(Icons.location_off, size: 24, color: AppColors.error),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            'Localização não encontrada',
                                            style: AppTypography.bodyLight.copyWith(
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.error,
                                            ),
                                          ),
                                        ),
                                        ElevatedButton.icon(
                                          onPressed: _fetchLocation,
                                          icon: const Icon(Icons.location_searching, size: 18),
                                          label: const Text('Buscar'),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: AppColors.error,
                                            foregroundColor: Colors.white,
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 16,
                                              vertical: 8,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Card: Instrumentos (apenas para músicos)
                if (!_isBand)
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(Icons.music_note, color: AppColors.primary, size: 20),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Instrumentos',
                                style: AppTypography.subtitleLight,
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.error.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  'Obrigatório',
                                  style: TextStyle(
                                    color: AppColors.error,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              ..._selectedInstruments.map((i) => Chip(
                                    label: Text(i),
                                    deleteIcon: const Icon(Icons.close, size: 18),
                                    onDeleted: () => setState(() => _selectedInstruments.remove(i)),
                                    backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                                    labelStyle: TextStyle(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  )),
                              ActionChip(
                                label: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.add, size: 18, color: AppColors.primary),
                                    const SizedBox(width: 4),
                                    Text('Adicionar', style: TextStyle(color: AppColors.primary)),
                                  ],
                                ),
                                onPressed: _showInstrumentPicker,
                                backgroundColor: Colors.white,
                                side: BorderSide(color: AppColors.primary),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                
                const SizedBox(height: 16),
                
                // Card: Gêneros
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.accent.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(Icons.album, color: AppColors.accent, size: 20),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Gêneros Musicais',
                              style: AppTypography.subtitleLight,
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            ..._selectedGenres.map((g) => Chip(
                                  label: Text(g),
                                  deleteIcon: const Icon(Icons.close, size: 18),
                                  onDeleted: () => setState(() => _selectedGenres.remove(g)),
                                  backgroundColor: AppColors.accent.withValues(alpha: 0.1),
                                  labelStyle: TextStyle(
                                    color: AppColors.accent,
                                    fontWeight: FontWeight.w600,
                                  ),
                                )),
                            ActionChip(
                              label: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.add, size: 18, color: AppColors.accent),
                                  const SizedBox(width: 4),
                                  Text('Adicionar', style: TextStyle(color: AppColors.accent)),
                                ],
                              ),
                              onPressed: _showGenrePicker,
                              backgroundColor: Colors.white,
                              side: BorderSide(color: AppColors.accent),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Card: Bio e YouTube
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextFormField(
                          controller: _bioController,
                          decoration: InputDecoration(
                            labelText: 'Bio',
                            hintText: 'Conte um pouco sobre você...',
                            prefixIcon: Icon(Icons.edit_note, color: AppColors.primary),
                            filled: true,
                            fillColor: AppColors.surface,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          minLines: 3,
                          maxLines: 5,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _youtubeController,
                          decoration: InputDecoration(
                            labelText: 'Link YouTube',
                            hintText: 'https://youtu.be/... ou youtube.com/watch?v=...',
                            prefixIcon: const Icon(Icons.play_circle_filled, color: Colors.red),
                            suffixIcon: _youtubeController.text.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear),
                                    onPressed: () {
                                      setState(() => _youtubeController.clear());
                                    },
                                  )
                                : null,
                            filled: true,
                            fillColor: AppColors.surface,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            helperText: 'Cole o link de um vídeo ou playlist',
                            helperStyle: AppTypography.captionLight.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          onChanged: (value) {
                            setState(() {}); // Rebuild para atualizar preview
                          },
                        ),
                        if (_youtubeController.text.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: _validateYouTubeUrl(_youtubeController.text) == null
                                  ? Colors.green.withValues(alpha: 0.1)
                                  : AppColors.error.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: _validateYouTubeUrl(_youtubeController.text) == null
                                    ? Colors.green
                                    : AppColors.error,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  _validateYouTubeUrl(_youtubeController.text) == null
                                      ? Icons.check_circle
                                      : Icons.error,
                                  color: _validateYouTubeUrl(_youtubeController.text) == null
                                      ? Colors.green
                                      : AppColors.error,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    _validateYouTubeUrl(_youtubeController.text) ?? 'URL válida! ✓',
                                    style: AppTypography.captionLight.copyWith(
                                      color: _validateYouTubeUrl(_youtubeController.text) == null
                                          ? Colors.green.shade700
                                          : AppColors.error,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 80), // Espaço para o botão fixo
              ],
            ),
          ),
          
          // Botão Salvar fixo
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(16),
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
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  textStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                onPressed: _isSaving ? null : _saveProfile,
                child: _isSaving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text('Salvar Perfil'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
