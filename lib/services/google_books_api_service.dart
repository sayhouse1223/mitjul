import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mitjul_app_new/models/book.dart'; // 이전 단계에서 정의한 Book 모델

class GoogleBooksApiService {
  // TODO: 실제 Google Books API Key를 여기에 설정하거나, 숨겨야 합니다.
  // 현재는 API Key 없이도 검색이 가능한 공개 API이므로 비워둡니다.
  static const String _apiKey = ''; 
  static const String _baseUrl = 'https://www.googleapis.com/books/v1/volumes';

  // 도서 검색 기능 (Future List<Book> 반환)
  Future<List<Book>> searchBooks(String query) async {
    // 쿼리 문자열 인코딩 및 API 호출 URL 생성
    final encodedQuery = Uri.encodeComponent(query);
    // maxResults: 결과 개수 제한 (20개)
    // projection=lite: 꼭 필요한 필드만 요청하여 응답 속도 향상
    final url = Uri.parse('$_baseUrl?q=$encodedQuery&maxResults=20&projection=lite&key=$_apiKey');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        // 성공적인 응답 처리
        final data = json.decode(response.body);
        
        // 'items' 배열이 있는지 확인
        if (data['items'] != null) {
          final List<dynamic> items = data['items'];
          
          // 각 아이템을 Book.fromJson 팩토리 메서드를 사용하여 Book 객체로 변환
          return items.map((item) => Book.fromJson(item)).toList();
        } else {
          // 검색 결과가 없는 경우
          return []; 
        }
      } else {
        // HTTP 요청 실패 (예: 404, 500 등)
        print('API 요청 실패. 상태 코드: ${response.statusCode}');
        throw Exception('도서 검색 API 호출에 실패했습니다.');
      }
    } on Exception catch (e) {
      // 네트워크 오류 또는 JSON 파싱 오류 처리
      print('예외 발생: $e');
      throw Exception('네트워크 오류 또는 데이터 처리 중 문제가 발생했습니다.');
    }
  }
}