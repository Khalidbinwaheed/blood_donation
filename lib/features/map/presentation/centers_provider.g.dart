// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'centers_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$nearbyCentersHash() => r'93fe4fc38749349a4bb019823ca6ed27337217bd';

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

/// See also [nearbyCenters].
@ProviderFor(nearbyCenters)
const nearbyCentersProvider = NearbyCentersFamily();

/// See also [nearbyCenters].
class NearbyCentersFamily extends Family<AsyncValue<List<CenterModel>>> {
  /// See also [nearbyCenters].
  const NearbyCentersFamily();

  /// See also [nearbyCenters].
  NearbyCentersProvider call({
    required double lat,
    required double lng,
  }) {
    return NearbyCentersProvider(
      lat: lat,
      lng: lng,
    );
  }

  @override
  NearbyCentersProvider getProviderOverride(
    covariant NearbyCentersProvider provider,
  ) {
    return call(
      lat: provider.lat,
      lng: provider.lng,
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
  String? get name => r'nearbyCentersProvider';
}

/// See also [nearbyCenters].
class NearbyCentersProvider
    extends AutoDisposeFutureProvider<List<CenterModel>> {
  /// See also [nearbyCenters].
  NearbyCentersProvider({
    required double lat,
    required double lng,
  }) : this._internal(
          (ref) => nearbyCenters(
            ref as NearbyCentersRef,
            lat: lat,
            lng: lng,
          ),
          from: nearbyCentersProvider,
          name: r'nearbyCentersProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$nearbyCentersHash,
          dependencies: NearbyCentersFamily._dependencies,
          allTransitiveDependencies:
              NearbyCentersFamily._allTransitiveDependencies,
          lat: lat,
          lng: lng,
        );

  NearbyCentersProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.lat,
    required this.lng,
  }) : super.internal();

  final double lat;
  final double lng;

  @override
  Override overrideWith(
    FutureOr<List<CenterModel>> Function(NearbyCentersRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: NearbyCentersProvider._internal(
        (ref) => create(ref as NearbyCentersRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        lat: lat,
        lng: lng,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<CenterModel>> createElement() {
    return _NearbyCentersProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is NearbyCentersProvider &&
        other.lat == lat &&
        other.lng == lng;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, lat.hashCode);
    hash = _SystemHash.combine(hash, lng.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin NearbyCentersRef on AutoDisposeFutureProviderRef<List<CenterModel>> {
  /// The parameter `lat` of this provider.
  double get lat;

  /// The parameter `lng` of this provider.
  double get lng;
}

class _NearbyCentersProviderElement
    extends AutoDisposeFutureProviderElement<List<CenterModel>>
    with NearbyCentersRef {
  _NearbyCentersProviderElement(super.provider);

  @override
  double get lat => (origin as NearbyCentersProvider).lat;
  @override
  double get lng => (origin as NearbyCentersProvider).lng;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
