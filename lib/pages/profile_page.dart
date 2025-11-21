import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'home_page.dart';
import 'package:to_sem_banda/pages/edit_profile_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> with SingleTickerProviderStateMixin {
  // Dados do usuário
  String? _name;
  String? _cep;
  String? _city;
  String? _neighborhood;
  String? _availability;
  String? _level;
  String? _photoUrl;
  String? _youtubeLink;
  List<String> _gallery = [];
  Set<String> _instruments = {};
  Set<String> _genres = {};
  bool _showDistance = true;
  bool _notifyNearby = true;
  bool _isBand = false;
  bool _loadingProfile = false;
  late TabController _tabController;
  String? _lastActiveProfileId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadProfileFromFirestore();
    _listenToProfileChanges();
  }
  
  /// Escuta mudanças no activeProfileId para recarregar dados
  void _listenToProfileChanges() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    
    FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .snapshots()
        .listen((snapshot) {
      if (!mounted) return;
      
      final data = snapshot.data();
      if (data == null) return;
      
      final currentActiveProfileId = data['activeProfileId'] as String?;
      
      // Se o activeProfileId mudou, recarregar perfil
      if (currentActiveProfileId != _lastActiveProfileId) {
        _lastActiveProfileId = currentActiveProfileId;
        _loadProfileFromFirestore();
      }
    });
  }

  // Garante que só retorna lista de strings válidas
  List<String> _asStringList(dynamic val) {
    if (val == null) return [];
    if (val is List) {
      return val.where((e) => e is String && e.isNotEmpty).map((e) => e as String).toList();
    }
    if (val is String && val.isNotEmpty) return [val];
    return [];
  }

  // Carrega dados do usuário no Firestore
  Future<void> _loadProfileFromFirestore() async {
    setState(() => _loadingProfile = true);
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    
    final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    if (!doc.exists) { 
      setState(() => _loadingProfile = false); 
      return; 
    }
    
    final data = doc.data()!;
    final activeProfileId = data['activeProfileId'] as String?;
    
    // Determinar qual perfil carregar
    Map<String, dynamic> profileData;
    
    // Se há um activeProfileId e é diferente do user.uid, buscar em profiles
    if (activeProfileId != null && activeProfileId != user.uid) {
      final profilesList = data['profiles'] as List<dynamic>?;
      if (profilesList != null) {
        try {
          final profile = profilesList
              .cast<Map<String, dynamic>>()
              .firstWhere((p) => p['profileId'] == activeProfileId);
          profileData = profile;
        } catch (_) {
          // Se não encontrou, usar perfil principal
          profileData = data;
        }
      } else {
        profileData = data;
      }
    } else {
      // Usar perfil principal
      profileData = data;
    }
    
    // Carregar dados do perfil ativo
    _name = profileData['name'] ?? '';
    _cep = profileData['cep'] ?? '';
    _city = profileData['city'] ?? '';
    _neighborhood = profileData['neighborhood'] ?? profileData['bairro'] ?? '';
    _availability = profileData['availability'] ?? '';
    _level = profileData['level'] ?? '';
    _photoUrl = profileData['photoUrl'];
    _youtubeLink = profileData['youtubeLink'];
    _showDistance = profileData['showDistance'] ?? data['showDistance'] ?? true;
    _notifyNearby = profileData['notifyNearby'] ?? data['notifyNearby'] ?? true;
    _isBand = profileData['isBand'] ?? false;
    _instruments = {..._asStringList(profileData['instruments'])};
    _genres = {..._asStringList(profileData['genres'])};
    _gallery = _asStringList(profileData['gallery']);
    
    if (mounted) setState(() => _loadingProfile = false);
  }

  // Cria ImageProvider seguro padrão
  ImageProvider<Object> createImageProvider(String? pathOrUrl) {
    if (pathOrUrl == null || pathOrUrl.isEmpty) {
      return const AssetImage('assets/avatar_placeholder.png');
    }

    if (pathOrUrl.startsWith('http')) {
      return CachedNetworkImageProvider(pathOrUrl);
    }

    try {
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
        return FileImage(f);
      } else {
        return const AssetImage('assets/avatar_placeholder.png');
      }
    } catch (e) {
      return const AssetImage('assets/avatar_placeholder.png');
    }
  }

  // Formata e abre link externo
  Widget buildYoutubeLink(String? url) {
    if (url == null || url.isEmpty) return const SizedBox.shrink();
    return InkWell(
      onTap: () async {
        try {
          final uri = Uri.tryParse(url);
          if (uri != null && (uri.scheme == 'http' || uri.scheme == 'https')) {
            if (await canLaunchUrl(uri)) {
              launchUrl(uri, mode: LaunchMode.externalApplication);
            }
          }
        } catch (_) {
          // ignore invalid urls or file paths
        }
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.link, color: Colors.blue[700], size: 18),
          const SizedBox(width: 5),
          Text(
            url,
            style: TextStyle(color: Colors.blue[700], decoration: TextDecoration.underline),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // Para player Youtube
  String? getYoutubeVideoId(String? url) {
    if (url == null || url.isEmpty) return null;
    return YoutubePlayer.convertUrlToId(url);
  }

  // Galeria Instagram-style
  Widget buildGalleryTab() {
    if (_gallery.isEmpty) {
      return const Center(child: Text('Nenhuma foto adicionada à galeria.'));
    }
    return GridView.builder(
      padding: EdgeInsets.zero,
      itemCount: _gallery.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 2,
        crossAxisSpacing: 2,
        childAspectRatio: 1,
      ),
      itemBuilder: (ctx, i) {
        final img = _gallery[i];
        try {
          if (img.startsWith('http')) {
            return CachedNetworkImage(
              imageUrl: img,
              fit: BoxFit.cover,
              memCacheWidth: 320,
              memCacheHeight: 320,
              placeholder: (context, url) => Container(
                color: Colors.grey[200],
                child: const Center(child: CircularProgressIndicator()),
              ),
              errorWidget: (context, url, error) => Container(
                color: Colors.grey[200],
                child: const Icon(Icons.broken_image),
              ),
            );
          }
          String candidate = img;
          if (candidate.startsWith('file://')) {
            try {
              candidate = Uri.parse(candidate).toFilePath();
            } catch (_) {
              candidate = candidate.replaceFirst('file://', '');
            }
          }
          final f = File(candidate);
          if (f.existsSync()) {
            return Image.file(f, fit: BoxFit.cover);
          }
          return Container(color: Colors.grey[200], child: const Icon(Icons.broken_image));
        } catch (e) {
          return Container(color: Colors.grey[200], child: const Icon(Icons.broken_image));
        }
      },
    );
  }

  Widget buildMediaTab() {
    final videoId = getYoutubeVideoId(_youtubeLink);
    if (_youtubeLink == null || !_youtubeLink!.contains('youtu') || videoId == null) {
      return const Center(child: Text('Nenhum vídeo do YouTube cadastrado.'));
    }
    return YoutubePlayer(
      controller: YoutubePlayerController(
        initialVideoId: videoId,
        flags: const YoutubePlayerFlags(autoPlay: false, mute: false),
      ),
      showVideoProgressIndicator: true,
      width: double.infinity,
      aspectRatio: 16/9,
    );
  }

  // AppBar customizado com ações
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      title: const Text("Meu Perfil"),
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.home),
        onPressed: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const HomePage()),
          );
        },
        tooltip: 'Home',
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.edit),
          tooltip: 'Editar',
          onPressed: () {
            // Redireciona para tela de edição de perfil (com dados iniciais)
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => EditProfilePage(
                initialName: _name,
                initialCep: _cep,
                initialAvailability: _availability,
                initialLevel: _level,
                initialPhotoUrl: _photoUrl,
                initialInstruments: _instruments.toList(),
                initialGenres: _genres.toList(),
                initialShowDistance: _showDistance,
                initialNotifyNearby: _notifyNearby,
                    initialIsBand: _isBand,
              )),
            );
          },
        ),
      ],
      // Transparent effect
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      elevation: 0,
      scrolledUnderElevation: 0,
    );
  }

  @override
  Widget build(BuildContext context) {
    return _loadingProfile
        ? const Scaffold(body: Center(child: CircularProgressIndicator()))
        : Scaffold(
            appBar: _buildAppBar(context),
            body: SafeArea(
              child: Column(
                children: [
                  // -- HEADER DO PERFIL (Avatar e estatísticas estilo Instagram) ------
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      children: [
                        // Avatar circular à esquerda
                        CircleAvatar(
                          radius: 44,
                          backgroundImage: createImageProvider(_photoUrl),
                        ),
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              // Removido do header: agora 'Nível' será exibido como um Chip junto com instrumentos/gêneros
                              // Coluna 2: Localização (CEP)
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text("Localização", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                  const SizedBox(height: 3),
                                  Text(_city != null && _city!.isNotEmpty ? (_neighborhood != null && _neighborhood!.isNotEmpty ? '${_neighborhood!}, ${_city!}' : _city!) : (_cep ?? '-'), style: const TextStyle(fontSize: 13)),
                                ],
                              ),
                              // Coluna 3: Disponibilidade
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text("Dispon.", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                  const SizedBox(height: 3),
                                  Text(_availability ?? "-", style: const TextStyle(fontSize: 13)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // -- NOME e TAGS CHIPS (Instrumentos e Estilos) ------
                  Padding(
                    padding: const EdgeInsets.only(left: 16, right: 16, top: 6),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Nome em destaque, fonte grande e negrito
                        Text(_name ?? '', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 6),
                        // Chips dos instrumentos e dos estilos/gêneros
                        Wrap(
                          spacing: 7,
                          runSpacing: 2,
                            children: [
                            // Exibe nível como Chip (mesma posição/configuração dos chips de instrumento/gênero)
                            Chip(
                              label: Text(_level != null && _level!.isNotEmpty ? _level! : 'Nível: -'),
                              backgroundColor: Colors.deepPurple[50],
                            ),
                            ..._instruments.map((e) => Chip(label: Text(e), backgroundColor: Colors.deepPurple[50])),
                            ..._genres.map((e) => Chip(label: Text(e), backgroundColor: Colors.blue[50])),
                          ],
                        ),
                        const SizedBox(height: 6),
                        // Link clicável (YouTube)
                        buildYoutubeLink(_youtubeLink),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  // -- TabBar (Galeria / Mídia) -----------------
                  TabBar(
                    controller: _tabController,
                    indicatorColor: Colors.deepPurple,
                    labelColor: Colors.deepPurple,
                    unselectedLabelColor: Colors.black,
                    tabs: const [
                      Tab(icon: Icon(Icons.grid_on_outlined), text: "Galeria"),
                      Tab(icon: Icon(Icons.play_circle_outline), text: "Mídia"),
                    ],
                  ),
                  // -- Conteúdo das Abas -------------------------
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        buildGalleryTab(),
                        buildMediaTab(),
                      ],
                    ),
                  ),
                  // -- Configurações/Privacidade ------------------
                  // switches removed from profile page — editing is available on EditProfilePage
                ],
              ),
            ),
          );
  }
}