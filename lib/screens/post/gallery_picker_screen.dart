import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:mitjul_app_new/components/app_header.dart';
import 'package:mitjul_app_new/constants/colors.dart';
import 'package:mitjul_app_new/screens/post/camera_screen.dart';
import 'package:mitjul_app_new/screens/post/ocr_extraction_screen.dart';

/// Step 1: 갤러리 선택 화면 (인스타그램 스타일)
/// 
/// 상단: 선택된 이미지 프리뷰 (큰 영역)
/// 하단: 갤러리 그리드 (첫번째는 카메라 아이콘)
class GalleryPickerScreen extends StatefulWidget {
  const GalleryPickerScreen({super.key});

  @override
  State<GalleryPickerScreen> createState() => _GalleryPickerScreenState();
}

class _GalleryPickerScreenState extends State<GalleryPickerScreen> with WidgetsBindingObserver {
  List<AssetEntity> _mediaList = [];
  AssetEntity? _selectedAsset;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadGalleryImages();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // 앱이 다시 활성화되면 갤러리 다시 로드
      _loadGalleryImages();
    }
  }

  /// 갤러리 이미지 로드
  Future<void> _loadGalleryImages() async {
    print('🖼️ 갤러리 이미지 로드 시작');
    
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }
    
    try {
      print('📸 권한 요청 시작');
      final PermissionState ps = await PhotoManager.requestPermissionExtend();
      print('📸 권한 상태: ${ps.isAuth ? "허용됨" : "거부됨"}');
      
      if (!mounted) {
        print('⚠️ Widget이 dispose됨 (권한 체크 후)');
        return;
      }
      
      if (!ps.isAuth) {
        print('❌ 권한이 거부되어 다이얼로그 표시');
        setState(() {
          _isLoading = false;
        });
        _showPermissionDialog();
        return;
      }

      print('📁 앨범 목록 가져오기 시작');
      final List<AssetPathEntity> albums = await PhotoManager.getAssetPathList(
        type: RequestType.image,
        onlyAll: true,
      );
      print('📁 앨범 개수: ${albums.length}');

      if (!mounted) {
        print('⚠️ Widget이 dispose됨 (앨범 로드 후)');
        return;
      }

      if (albums.isEmpty) {
        print('⚠️ 앨범이 비어있음');
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final recentAlbum = albums.first;
      print('📷 최근 앨범에서 이미지 가져오기: ${recentAlbum.name}');
      
      final List<AssetEntity> media = await recentAlbum.getAssetListRange(
        start: 0,
        end: 100, // 최근 100개 이미지
      );
      print('📷 로드된 이미지 개수: ${media.length}');

      if (!mounted) {
        print('⚠️ Widget이 dispose됨 (이미지 로드 후)');
        return;
      }

      setState(() {
        _mediaList = media;
        _selectedAsset = media.isNotEmpty ? media.first : null;
        _isLoading = false;
      });
      
      print('✅ 갤러리 로드 완료');
    } catch (e, stackTrace) {
      print('❌ 갤러리 로드 오류: $e');
      print('스택 트레이스: $stackTrace');
      
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('갤러리를 불러올 수 없습니다: $e')),
        );
      }
    }
  }

  /// 권한 요청 다이얼로그
  void _showPermissionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('사진 권한 필요'),
        content: const Text('갤러리에서 사진을 선택하려면 사진 접근 권한이 필요합니다.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // 다이얼로그 닫기
              Navigator.of(context).pop(); // 갤러리 화면 닫기
            },
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop(); // 다이얼로그 닫기
              await PhotoManager.openSetting();
              // 설정에서 돌아오면 didChangeAppLifecycleState가 호출되어 자동으로 다시 로드
            },
            child: const Text('설정으로 이동'),
          ),
        ],
      ),
    );
  }

  /// 카메라 화면으로 이동
  void _openCamera() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const CameraScreen(),
      ),
    );
  }

  /// 선택된 이미지로 다음 단계 진행
  Future<void> _proceedWithSelectedImage() async {
    if (_selectedAsset == null) return;

    // AssetEntity를 File로 변환
    final file = await _selectedAsset!.file;
    if (file == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('이미지를 불러올 수 없습니다.')),
      );
      return;
    }

    if (mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => OcrExtractionScreen(imageFile: file),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppHeader.sub(
        title: '꾸미기',
        onBack: () => Navigator.of(context).pop(),
        rightButtonText: '다음',
        onRightAction: _proceedWithSelectedImage,
        isRightButtonEnabled: _selectedAsset != null,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // 상단: 선택된 이미지 프리뷰
                _buildPreviewArea(),

                // 하단: 갤러리 그리드
                Expanded(
                  child: _buildGalleryGrid(),
                ),
              ],
            ),
    );
  }

  /// 상단 프리뷰 영역
  Widget _buildPreviewArea() {
    return Container(
      width: double.infinity,
      height: MediaQuery.of(context).size.width, // 정사각형
      color: AppColors.grayscale20,
      child: _selectedAsset == null
          ? const Center(
              child: Icon(Icons.image, size: 80, color: AppColors.grayscale40),
            )
          : FutureBuilder<File?>(
              future: _selectedAsset!.file,
              builder: (context, snapshot) {
                if (snapshot.hasData && snapshot.data != null) {
                  return Image.file(
                    snapshot.data!,
                    fit: BoxFit.cover,
                  );
                }
                return const Center(child: CircularProgressIndicator());
              },
            ),
    );
  }

  /// 하단 갤러리 그리드
  Widget _buildGalleryGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(2),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 2,
        mainAxisSpacing: 2,
      ),
      itemCount: _mediaList.length + 1, // +1 for camera button
      itemBuilder: (context, index) {
        // 첫 번째 아이템: 카메라 버튼
        if (index == 0) {
          return _buildCameraButton();
        }

        // 나머지: 갤러리 이미지
        final asset = _mediaList[index - 1];
        final isSelected = _selectedAsset?.id == asset.id;

        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedAsset = asset;
            });
          },
          child: Stack(
            fit: StackFit.expand,
            children: [
              AssetEntityImage(
                asset,
                isOriginal: false,
                thumbnailSize: const ThumbnailSize.square(200),
                fit: BoxFit.cover,
              ),
              if (isSelected)
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: AppColors.primary0,
                      width: 3,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  /// 카메라 버튼 (그리드 첫 번째 아이템)
  Widget _buildCameraButton() {
    return GestureDetector(
      onTap: _openCamera,
      child: Container(
        color: AppColors.grayscale20,
        child: const Center(
          child: Icon(
            Icons.camera_alt,
            size: 40,
            color: AppColors.grayscale60,
          ),
        ),
      ),
    );
  }
}

/// AssetEntity를 이미지로 표시하는 위젯
class AssetEntityImage extends StatelessWidget {
  final AssetEntity asset;
  final bool isOriginal;
  final ThumbnailSize thumbnailSize;
  final BoxFit fit;

  const AssetEntityImage(
    this.asset, {
    super.key,
    this.isOriginal = false,
    this.thumbnailSize = const ThumbnailSize.square(200),
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Uint8List?>(
      future: asset.thumbnailDataWithSize(thumbnailSize),
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data != null) {
          return Image.memory(
            snapshot.data!,
            fit: fit,
          );
        }
        return Container(
          color: AppColors.grayscale10,
          child: const Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }
}

