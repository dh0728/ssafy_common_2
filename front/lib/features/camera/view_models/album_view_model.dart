import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kkulkkulk/features/camera/data/models/album_model.dart';
import 'package:kkulkkulk/features/camera/data/repositories/album_repository.dart';
import 'package:logger/logger.dart';

final logger = Logger();

final albumViewModelProvider =
    AsyncNotifierProvider<AlbumViewModel, AlbumResponse?>(
        () => AlbumViewModel());

class AlbumViewModel extends AsyncNotifier<AlbumResponse?> {
  late final AlbumRepository _repository;

  @override
  Future<AlbumResponse?> build() async {
    _repository = ref.read(albumRepositoryProvider);
    return null;
  }

  Future<void> fetchAlbum({
    required String date,
    required bool isSuccess,
  }) async {
    state = const AsyncLoading();
    try {
      logger.d("앨범 데이터 요청 시작: date=$date, isSuccess=$isSuccess");

      final response = await _repository.getAlbums(
        date: date,
        isSuccess: isSuccess,
      );

      if (response.statusCode == 200) {
        final albumResponse = AlbumResponse.fromJson(response.data);
        state = AsyncData(albumResponse);
        logger.d("앨범 데이터 로드 성공: ${albumResponse.albumObject.length}개의 항목");
      } else {
        throw Exception('앨범 데이터 로드 실패: ${response.statusCode}');
      }
    } catch (e, stack) {
      state = AsyncError(e, stack);
    }
  }

  void setLoading() {
    state = const AsyncLoading();
  }

  void resetAlbumData() {
    state = const AsyncData(null);
  }
}
