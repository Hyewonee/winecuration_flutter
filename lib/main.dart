import 'dart:async';
import 'package:flutter/material.dart';

void main() {
  runApp(WineApp());
}
// 메인화면 최적화 사이즈 768*768
class WineApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wine Curation',
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final FocusNode _searchFocusNode = FocusNode();
  final TextEditingController _controller = TextEditingController();
  Timer? _debounce;
  final List<Map<String, String>> wines = [
    {
      'name': 'Gran Corte 2018',
      'image': 'assets/wine1.png',
      'sweetness': 'Dry',
      'body': 'Full-bodied',
      'pairing': 'Steak, Lamb',
      'itemcd': '020714389109' // 핸드크림 바코드 (임시 zzzzz)
    },
    {
      'name': 'Pinot Gris 2022',
      'image': 'assets/wine2.png',
      'sweetness': 'Dry',
      'body': 'Full-bodied',
      'pairing': 'Beef, Venison',
      'itemcd': '4021354034066' // 핸드크림2 바코드 (임시 zzzzz)
    },
    // Add more wine entries here
  ];

  List<Map<String, String>> filteredWines = [];
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    filteredWines = wines;

    // Automatically focus the search TextField when the screen is loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _searchFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    // Clean up the focus node when the widget is disposed
    _searchFocusNode.dispose();
    _controller.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _searchWines() {
    setState(() {
      filteredWines = wines
          .where((wine) => wine['itemcd']!.toLowerCase().contains(searchQuery.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // 왼쪽 8할 : 대표상품 GridView
          Expanded(
            flex: 7,
            child: Container(
              height: MediaQuery.of(context).size.height ,
              child: GridView.builder(
                padding: EdgeInsets.all(50.0),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10.0,
                  mainAxisSpacing: 10.0,
                  childAspectRatio: 2 / 3,
                ),
                itemCount: filteredWines.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => WineDetailScreen(wine: filteredWines[index]),
                        ),
                      );
                    },
                    child: GridTile(
                      child: Image.asset(
                        filteredWines[index]['image']!,
                        height: MediaQuery.of(context).size.height,
                        fit: BoxFit.fitHeight,
                      ),
                      footer: GridTileBar(
                        backgroundColor: Color(0xFF3C3636),
                        title: Text(filteredWines[index]['name']!),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          // 오른쪽 2할: 검색바와 버튼
          Expanded(
            flex: 3,
            child: Container(
              color: Color(0xFF3C3636), // 배경 색상 설정
              padding: EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // 로고 이미지 추가
                  Image.asset(
                    'assets/thehyundailogo.png',
                    fit: BoxFit.contain,
                  ),
                  SizedBox(height: 50.0),
                  // Search Bar and Button
                  Padding(
                    padding: EdgeInsets.only(bottom: 16.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            focusNode: _searchFocusNode, // Attach FocusNode
                            controller: _controller,
                            onChanged: (value) {
                              searchQuery = value;
                              // 이전 타이머 취소
                              if (_debounce?.isActive ?? false) _debounce?.cancel();

                              // 500ms 대기 후 검색 함수 호출
                              _debounce = Timer(Duration(milliseconds: 500), () {
                                _searchWines();
                              });
                            },
                            decoration: InputDecoration(
                              hintText: '조회할 상품을 스캔해주세요',
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(horizontal: 10.0),
                            ),
                          ),
                        ),
                        SizedBox(width: 10.0),
                        ElevatedButton(
                          onPressed: _searchWines,
                          child: Text('검색'),
                        ),
                      ],
                    ),
                  ),
                  // Image.asset for info.gif
                  Expanded(
                    child: Image.asset(
                      'assets/main_info.gif',
                      fit: BoxFit.cover,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class WineDetailScreen extends StatelessWidget {
  final Map<String, String> wine;

  WineDetailScreen({required this.wine});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Image.asset(
              'assets/thehyundailogo.png'
          ),
          backgroundColor: Color(0xFF3C3636)
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Row(
          children: [
            // 왼쪽 3할: 와인 이미지
            Expanded(
              flex: 3,
              child: Image.asset(
                wine['image']!,
                fit: BoxFit.fitHeight,
              ),
            ),
            SizedBox(width: 16.0),
            Expanded(
              flex: 7,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('이름: ${wine['name']}', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  SizedBox(height: 8.0),
                  Text('당도: ${wine['sweetness']}', style: TextStyle(fontSize: 18)),
                  SizedBox(height: 8.0),
                  Text('바디: ${wine['body']}', style: TextStyle(fontSize: 18)),
                  SizedBox(height: 8.0),
                  Text('페어링: ${wine['pairing']}', style: TextStyle(fontSize: 18)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}