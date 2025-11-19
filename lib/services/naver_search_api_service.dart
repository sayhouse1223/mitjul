import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mitjul_app_new/models/book.dart';

class NaverSearchApiService {
  // Naver Search API 인증 정보
  // TODO: 실제 Client ID와 Client Secret을 설정하거나 환경 변수로 관리하세요
  // Naver Developers (https://developers.naver.com/)에서 애플리케이션 등록 후 발급받은 키를 입력하세요
  static const String _clientId = 'NGJ5y7kLSql91CQR5WRt';
  static const String _clientSecret = 'pniLNCPvyA';
  static const String _baseUrl = 'https://openapi.naver.com/v1/search/book.json';

  // 도서 검색 기능 (Future List<Book> 반환)
  Future<List<Book>> searchBooks(String query, {int start = 1}) async {
    
    // API 키가 설정되지 않았는지 확인 (플레이스홀더 값과 비교)
    if (_clientId.isEmpty || _clientSecret.isEmpty || 
        _clientId == 'YOUR_NAVER_CLIENT_ID' || _clientSecret == 'YOUR_NAVER_CLIENT_SECRET') {
      throw Exception('Naver API 인증 정보가 설정되지 않았습니다. Client ID와 Client Secret을 설정해주세요.');
    }

    // 쿼리 문자열 인코딩 및 API 호출 URL 생성
    final encodedQuery = Uri.encodeComponent(query);
    // display: 한 번에 가져올 개수 (20개로 고정)
    // start: 검색 시작 위치 (1부터 시작, 1001 이상은 불가능)
    // sort: sim 유지
    final url = Uri.parse('$_baseUrl?query=$encodedQuery&display=20&start=$start&sort=sim'); 

    try {
      final response = await http.get(
        url,
        headers: {
          'X-Naver-Client-Id': _clientId,
          'X-Naver-Client-Secret': _clientSecret,
        },
      );

      if (response.statusCode == 200) {
        // 성공적인 응답 처리
        final data = json.decode(response.body);
        
        // 'items' 배열이 있는지 확인
        if (data['items'] != null) {
          final List<dynamic> items = data['items'];
          
          // 각 아이템을 Book.fromJson 팩토리 메서드를 사용하여 Book 객체로 변환
          return items.map((item) => Book.fromNaverJson(item)).toList();
        } else {
          // 검색 결과가 없는 경우
          return []; 
        }
      } else {
        // HTTP 요청 실패 (예: 401 인증 오류, 404, 500 등)
        final errorBody = json.decode(response.body);
        final errorMessage = errorBody['errorMessage'] ?? '알 수 없는 오류';
        final errorCode = errorBody['errorCode'] ?? '';
        
        print('Naver API 요청 실패. 상태 코드: ${response.statusCode}');
        print('에러 코드: $errorCode');
        print('에러 메시지: $errorMessage');
        print('응답 본문: ${response.body}');
        
        if (response.statusCode == 401) {
          throw Exception('Naver API 인증 실패: $errorMessage (에러 코드: $errorCode)\nClient ID와 Client Secret이 올바른지 확인해주세요.');
        }
        
        throw Exception('도서 검색 API 호출에 실패했습니다: $errorMessage');
      }
    } catch (e) {
      // 네트워크 오류 또는 JSON 파싱 오류 처리
      if (e is Exception && e.toString().contains('Naver API 인증')) {
        rethrow; // 인증 관련 에러는 그대로 전달
      }
      print('예외 발생: $e');
      throw Exception('네트워크 오류 또는 데이터 처리 중 문제가 발생했습니다: $e');
    }
  }
}

