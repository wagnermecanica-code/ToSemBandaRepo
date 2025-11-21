// TÔ SEM BANDA – HOME PAGE (2025, Flutter 3.24+, Dart 3.5+, Riverpod 3.x)
// Arquitetura: Instagram-style multi-profile, busca por área, mapa com clustering, carrossel flutuante, filtros, interesse otimista
// Design System: AppColors, AppTheme, WIREFRAME.md

import "dart:async";
import "package:cloud_firestore/cloud_firestore.dart";
import "package:collection/collection.dart";
import "package:firebase_auth/firebase_auth.dart";
import "package:flutter/material.dart";
import 'package:geohash_plus/geohash_plus.dart';
import "package:geolocator/geolocator.dart";
import "package:google_maps_flutter/google_maps_flutter.dart";
import "package:cached_network_image/cached_network_image.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:google_maps_cluster_manager/google_maps_cluster_manager.dart"
    as gm_cluster;
import "package:to_sem_banda/pages/profile_form_page.dart";
import "package:url_launcher/url_launcher.dart";

import '../models/post.dart';
import '../models/profile.dart';
import '../models/search_params.dart';
import '../providers/posts_provider.dart';
import '../providers/profile_provider.dart';
import '../services/marker_cache_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../utils/debouncer.dart';
import '../widgets/app_loading_overlay.dart';
import '../widgets/empty_state.dart';
import 'view_profile_page.dart';

// Classe utilitária para clustering de posts no mapa
class PostClusterItem implements gm_cluster.ClusterItem {
  final Post post;
  @override
  final LatLng location;
  @override
  String? geohash;

  PostClusterItem(this.post) : location = post.location! {
    geohash =
        Geohash.encode(location.latitude, location.longitude, precision: 10);
  }

  @override
  String toString() {
    return 'PostClusterItem{post: ${post.id}, location: $location}';
  }
}

class HomePage extends ConsumerStatefulWidget {
  final ValueNotifier<SearchParams?>? searchNotifier;
  const HomePage({super.key, this.searchNotifier});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage>
    with TickerProviderStateMixin {
  // ========================= ESTADO DA UI =========================
  GoogleMapController? _mapController;
  final PageController _carouselController = PageController();
  final Debouncer _debouncer = Debouncer(milliseconds: 500);
  final MarkerCacheService _markerCache = MarkerCacheService();
  gm_cluster.ClusterManager<PostClusterItem>? _clusterManager;

  // Estado de dados e filtros (agora gerenciado pelo PostsNotifier)
  List<Post> _visiblePosts = [];
  final Set<String> _sentInterests = <String>{};

  // Estado do Mapa
  Set<Marker> _markers = {};
  LatLng? _currentPos;
  double _currentZoom = 12.0;
  LatLngBounds? _lastSearchBounds;
  bool _showSearchAreaButton = false;
  bool _useClustering = false;

  // Estado do Carrossel e Cards
  String? _activePostId;
  String? _expandedCardId;
  int _currentCarouselPage = 0;

  // Estado dos Filtros
  SearchParams _searchParams = const SearchParams();

  // Perfil ativo (obtido do Riverpod)
  Profile? get _activeProfile => ref.read(profileProvider).value?.activeProfile;

  // ========================= CICLO DE VIDA =========================

  @override
  void initState() {
    super.initState();
    _initializePage();
  }

  @override
  void dispose() {
    _mapController?.dispose();
    _carouselController.dispose();
    super.dispose();
  }

  Future<void> _initializePage() async {
    await _ensureSignedIn();
    await _determinePosition();

    // A carga inicial é gerenciada pelo `build` do PostsNotifier.
    // Podemos ouvir mudanças nos filtros ou na localização para recarregar.
    widget.searchNotifier?.addListener(_onSearchChanged);
  }

  // ========================= MÉTODOS DE LÓGICA =========================

  void _onSearchChanged() {
    final newParams = widget.searchNotifier?.value;
    if (newParams != null) {
      _searchParams = newParams.copyWith(userLocation: _currentPos);
      ref.read(postsNotifierProvider.notifier).applyFilters(_searchParams);
    }
  }

  Future<void> _rebuildMarkers() async {
    if (!mounted) return;

    final shouldCluster = _visiblePosts.length > 200;
    if (_useClustering != shouldCluster) {
      setState(() => _useClustering = shouldCluster);
    }

    if (_useClustering) {
      final clusterItems = _visiblePosts
          .where((p) => p.location != null)
          .map((p) => PostClusterItem(p))
          .toList();

      if (_clusterManager == null) {
        _clusterManager = gm_cluster.ClusterManager<PostClusterItem>(
          clusterItems,
          _updateMarkersFromCluster,
          markerBuilder: _buildClusterMarker,
          stopClusteringZoom: 17,
        );
        if (_mapController != null) {
          _clusterManager!.setMapId(_mapController!.mapId);
        }
      } else {
        _clusterManager!.setItems(clusterItems);
      }
      await _clusterManager!.updateMap();
    } else {
      final newMarkers = <Marker>{};
      for (final post in _visiblePosts) {
        if (post.location != null) {
          final isActive = post.id == _activePostId;
          final markerIcon = await _markerCache.getMarker(post.type, isActive);
          newMarkers.add(Marker(
            markerId: MarkerId(post.id),
            position: post.location!,
            icon: markerIcon,
            anchor: const Offset(0.5, 0.5),
            zIndex: isActive ? 10 : (post.type == 'band' ? 2 : 1),
            onTap: () => _onMarkerTapped(post),
          ));
        }
      }
      if (mounted) {
        setState(() {
          _markers = newMarkers;
        });
      }
    }
  }

  void _onMarkerTapped(Post post) async {
    if (!mounted) return;
    setState(() => _activePostId = post.id);

    final index = _visiblePosts.indexWhere((p) => p.id == post.id);
    if (index != -1 && _carouselController.hasClients) {
      await _carouselController.animateToPage(
        index,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }

    try {
      if (post.location != null) {
        await _mapController
            ?.animateCamera(CameraUpdate.newLatLng(post.location!));
      }
    } catch (e) {
      debugPrint('Erro ao animar câmera: $e');
    }

    await _rebuildMarkers();

    if (post.authorUid.isNotEmpty) {
      _showMarkerOptionsSheet(context, post);
    }
  }

  Future<BitmapDescriptor> _getClusterIcon(int count) async {
    // TODO: Implementar um ícone de cluster customizado
    return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure);
  }

  Future<void> _centerMapOnPosts(List<Post> posts) async {
    if (posts.isEmpty || _mapController == null) return;

    try {
      final bounds = posts
          .where((p) => p.location != null)
          .map((p) => p.location!)
          .fold<LatLngBounds?>(null, (bounds, loc) {
        if (bounds == null) {
          return LatLngBounds(southwest: loc, northeast: loc);
        }
        return bounds.union(LatLngBounds(
          southwest: LatLng(
              loc.latitude < bounds.southwest.latitude
                  ? loc.latitude
                  : bounds.southwest.latitude,
              loc.longitude < bounds.southwest.longitude
                  ? loc.longitude
                  : bounds.southwest.longitude),
          northeast: LatLng(
              loc.latitude > bounds.northeast.latitude
                  ? loc.latitude
                  : bounds.northeast.latitude,
              loc.longitude > bounds.northeast.longitude
                  ? loc.longitude
                  : bounds.northeast.longitude),
        ));
      });

      if (bounds != null) {
        await _mapController!
            .animateCamera(CameraUpdate.newLatLngBounds(bounds, 100));
      }
    } catch (e) {
      debugPrint('Erro ao centralizar mapa: $e');
    }
  }

  Future<void> _ensureSignedIn() async {
    try {
      final auth = FirebaseAuth.instance;
      if (auth.currentUser == null) {
        final cred = await auth.signInAnonymously();
        debugPrint('HomePage: signed in anonymously uid=${cred.user?.uid}');
      }
    } catch (e, st) {
      debugPrint('HomePage: _ensureSignedIn failed: $e\n$st');
    }
  }

  void _updateMarkersFromCluster(Set<Marker> markers) {
    if (!mounted) return;
    setState(() {
      _markers = markers;
    });
  }

  Future<Marker> _buildClusterMarker(
      gm_cluster.Cluster<PostClusterItem> cluster) async {
    if (cluster.isMultiple) {
      return Marker(
        markerId: MarkerId('cluster_${cluster.getId()}'),
        position: cluster.location,
        icon: await _getClusterIcon(cluster.count),
        onTap: () {
          _mapController?.animateCamera(
              CameraUpdate.newLatLngZoom(cluster.location, _currentZoom + 2));
        },
      );
    } else {
      final item = cluster.items.first;
      final post = item.post;
      final isActive = post.id == _activePostId;
      final markerIcon = await _markerCache.getMarker(post.type, isActive);
      return Marker(
        markerId: MarkerId(post.id),
        position: post.location!,
        icon: markerIcon,
        anchor: const Offset(0.5, 0.5),
        zIndex: isActive ? 10 : (post.type == 'band' ? 2 : 1),
        onTap: () => _onMarkerTapped(post),
      );
    }
  }

  void _showMarkerOptionsSheet(BuildContext context, Post post) {
    if (post.authorUid.isEmpty) return;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => FutureBuilder<bool>(
        future: _isMyProfile(post.authorProfileId),
        builder: (context, snapshot) {
          final isOwner = snapshot.data ?? false;
          return SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 8),
                Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2))),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(children: [
                    Icon(post.type == 'band' ? Icons.groups : Icons.person,
                        color:
                            post.type == 'band' ? Colors.orange : Colors.blue),
                    const SizedBox(width: 8),
                    Expanded(
                        child: Text(
                      post.content.isNotEmpty
                          ? post.content
                          : (post.type == 'band'
                              ? 'Vaga de Banda'
                              : 'Procura Músico'),
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    )),
                  ]),
                ),
                const SizedBox(height: 8),
                const Divider(),
                ListTile(
                  leading:
                      const Icon(Icons.account_circle, color: AppColors.primary),
                  title: const Text('Ver Perfil do Autor'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => ViewProfilePage(
                            userId: post.authorUid,
                            profileId: post.authorProfileId)));
                  },
                ),
                if (!isOwner)
                  ListTile(
                    leading: const Icon(Icons.favorite, color: Colors.pink),
                    title: const Text('Tenho Interesse'),
                    onTap: () {
                      Navigator.pop(context);
                      _showInterestDialog(context, post);
                    },
                  ),
                const SizedBox(height: 16),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showInterestDialog(BuildContext context, Post post) {
    if (post.id.isEmpty || post.authorUid.isEmpty) return;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(children: [
          Icon(Icons.favorite,
              color:
                  post.type == 'band' ? AppColors.accent : AppColors.primary),
          const SizedBox(width: 8),
          const Expanded(child: Text('Demonstrar Interesse')),
        ]),
        content: const Text(
            'Deseja enviar uma notificação ao autor deste post informando seu interesse?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _sendInterestOptimistically(post);
            },
            style: ElevatedButton.styleFrom(
                backgroundColor:
                    post.type == 'band' ? AppColors.accent : AppColors.primary),
            child: const Text('Enviar'),
          ),
        ],
      ),
    );
  }

  Future<void> _sendInterestNotification(Post post) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    final activeProfile = _activeProfile;
    if (currentUser == null || activeProfile == null) {
      throw Exception('Usuário não autenticado ou perfil não ativo.');
    }

    // TODO: Usar o NotificationService para criar a notificação.
    // Temporariamente, usamos o método antigo para manter a funcionalidade.
    await FirebaseFirestore.instance.collection('interests').add({
      'postId': post.id,
      'postAuthorUid': post.authorUid,
      'postAuthorProfileId': post.authorProfileId,
      'interestedUid': currentUser.uid,
      'interestedProfileId': activeProfile.profileId,
      'interestedName': activeProfile.name,
      'createdAt': FieldValue.serverTimestamp(),
      'read': false,
    });
  }

  Future<void> _sendInterestOptimistically(Post post) async {
    if (!mounted) return;
    setState(() => _sentInterests.add(post.id));

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(children: [
          Icon(Icons.favorite, color: Colors.white),
          SizedBox(width: 12),
          Text('Interesse enviado! 🎵'),
        ]),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );

    try {
      await _sendInterestNotification(post);
    } catch (e) {
      debugPrint('Erro no envio otimista de interesse: $e');
      if (mounted) {
        setState(() => _sentInterests.remove(post.id));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(children: [
              const Icon(Icons.error, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(child: Text('Erro ao enviar interesse: $e'))
            ]),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  // ========================= UI BUILD =========================

  @override
  Widget build(BuildContext context) {
    final postsAsync = ref.watch(postsNotifierProvider);

    return Theme(
      data: AppTheme.light,
      child: Scaffold(
        body: postsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) {
            debugPrintStack(stackTrace: stack, label: err.toString());
            return Center(child: Text('Erro ao carregar posts: $err'));
          },
          data: (posts) {
            // Atualiza os posts visíveis quando o provider muda
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) _onMapIdle();
            });

            return Stack(
              children: [
                _buildMapView(),
                if (_showSearchAreaButton)
                  Positioned(
                    top: 32,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24)),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
                          elevation: 4,
                        ),
                        icon: const Icon(Icons.search),
                        label: const Text('Buscar nesta área'),
                        onPressed: _searchThisArea,
                      ),
                    ),
                  ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: _buildFloatingCarousel(posts),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildMapView() {
    final initial = _currentPos ?? const LatLng(-23.55052, -46.633308);
    return GoogleMap(
      initialCameraPosition: CameraPosition(target: initial, zoom: _currentZoom),
      myLocationEnabled: true,
      myLocationButtonEnabled: true,
      zoomControlsEnabled: false,
      mapToolbarEnabled: false,
      onMapCreated: (c) async {
        _mapController = c;
        await Future.delayed(const Duration(milliseconds: 200));
        if (_mapController != null) {
          _lastSearchBounds = await _mapController!.getVisibleRegion();
        }
        await _onMapIdle();
      },
      markers: _markers,
      onCameraMove: (pos) {
        _currentZoom = pos.zoom;
        _clusterManager?.onCameraMove(pos);
      },
      onCameraIdle: () async {
        await _onMapIdle();
        _clusterManager?.updateMap();
      },
    );
  }

  Future<void> _onMapIdle() async {
    final allPosts = ref.read(postsNotifierProvider).value ?? [];
    if (_mapController == null || !mounted) return;

    try {
      final bounds = await _mapController!.getVisibleRegion();
      if (!_boundsEqual(bounds, _lastSearchBounds)) {
        if (mounted) setState(() => _showSearchAreaButton = true);
      }

      final visible = allPosts
          .where((post) =>
              post.location != null && _latLngInBounds(post.location!, bounds))
          .toList();

      final visibleIds = visible.map((p) => p.id).toSet();
      final currentVisibleIds = _visiblePosts.map((p) => p.id).toSet();

      if (!const SetEquality().equals(visibleIds, currentVisibleIds)) {
        setState(() => _visiblePosts = visible);
        await _rebuildMarkers();
      }
    } catch (e) {
      debugPrint('Erro ao obter bounds do mapa: $e');
      if (mounted && _visiblePosts.isEmpty) {
        setState(() => _visiblePosts = allPosts);
        await _rebuildMarkers();
      }
    }
  }

  bool _boundsEqual(LatLngBounds a, LatLngBounds? b) {
    if (b == null) return false;
    const threshold = 0.01;
    return (a.northeast.latitude - b.northeast.latitude).abs() < threshold &&
        (a.northeast.longitude - b.northeast.longitude).abs() < threshold &&
        (a.southwest.latitude - b.southwest.latitude).abs() < threshold &&
        (a.southwest.longitude - b.southwest.longitude).abs() < threshold;
  }

  Future<void> _searchThisArea() async {
    if (_mapController == null) return;
    if (mounted) setState(() => _showSearchAreaButton = false);

    try {
      final bounds = await _mapController!.getVisibleRegion();
      _lastSearchBounds = bounds;
      final center = LatLng(
        (bounds.northeast.latitude + bounds.southwest.latitude) / 2,
        (bounds.northeast.longitude + bounds.southwest.longitude) / 2,
      );
      final radiusKm = Geolocator.distanceBetween(
              center.latitude,
              center.longitude,
              bounds.northeast.latitude,
              bounds.northeast.longitude) /
          1000;

      final newParams = _searchParams.copyWith(
        userLocation: center,
        maxDistanceKm: radiusKm,
      );
      ref.read(postsNotifierProvider.notifier).applyFilters(newParams);
    } catch (e) {
      debugPrint("Erro ao buscar nesta área: $e");
    }
  }

  bool _latLngInBounds(LatLng p, LatLngBounds b) {
    return (p.latitude >= b.southwest.latitude &&
            p.latitude <= b.northeast.latitude) &&
        (p.longitude >= b.southwest.longitude &&
            p.longitude <= b.northeast.longitude);
  }

  Widget _buildFloatingCarousel(List<Post> posts) {
    if (_visiblePosts.isEmpty) {
      return const Align(
        alignment: Alignment.bottomCenter,
        child: EmptyState(
          icon: Icons.explore_outlined,
          title: 'Nenhum post encontrado',
          subtitle:
              'Use os filtros ou navegue pelo mapa para encontrar músicos e bandas.',
          actionLabel: 'Ver todos', // TODO: Implementar
        ),
      );
    }

    return Align(
      alignment: Alignment.bottomCenter,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 200,
            child: PageView.builder(
              controller: _carouselController,
              itemCount: _visiblePosts.length,
              onPageChanged: (idx) async {
                if (!mounted) return;
                final post = _visiblePosts[idx];
                setState(() {
                  _currentCarouselPage = idx;
                  _activePostId = post.id;
                });

                if (post.location != null) {
                  try {
                    await _mapController
                        ?.animateCamera(CameraUpdate.newLatLng(post.location!));
                  } catch (e) {
                    debugPrint('Erro ao animar câmera: $e');
                  }
                  await _rebuildMarkers();
                }
              },
              itemBuilder: (context, idx) {
                final post = _visiblePosts[idx];
                final isActive = post.id == _activePostId;
                final isExpanded = post.id == _expandedCardId;
                return AnimatedScale(
                  scale: isActive ? 1.0 : 0.95,
                  duration: const Duration(milliseconds: 200),
                  child: PostCard(
                    post: post,
                    isActive: isActive,
                    isExpanded: isExpanded,
                    currentActiveProfileId: _activeProfile?.profileId,
                    isInterestSent: _sentInterests.contains(post.id),
                    onTap: () async {
                      if (!mounted) return;
                      setState(
                          () => _expandedCardId = isExpanded ? null : post.id);
                      if (post.location != null) {
                        try {
                          await _mapController?.animateCamera(
                              CameraUpdate.newLatLngZoom(post.location!, 14.0));
                        } catch (e) {
                          debugPrint('Erro ao animar câmera: $e');
                        }
                        await _rebuildMarkers();
                      }
                    },
                    onInterest: _sendInterestOptimistically,
                  ),
                );
              },
            ),
          ),
          if (_visiblePosts.length > 1)
            Padding(
              padding: const EdgeInsets.only(bottom: 16, top: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _visiblePosts.length,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: index == _currentCarouselPage
                          ? AppColors.primary
                          : Colors.white.withOpacity(0.5),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }
    if (permission == LocationPermission.deniedForever) return;

    try {
      final position = await Geolocator.getCurrentPosition();
      if (mounted) {
        setState(
            () => _currentPos = LatLng(position.latitude, position.longitude));
        _mapController?.animateCamera(CameraUpdate.newLatLng(_currentPos!));
      }
    } catch (e) {
      debugPrint("Error getting location: $e");
    }
  }

  Future<bool> _isMyProfile(String profileId) async {
    return _activeProfile?.profileId == profileId;
  }
}

// ============================================================================
// PostCard Widget - Separated component for better maintainability
// ============================================================================
class PostCard extends StatelessWidget {
  final Post post;
  final bool isActive;
  final bool isExpanded;
  final VoidCallback onTap;
  final Function(Post) onInterest;
  final String? currentActiveProfileId;
  final bool isInterestSent;

  const PostCard({
    super.key,
    required this.post,
    required this.isActive,
    required this.isExpanded,
    required this.onTap,
    required this.onInterest,
    this.currentActiveProfileId,
    this.isInterestSent = false,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor =
        post.type == 'band' ? AppColors.accent : AppColors.primary;
    final lightColor = primaryColor.withOpacity(0.1);
    final borderColor = primaryColor.withOpacity(0.3);
    final textPrimary = AppColors.textPrimary;
    final textSecondary = AppColors.textSecondary;
    final surfaceColor = AppColors.surface;
    final borderColorTheme = AppColors.border;

    final isOwner = post.authorProfileId.isNotEmpty &&
        post.authorProfileId == currentActiveProfileId;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          splashColor: primaryColor.withOpacity(0.1),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            height: isExpanded ? 220 : 180,
            decoration: BoxDecoration(
              color: surfaceColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isActive ? primaryColor : borderColorTheme,
                width: isActive ? 2 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: (isActive ? primaryColor : Colors.black)
                      .withOpacity(isActive ? 0.2 : 0.08),
                  blurRadius: isActive ? 16 : 8,
                  offset: Offset(0, isActive ? 4 : 2),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 100,
                  child: _buildImage(post.photoUrl ?? '', post.type,
                      primaryColor, lightColor),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildActionButtons(context, post.youtubeLink, isOwner,
                            primaryColor, textSecondary),
                        const SizedBox(height: 8),
                        _buildTypeHeader(post.type, post.seekingMusicians,
                            primaryColor, textPrimary),
                        const SizedBox(height: 6),
                        if (post.level.isNotEmpty) ...[
                          _buildLevelBadge(post.level, textPrimary),
                          const SizedBox(height: 4),
                        ],
                        if (post.type == 'musician' &&
                            post.instruments.isNotEmpty)
                          _buildChips(post.instruments, post.genres,
                              primaryColor, textSecondary)
                        else if (post.type == 'band' &&
                            post.seekingMusicians.isNotEmpty)
                          _buildChips(post.seekingMusicians, post.genres,
                              primaryColor, textSecondary),
                        const Spacer(),
                        _buildBottomBar(
                            context,
                            isExpanded,
                            post.distanceKm,
                            post.city,
                            post.authorUid,
                            post.authorProfileId,
                            primaryColor,
                            textPrimary,
                            textSecondary,
                            borderColor),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImage(
      String img, String type, Color primaryColor, Color lightColor) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(18),
        bottomLeft: Radius.circular(18),
      ),
      child: SizedBox(
        height: double.infinity,
        width: double.infinity,
        child: img.isNotEmpty
            ? CachedNetworkImage(
                imageUrl: img,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(color: lightColor),
                errorWidget: (context, url, error) => Container(
                    color: lightColor,
                    child: Icon(type == 'band' ? Icons.groups : Icons.person,
                        size: 40, color: primaryColor)),
              )
            : Container(
                color: lightColor,
                child: Icon(type == 'band' ? Icons.groups : Icons.person,
                    size: 40, color: primaryColor),
              ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, String? youtubeLink,
      bool isOwner, Color primaryColor, Color textSecondary) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (youtubeLink != null && youtubeLink.isNotEmpty)
          InkWell(
            onTap: () async {
              final uri = Uri.parse(youtubeLink);
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              }
            },
            child:
                const Icon(Icons.play_circle_filled, color: Colors.red, size: 24),
          ),
        const Spacer(),
        if (!isOwner)
          InkWell(
            onTap: () => onInterest(post),
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: isInterestSent
                    ? Colors.pink.withOpacity(0.2)
                    : primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.favorite,
                  size: 16,
                  color: isInterestSent ? Colors.pink : primaryColor),
            ),
          ),
      ],
    );
  }

  Widget _buildTypeHeader(
    String type,
    List<String> seekingMusicians,
    Color primaryColor,
    Color textPrimary,
  ) {
    String headerText =
        type == 'band' ? 'Banda procura músico' : 'Músico procura banda';
    return Row(
      children: [
        Icon(type == 'band' ? Icons.groups : Icons.person,
            size: 18, color: primaryColor),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            headerText,
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: textPrimary),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildLevelBadge(String level, Color textPrimary) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.accent.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(level,
          style: TextStyle(
              color: textPrimary, fontWeight: FontWeight.w600, fontSize: 11)),
    );
  }

  Widget _buildChips(List<String> items1, List<String> items2,
      Color primaryColor, Color textSecondary) {
    final allItems = [...items1, ...items2];
    if (allItems.isEmpty) return const SizedBox.shrink();
    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: allItems
          .take(3)
          .map((item) => _buildChip(
              item,
              items1.contains(item) ? Icons.music_note : Icons.library_music,
              primaryColor,
              textSecondary))
          .toList(),
    );
  }

  Widget _buildChip(
      String label, IconData icon, Color iconColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: iconColor),
          const SizedBox(width: 4),
          Text(label,
              style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: textColor)),
        ],
      ),
    );
  }

  Widget _buildBottomBar(
    BuildContext context,
    bool isExpanded,
    double? distanceKm,
    String city,
    String authorUid,
    String authorProfileId,
    Color primaryColor,
    Color textPrimary,
    Color textSecondary,
    Color borderColor,
  ) {
    return Container(
      padding: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
          border: Border(top: BorderSide(color: borderColor, width: 0.5))),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (post.content.isNotEmpty)
            Icon(
                isExpanded
                    ? Icons.keyboard_arrow_up
                    : Icons.keyboard_arrow_down,
                size: 16,
                color: primaryColor),
          if (post.content.isNotEmpty) const SizedBox(width: 4),
          if (distanceKm != null)
            Expanded(
              child: Text(
                '${distanceKm.toStringAsFixed(1)}km${city.isNotEmpty ? ' • $city' : ''}',
                style: TextStyle(
                    fontSize: 11,
                    color: textPrimary,
                    fontWeight: FontWeight.w600),
                overflow: TextOverflow.ellipsis,
              ),
            )
          else if (city.isNotEmpty)
            Expanded(
              child: Text(city,
                  style: TextStyle(
                      fontSize: 11,
                      color: textSecondary,
                      fontWeight: FontWeight.w500),
                  overflow: TextOverflow.ellipsis),
            )
          else
            const Spacer(),
          if (authorUid.isNotEmpty)
            InkWell(
              onTap: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => ViewProfilePage(
                      userId: authorUid, profileId: authorProfileId))),
              child: const Icon(Icons.arrow_forward_ios, size: 14),
            ),
        ],
      ),
    );
  }
}