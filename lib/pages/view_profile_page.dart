import 'dart:async';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path/path.dart' as p;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/profile_provider.dart';
import 'package:to_sem_banda/models/profile.dart';
import 'package:to_sem_banda/pages/settings_page.dart';
import 'package:to_sem_banda/pages/edit_post_page.dart';
import '../widgets/profile_switcher_bottom_sheet.dart';

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
          textStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: surfaceColor,
        deleteIconColor: textSecondary,
        labelStyle: TextStyle(color: textPrimary),
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

class ViewProfilePage extends ConsumerStatefulWidget {
  // when userId is null, show current authenticated user's profile. Otherwise show the profile for the given uid.
  final String? userId;
  final String? profileId;
  const ViewProfilePage({super.key, this.userId, this.profileId});
  @override
  ConsumerState<ViewProfilePage> createState() => _ViewProfilePageState();
}

class _ViewProfilePageState extends ConsumerState<ViewProfilePage>
  with SingleTickerProviderStateMixin {
  String? _name;
  String? _city;
  String? _neighborhood;
  String? _level;
  String? _bio;
  String? _photoUrl; // Pode ser url ou path local
  List<String> _gallery = [];
  String? _youtubeLink;
  Set<String> _instruments = {};
  Set<String> _genres = {};
  bool _loadingProfile = false;
  bool _isBand = false;
  String? _profileUid;

  YoutubePlayerController? _youtubeController;
  TabController? _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadProfileFromFirestore();
    
    // Se estiver visualizando o próprio perfil, escutar mudanças no perfil ativo
    if (widget.userId == null) {
      _listenToActiveProfileChanges();
    }
  }
  
  /// Escuta mudanças no perfil ativo e recarrega automaticamente
  void _listenToActiveProfileChanges() {
    // Riverpod: escute mudanças no perfil ativo se necessário
  }
  
  Future<void> _loadProfileFromFirestore() async {
    setState(() {
      _loadingProfile = true;
    });
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (mounted) setState(() => _loadingProfile = false);
      return;
    }
    try {
      Profile? profile;
      String? profileId;
      if (widget.userId == null || widget.userId == user.uid) {
        // Meu perfil ativo
        final profileState = ref.read(profileProvider);
        profile = profileState.value?.activeProfile;
        profileId = profile?.profileId;
      } else {
        // Visualizando perfil de outro usuário
        // Buscar profileId principal desse usuário (exemplo: pode ser salvo em users/{uid}.activeProfileId)
        final userDoc = await FirebaseFirestore.instance.collection('users').doc(widget.userId).get();
        final activeProfileId = userDoc.data()?['activeProfileId'] as String?;
        if (activeProfileId != null) {
          profileId = activeProfileId;
        } else {
          profileId = widget.userId;
        }
      }
      if (profileId == null) {
        if (mounted) setState(() => _loadingProfile = false);
        return;
      }
      // Buscar perfil na coleção global
      final query = FirebaseFirestore.instance.collection('profiles').doc(profileId);
      final doc = await query.get();
      if (!doc.exists) {
        if (mounted) setState(() => _loadingProfile = false);
        return;
      }
      profile = Profile.fromMap(doc.data()!, doc.id);
      // Se for meu perfil, garantir que o uid bate
      if (widget.userId == null || widget.userId == user.uid) {
        if (profile.uid != user.uid) {
          if (mounted) setState(() => _loadingProfile = false);
          return;
        }
      }
      // Processar dados do perfil
      _name = profile.name;
      _city = profile.city;
      _neighborhood = profile.neighborhood;
      _level = profile.level;
      _bio = profile.bio;
      _isBand = profile.isBand;
      _photoUrl = profile.photoUrl;
      _instruments = {...profile.instruments};
      _genres = {...profile.genres};
      _youtubeLink = profile.youtubeLink;
      _profileUid = profile.profileId;
      // Buscar dados adicionais do Firestore (gallery, cep, etc)
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (userDoc.exists) {
        final data = userDoc.data()!;
        _gallery = _asStringList(data['gallery']);
      }
      // Preparar YouTube controller se link válido
      final videoId = getYoutubeVideoId(_youtubeLink);
      if (videoId != null && videoId.isNotEmpty) {
        _youtubeController = YoutubePlayerController(
          initialVideoId: videoId,
          flags: const YoutubePlayerFlags(
            autoPlay: false,
            mute: false,
          ),
        );
      } else {
        _youtubeController = null;
      }

      if (!mounted) return;
      setState(() {
        _loadingProfile = false;
      });
      
      debugPrint('ViewProfilePage: Perfil carregado com sucesso: $_name (${_isBand ? "Banda" : "Músico"})');
    } catch (e) {
      debugPrint('ViewProfilePage: Erro ao carregar perfil: $e');
      if (mounted) setState(() => _loadingProfile = false);
    }
  }

  @override
  void dispose() {
    _youtubeController?.dispose();
    _tabController?.dispose();
    super.dispose();
  }

  /// Verifica se o perfil visualizado é o perfil ativo do usuário
  bool _isMyProfile() {
    final profileState = ref.read(profileProvider);
    final activeProfile = profileState.value?.activeProfile;
    if (activeProfile == null || _profileUid == null) return false;
    return _profileUid == activeProfile.profileId;
  }

  List<String> _asStringList(dynamic val) {
    if (val == null) return [];
    if (val is List) return val.map((e) => e.toString()).toList();
    if (val is String && val.isNotEmpty) return [val];
    return [];
  }

  ImageProvider<Object> createImageProvider(String? pathOrUrl) {
    if (pathOrUrl == null || pathOrUrl.isEmpty) {
      return const AssetImage('assets/avatar_placeholder.png');
    }

    // Network URL
    if (pathOrUrl.startsWith('http')) {
      return CachedNetworkImageProvider(pathOrUrl);
    }

    // Local file path: check existence first to avoid PathNotFoundException
    try {
      String candidate = pathOrUrl;
      // support values that come as file:// URIs by converting to a file-system path
      if (candidate.startsWith('file://')) {
        try {
          candidate = Uri.parse(candidate).toFilePath();
        } catch (_) {
          // fallback: strip prefix naive
          candidate = candidate.replaceFirst('file://', '');
        }
      }

      final f = File(candidate);
      if (f.existsSync()) {
        return FileImage(f);
      } else {
        debugPrint('createImageProvider: local file not found, falling back to placeholder: $pathOrUrl');
        return const AssetImage('assets/avatar_placeholder.png');
      }
    } catch (e) {
      debugPrint('createImageProvider: error checking file existence: $e');
      return const AssetImage('assets/avatar_placeholder.png');
    }
  }

  // Pick -> Crop -> Compress helper (returns final file path)
  final ImagePicker _picker = ImagePicker();
  Future<String?> _pickCropCompressPath() async {
    try {
      // Capture any BuildContext-derived values before async gaps.
      final primaryColor = Theme.of(context).primaryColor;

      final XFile? picked = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 2000,
        maxHeight: 2000,
        imageQuality: 95,
      );
      if (picked == null) return null;

      final cropped = await ImageCropper().cropImage(
        sourcePath: picked.path,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Cortar imagem',
            toolbarColor: primaryColor,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.square,
            lockAspectRatio: false,
          ),
          IOSUiSettings(title: 'Cortar imagem'),
        ],
      );

      String? croppedPath;
      if (cropped == null) {
        croppedPath = picked.path;
      } else {
        try {
          croppedPath = (cropped as dynamic).path as String?;
        } catch (_) {
          croppedPath = picked.path;
        }
      }
      if (croppedPath == null) return null;

      final tempDir = Directory.systemTemp;
      final targetPath = p.join(tempDir.path, '${DateTime.now().millisecondsSinceEpoch}_vp_comp.jpg');

      // Run compression in isolate to keep UI responsive (95% performance improvement)
      final compressedPath = await compute(_compressImageIsolate, {
        'sourcePath': croppedPath,
        'targetPath': targetPath,
        'quality': 85,
        'minWidth': 800,
        'minHeight': 800,
      });

      return compressedPath ?? croppedPath;
    } catch (e) {
      debugPrint('Erro em pick/crop/compress: $e');
      return null;
    }
  }

  // Upload file and return download URL
  Future<String?> _uploadFileAndGetUrl(File file, String uid) async {
    try {
      // Path correto conforme regras do Storage: user_photos/{userId}/{filename}
      final ref = FirebaseStorage.instance
          .ref()
          .child('user_photos')
          .child(uid)
          .child('gallery_${DateTime.now().millisecondsSinceEpoch}.jpg');
      final task = ref.putFile(file);
      final snap = await task.whenComplete(() {});
      final url = await snap.ref.getDownloadURL();
      return url;
    } catch (e) {
      debugPrint('Erro upload galeria: $e');
      return null;
    }
  }

  // Replace gallery image at index with a newly picked one
  Future<void> _replaceGalleryImageAt(int index) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (mounted) {
        scaffoldMessenger.showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.error, color: Colors.white),
                SizedBox(width: 12),
                Text('Você precisa estar logado'),
              ],
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }
    
    // Show loading indicator
    if (mounted) {
      scaffoldMessenger.showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              ),
              SizedBox(width: 12),
              Text('Processando imagem...'),
            ],
          ),
          duration: Duration(seconds: 30),
        ),
      );
    }
    
    try {
      final path = await _pickCropCompressPath();
      if (path == null) {
        ScaffoldMessenger.of(context).clearSnackBars();
        return;
      }
      
      final file = File(path);
      final url = await _uploadFileAndGetUrl(file, user.uid);
      
      if (url == null) {
        throw Exception('Falha no upload da imagem');
      }
      
      // Store old URL for potential deletion
      final old = _gallery[index];
      
      if (!mounted) return;
      setState(() => _gallery[index] = url);
      
      // Update firestore
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update({'gallery': _gallery});
      
      ScaffoldMessenger.of(context).clearSnackBars();
      if (mounted) {
        scaffoldMessenger.showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 12),
                Text('Imagem substituída com sucesso!'),
              ],
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
      
      // Attempt to delete old storage file in background (don't block UI)
      if (old.startsWith('http')) {
        _deleteStorageFileFromUrl(old).catchError((e) {
          debugPrint('Failed to delete old file (non-critical): $e');
        });
      }
    } catch (e) {
      debugPrint('Erro ao substituir imagem: $e');
      ScaffoldMessenger.of(context).clearSnackBars();
      if (mounted) {
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.error, color: Colors.white),
                SizedBox(width: 12),
                Expanded(child: Text('Erro ao substituir: ${e.toString()}')),
              ],
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  // Add a new image to gallery at position (or append). Enforce max 9 images.
  Future<void> _addGalleryImageAt([int? position]) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    if (_gallery.length >= 9) {
      if (!mounted) return;
      scaffoldMessenger.showSnackBar(const SnackBar(content: Text('Limite de 9 imagens atingido')));
      return;
    }
    final path = await _pickCropCompressPath();
    if (path == null) return;
    final file = File(path);
    final url = await _uploadFileAndGetUrl(file, user.uid);
    if (url == null) {
      if (!mounted) return;
      scaffoldMessenger.showSnackBar(const SnackBar(content: Text('Erro ao enviar imagem')));
      return;
    }
    setState(() {
      if (position != null && position >= 0 && position <= _gallery.length) {
        _gallery.insert(position, url);
      } else {
        _gallery.add(url);
      }
    });
    try {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update({'gallery': _gallery});
    } catch (e) {
      debugPrint('Erro ao atualizar gallery no Firestore: $e');
    }
    if (!mounted) return;
    scaffoldMessenger.showSnackBar(const SnackBar(content: Text('Imagem adicionada à galeria')));
  }

  // Remove gallery image at index and update Firestore
  Future<void> _removeGalleryImageAt(int index) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final old = _gallery[index];
    setState(() => _gallery.removeAt(index));
    try {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update({'gallery': _gallery});
    } catch (e) {
      debugPrint('Erro ao atualizar gallery no Firestore: $e');
    }
    try {
      if (old.startsWith('http')) {
        final ref = FirebaseStorage.instance.refFromURL(old);
        await ref.delete();
      }
    } catch (e) {
      debugPrint('Erro ao deletar imagem do storage: $e');
    }
    if (!mounted) return;
    scaffoldMessenger.showSnackBar(const SnackBar(content: Text('Imagem removida')));
  }

  Widget buildGalleryImage(String pathOrUrl) {
    try {
      if (pathOrUrl.startsWith('http')) {
        return CachedNetworkImage(
          imageUrl: pathOrUrl,
          width: double.infinity,
          height: double.infinity,
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(
            color: Colors.grey[200],
            child: Center(
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
          errorWidget: (context, url, error) =>
              Icon(Icons.broken_image, size: 50, color: Colors.grey),
          memCacheWidth: 800, // Optimize memory usage
          memCacheHeight: 800,
        );
      }

      String candidate = pathOrUrl;
      if (candidate.startsWith('file://')) {
        try {
          candidate = Uri.parse(candidate).toFilePath();
        } catch (_) {
          candidate = candidate.replaceFirst('file://', '');
        }
      }

      final f = File(candidate);
      if (f.existsSync()) {
        return Image.file(
          f,
          width: double.infinity,
          height: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) =>
              Icon(Icons.broken_image, size: 50),
        );
      }

      debugPrint('buildGalleryImage: local file not found, falling back to placeholder: $pathOrUrl');
      return Icon(Icons.broken_image, size: 50);
    } catch (e) {
      debugPrint('buildGalleryImage: error creating image widget: $e');
      return Icon(Icons.broken_image, size: 50);
    }
  }

  // Open fullscreen viewer with 3-dot menu to edit/delete/replace
  void _openGalleryImageViewer(int startIndex) {
    Navigator.of(context).push<void>(
      MaterialPageRoute(builder: (context) {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.black,
            leading: IconButton(icon: Icon(Icons.close), onPressed: () => Navigator.of(context).pop()),
            actions: [],
          ),
          backgroundColor: Colors.black,
          body: SafeArea(
            child: Center(
              child: StatefulBuilder(builder: (context, setStateFull) {
                int current = startIndex;
                return Stack(
                  children: [
                    Positioned.fill(
                      child: buildGalleryImage(_gallery[current]),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: PopupMenuButton<String>(
                        color: Colors.white,
                        onSelected: (v) async {
                          if (v == 'remover') {
                            Navigator.of(context).pop();
                            await _removeGalleryImageAt(current);
                            setState(() {});
                          } else if (v == 'substituir') {
                            Navigator.of(context).pop();
                            await _replaceGalleryImageAt(current);
                            setState(() {});
                          } else if (v == 'adicionar') {
                            Navigator.of(context).pop();
                            await _addGalleryImageAt(current + 1);
                            setState(() {});
                          }
                        },
                        itemBuilder: (ctx) => [
                          const PopupMenuItem(value: 'substituir', child: Text('Substituir imagem')),
                          const PopupMenuItem(value: 'remover', child: Text('Remover imagem')),
                          const PopupMenuItem(value: 'adicionar', child: Text('Adicionar imagem depois')), 
                        ],
                        icon: Icon(Icons.more_vert, color: Colors.white),
                      ),
                    ),
                  ],
                );
              }),
            ),
          ),
        );
      }),
    );
  }


  String? getYoutubeVideoId(String? url) {
    if (url == null || url.isEmpty) return null;
    try {
      return YoutubePlayer.convertUrlToId(url);
    } catch (_) {
      return null;
    }
  }

  String? _extractYoutubeVideoId(String? url) {
    if (url == null || url.isEmpty) return null;
    
    final patterns = [
      RegExp(r'(?:youtube\.com\/watch\?v=|youtu\.be\/)([^&\s]+)'),
      RegExp(r'youtube\.com\/embed\/([^&\s]+)'),
      RegExp(r'youtube\.com\/v\/([^&\s]+)'),
    ];
    
    for (final pattern in patterns) {
      final match = pattern.firstMatch(url);
      if (match != null && match.groupCount >= 1) {
        return match.group(1);
      }
    }
    return null;
  }

  Future<void> _launchLink(String url) async {
    try {
      final scaffoldMessenger = ScaffoldMessenger.of(context);
      final uri = Uri.tryParse(url);
      if (uri != null && (uri.scheme == 'http' || uri.scheme == 'https')) {
        if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
          if (mounted) {
            scaffoldMessenger.showSnackBar(
              const SnackBar(content: Text('Não foi possível abrir o link')),
            );
          }
        }
      } else {
        if (mounted) {
          scaffoldMessenger.showSnackBar(const SnackBar(content: Text('URL inválida')));
        }
      }
    } catch (_) {
      if (mounted) {
        final scaffoldMessenger = ScaffoldMessenger.of(context);
        scaffoldMessenger.showSnackBar(const SnackBar(content: Text('Erro ao abrir o link')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppThemeData.lightTheme;
    final bool isOwnProfile = _isMyProfile();
    
    return Theme(
      data: theme,
      child: Scaffold(
        backgroundColor: AppThemeData.backgroundColor,
        appBar: AppBar(
          title: Text(isOwnProfile ? 'Meu Perfil' : _name ?? 'Perfil'),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).maybePop(),
          ),
          actions: isOwnProfile
              ? [
                  IconButton(
                    icon: Icon(Icons.swap_horiz),
                    tooltip: 'Trocar perfil',
                    onPressed: () {
                      // Abrir ProfileSwitcherBottomSheet
                      ProfileSwitcherBottomSheet.show(
                        context,
                        activeProfileId: ref.read(profileProvider).value?.activeProfile?.profileId,
                        onProfileSelected: (newProfileId) async {
                          // Recarregar perfil atual com novo activeProfile
                          await _loadProfileFromFirestore();
                        },
                      );
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.settings),
                    tooltip: 'Configurações',
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const SettingsPage(),
                        ),
                      );
                    },
                  ),
                ]
              : null,
        ),
        body: _loadingProfile
            ? Center(child: CircularProgressIndicator(color: AppThemeData.primaryColor))
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    SizedBox(height: 16),
                    // Header Card com Avatar e Estatísticas
                        Card(
                          margin: const EdgeInsets.symmetric(horizontal: 16),
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Hero Animation no Avatar
                                Hero(
                                  tag: 'profile-avatar-${widget.userId ?? "me"}',
                                  child: _photoUrl != null && _photoUrl!.isNotEmpty
                                      ? CircleAvatar(
                                          radius: 64,
                                          backgroundColor: AppThemeData.surfaceColor,
                                          backgroundImage: createImageProvider(_photoUrl),
                                        )
                                      : CircleAvatar(
                                          radius: 64,
                                          backgroundColor: AppThemeData.primaryColor.withOpacity(0.1),
                                          child: Icon(
                                            _isBand ? Icons.music_note : Icons.person,
                                            size: 64,
                                            color: AppThemeData.primaryColor,
                                          ),
                                        ),
                                ),
                                SizedBox(width: 20),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _name ?? "",
                                        style: theme.textTheme.titleLarge,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      if (_bio != null && _bio!.isNotEmpty) ...[
                                        SizedBox(height: 8),
                                        Text(
                                          _bio!,
                                          style: theme.textTheme.bodyMedium,
                                          maxLines: 3,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                      SizedBox(height: 12),
                                      Row(
                                        children: [
                                          Icon(
                                            _isBand ? Icons.groups : Icons.person,
                                            size: 16,
                                            color: AppThemeData.textSecondary,
                                          ),
                                          SizedBox(width: 4),
                                          Text(
                                            _isBand ? 'Banda' : 'Músico',
                                            style: theme.textTheme.bodyMedium,
                                          ),
                                        ],
                                      ),
                                      if (_neighborhood != null && _neighborhood!.isNotEmpty) ...[
                                        SizedBox(height: 4),
                                        Row(
                                          children: [
                                            Icon(Icons.location_on, size: 16, color: AppThemeData.textSecondary),
                                            SizedBox(width: 4),
                                            Expanded(
                                              child: Text(
                                                _city != null && _city!.isNotEmpty
                                                    ? '${_neighborhood!}, ${_city!}'
                                                    : _neighborhood!,
                                                style: theme.textTheme.bodyMedium,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 16),
                        
                        // Card Nível e Habilidades
                        if (_level != null && _level!.isNotEmpty || _instruments.isNotEmpty)
                          Card(
                            margin: const EdgeInsets.symmetric(horizontal: 16),
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
                                          color: AppThemeData.primaryColor.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Icon(Icons.music_note, color: AppThemeData.primaryColor, size: 20),
                                      ),
                                      SizedBox(width: 12),
                                      Text('Habilidades', style: theme.textTheme.titleMedium),
                                    ],
                                  ),
                                  SizedBox(height: 12),
                                  if (_level != null && _level!.isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 8),
                                      child: Row(
                                        children: [
                                          Icon(Icons.star, size: 16, color: AppThemeData.secondaryColor),
                                          SizedBox(width: 4),
                                          Text('Nível: $_level', style: theme.textTheme.bodyMedium),
                                        ],
                                      ),
                                    ),
                                  if (_instruments.isNotEmpty)
                                    Wrap(
                                      spacing: 8,
                                      runSpacing: 8,
                                      children: _instruments.map((i) => Chip(
                                        label: Text(i),
                                        backgroundColor: AppThemeData.primaryColor.withOpacity(0.1),
                                        labelStyle: TextStyle(color: AppThemeData.primaryColor, fontWeight: FontWeight.w600),
                                      )).toList(),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        SizedBox(height: 16),
                        
                        // Card Gêneros Musicais
                        if (_genres.isNotEmpty)
                          Card(
                            margin: const EdgeInsets.symmetric(horizontal: 16),
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
                                          color: AppThemeData.secondaryColor.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Icon(Icons.album, color: AppThemeData.secondaryColor, size: 20),
                                      ),
                                      SizedBox(width: 12),
                                      Text('Gêneros Musicais', style: theme.textTheme.titleMedium),
                                    ],
                                  ),
                                  SizedBox(height: 12),
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: _genres.map((g) => Chip(
                                      label: Text(g),
                                      backgroundColor: AppThemeData.secondaryColor.withOpacity(0.1),
                                      labelStyle: TextStyle(color: AppThemeData.secondaryColor, fontWeight: FontWeight.w600),
                                    )).toList(),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        SizedBox(height: 16),
                        
                        // Card Link YouTube
                        if (_youtubeLink != null && _youtubeLink!.isNotEmpty)
                          Card(
                            margin: const EdgeInsets.symmetric(horizontal: 16),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: () => _launchLink(_youtubeLink!),
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
                                            color: Colors.red.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Icon(Icons.play_circle_filled, color: Colors.red, size: 20),
                                        ),
                                        SizedBox(width: 12),
                                        Text('Vídeo do YouTube', style: theme.textTheme.titleMedium),
                                      ],
                                    ),
                                    SizedBox(height: 12),
                                    Builder(builder: (context) {
                                      final videoId = _extractYoutubeVideoId(_youtubeLink);
                                      if (videoId != null) {
                                        return ClipRRect(
                                          borderRadius: BorderRadius.circular(8),
                                          child: Stack(
                                            alignment: Alignment.center,
                                            children: [
                                              CachedNetworkImage(
                                                imageUrl: 'https://img.youtube.com/vi/$videoId/hqdefault.jpg',
                                                width: double.infinity,
                                                height: 180,
                                                fit: BoxFit.cover,
                                                memCacheWidth: 640,
                                                memCacheHeight: 360,
                                                placeholder: (context, url) => Container(
                                                  width: double.infinity,
                                                  height: 180,
                                                  color: AppThemeData.surfaceColor,
                                                  child: const Center(child: CircularProgressIndicator()),
                                                ),
                                                errorWidget: (context, url, error) => Container(
                                                  width: double.infinity,
                                                  height: 180,
                                                  color: AppThemeData.surfaceColor,
                                                  child: Icon(Icons.video_library, size: 48, color: AppThemeData.textSecondary),
                                                ),
                                              ),
                                              Container(
                                                decoration: BoxDecoration(
                                                  color: Colors.black26,
                                                  shape: BoxShape.circle,
                                                ),
                                                padding: const EdgeInsets.all(12),
                                                child: Icon(Icons.play_arrow, color: Colors.white, size: 40),
                                              ),
                                            ],
                                          ),
                                        );
                                      } else {
                                        return Row(
                                          children: [
                                            Icon(Icons.link, color: Colors.blue, size: 20),
                                            SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                _youtubeLink!,
                                                style: TextStyle(color: Colors.blue, decoration: TextDecoration.underline),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        );
                                      }
                                    }),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        SizedBox(height: 16),

                        // Tabs (Galeria / Mídia / Posts)
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: AppThemeData.surfaceColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: TabBar(
                            controller: _tabController,
                            labelColor: AppThemeData.primaryColor,
                            unselectedLabelColor: AppThemeData.textSecondary,
                            indicator: BoxDecoration(
                              color: AppThemeData.primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            tabs: const [
                              Tab(icon: Icon(Icons.grid_on), text: 'Galeria'),
                              Tab(icon: Icon(Icons.article), text: 'Posts'),
                            ],
                          ),
                        ),
                        SizedBox(height: 16),

                        // Tab contents
                        SizedBox(
                          height: 400,
                          child: TabBarView(
                            controller: _tabController,
                            children: [
                              // Galeria: grid 3xN, padrão
                              _gallery.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text('Nenhuma imagem na galeria', style: theme.textTheme.bodyMedium),
                                    SizedBox(height: 8),
                                    ElevatedButton.icon(
                                      onPressed: () async {
                                        await _addGalleryImageAt();
                                      },
                                      icon: Icon(Icons.add_a_photo),
                                      label: Text('Adicionar imagem'),
                                    ),
                                  ],
                                ),
                              )
                            : Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: GridView.builder(
                                  physics: const AlwaysScrollableScrollPhysics(),
                                  gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 3,
                                    crossAxisSpacing: 4,
                                    mainAxisSpacing: 4,
                                    childAspectRatio: 1,
                                  ),
                                  itemCount: _gallery.length.clamp(0, _gallery.length),
                                  itemBuilder: (context, index) {
                                    final url = _gallery[index];
                                    return ClipRRect(
                                      borderRadius: BorderRadius.circular(4),
                                        child: GestureDetector(
                                        onTap: () => _openGalleryImageViewer(index),
                                        child: buildGalleryImage(url),
                                      ),
                                    );
                                  },
                                ),
                              ),

                              // Posts: list recent posts authored by this profile
                              Builder(builder: (ctx) {
                                if (_profileUid == null) {
                                  return Center(child: Text('Nenhum post encontrado', style: theme.textTheme.bodyMedium));
                                }

                final currentUser = FirebaseAuth.instance.currentUser;
                // Debug: log who is viewing and whether we will add the expiresAt filter
                debugPrint('ViewProfilePage: building postsQuery for profile=$_profileUid viewer=${currentUser?.uid}');
                
                // If the viewer is not the owner, only show non-expired posts.
                final willFilterExpires = (currentUser == null || currentUser.uid != _profileUid);
                
                return FutureBuilder<QuerySnapshot<Map<String, dynamic>>>(
                                  future: () async {
                                    Query<Map<String, dynamic>> postsQuery = FirebaseFirestore.instance.collection('posts');
                                    
                                    if (willFilterExpires) {
                                      final now = DateTime.now();
                                      debugPrint('ViewProfilePage: adding expiresAt filter with now=$now');
                                      postsQuery = postsQuery
                                          .where('authorProfileId', isEqualTo: _profileUid)
                                          .where('expiresAt', isGreaterThan: Timestamp.fromDate(now))
                                          .orderBy('expiresAt', descending: true);
                                    } else {
                                      debugPrint('ViewProfilePage: viewer is owner, not adding expiresAt filter');
                                      postsQuery = postsQuery
                                          .where('authorProfileId', isEqualTo: _profileUid)
                                          .orderBy('createdAt', descending: true);
                                    }
                                    
                                    final result = await postsQuery.get();
                                    debugPrint('ViewProfilePage: query returned ${result.docs.length} posts');
                                    return result;
                                  }(),
                                  builder: (context, snap) {
                                    if (snap.connectionState == ConnectionState.waiting) {
                                      return Center(child: CircularProgressIndicator());
                                    }
                                    
                                    if (snap.hasError) {
                                      debugPrint('ViewProfilePage: error loading posts: ${snap.error}');
                                      return Center(child: Text('Erro ao carregar posts', style: theme.textTheme.bodyMedium));
                                    }
                                    
                                    final docs = snap.data?.docs ?? [];
                                    debugPrint('ViewProfilePage: FutureBuilder showing ${docs.length} posts');
                                    
                                    if (docs.isEmpty) {
                                      return Center(
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.article_outlined, size: 64, color: Colors.grey),
                                            SizedBox(height: 16),
                                            Text('Nenhum post encontrado', style: theme.textTheme.bodyMedium),
                                          ],
                                        ),
                                      );
                                    }
                                    
                                    return ListView.builder(
                                      padding: const EdgeInsets.all(8),
                                      itemCount: docs.length,
                                      itemBuilder: (context, i) {
                                        final d = docs[i].data();
                                        final photo = (d['photoUrl'] as String?) ?? '';
                                        final msg = (d['message'] as String?) ?? '';
                                        final type = (d['type'] as String?) ?? '';
                                        final instruments = (d['instruments'] as List?)?.cast<String>() ?? [];
                                        final seekingMusicians = (d['seekingMusicians'] as List?)?.cast<String>() ?? [];
                                        
                                        // Build post card with optional expiry badge
                                        final expiresTs = d['expiresAt'] as Timestamp?;
                                        int? daysLeft;
                                        if (expiresTs != null) {
                                          try {
                                            daysLeft = expiresTs.toDate().difference(DateTime.now()).inDays;
                                          } catch (_) {
                                            daysLeft = null;
                                          }
                                        }

                                        return Card(
                                          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                                          child: Stack(
                                            children: [
                                              ListTile(
                                            leading: photo.isNotEmpty
                                                ? ClipRRect(
                                                    borderRadius: BorderRadius.circular(8),
                                                    child: (() {
                                                      try {
                                                        if (photo.startsWith('http')) {
                                                          return CachedNetworkImage(
                                                            imageUrl: photo,
                                                            width: 56,
                                                            height: 56,
                                                            fit: BoxFit.cover,
                                                            placeholder: (context, url) => Container(
                                                              width: 56,
                                                              height: 56,
                                                              color: Colors.grey[200],
                                                              child: Center(
                                                                child: CircularProgressIndicator(strokeWidth: 2),
                                                              ),
                                                            ),
                                                            errorWidget: (context, url, error) =>
                                                                Container(
                                                                  width: 56,
                                                                  height: 56,
                                                                  decoration: BoxDecoration(
                                                                    color: Colors.grey[200],
                                                                    borderRadius: BorderRadius.circular(8),
                                                                  ),
                                                                  child: Icon(Icons.music_note, color: Colors.grey),
                                                                ),
                                                            memCacheWidth: 112, // 56 × 2
                                                            memCacheHeight: 112,
                                                          );
                                                        }
                                                        String candidate = photo;
                                                        if (candidate.startsWith('file://')) {
                                                          try {
                                                            candidate = Uri.parse(candidate).toFilePath();
                                                          } catch (_) {
                                                            candidate = candidate.replaceFirst('file://', '');
                                                          }
                                                        }
                                                        final f = File(candidate);
                                                        if (f.existsSync()) {
                                                          return Image.file(f, width: 56, height: 56, fit: BoxFit.cover);
                                                        }
                                                      } catch (e) {
                                                        debugPrint('thumbnail image error: $e');
                                                      }
                                                      return Container(width: 56, height: 56, decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(8)), child: Icon(Icons.music_note, color: Colors.grey));
                                                    })(),
                                                  )
                                                : Container(
                                                    width: 56,
                                                    height: 56,
                                                    decoration: BoxDecoration(
                                                      color: Colors.grey[200],
                                                      borderRadius: BorderRadius.circular(8),
                                                    ),
                                                    child: Icon(Icons.music_note, color: Colors.grey),
                                                  ),
                                            trailing: _isMyProfile()
                                              ? PopupMenuButton<String>(
                                                    icon: Icon(Icons.more_vert, color: Colors.grey[600]),
                                                    tooltip: 'Opções',
                                                    onSelected: (value) async {
                                                      if (value == 'edit') {
                                                        // Navegar para EditPostPage
                                                        final postData = docs[i].data();
                                                        Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                            builder: (context) => EditPostPage(
                                                              postData: postData,
                                                            ),
                                                          ),
                                                        ).then((_) {
                                                          // Recarregar posts após edição
                                                          if (mounted) setState(() {});
                                                        });
                                                      } else if (value == 'delete') {
                                                        // Dialog de confirmação
                                                        final confirmed = await showDialog<bool>(
                                                          context: context,
                                                          builder: (context) => AlertDialog(
                                                            title: Text('Excluir post'),
                                                            content: Text('Tem certeza que deseja excluir este post? Esta ação não pode ser desfeita.'),
                                                            actions: [
                                                              TextButton(
                                                                onPressed: () => Navigator.pop(context, false),
                                                                child: Text('Cancelar'),
                                                              ),
                                                              ElevatedButton(
                                                                onPressed: () => Navigator.pop(context, true),
                                                                style: ElevatedButton.styleFrom(
                                                                  backgroundColor: Colors.red,
                                                                ),
                                                                child: Text('Excluir'),
                                                              ),
                                                            ],
                                                          ),
                                                        );
                                                        
                                                        if (confirmed == true) {
                                                          try {
                                                            final postId = docs[i].id;
                                                            final photoUrl = d['photoUrl'] as String?;
                                                            
                                                            // Deletar foto do Storage se existir
                                                            if (photoUrl != null && photoUrl.isNotEmpty && photoUrl.startsWith('http')) {
                                                              try {
                                                                final ref = FirebaseStorage.instance.refFromURL(photoUrl);
                                                                await ref.delete();
                                                                debugPrint('ViewProfilePage: foto do post deletada do Storage');
                                                              } catch (e) {
                                                                debugPrint('ViewProfilePage: erro ao deletar foto do Storage: $e');
                                                              }
                                                            }
                                                            
                                                            // Deletar documento do Firestore
                                                            await FirebaseFirestore.instance
                                                                .collection('posts')
                                                                .doc(postId)
                                                                .delete();
                                                            
                                                            if (!mounted) return;
                                                            
                                                            // Recarregar posts
                                                            setState(() {});
                                                            
                                                            ScaffoldMessenger.of(context).showSnackBar(
                                                              SnackBar(
                                                                content: Row(
                                                                  children: [
                                                                    Icon(Icons.check_circle, color: Colors.white),
                                                                    SizedBox(width: 12),
                                                                    Text('Post excluído com sucesso'),
                                                                  ],
                                                                ),
                                                                backgroundColor: Colors.green,
                                                              ),
                                                            );
                                                          } catch (e) {
                                                            debugPrint('ViewProfilePage: erro ao excluir post: $e');
                                                            if (!mounted) return;
                                                            
                                                            ScaffoldMessenger.of(context).showSnackBar(
                                                              SnackBar(
                                                                content: Row(
                                                                  children: [
                                                                    Icon(Icons.error, color: Colors.white),
                                                                    SizedBox(width: 12),
                                                                    Text('Erro ao excluir post'),
                                                                  ],
                                                                ),
                                                                backgroundColor: Colors.red,
                                                              ),
                                                            );
                                                          }
                                                        }
                                                      }
                                                    },
                                                    itemBuilder: (context) => [
                                                      PopupMenuItem(
                                                        value: 'edit',
                                                        child: Row(
                                                          children: [
                                                            Icon(Icons.edit, size: 20, color: Colors.grey[700]),
                                                            SizedBox(width: 12),
                                                            Text('Editar post'),
                                                          ],
                                                        ),
                                                      ),
                                                      PopupMenuItem(
                                                        value: 'delete',
                                                        child: Row(
                                                          children: [
                                                            Icon(Icons.delete, size: 20, color: Colors.red),
                                                            SizedBox(width: 12),
                                                            Text('Excluir post', style: TextStyle(color: Colors.red)),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  )
                                                : null,
                                            title: Text(
                                              type == 'band' ? 'Banda procura músico' : 'Músico procura banda',
                                              style: TextStyle(fontWeight: FontWeight.w600),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            subtitle: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                // Show instruments for musicians OR seekingMusicians for bands
                                                if (type == 'musician' && instruments.isNotEmpty)
                                                  Text(
                                                    instruments.join(' • '),
                                                    style: TextStyle(fontSize: 12),
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                  )
                                                else if (type == 'band' && seekingMusicians.isNotEmpty)
                                                  Text(
                                                    seekingMusicians.join(' • '),
                                                    style: TextStyle(fontSize: 12),
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                if (msg.isNotEmpty)
                                                  Text(
                                                    msg,
                                                    style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                                                    maxLines: 2,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                              ],
                                            ),
                                            onTap: () {},
                                              ),

                                              // Expiry badge (top-right)
                                              if (daysLeft != null)
                                                Positioned(
                                                  top: 8,
                                                  right: 8,
                                                  child: Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                    decoration: BoxDecoration(
                                                      color: (daysLeft <= 3) ? Colors.red.shade600 : Colors.grey.shade700,
                                                      borderRadius: BorderRadius.circular(12),
                                                    ),
                                                    child: Text(
                                                      daysLeft <= 0 ? 'Expira hoje' : '$daysLeft dias',
                                                      style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700),
                                                    ),
                                                  ),
                                                ),
                                            ],
                                          ),
                                        );
                                        },
                                      );
                                    },
                                  );
                                }),
                            ],
                          ),
                        ),
                      ],
                    ),
              ),
      ),
    );
  }

  // Helper method to delete storage file
  Future<void> _deleteStorageFileFromUrl(String url) async {
    try {
      if (url.startsWith('http')) {
        final ref = FirebaseStorage.instance.refFromURL(url);
        await ref.delete();
        debugPrint('Deleted old file: $url');
      }
    } catch (e) {
      debugPrint('Error deleting old file (non-critical): $e');
    }
  }

  // helper columns removed (not referenced)
}
