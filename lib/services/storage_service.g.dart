// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'storage_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(StorageService)
final storageServiceProvider = StorageServiceProvider._();

final class StorageServiceProvider
    extends $AsyncNotifierProvider<StorageService, SharedPreferences> {
  StorageServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'storageServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$storageServiceHash();

  @$internal
  @override
  StorageService create() => StorageService();
}

String _$storageServiceHash() => r'869dfee6470a6919520dd3d04897362b6a40f098';

abstract class _$StorageService extends $AsyncNotifier<SharedPreferences> {
  FutureOr<SharedPreferences> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<SharedPreferences>, SharedPreferences>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<SharedPreferences>, SharedPreferences>,
              AsyncValue<SharedPreferences>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
