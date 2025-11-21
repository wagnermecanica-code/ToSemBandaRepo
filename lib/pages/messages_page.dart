import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../theme/app_colors.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/profile_provider.dart';
import '../widgets/conversation_item.dart';
import '../widgets/empty_state.dart';
import 'chat_detail_page.dart';

/// Tela principal de mensagens
/// Lista todas as conversas do usuário com preview da última mensagem
class MessagesPage extends ConsumerStatefulWidget {
  const MessagesPage({super.key});
  @override
  ConsumerState<MessagesPage> createState() => _MessagesPageState();
}
class _MessagesPageState extends ConsumerState<MessagesPage> {

  // Controllers e estado
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final String _searchQuery = '';
  StreamSubscription? _conversationsSubscription;
  Box? _conversationsBox;
  List<Map<String, dynamic>> _conversations = [];
  bool _isLoading = true;
  
  // Paginação
  DocumentSnapshot? _lastConversationDoc;
  bool _hasMoreConversations = true;
  final int _conversationsPerPage = 20;
  bool _isLoadingMore = false;
  
  // Seleção múltipla
  bool _isSelectionMode = false;
    /// Carrega mais conversas para paginação
    Future<void> _loadMoreConversations() async {
      if (_isLoadingMore || !_hasMoreConversations) return;
      setState(() => _isLoadingMore = true);
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        setState(() => _isLoadingMore = false);
        return;
      }
      final profileState = ref.read(profileProvider);
      final activeProfile = profileState.value?.activeProfile;
      if (activeProfile == null) {
        setState(() => _isLoadingMore = false);
        return;
      }
      final currentProfileId = activeProfile.profileId;
      final query = FirebaseFirestore.instance
          .collection('conversations')
          .where('participantProfiles', arrayContains: currentProfileId)
          .where('archived', isEqualTo: false)
          .orderBy('lastMessageTimestamp', descending: true)
          .startAfterDocument(_lastConversationDoc!)
          .limit(_conversationsPerPage);
      final querySnapshot = await query.get();
      if (querySnapshot.docs.isEmpty) {
        setState(() {
          _hasMoreConversations = false;
          _isLoadingMore = false;
        });
        return;
      }
      final userFutures = querySnapshot.docs.map((doc) {
        final data = doc.data();
        final participantProfiles = (data['participantProfiles'] as List?)?.cast<String>() ?? [];
        final participantUsers = (data['participants'] as List?)?.cast<String>() ?? [];
        final otherProfileId = participantProfiles.firstWhere(
          (id) => id != currentProfileId,
          orElse: () => '',
        );
        final otherUserId = participantUsers.firstWhere(
          (id) => id != currentUser.uid,
          orElse: () => currentUser.uid,
        );
        return {
          'doc': doc,
          'otherProfileId': otherProfileId,
          'otherUserId': otherUserId,
          'future': otherUserId.isNotEmpty
              ? FirebaseFirestore.instance.collection('users').doc(otherUserId).get()
              : Future.value(null),
        };
      }).toList();
      final userSnapshots = await Future.wait(
        userFutures.map((item) => item['future'] as Future<DocumentSnapshot?>).toList(),
      );
      final newConversations = <Map<String, dynamic>>[];
      for (var i = 0; i < userFutures.length; i++) {
        final item = userFutures[i];
        final doc = item['doc'] as QueryDocumentSnapshot;
        final data = doc.data() as Map<String, dynamic>;
        final otherProfileId = item['otherProfileId'] as String;
        final otherUserId = item['otherUserId'] as String;
        final otherUserDoc = userSnapshots[i];
        if (otherProfileId.isEmpty || otherUserDoc == null || !otherUserDoc.exists) {
          continue;
        }
        final otherUserData = otherUserDoc.data() as Map<String, dynamic>;
        String otherProfileName = 'Usuário';
        String otherProfilePhoto = '';
        bool otherProfileIsBand = false;
        if (otherProfileId == otherUserId) {
          otherProfileName = otherUserData['name'] ?? 'Usuário';
          otherProfilePhoto = otherUserData['photoUrl'] ?? '';
          otherProfileIsBand = otherUserData['isBand'] ?? false;
        } else {
          final profilesList = otherUserData['profiles'] as List<dynamic>?;
          if (profilesList != null) {
            try {
              final profileData = profilesList
                  .cast<Map<String, dynamic>>() 
                  .firstWhere((p) => p['profileId'] == otherProfileId);
              otherProfileName = profileData['name'] ?? 'Usuário';
              otherProfilePhoto = profileData['photoUrl'] ?? '';
              otherProfileIsBand = profileData['isBand'] ?? false;
            } catch (_) {
              otherProfileName = otherUserData['name'] ?? 'Usuário';
              otherProfilePhoto = otherUserData['photoUrl'] ?? '';
            }
          }
        }
        final unreadCount = (data['unreadCount'] as Map?)?.containsKey(currentProfileId) ?? false
            ? (data['unreadCount'][currentProfileId] as int?) ?? 0
            : 0;
        newConversations.add({
          'conversationId': doc.id,
          'otherUserId': otherUserId,
          'otherProfileId': otherProfileId,
          'otherUserName': otherProfileName,
          'otherUserPhoto': otherProfilePhoto,
          'lastMessage': data['lastMessage'] ?? '',
          'lastMessageTimestamp': data['lastMessageTimestamp'] as Timestamp?,
          'unreadCount': unreadCount,
          'isOnline': otherUserData['isOnline'] ?? false,
          'type': otherProfileIsBand ? 'band' : 'musician',
        });
      }
      setState(() {
        _conversations.addAll(newConversations);
        _isLoadingMore = false;
        if (querySnapshot.docs.isNotEmpty) {
          _lastConversationDoc = querySnapshot.docs.last;
        }
      });
      _conversationsBox?.put('conversations', _conversations);
    }

    /// Carrega conversas do cache local Hive
    Future<void> _loadConversationsFromCache() async {
      final cached = _conversationsBox?.get('conversations') as List<dynamic>?;
      if (cached != null) {
        setState(() {
          _conversations = List<Map<String, dynamic>>.from(cached);
          _isLoading = false;
        });
      }
    }
  final Set<String> _selectedConversations = {};

  // Paleta de cores
  static final Color _primaryColor = AppColors.primary;
  static final Color _secondaryColor = AppColors.accent;
  static const Color _backgroundColor = Color(0xFFFFFFFF);

  @override
  void initState() {
    super.initState();
    // Configurar locale pt_BR para timeago
    timeago.setLocaleMessages('pt_BR', timeago.PtBrMessages());
    _initCacheAndLoad();
    // Listener para paginação (carregar mais ao rolar até 90%)
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= 
          _scrollController.position.maxScrollExtent * 0.9) {
        _loadMoreConversations();
      }
    });

  }

  Future<void> _initCacheAndLoad() async {
    await Hive.initFlutter();
    _conversationsBox = await Hive.openBox('conversationsBox');
    await _loadConversationsFromCache();
    await _loadConversations();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _conversationsSubscription?.cancel();
    _conversationsBox?.close();
    super.dispose();
  }


  /// Carrega conversas do Firestore em tempo real
  void _loadConversations() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      setState(() => _isLoading = false);
      return;
    }

    // Use Riverpod profileProvider to get current active profile
    final profileState = ref.read(profileProvider);
    final activeProfile = profileState.value?.activeProfile;
    if (activeProfile == null) {
      setState(() => _isLoading = false);
      return;
    }
    final currentProfileId = activeProfile.profileId;

    // Busca conversas do Firestore (apenas uma vez, não stream)
    final querySnapshot = await FirebaseFirestore.instance
        .collection('conversations')
        .where('participantProfiles', arrayContains: currentProfileId)
        .where('archived', isEqualTo: false)
        .orderBy('lastMessageTimestamp', descending: true)
        .limit(_conversationsPerPage)
        .get();

    // Paraleliza queries de usuários
    final userFutures = querySnapshot.docs.map((doc) {
      final data = doc.data();
      final participantProfiles = (data['participantProfiles'] as List?)?.cast<String>() ?? [];
      final participantUsers = (data['participants'] as List?)?.cast<String>() ?? [];
      final otherProfileId = participantProfiles.firstWhere(
        (id) => id != currentProfileId,
        orElse: () => '',
      );
      final otherUserId = participantUsers.firstWhere(
        (id) => id != currentUser.uid,
        orElse: () => currentUser.uid,
      );
      return {
        'doc': doc,
        'otherProfileId': otherProfileId,
        'otherUserId': otherUserId,
        'future': otherUserId.isNotEmpty
            ? FirebaseFirestore.instance.collection('users').doc(otherUserId).get()
            : Future.value(null),
      };
    }).toList();

    final userSnapshots = await Future.wait(
      userFutures.map((item) => item['future'] as Future<DocumentSnapshot?>).toList(),
    );

    final conversations = <Map<String, dynamic>>[];

    for (var i = 0; i < userFutures.length; i++) {
      final item = userFutures[i];
      final doc = item['doc'] as QueryDocumentSnapshot;
      final data = doc.data() as Map<String, dynamic>;
      final otherProfileId = item['otherProfileId'] as String;
      final otherUserId = item['otherUserId'] as String;
      final otherUserDoc = userSnapshots[i];

      if (otherProfileId.isEmpty || otherUserDoc == null || !otherUserDoc.exists) {
        continue;
      }

      final otherUserData = otherUserDoc.data() as Map<String, dynamic>;
      String otherProfileName = 'Usuário';
      String otherProfilePhoto = '';
      bool otherProfileIsBand = false;

      if (otherProfileId == otherUserId) {
        otherProfileName = otherUserData['name'] ?? 'Usuário';
        otherProfilePhoto = otherUserData['photoUrl'] ?? '';
        otherProfileIsBand = otherUserData['isBand'] ?? false;
      } else {
        final profilesList = otherUserData['profiles'] as List<dynamic>?;
        if (profilesList != null) {
          try {
            final profileData = profilesList
                .cast<Map<String, dynamic>>() 
                .firstWhere((p) => p['profileId'] == otherProfileId);
            otherProfileName = profileData['name'] ?? 'Usuário';
            otherProfilePhoto = profileData['photoUrl'] ?? '';
            otherProfileIsBand = profileData['isBand'] ?? false;
          } catch (_) {
            otherProfileName = otherUserData['name'] ?? 'Usuário';
            otherProfilePhoto = otherUserData['photoUrl'] ?? '';
          }
        }
      }

      final unreadCount = (data['unreadCount'] as Map?)?.containsKey(currentProfileId) ?? false
          ? (data['unreadCount'][currentProfileId] as int?) ?? 0
          : 0;

      conversations.add({
        'conversationId': doc.id,
        'otherUserId': otherUserId,
        'otherProfileId': otherProfileId,
        'otherUserName': otherProfileName,
        'otherUserPhoto': otherProfilePhoto,
        'lastMessage': data['lastMessage'] ?? '',
        'lastMessageTimestamp': data['lastMessageTimestamp'] as Timestamp?,
        'unreadCount': unreadCount,
        'isOnline': otherUserData['isOnline'] ?? false,
        'type': otherProfileIsBand ? 'band' : 'musician',
      });
    }

    if (mounted) {
      setState(() {
        _conversations = conversations;
        _isLoading = false;
        if (querySnapshot.docs.isNotEmpty) {
          _lastConversationDoc = querySnapshot.docs.last;
        }
      });
      // Salva no cache local
      _conversationsBox?.put('conversations', conversations);
    }
  }

  // ...existing code...

  /// Filtra conversas baseado na busca
  List<Map<String, dynamic>> get _filteredConversations {
    if (_searchQuery.isEmpty) return _conversations;

    return _conversations.where((conv) {
      final name = (conv['otherUserName'] as String).toLowerCase();
      final message = (conv['lastMessage'] as String).toLowerCase();
      final query = _searchQuery.toLowerCase();

      return name.contains(query) || message.contains(query);
    }).toList();
  }

  /// Exclui uma conversa
  Future<void> _deleteConversation(String conversationId) async {
    try {
      await FirebaseFirestore.instance
          .collection('conversations')
          .doc(conversationId)
          .delete();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Conversa excluída'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao excluir: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Arquiva conversas selecionadas
  Future<void> _archiveSelectedConversations() async {
    for (final conversationId in _selectedConversations) {
      try {
        await FirebaseFirestore.instance
            .collection('conversations')
            .doc(conversationId)
            .update({'archived': true});
      } catch (e) {
      }
    }

    setState(() {
      _selectedConversations.clear();
      _isSelectionMode = false;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Conversas arquivadas'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  /// Marca conversa como lida
  Future<void> _markAsRead(String conversationId) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    final profileState = ref.read(profileProvider);
    final activeProfile = profileState.value?.activeProfile;
    if (activeProfile == null) return;
    
    final currentProfileId = activeProfile.profileId;

    try {
      await FirebaseFirestore.instance
          .collection('conversations')
          .doc(conversationId)
          .update({
        'unreadCount.$currentProfileId': 0,
      });
    } catch (e) {
    }
  }

  /// Navega para tela de chat
  void _openChat(Map<String, dynamic> conversation) {
    // Marca como lida
    _markAsRead(conversation['conversationId']);

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChatDetailPage(
          conversationId: conversation['conversationId'],
          otherUserId: conversation['otherUserId'],
          otherProfileId: conversation['otherProfileId'], // Passa o profileId
          otherUserName: conversation['otherUserName'],
          otherUserPhoto: conversation['otherUserPhoto'],
        ),
      ),
    );
  }

  /// Toggle seleção de conversa
  void _toggleSelection(String conversationId) {
    setState(() {
      if (_selectedConversations.contains(conversationId)) {
        _selectedConversations.remove(conversationId);
        if (_selectedConversations.isEmpty) {
          _isSelectionMode = false;
        }
      } else {
        _selectedConversations.add(conversationId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: _buildAppBar(),
      body: _buildBody(),
      floatingActionButton: !_isSelectionMode ? _buildNewChatButton() : null,
    );
  }

  /// AppBar com busca e ações
  PreferredSizeWidget _buildAppBar() {
    if (_isSelectionMode) {
      return AppBar(
        backgroundColor: _primaryColor,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            setState(() {
              _isSelectionMode = false;
              _selectedConversations.clear();
            });
          },
        ),
        title: Text('${_selectedConversations.length} selecionada(s)'),
        actions: [
          IconButton(
            icon: const Icon(Icons.archive),
            tooltip: 'Arquivar',
            onPressed: _archiveSelectedConversations,
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            tooltip: 'Excluir',
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Excluir conversas'),
                  content: Text(
                    'Deseja excluir ${_selectedConversations.length} conversa(s)?',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancelar'),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      child: const Text('Excluir'),
                    ),
                  ],
                ),
              );

              if (confirm == true) {
                for (final id in _selectedConversations) {
                  await _deleteConversation(id);
                }
                setState(() {
                  _isSelectionMode = false;
                  _selectedConversations.clear();
                });
              }
            },
          ),
        ],
      );
    }

    return AppBar(
      backgroundColor: _primaryColor,
      elevation: 0,
      title: const Text(
        'Mensagens',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
      actions: [
        // Ícone de busca
        IconButton(
          icon: const Icon(Icons.search),
          tooltip: 'Buscar',
          onPressed: () {
            showSearch(
              context: context,
              delegate: _ConversationSearchDelegate(_conversations),
            );
          },
        ),
      ],
    );
  }

  /// Corpo principal com lista de conversas
  Widget _buildBody() {
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(color: _primaryColor),
      );
    }

    final conversations = _filteredConversations;

    if (conversations.isEmpty) {
      return EmptyState(
        icon: Icons.chat_bubble_outline,
        title: 'Nenhuma conversa ainda',
        subtitle: 'Converse com outros músicos e bandas para começar a se conectar.',
        actionLabel: 'Iniciar nova conversa',
        onActionPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => Scaffold(
                appBar: AppBar(title: Text('Nova Conversa')),
                body: Center(child: Text('Em desenvolvimento')),
              ),
            ),
          );
        },
      );
    }

    return ListView.builder(
      controller: _scrollController,
      itemCount: conversations.length + (_isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        // Loading indicator no final da lista
        if (index == conversations.length) {
          return const Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        final conversation = conversations[index];
        return _buildConversationItem(conversation);
      },
    );
  }

  /// Item da lista de conversas usando widget reutilizável
  Widget _buildConversationItem(Map<String, dynamic> conversation) {
    final conversationId = conversation['conversationId'] as String;
    final isSelected = _selectedConversations.contains(conversationId);

    return ConversationItem(
      conversation: conversation,
      isSelected: isSelected,
      isSelectionMode: _isSelectionMode,
      onTap: () {
        if (_isSelectionMode) {
          _toggleSelection(conversationId);
        } else {
          _openChat(conversation);
        }
      },
      onLongPress: () {
        setState(() {
          _isSelectionMode = true;
          _toggleSelection(conversationId);
        });
      },
      onToggleSelection: () => _toggleSelection(conversationId),
      onDelete: _deleteConversation,
      onArchive: (id) async {
        await FirebaseFirestore.instance
            .collection('conversations')
            .doc(id)
            .update({'archived': true});
      },
    );
  }

  /// Botão de nova conversa
  Widget _buildNewChatButton() {
    return FloatingActionButton(
      onPressed: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => Scaffold(
              appBar: AppBar(title: Text('Nova Conversa')),
              body: Center(child: Text('Em desenvolvimento')),
            ),
          ),
        );
      },
      backgroundColor: _secondaryColor,
      child: const Icon(Icons.edit, color: Colors.white),
    );
  }
}

/// SearchDelegate customizado para buscar conversas
class _ConversationSearchDelegate extends SearchDelegate<Map<String, dynamic>?> {
  final List<Map<String, dynamic>> conversations;

  _ConversationSearchDelegate(this.conversations);

  @override
  ThemeData appBarTheme(BuildContext context) {
    return Theme.of(context).copyWith(
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.primary,
        elevation: 0,
      ),
      inputDecorationTheme: const InputDecorationTheme(
        border: InputBorder.none,
        hintStyle: TextStyle(color: Colors.white70),
      ),
      textTheme: const TextTheme(
        titleLarge: TextStyle(
          color: Colors.white,
          fontSize: 18,
        ),
      ),
    );
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () => query = '',
        ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildSearchResults();
  }

  Widget _buildSearchResults() {
    final results = conversations.where((conv) {
      final name = (conv['otherUserName'] as String).toLowerCase();
      final message = (conv['lastMessage'] as String).toLowerCase();
      final q = query.toLowerCase();

      return name.contains(q) || message.contains(q);
    }).toList();

    if (results.isEmpty) {
      return const Center(
        child: Text(
          'Nenhuma conversa encontrada',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final conversation = results[index];
        return ListTile(
          leading: CircleAvatar(
            child: conversation['otherUserPhoto'] != null &&
                    (conversation['otherUserPhoto'] as String).isNotEmpty
                ? ClipOval(
                    child: CachedNetworkImage(
                      imageUrl: conversation['otherUserPhoto'],
                      width: 40,
                      height: 40,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => const CircularProgressIndicator(strokeWidth: 2),
                      errorWidget: (context, url, error) => const Icon(Icons.person),
                      memCacheWidth: 80,
                      memCacheHeight: 80,
                    ),
                  )
                : const Icon(Icons.person),
          ),
          title: Text(conversation['otherUserName']),
          subtitle: Text(
            conversation['lastMessage'],
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          onTap: () => close(context, conversation),
        );
      },
    );
  }
}
