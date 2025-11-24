import 'dart:io';
import 'package:flutter/material.dart';
import 'package:mitjul_app_new/components/app_header.dart';
import 'package:mitjul_app_new/constants/colors.dart';
import 'package:mitjul_app_new/constants/text_styles.dart';
import 'package:mitjul_app_new/models/book.dart';
import 'package:mitjul_app_new/models/card_style.dart';
import 'package:mitjul_app_new/models/sticker.dart';
import 'package:mitjul_app_new/services/color_extraction_service.dart';
import 'package:mitjul_app_new/services/image_composition_service.dart';
import 'package:mitjul_app_new/screens/post/caption_input_screen.dart';
import 'package:mitjul_app_new/screens/post/widgets/card_canvas.dart';
import 'package:mitjul_app_new/screens/post/widgets/editing_panel.dart';
import 'package:palette_generator/palette_generator.dart';

/// Step 4: 카드 꾸미기 화면
/// 
/// 1:1 캔버스에서 배경, 텍스트, 스티커를 편집하여
/// 공유할 이미지 카드를 제작합니다.
class CardEditingScreen extends StatefulWidget {
  final Book selectedBook;
  final String extractedText;

  const CardEditingScreen({
    super.key,
    required this.selectedBook,
    required this.extractedText,
  });

  @override
  State<CardEditingScreen> createState() => _CardEditingScreenState();
}

class _CardEditingScreenState extends State<CardEditingScreen> {
  // 카드 캡처를 위한 GlobalKey
  final GlobalKey _cardKey = GlobalKey();

  // 카드 스타일
  late CardStyle _cardStyle;

  // 스티커 리스트
  List<Sticker> _stickers = [];

  // 선택된 스티커 ID
  String? _selectedStickerId;

  // 책 표지 색상 팔레트
  PaletteGenerator? _bookPalette;

  // 로딩 상태
  bool _isLoading = false;

  // 선택된 편집 탭
  EditingTab _selectedTab = EditingTab.background;

  @override
  void initState() {
    super.initState();
    _initializeCardStyle();
    _extractBookColors();
  }

  /// 카드 스타일 초기화
  void _initializeCardStyle() {
    _cardStyle = CardStyle(
      backgroundType: BackgroundType.blur, // 기본값을 Blur로 변경
      textSize: TextSize.medium,
      textColor: Colors.black,
      backgroundImageUrl: widget.selectedBook.thumbnailUrl,
    );
  }

  /// 책 표지에서 색상 추출
  Future<void> _extractBookColors() async {
    if (widget.selectedBook.thumbnailUrl == null) return;

    final imageProvider = NetworkImage(
      widget.selectedBook.thumbnailUrl!.replaceFirst('http://', 'https://'),
    );

    final palette = await ColorExtractionService.extractPalette(imageProvider);
    setState(() {
      _bookPalette = palette;
      // 추출된 색상으로 그라데이션 생성 (첫 번째 그라데이션을 기본값으로)
      if (palette != null) {
        final gradients = ColorExtractionService.createGradientsFromPalette(palette);
        _cardStyle = _cardStyle.copyWith(
          customGradient: gradients.first,
        );
      }
    });
  }

  /// 배경 타입 변경
  void _updateBackgroundType(BackgroundType type, {LinearGradient? gradient}) {
    setState(() {
      _cardStyle = _cardStyle.copyWith(
        backgroundType: type,
        customGradient: gradient,
      );
    });
  }

  /// 텍스트 스타일 변경
  void _updateTextStyle({TextSize? size, Color? color}) {
    setState(() {
      _cardStyle = _cardStyle.copyWith(
        textSize: size,
        textColor: color,
      );
    });
  }

  /// 스티커 추가
  void _addSticker(String assetPath) {
    setState(() {
      final sticker = Sticker(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        assetPath: assetPath,
        position: const Offset(150, 150), // 캔버스 중앙 근처
        size: 1.0,
        rotation: 0.0,
      );
      _stickers.add(sticker);
      _selectedStickerId = sticker.id; // 추가한 스티커 선택
    });
  }

  /// 스티커 업데이트
  void _updateSticker(Sticker updatedSticker) {
    setState(() {
      final index = _stickers.indexWhere((s) => s.id == updatedSticker.id);
      if (index != -1) {
        _stickers[index] = updatedSticker;
      }
    });
  }

  /// 스티커 선택
  void _selectSticker(String stickerId) {
    setState(() {
      _selectedStickerId = stickerId;
    });
  }

  /// 스티커 선택 해제
  void _deselectSticker() {
    setState(() {
      _selectedStickerId = null;
    });
  }

  /// 스티커 삭제
  void _deleteSticker(String stickerId) {
    setState(() {
      _stickers.removeWhere((s) => s.id == stickerId);
      if (_selectedStickerId == stickerId) {
        _selectedStickerId = null;
      }
    });
  }

  /// 카드 저장 및 다음 단계로 이동
  Future<void> _saveAndContinue() async {
    // 이미지 캡처 전에 선택된 스티커 저장
    final previousSelectedStickerId = _selectedStickerId;
    
    setState(() {
      _isLoading = true;
      _selectedStickerId = null; // 스티커 선택 해제 (핸들 숨김)
    });

    // UI 업데이트를 위해 짧은 대기
    await Future.delayed(const Duration(milliseconds: 100));

    try {
      // 카드를 이미지로 캡처
      final imageFile = await ImageCompositionService.captureWidgetAsImage(
        widgetKey: _cardKey,
        pixelRatio: 3.0,
      );

      if (imageFile == null) {
        throw Exception('이미지 생성에 실패했습니다.');
      }

      if (mounted) {
        // Step 5: 감상 입력 화면으로 이동
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => CaptionInputScreen(
              cardImageFile: imageFile,
              selectedBook: widget.selectedBook,
              extractedText: widget.extractedText,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        // 오류 발생 시 이전 선택 상태 복원
        setState(() {
          _selectedStickerId = previousSelectedStickerId;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('이미지 생성 중 오류가 발생했습니다: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    return Scaffold(
      backgroundColor: AppColors.grayscale10,
      appBar: AppHeader.sub(
        title: '꾸미기',
        onBack: () => Navigator.of(context).pop(),
        rightButtonText: '다음',
        onRightAction: _isLoading ? null : _saveAndContinue,
        isRightButtonEnabled: !_isLoading,
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // 1:1 캔버스 영역 (네비게이션 바로 아래, 여백 없이)
              SizedBox(
                width: screenWidth,
                height: screenWidth, // 1:1 비율
                child: RepaintBoundary(
                  key: _cardKey,
                  child: GestureDetector(
                    onTap: _deselectSticker, // 빈 공간 클릭 시 선택 해제
                    child: CardCanvas(
                      cardStyle: _cardStyle,
                      stickers: _stickers,
                      selectedStickerId: _selectedStickerId,
                      extractedText: widget.extractedText,
                      book: widget.selectedBook,
                      onStickerUpdate: _updateSticker,
                      onStickerSelect: _selectSticker,
                      onStickerDelete: _deleteSticker,
                    ),
                  ),
                ),
              ),

              // 편집 패널
              Expanded(
                child: EditingPanel(
                  selectedTab: _selectedTab,
                  cardStyle: _cardStyle,
                  bookPalette: _bookPalette,
                  bookCoverUrl: widget.selectedBook.thumbnailUrl,
                  onTabChange: (tab) {
                    setState(() {
                      _selectedTab = tab;
                    });
                  },
                  onBackgroundTypeChange: _updateBackgroundType,
                  onTextStyleChange: _updateTextStyle,
                  onStickerAdd: _addSticker,
                ),
              ),
            ],
          ),

          // 로딩 오버레이
          if (_isLoading)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.5),
                child: const Center(
                  child: CircularProgressIndicator(
                    color: Colors.white,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// 편집 탭 타입
enum EditingTab {
  background, // 배경
  text,       // 텍스트
  sticker,    // 스티커
}

