import 'dart:convert';

import 'package:grpc/grpc_connection_interface.dart';
import 'package:nakama/api.dart';
import 'package:nakama/src/api/proto/apigrpc/apigrpc.pbgrpc.dart';
import 'package:grpc/grpc.dart';
import 'package:nakama/nakama.dart';
import 'package:nakama/src/session.dart' as model;

import 'nakama_client.dart';

const _kDefaultAppKey = 'default';

/// Base class for communicating with Nakama via gRPC.
/// [NakamaGrpcClient] abstracts the gRPC calls and handles authentication
/// for you.
class NakamaGrpcClient extends NakamaBaseClient {
  static final Map<String, NakamaGrpcClient> _clients = {};

  /// The host address of the server.
  final String host;

  /// The port number of the server. Defaults to 7349
  final int port;
  final bool ssl;

  late final ClientChannelBase _channel;
  late final NakamaClient _client;

  /// The key used to authenticate with the server without a session.
  /// Defaults to "defaultkey".
  late final String serverKey;

  /// Either inits and returns a new instance of [NakamaGrpcClient] or
  /// returns a already initialized one.
  factory NakamaGrpcClient.init({
    String? host,
    String? serverKey,
    String key = _kDefaultAppKey,
    int port = 7349,
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
    return _clients[key] = NakamaGrpcClient(
      host: host,
      port: port,
      serverKey: serverKey,
      ssl: ssl,
    );
  }

  NakamaGrpcClient({
    required this.host,
    this.port = 7349,
    required this.ssl,
    required String serverKey,
  }) {
    this.serverKey = 'Basic ${base64Encode('defaultkey:'.codeUnits)}';

    _channel = ClientChannel(
      host,
      port: port,
      options: ChannelOptions(
        credentials: ssl == true
            ? const ChannelCredentials.secure()
            : const ChannelCredentials.insecure(),
      ),
    );

    _client = NakamaClient(
      _channel,
      options: CallOptions(metadata: {'authorization': this.serverKey}),
    );
  }

  /// This method returns the original generated gPRC client, usually there
  /// might be no use case for direct access.
  /// Use with cation, API can change every time.
  NakamaClient get rawGrpcClient => _client;

  CallOptions _getSessionCallOptions(model.Session session) => CallOptions(
        metadata: {'authorization': 'Bearer ${session.token}'},
      );

  @override
  Future<model.Session> authenticateEmail({
    required String email,
    required String password,
    bool create = true,
    String? username,
    Map<String, String>? vars,
  }) async {
    final request = AuthenticateEmailRequest()
      ..create_2 = BoolValue(value: create)
      ..account = (AccountEmail()
        ..email = email
        ..password = password
        ..vars.addAll(vars ?? {}));

    if (username != null) {
      request.username = username;
    }

    final res = await _client.authenticateEmail(request);

    return model.Session(
      created: res.created,
      token: res.token,
      refreshToken: res.refreshToken,
    );
  }

  @override
  Future<model.Session> authenticateDevice({
    required String deviceId,
    bool create = true,
    String? username,
    Map<String, String>? vars,
  }) async {
    final request = AuthenticateDeviceRequest()
      ..create_2 = BoolValue(value: create)
      ..account = (AccountDevice()
        ..id = deviceId
        ..vars.addAll(vars ?? {}));

    if (username != null) {
      request.username = username;
    }

    final res = await _client.authenticateDevice(request);

    return model.Session(
      created: res.created,
      token: res.token,
      refreshToken: res.refreshToken,
    );
  }

  @override
  Future<model.Session> authenticateFacebook({
    required String token,
    bool create = true,
    String? username,
    Map<String, String>? vars,
  }) async {
    final request = AuthenticateFacebookRequest()
      ..create_2 = BoolValue(value: create)
      ..account = (AccountFacebook()
        ..token = token
        ..vars.addAll(vars ?? {}));

    if (username != null) {
      request.username = username;
    }

    final res = await _client.authenticateFacebook(request);

    return model.Session(
      created: res.created,
      token: res.token,
      refreshToken: res.refreshToken,
    );
  }

  @override
  Future<model.Session> authenticateGoogle({
    required String token,
    bool create = true,
    String? username,
    Map<String, String>? vars,
  }) async {
    final request = AuthenticateGoogleRequest()
      ..create_2 = BoolValue(value: create)
      ..account = (AccountGoogle()
        ..token = token
        ..vars.addAll(vars ?? {}));

    if (username != null) {
      request.username = username;
    }

    final res = await _client.authenticateGoogle(request);

    return model.Session(
      created: res.created,
      token: res.token,
      refreshToken: res.refreshToken,
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
    final request = AuthenticateGameCenterRequest()
      ..create_2 = BoolValue(value: create)
      ..account = (AccountGameCenter()
        ..playerId = playerId
        ..bundleId = bundleId
        ..timestampSeconds = Int64(timestampSeconds)
        ..salt = salt
        ..signature = signature
        ..publicKeyUrl = publicKeyUrl
        ..vars.addAll(vars ?? {}));

    if (username != null) {
      request.username = username;
    }

    final res = await _client.authenticateGameCenter(request);

    return model.Session(
      created: res.created,
      token: res.token,
      refreshToken: res.refreshToken,
    );
  }

  @override
  Future<model.Session> authenticateSteam({
    required String token,
    bool create = true,
    String? username,
    Map<String, String>? vars,
  }) async {
    final request = AuthenticateSteamRequest()
      ..create_2 = BoolValue(value: create)
      ..account = (AccountSteam()
        ..token = token
        ..vars.addAll(vars ?? {}));

    if (username != null) {
      request.username = username;
    }

    final res = await _client.authenticateSteam(request);

    return model.Session(
      created: res.created,
      token: res.token,
      refreshToken: res.refreshToken,
    );
  }

  @override
  Future<model.Session> authenticateCustom({
    required String id,
    bool create = true,
    String? username,
    Map<String, String>? vars,
  }) async {
    final request = AuthenticateCustomRequest()
      ..create_2 = BoolValue(value: create)
      ..account = (AccountCustom()
        ..id = id
        ..vars.addAll(vars ?? {}));

    if (username != null) {
      request.username = username;
    }

    final res = await _client.authenticateCustom(request);

    return model.Session(
      created: res.created,
      token: res.token,
      refreshToken: res.refreshToken,
    );
  }

  @override
  Future<Account> getAccount(model.Session session) async {
    return await _client.getAccount(
      Empty(),
      options: _getSessionCallOptions(session),
    );
  }

  @override
  Future<Users> getUsers({
    required model.Session session,
    List<String>? facebookIds,
    List<String>? ids,
    List<String>? usernames,
  }) async {
    return await _client.getUsers(
      GetUsersRequest(
        facebookIds: facebookIds,
        ids: ids,
        usernames: usernames,
      ),
      options: _getSessionCallOptions(session),
    );
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
  }) {
    return _client.writeStorageObjects(
      WriteStorageObjectsRequest(
        objects: [
          WriteStorageObject(
            collection: collection,
            key: key,
            value: value,
            version: version,
            permissionWrite: writePermission != null
                ? Int32Value(
                    value:
                        StorageWritePermission.values.indexOf(writePermission),
                  )
                : null,
            permissionRead: readPermission != null
                ? Int32Value(
                    value: StorageReadPermission.values.indexOf(readPermission),
                  )
                : null,
          ),
        ],
      ),
      options: _getSessionCallOptions(session),
    );
  }

  @override
  Future<StorageObjectAcks> writeStorageObjects({
    required model.Session session,
    required List<WriteStorageObject> objects,
  }) {
    return _client.writeStorageObjects(
      WriteStorageObjectsRequest(
        objects: objects,
      ),
      options: _getSessionCallOptions(session),
    );
  }

  @override
  Future<StorageObjects> readStorageObjects({
    required model.Session session,
    required Iterable<ReadStorageObjectId> ids,
  }) {
    return _client.readStorageObjects(
      ReadStorageObjectsRequest(
        objectIds: ids.toList(),
      ),
      options: _getSessionCallOptions(session),
    );
  }

  @override
  Future<StorageObjectList> listStorageObjects({
    required model.Session session,
    String? collection,
    String? cursor,
    int? limit,
    String? userId,
  }) {
    return _client.listStorageObjects(
      ListStorageObjectsRequest(
        collection: collection,
        cursor: cursor,
        limit: Int32Value(value: limit),
        userId: userId,
      ),
      options: _getSessionCallOptions(session),
    );
  }

  @override
  Future callRpc({required model.Session session, required String rpcId, required String payload}) {
    // TODO: implement callRpc
    return _client.rpcFunc(Rpc(id: rpcId, payload: payload));
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
    NakamaGrpcClient.init(
      host: host,
      key: key,
      port: grpcPort,
      serverKey: serverKey,
      ssl: ssl,
    );
