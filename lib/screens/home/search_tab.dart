import 'package:flutter/material.dart';
import 'package:mitjul_app_new/components/app_header.dart';
import 'package:mitjul_app_new/components/chips.dart';
import 'package:mitjul_app_new/constants/colors.dart';
import 'package:mitjul_app_new/features/search/controllers/book_search_controller.dart';
import 'package:mitjul_app_new/features/search/widgets/book_search_result_list.dart';
import 'package:mitjul_app_new/features/search/widgets/search_bar.dart';
import 'package:mitjul_app_new/features/search/widgets/search_empty_state.dart';
import 'package:mitjul_app_new/models/book.dart';
import 'package:mitjul_app_new/screens/post/post_creation_screen.dart';

class SearchTab extends StatefulWidget {
  const SearchTab({super.key});

  @override
  State<SearchTab> createState() => _SearchTabState();
}

class _SearchTabState extends State<SearchTab> {
  final TextEditingController _searchFieldController = TextEditingController();
  late final BookSearchController _bookSearchController = BookSearchController();
  final ScrollController _scrollController = ScrollController();
  SearchTabType _selectedTab = SearchTabType.underline;
  bool _isChipVisible = true;
  double _lastScrollOffset = 0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_handleScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_handleScroll);
    _scrollController.dispose();
    _searchFieldController.dispose();
    _bookSearchController.dispose();
    super.dispose();
  }

  void _handleScroll() {
    if (!_scrollController.hasClients) return;
    
    final currentOffset = _scrollController.offset;
    final scrollDelta = currentOffset - _lastScrollOffset;
    final maxScrollExtent = _scrollController.position.maxScrollExtent;
    
    // 스크롤을 아래로 내리면 칩 영역 숨김 (10px 이상 스크롤)
    if (scrollDelta > 10 && _isChipVisible) {
      setState(() {
        _isChipVisible = false;
      });
    }
    // 스크롤을 위로 올리면 칩 영역 표시 (10px 이상 스크롤)
    else if (scrollDelta < -10 && !_isChipVisible) {
      setState(() {
        _isChipVisible = true;
      });
    }
    
    // 무한 스크롤: 스크롤이 끝에 가까워지면 추가 데이터 로드
    // 현재 위치가 최대 스크롤 위치의 80% 이상이면 추가 로드
    if (_selectedTab == SearchTabType.book && 
        maxScrollExtent > 0 && 
        currentOffset >= maxScrollExtent * 0.8 &&
        _bookSearchController.hasMore &&
        !_bookSearchController.isFetchingMore) {
      _bookSearchController.fetchMore();
    }
    
    _lastScrollOffset = currentOffset;
  }

  void _handleSearch(String query) {
    final trimmed = query.trim();
    
    // 검색어가 비어있으면 모든 탭 초기화
    if (trimmed.isEmpty) {
      _bookSearchController.clear();
      // TODO: 밑줄, 라이너 검색 결과도 초기화
      return;
    }
    
    // 세 탭 모두에서 검색 실행
    _bookSearchController.search(trimmed);
    // TODO: 밑줄 검색 실행
    // TODO: 라이너 검색 실행
    print('밑줄 검색: $trimmed');
    print('라이너 검색: $trimmed');
  }

  void _handleBookSelection(Book book) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PostCreationScreen(selectedBook: book),
      ),
    );
  }

  Widget _buildTabChips() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          AppChip(
            label: '밑줄',
            isSelected: _selectedTab == SearchTabType.underline,
            onTap: () {
              setState(() {
                _selectedTab = SearchTabType.underline;
              });
            },
            style: ChipStyle.line,
            size: ChipSize.small,
          ),
          const SizedBox(width: 8),
          AppChip(
            label: '책',
            isSelected: _selectedTab == SearchTabType.book,
            onTap: () {
              setState(() {
                _selectedTab = SearchTabType.book;
              });
            },
            style: ChipStyle.line,
            size: ChipSize.small,
          ),
          const SizedBox(width: 8),
          AppChip(
            label: '라이너',
            isSelected: _selectedTab == SearchTabType.liner,
            onTap: () {
              setState(() {
                _selectedTab = SearchTabType.liner;
              });
            },
            style: ChipStyle.line,
            size: ChipSize.small,
          ),
        ],
      ),
    );
  }

  Widget _buildResults() {
    // 책 검색 탭인 경우에만 BookSearchController 사용
    if (_selectedTab == SearchTabType.book) {
      return AnimatedBuilder(
        animation: _bookSearchController,
        builder: (context, _) {
          final status = _bookSearchController.status;
          final hasQuery = _searchFieldController.text.trim().isNotEmpty;

          switch (status) {
            case SearchStatus.loading:
              return const Center(
                child: CircularProgressIndicator(color: AppColors.primary0),
              );
            case SearchStatus.error:
              return SearchEmptyState(
                tabType: SearchTabType.book,
              );
            case SearchStatus.empty:
              return SearchEmptyState(
                tabType: SearchTabType.book,
              );
            case SearchStatus.success:
              return Column(
                children: [
                  Expanded(
                    child: BookSearchResultList(
                      books: _bookSearchController.books,
                      onBookTap: _handleBookSelection,
                      scrollController: _scrollController,
                    ),
                  ),
                  // 추가 로딩 인디케이터
                  if (_bookSearchController.isFetchingMore)
                    const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.primary0,
                        ),
                      ),
                    ),
                ],
              );
            case SearchStatus.idle:
            default:
              if (hasQuery) {
                return SearchEmptyState(
                  tabType: SearchTabType.book,
                );
              }
              return SearchEmptyState(
                tabType: SearchTabType.book,
              );
          }
        },
      );
    }

    // 밑줄 또는 라이너 탭
    final hasQuery = _searchFieldController.text.trim().isNotEmpty;
    if (hasQuery) {
      // TODO: 실제 검색 결과 표시
      return SearchEmptyState(
        tabType: _selectedTab,
        onRegisterTap: _selectedTab == SearchTabType.underline
            ? () {
                // TODO: 밑줄 등록 화면으로 이동
                print('밑줄 등록하기');
              }
            : null,
      );
    }

    return SearchEmptyState(
      tabType: _selectedTab,
      onRegisterTap: _selectedTab == SearchTabType.underline
          ? () {
              // TODO: 밑줄 등록 화면으로 이동
              print('밑줄 등록하기');
            }
          : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          // 공통 헤더 (로고 + 알림 아이콘)
          const AppHeader(),
          // 검색 필드
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 12.0),
            child: AppSearchBar(
              controller: _searchFieldController,
              hintText: '검색어 입력',
              onSubmitted: _handleSearch,
              onSearchTap: () => _handleSearch(_searchFieldController.text),
              onClear: () {
                _searchFieldController.clear();
                // 모든 탭의 검색 결과 초기화
                _bookSearchController.clear();
                // TODO: 밑줄, 라이너 검색 결과도 초기화
              },
            ),
          ),
        // 탭 칩 (스크롤 방향에 따라 표시/숨김)
        AnimatedSize(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          child: _isChipVisible
              ? Column(
                  children: [
                    _buildTabChips(),
                    const SizedBox(height: 16),
                  ],
                )
              : const SizedBox.shrink(),
        ),
        // 검색 결과
        Expanded(
          child: _buildResults(),
        ),
        ],
      ),
    );
  }
}