import 'package:nakama/api.dart';
import 'package:nakama/nakama.dart';
import 'package:nakama/src/session.dart' as model;

const _kDefaultAppKey = 'default';

/// This defines the interface to communicate with Nakama API. It is a little
/// tricky to support web (via REST) and io (via gRPC) with just one codebase
/// so please don't use this directly but get your fitting instance with
/// [getNakamaClient()].
abstract class NakamaBaseClient {
  NakamaBaseClient.init({
    String? host,
    String? serverKey,
    String key = _kDefaultAppKey,
    int httpPort = 7350,
    int grpcPort = 7349,
    bool ssl = false,
  });

  NakamaBaseClient();

  Future<model.Session> authenticateEmail({
    required String email,
    required String password,
    bool create = false,
    String? username,
    Map<String, String>? vars,
  });

  Future<model.Session> authenticateDevice({
    required String deviceId,
    bool create = false,
    String? username,
    Map<String, String>? vars,
  });

  Future<model.Session> authenticateFacebook({
    required String token,
    bool create = true,
    String? username,
    Map<String, String>? vars,
  });

  Future<model.Session> authenticateGoogle({
    required String token,
    bool create = true,
    String? username,
    Map<String, String>? vars,
  });

  Future<model.Session> authenticateGameCenter({
    required String playerId,
    required String bundleId,
    required int timestampSeconds,
    required String salt,
    required String signature,
    required String publicKeyUrl,
    bool create = true,
    String? username,
    Map<String, String>? vars,
  });

  Future<model.Session> authenticateSteam({
    required String token,
    bool create = true,
    String? username,
    Map<String, String>? vars,
  });

  Future<model.Session> authenticateCustom({
    required String id,
    bool create = true,
    String? username,
    Map<String, String>? vars,
  });

  Future<Account> getAccount(model.Session session);

  Future<Users> getUsers({
    required model.Session session,
    List<String>? facebookIds,
    List<String>? ids,
    List<String>? usernames,
  });

  Future<StorageObjectAcks> writeStorageObject({
    required model.Session session,
    String? collection,
    String? key,
    String? value,
    String? version,
    StorageWritePermission? writePermission,
    StorageReadPermission? readPermission,
  });

  Future<StorageObjectAcks> writeStorageObjects({
    required model.Session session,
    required List<WriteStorageObject> objects,
  });

  Future<StorageObjects> readStorageObjects({
    required model.Session session,
    required Iterable<ReadStorageObjectId> ids,
  });

  Future<StorageObjectList> listStorageObjects({
    required model.Session session,
    String? collection,
    String? cursor,
    int? limit,
    String? userId,
  });

  Future<dynamic> callRpc({
    required model.Session session, 
    required String rpcId,
    required String payload,
  });
}
