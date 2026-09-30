// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(isAppInstalled)
final isAppInstalledProvider = IsAppInstalledFamily._();

final class IsAppInstalledProvider
    extends $FunctionalProvider<AsyncValue<bool>, bool, FutureOr<bool>>
    with $FutureModifier<bool>, $FutureProvider<bool> {
  IsAppInstalledProvider._({
    required IsAppInstalledFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'isAppInstalledProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$isAppInstalledHash();

  @override
  String toString() {
    return r'isAppInstalledProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<bool> create(Ref ref) {
    final argument = this.argument as String;
    return isAppInstalled(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is IsAppInstalledProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$isAppInstalledHash() => r'e90f87dc72c69900551a361888b6f5f94a2a33ae';

final class IsAppInstalledFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<bool>, String> {
  IsAppInstalledFamily._()
    : super(
        retry: null,
        name: r'isAppInstalledProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  IsAppInstalledProvider call(String packageName) =>
      IsAppInstalledProvider._(argument: packageName, from: this);

  @override
  String toString() => r'isAppInstalledProvider';
}

@ProviderFor(AppService)
final appServiceProvider = AppServiceProvider._();

final class AppServiceProvider
    extends $NotifierProvider<AppService, AppServiceState> {
  AppServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appServiceHash();

  @$internal
  @override
  AppService create() => AppService();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AppServiceState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AppServiceState>(value),
    );
  }
}

String _$appServiceHash() => r'351ee19a69246d76323b21667cc12d3e4e410116';

abstract class _$AppService extends $Notifier<AppServiceState> {
  AppServiceState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AppServiceState, AppServiceState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AppServiceState, AppServiceState>,
              AppServiceState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
