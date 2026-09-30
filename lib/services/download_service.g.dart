// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'download_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(isDownloading)
final isDownloadingProvider = IsDownloadingFamily._();

final class IsDownloadingProvider extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  IsDownloadingProvider._({
    required IsDownloadingFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'isDownloadingProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$isDownloadingHash();

  @override
  String toString() {
    return r'isDownloadingProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    final argument = this.argument as String;
    return isDownloading(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is IsDownloadingProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$isDownloadingHash() => r'b51182975e0c04016744b0623a090aa55fe56f7e';

final class IsDownloadingFamily extends $Family
    with $FunctionalFamilyOverride<bool, String> {
  IsDownloadingFamily._()
    : super(
        retry: null,
        name: r'isDownloadingProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  IsDownloadingProvider call(String packageName) =>
      IsDownloadingProvider._(argument: packageName, from: this);

  @override
  String toString() => r'isDownloadingProvider';
}

@ProviderFor(isLoading)
final isLoadingProvider = IsLoadingFamily._();

final class IsLoadingProvider extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  IsLoadingProvider._({
    required IsLoadingFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'isLoadingProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$isLoadingHash();

  @override
  String toString() {
    return r'isLoadingProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    final argument = this.argument as String;
    return isLoading(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is IsLoadingProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$isLoadingHash() => r'b1ebe03e720f45a67dc427bebacf6b15dca265fc';

final class IsLoadingFamily extends $Family
    with $FunctionalFamilyOverride<bool, String> {
  IsLoadingFamily._()
    : super(
        retry: null,
        name: r'isLoadingProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  IsLoadingProvider call(String packageName) =>
      IsLoadingProvider._(argument: packageName, from: this);

  @override
  String toString() => r'isLoadingProvider';
}

@ProviderFor(isCompleted)
final isCompletedProvider = IsCompletedFamily._();

final class IsCompletedProvider extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  IsCompletedProvider._({
    required IsCompletedFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'isCompletedProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$isCompletedHash();

  @override
  String toString() {
    return r'isCompletedProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    final argument = this.argument as String;
    return isCompleted(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is IsCompletedProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$isCompletedHash() => r'59227ba0ff7368ae0c1b1913081fd907eec71ca0';

final class IsCompletedFamily extends $Family
    with $FunctionalFamilyOverride<bool, String> {
  IsCompletedFamily._()
    : super(
        retry: null,
        name: r'isCompletedProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  IsCompletedProvider call(String packageName) =>
      IsCompletedProvider._(argument: packageName, from: this);

  @override
  String toString() => r'isCompletedProvider';
}

@ProviderFor(downloadProgress)
final downloadProgressProvider = DownloadProgressFamily._();

final class DownloadProgressProvider
    extends $FunctionalProvider<double, double, double>
    with $Provider<double> {
  DownloadProgressProvider._({
    required DownloadProgressFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'downloadProgressProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$downloadProgressHash();

  @override
  String toString() {
    return r'downloadProgressProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<double> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  double create(Ref ref) {
    final argument = this.argument as String;
    return downloadProgress(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(double value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<double>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is DownloadProgressProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$downloadProgressHash() => r'5832f9a76422270d75b1d28b5fd32596d9d39f13';

final class DownloadProgressFamily extends $Family
    with $FunctionalFamilyOverride<double, String> {
  DownloadProgressFamily._()
    : super(
        retry: null,
        name: r'downloadProgressProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  DownloadProgressProvider call(String packageName) =>
      DownloadProgressProvider._(argument: packageName, from: this);

  @override
  String toString() => r'downloadProgressProvider';
}

@ProviderFor(DownloadService)
final downloadServiceProvider = DownloadServiceProvider._();

final class DownloadServiceProvider
    extends $NotifierProvider<DownloadService, Map<String, DownloadSnapshot>> {
  DownloadServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'downloadServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$downloadServiceHash();

  @$internal
  @override
  DownloadService create() => DownloadService();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Map<String, DownloadSnapshot> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Map<String, DownloadSnapshot>>(
        value,
      ),
    );
  }
}

String _$downloadServiceHash() => r'8749d52aebb4bb47677876c891004b75b6d4304f';

abstract class _$DownloadService
    extends $Notifier<Map<String, DownloadSnapshot>> {
  Map<String, DownloadSnapshot> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<
              Map<String, DownloadSnapshot>,
              Map<String, DownloadSnapshot>
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                Map<String, DownloadSnapshot>,
                Map<String, DownloadSnapshot>
              >,
              Map<String, DownloadSnapshot>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
