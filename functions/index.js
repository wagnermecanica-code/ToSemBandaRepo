/**
 * Firebase Cloud Functions para Tô Sem Banda
 * 
 * Função: notifyNearbyPosts
 * Trigger: onCreate em posts/{postId}
 * Região: southamerica-east1 (São Paulo)
 * 
 * Descrição: Notifica perfis próximos quando um novo post é criado.
 * Usa cálculo Haversine para distância e respeita configuração de raio do usuário.
 */

const functions = require('firebase-functions');
const admin = require('firebase-admin');

admin.initializeApp();
const db = admin.firestore();

/**
 * Notifica perfis quando um novo post é criado próximo a eles.
 * 
 * Lógica:
 * 1. Obtém localização do novo post (location GeoPoint)
 * 2. Busca todos os perfis com notificationRadiusEnabled = true
 * 3. Para cada perfil:
 *    - Calcula distância usando Haversine
 *    - Se distância <= notificationRadius, cria notificação
 * 4. Batch write de todas as notificações
 * 
 * Filtros aplicados:
 * - Perfil tem notificationRadiusEnabled = true
 * - Perfil tem location (GeoPoint)
 * - Perfil NÃO é o autor do post (authorProfileId)
 * - Distância <= notificationRadius configurado pelo perfil (default: 20km)
 */
exports.notifyNearbyPosts = functions
    .runWith({
      memory: '256MB',
      timeoutSeconds: 60,
    })
    .region('southamerica-east1') // São Paulo region para menor latência
    .firestore.document('posts/{postId}')
    .onCreate(async (snap) => {
      const post = snap.data();
      const postId = snap.id;

      // Validação: Post deve ter location (GeoPoint)
      if (!post.location || !post.location._latitude || !post.location._longitude) {
        console.log(`Post ${postId} ignorado: sem localização válida`);
        return null;
      }

      const postLat = post.location._latitude;
      const postLng = post.location._longitude;
      const postCity = post.city || 'cidade desconhecida';
      const postType = post.type === 'band' ? 'banda' : 'músico';
      const authorName = post.authorName || 'Alguém';
      const authorProfileId = post.authorProfileId;

      console.log(`📍 Novo post criado em ${postCity}: ${authorName} (${postType})`);
      console.log(`   Coordenadas: (${postLat.toFixed(4)}, ${postLng.toFixed(4)})`);

      // Query: Busca perfis com notificações de posts próximos habilitadas
      const profilesSnap = await db
          .collection('profiles')
          .where('notificationRadiusEnabled', '==', true)
          .get();

      console.log(`🔍 Encontrados ${profilesSnap.size} perfis com notificações habilitadas`);

      const notifications = [];

      for (const doc of profilesSnap.docs) {
        const profile = doc.data();
        const profileId = doc.id;

        // Filtro 1: Perfil deve ter location
        if (!profile.location || !profile.location._latitude || !profile.location._longitude) {
          continue;
        }

        // Filtro 2: Não notificar o próprio autor do post
        if (profileId === authorProfileId) {
          continue;
        }

        const userLat = profile.location._latitude;
        const userLng = profile.location._longitude;
        const radius = profile.notificationRadius || 20; // CAMPO CORRETO

        // Cálculo Haversine para distância em km
        const R = 6371; // Raio da Terra em km
        const dLat = (postLat - userLat) * Math.PI / 180;
        const dLon = (postLng - userLng) * Math.PI / 180;
        const a = Math.sin(dLat / 2) * Math.sin(dLat / 2) +
                  Math.cos(userLat * Math.PI / 180) * Math.cos(postLat * Math.PI / 180) *
                  Math.sin(dLon / 2) * Math.sin(dLon / 2);
        const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
        const distance = R * c;

        // Filtro 3: Distância dentro do raio configurado
        if (distance <= radius) {
          const distanceStr = distance.toFixed(1);
          console.log(`   ✅ ${profile.name} (${profileId.substring(0, 8)}...): ${distanceStr} km (raio: ${radius} km)`);

          notifications.push({
            recipientProfileId: profileId,
            type: 'nearbyPost',
            priority: 'medium',
            title: 'Novo post próximo!',
            body: `${authorName} está procurando ${postType} a ${distanceStr} km de você em ${postCity}`,
            data: {
              postId: postId,
              distance: distanceStr,
              city: postCity,
              postType: post.type,
              authorName: authorName,
              authorProfileId: authorProfileId,
            },
            createdAt: admin.firestore.FieldValue.serverTimestamp(),
            read: false,
            expiresAt: admin.firestore.Timestamp.fromDate(new Date(Date.now() + 7 * 24 * 60 * 60 * 1000)), // 7 dias
          });
        } else {
          // Log apenas se muito próximo (debugging)
          if (distance <= radius * 1.5) {
            console.log(`   ❌ ${profile.name}: ${distance.toFixed(1)} km (fora do raio de ${radius} km)`);
          }
        }
      }

      // Batch write de todas as notificações
      if (notifications.length > 0) {
        const batch = db.batch();
        notifications.forEach((notification) => {
          const notificationRef = db.collection('notifications').doc();
          batch.set(notificationRef, notification);
        });

        await batch.commit();
        console.log(`🔔 Enviadas ${notifications.length} notificações de post próximo`);
      } else {
        console.log('📭 Nenhum perfil próximo encontrado para notificar');
      }

      return null;
    });

/**
 * Limpa notificações expiradas (opcional).
 * 
 * Execução: Diária às 3h da manhã (horário de Brasília)
 * 
 * Remove notificações onde:
 * - expiresAt < agora
 * 
 * Batch delete de até 500 documentos por execução.
 */
exports.cleanupExpiredNotifications = functions
    .runWith({
      memory: '256MB',
      timeoutSeconds: 120,
    })
    .region('southamerica-east1')
    .pubsub.schedule('0 3 * * *') // 3h da manhã todos os dias
    .timeZone('America/Sao_Paulo')
    .onRun(async () => {
      const now = admin.firestore.Timestamp.now();

      const expiredSnap = await db
          .collection('notifications')
          .where('expiresAt', '<', now)
          .limit(500) // Limite de segurança
          .get();

      if (expiredSnap.empty) {
        console.log('🧹 Nenhuma notificação expirada encontrada');
        return null;
      }

      const batch = db.batch();
      expiredSnap.docs.forEach((doc) => {
        batch.delete(doc.ref);
      });

      await batch.commit();
      console.log(`🧹 Deletadas ${expiredSnap.size} notificações expiradas`);

      return null;
    });
