// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$authRepositoryHash() => r'8ee2ff19c054c39e160fd4afbb1cac78d6987acc';

/// See also [authRepository].
@ProviderFor(authRepository)
final authRepositoryProvider = AutoDisposeProvider<AuthRepository>.internal(
  authRepository,
  name: r'authRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$authRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AuthRepositoryRef = AutoDisposeProviderRef<AuthRepository>;
String _$currentUserHash() => r'212db705cd85b7c960e904fe5d352b2c6099e6bd';

/// See also [currentUser].
@ProviderFor(currentUser)
final currentUserProvider = AutoDisposeProvider<User?>.internal(
  currentUser,
  name: r'currentUserProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$currentUserHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CurrentUserRef = AutoDisposeProviderRef<User?>;
String _$loadUserInformationHash() =>
    r'450ae7c90b346b56940f771b78cbb96091299ff1';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// See also [loadUserInformation].
@ProviderFor(loadUserInformation)
const loadUserInformationProvider = LoadUserInformationFamily();

/// See also [loadUserInformation].
class LoadUserInformationFamily extends Family<AsyncValue<AppUser>> {
  /// See also [loadUserInformation].
  const LoadUserInformationFamily();

  /// See also [loadUserInformation].
  LoadUserInformationProvider call(
    String userId,
  ) {
    return LoadUserInformationProvider(
      userId,
    );
  }

  @override
  LoadUserInformationProvider getProviderOverride(
    covariant LoadUserInformationProvider provider,
  ) {
    return call(
      provider.userId,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'loadUserInformationProvider';
}

/// See also [loadUserInformation].
class LoadUserInformationProvider extends AutoDisposeStreamProvider<AppUser> {
  /// See also [loadUserInformation].
  LoadUserInformationProvider(
    String userId,
  ) : this._internal(
          (ref) => loadUserInformation(
            ref as LoadUserInformationRef,
            userId,
          ),
          from: loadUserInformationProvider,
          name: r'loadUserInformationProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$loadUserInformationHash,
          dependencies: LoadUserInformationFamily._dependencies,
          allTransitiveDependencies:
              LoadUserInformationFamily._allTransitiveDependencies,
          userId: userId,
        );

  LoadUserInformationProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.userId,
  }) : super.internal();

  final String userId;

  @override
  Override overrideWith(
    Stream<AppUser> Function(LoadUserInformationRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: LoadUserInformationProvider._internal(
        (ref) => create(ref as LoadUserInformationRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        userId: userId,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<AppUser> createElement() {
    return _LoadUserInformationProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is LoadUserInformationProvider && other.userId == userId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, userId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin LoadUserInformationRef on AutoDisposeStreamProviderRef<AppUser> {
  /// The parameter `userId` of this provider.
  String get userId;
}

class _LoadUserInformationProviderElement
    extends AutoDisposeStreamProviderElement<AppUser>
    with LoadUserInformationRef {
  _LoadUserInformationProviderElement(super.provider);

  @override
  String get userId => (origin as LoadUserInformationProvider).userId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
