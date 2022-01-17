import 'dart:convert';

import 'package:chopper/chopper.dart';
import 'package:nakama/api.dart';
import 'package:nakama/nakama.dart';
import 'package:nakama/src/rest/apigrpc.swagger.dart';
import 'package:nakama/src/session.dart' as model;

import 'nakama_client.dart';

const _kDefaultAppKey = 'default';

/// Base class for communicating with Nakama via gRPC.
/// [NakamaGrpcClient] abstracts the gRPC calls and handles authentication
/// for you.
class NakamaRestApiClient extends NakamaBaseClient {
  static final Map<String, NakamaRestApiClient> _clients = {};

  late final ChopperClient _chopperClient;

  /// The key used to authenticate with the server without a session.
  /// Defaults to "defaultkey".
  late final String serverKey;

  /// Temporarily holds the current valid session to use in the Chopper
  /// interceptor for JWT auth.
  model.Session? _session;

  /// Either inits and returns a new instance of [NakamaRestApiClient] or
  /// returns a already initialized one.
  factory NakamaRestApiClient.init({
    String? host,
    String? serverKey,
    String key = _kDefaultAppKey,
    int port = 7350,
    bool ssl = false,
  }) {
    if (_clients.containsKey(key)) {
      return _clients[key]!;
    }

    // Not yet initialized -> check if we've got all parameters to do so
    if (host == null || serverKey == null) {
      throw Exception(
        'Not yet initialized, need parameters [host] and [serverKey] to initialize.',
      );
    }

    // Create a new instance of this with given parameters.
    return _clients[key] = NakamaRestApiClient._(
      host: host,
      port: port,
      serverKey: serverKey,
      ssl: ssl,
    );
  }

  NakamaRestApiClient._({
    required String host,
    required String serverKey,
    required int port,
    required bool ssl,
  }) {
    _chopperClient = ChopperClient(
      converter: JsonSerializableConverter(),
      baseUrl: Uri(
        host: host,
        scheme: ssl ? 'https' : 'http',
        port: port,
      ).toString(),
      services: [Apigrpc.create()],
      interceptors: [
        // Auth Interceptor
        (Request request) async {
          // Server Key Auth
          if (_session == null) {
            return applyHeader(
              request,
              'Authorization',
              'Basic ' + base64Encode('$serverKey:'.codeUnits),
            );
          }

          // User's JWT auth
          return applyHeader(
            request,
            'Authorization',
            'Bearer ${_session!.token}',
          );
        },
      ],
    );
  }

  Apigrpc get _api => _chopperClient.getService<Apigrpc>();

  @override
  Future<model.Session> authenticateEmail({
    required String email,
    required String password,
    bool create = true,
    String? username,
    Map<String, String>? vars,
  }) async {
    final res = await _api.nakamaAuthenticateEmail(
      body: ApiAccountEmail(
        email: email,
        password: password,
        vars: vars,
      ),
      create: create,
      username: username,
    );

    if (res.body == null) {
      throw Exception('Authentication failed.');
    }

    final data = res.body!;

    return model.Session(
      created: data.created ?? false,
      token: data.token!,
      refreshToken: data.refreshToken,
    );
  }

  @override
  Future<model.Session> authenticateDevice({
    required String deviceId,
    bool create = true,
    String? username,
    Map<String, String>? vars,
  }) async {
    final res = await _api.nakamaAuthenticateDevice(
      body: ApiAccountDevice(
        id: deviceId,
        vars: vars,
      ),
      create: create,
      username: username,
    );

    if (res.body == null) {
      throw Exception('Authentication failed.');
    }

    final data = res.body!;

    return model.Session(
      created: data.created ?? false,
      token: data.token!,
      refreshToken: data.refreshToken,
    );
  }

  @override
  Future<model.Session> authenticateFacebook({
    required String token,
    bool create = true,
    String? username,
    Map<String, String>? vars,
  }) async {
    final res = await _api.nakamaAuthenticateFacebook(
      body: ApiAccountFacebook(
        token: token,
        vars: vars,
      ),
      create: create,
      username: username,
    );

    if (res.body == null) {
      throw Exception('Authentication failed.');
    }

    final data = res.body!;

    return model.Session(
      created: data.created ?? false,
      token: data.token!,
      refreshToken: data.refreshToken,
    );
  }

  @override
  Future<model.Session> authenticateGoogle({
    required String token,
    bool create = true,
    String? username,
    Map<String, String>? vars,
  }) async {
    final res = await _api.nakamaAuthenticateGoogle(
      body: ApiAccountGoogle(
        token: token,
        vars: vars,
      ),
      create: create,
      username: username,
    );

    if (res.body == null) {
      throw Exception('Authentication failed.');
    }

    final data = res.body!;

    return model.Session(
      created: data.created ?? false,
      token: data.token!,
      refreshToken: data.refreshToken,
    );
  }

  @override
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
  }) async {
    final res = await _api.nakamaAuthenticateGameCenter(
      body: ApiAccountGameCenter(
        playerId: playerId,
        bundleId: bundleId,
        timestampSeconds: timestampSeconds.toString(),
        salt: salt,
        signature: signature,
        publicKeyUrl: publicKeyUrl,
        vars: vars,
      ),
      create: create,
      username: username,
    );

    if (res.body == null) {
      throw Exception('Authentication failed.');
    }

    final data = res.body!;

    return model.Session(
      created: data.created ?? false,
      token: data.token!,
      refreshToken: data.refreshToken,
    );
  }

  @override
  Future<model.Session> authenticateSteam({
    required String token,
    bool create = true,
    String? username,
    Map<String, String>? vars,
  }) async {
    final res = await _api.nakamaAuthenticateSteam(
      body: ApiAccountSteam(token: token, vars: vars),
      create: create,
      username: username,
    );

    if (res.body == null) {
      throw Exception('Authentication failed.');
    }

    final data = res.body!;

    return model.Session(
      created: data.created ?? false,
      token: data.token!,
      refreshToken: data.refreshToken,
    );
  }

  @override
  Future<model.Session> authenticateCustom({
    required String id,
    bool create = true,
    String? username,
    Map<String, String>? vars,
  }) async {
    final res = await _api.nakamaAuthenticateCustom(
      body: ApiAccountCustom(id: id, vars: vars),
      create: create,
      username: username,
    );

    if (res.body == null) {
      throw Exception('Authentication failed.');
    }

    final data = res.body!;

    return model.Session(
      created: data.created ?? false,
      token: data.token!,
      refreshToken: data.refreshToken,
    );
  }

  @override
  Future<Account> getAccount(model.Session session) async {
    _session = session;
    final res = await _api.nakamaGetAccount();

    final acc = Account();
    // Some workaround here while protobuf expects the vars map to not be null
    acc.mergeFromProto3Json((res.body!.copyWith(
      devices: res.body!.devices!
          .map((e) => e.copyWith(
                vars: e.vars ?? {},
              ))
          .toList(),
    )).toJson());

    return acc;
  }

  @override
  Future<Users> getUsers({
    required model.Session session,
    List<String>? facebookIds,
    List<String>? ids,
    List<String>? usernames,
  }) async {
    _session = session;
    final res = await _api.nakamaGetUsers(
      facebookIds: facebookIds,
      ids: ids,
      usernames: usernames,
    );

    return Users()..mergeFromProto3Json(res.body!.toJson());
  }

  @override
  Future<StorageObjectAcks> writeStorageObject({
    required model.Session session,
    String? collection,
    String? key,
    String? value,
    String? version,
    StorageWritePermission? writePermission,
    StorageReadPermission? readPermission,
  }) async {
    _session = session;
    final res = await _api.nakamaWriteStorageObjects(
      body: ApiWriteStorageObjectsRequest(
        objects: [
          ApiWriteStorageObject(
            collection: collection,
            key: key,
            value: value,
            version: version,
            permissionWrite: writePermission != null
                ? StorageWritePermission.values.indexOf(writePermission)
                : null,
            permissionRead: readPermission != null
                ? StorageReadPermission.values.indexOf(readPermission)
                : null,
          ),
        ],
      ),
    );

    return StorageObjectAcks()
      ..acks.addAll(
        res.body!.acks!.map(
          (e) => StorageObjectAck(
            collection: e.collection,
            key: e.key,
            userId: e.userId,
            version: e.version,
          ),
        ),
      );
  }

  @override
  Future<StorageObjectAcks> writeStorageObjects({
    required model.Session session,
    required List<WriteStorageObject> objects,
  }) async {
    _session = session;
    final res = await _api.nakamaWriteStorageObjects(
      body: ApiWriteStorageObjectsRequest(
        objects: objects
            .map((e) => ApiWriteStorageObject(
                  collection: e.collection,
                  key: e.key,
                  value: e.value,
                  version: e.version,
                  permissionRead: e.permissionRead.value,
                  permissionWrite: e.permissionWrite.value,
                ))
            .toList(),
      ),
    );

    return StorageObjectAcks()
      ..acks.addAll(
        res.body!.acks!.map(
          (e) => StorageObjectAck(
            collection: e.collection,
            key: e.key,
            userId: e.userId,
            version: e.version,
          ),
        ),
      );
  }

  @override
  Future<StorageObjects> readStorageObjects({
    required model.Session session,
    required Iterable<ReadStorageObjectId> ids,
  }) async {
    _session = session;
    final res = await _api.nakamaReadStorageObjects(
      body: ApiReadStorageObjectsRequest(
        objectIds: ids
            .map((e) => ApiReadStorageObjectId(
                  collection: e.collection,
                  key: e.key,
                  userId: e.userId,
                ))
            .toList(),
      ),
    );

    return StorageObjects()
      ..objects.addAll(
        res.body!.objects!.map(
          (e) => StorageObject(
            collection: e.collection,
            createTime: e.createTime != null
                ? Timestamp(nanos: e.createTime!.millisecondsSinceEpoch)
                : null,
            key: e.key,
            permissionRead: e.permissionRead,
            permissionWrite: e.permissionWrite,
            updateTime: e.updateTime != null
                ? Timestamp(nanos: e.updateTime!.millisecondsSinceEpoch)
                : null,
            userId: e.userId,
            value: e.value,
            version: e.version,
          ),
        ),
      );
  }

  @override
  Future<StorageObjectList> listStorageObjects({
    required model.Session session,
    String? collection,
    String? cursor,
    int? limit,
    String? userId,
  }) async {
    _session = session;

    final res = await _api.nakamaListStorageObjects(
      collection: collection,
      cursor: cursor,
      limit: limit,
      userId: userId,
    );

    return StorageObjectList(
      cursor: res.body!.cursor,
      objects: res.body!.objects!
          .map((e) => StorageObject(
                collection: e.collection,
                createTime: e.createTime != null
                    ? Timestamp(
                        nanos: e.createTime!.millisecondsSinceEpoch,
                      )
                    : null,
                updateTime: e.updateTime != null
                    ? Timestamp(
                        nanos: e.updateTime!.millisecondsSinceEpoch,
                      )
                    : null,
                key: e.key,
                permissionRead: e.permissionRead,
                permissionWrite: e.permissionWrite,
                userId: e.userId,
                value: e.value,
                version: e.version,
              ))
          .toList(),
    );
  }

  @override
  Future callRpc({required model.Session session, required String rpcId, required String payload}) {
    // TODO: implement callRpc
    return _api.nakamaRpcFunc(id: rpcId, body: payload, httpKey: serverKey);
  }
}

NakamaBaseClient getNakamaClient({
  String? host,
  String? serverKey,
  String key = _kDefaultAppKey,
  int httpPort = 7350,
  int grpcPort = 7349,
  bool ssl = false,
}) =>
    NakamaRestApiClient.init(
      host: host,
      key: key,
      port: httpPort,
      serverKey: serverKey,
      ssl: ssl,
    );
