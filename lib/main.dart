import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // For kIsWeb
import 'package:flutter/services.dart'; // For Clipboard
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

void main() {
  runApp(WineApp());
}

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
    {
      'name': 'Gran Corte 2019',
      'image': 'assets/wine1.png',
      'sweetness': 'Dry',
      'body': 'Full-bodied',
      'pairing': 'Steak, Lamb',
      'itemcd': '020714389109111' // 핸드크림 바코드 (임시 zzzzz)
    },
    {
      'name': 'Pinot Gris 2021',
      'image': 'assets/wine2.png',
      'sweetness': 'Dry',
      'body': 'Full-bodied',
      'pairing': 'Beef, Venison',
      'itemcd': '4021354034066222' // 핸드크림2 바코드 (임시 zzzzz)
    },
    {
      'name': 'Gran Corte 2020',
      'image': 'assets/wine1.png',
      'sweetness': 'Dry',
      'body': 'Full-bodied',
      'pairing': 'Steak, Lamb',
      'itemcd': '020714389109333' // 핸드크림 바코드 (임시 zzzzz)
    },
    {
      'name': 'Pinot Gris 2020',
      'image': 'assets/wine2.png',
      'sweetness': 'Dry',
      'body': 'Full-bodied',
      'pairing': 'Beef, Venison',
      'itemcd': '4021354034066444' // 핸드크림2 바코드 (임시 zzzzz)
    },
    {
      'name': 'Gran Corte 1998',
      'image': 'assets/wine1.png',
      'sweetness': 'Dry',
      'body': 'Full-bodied',
      'pairing': 'Steak, Lamb',
      'itemcd': '020714389109555' // 핸드크림 바코드 (임시 zzzzz)
    },
    {
      'name': 'Pinot Gris 2023',
      'image': 'assets/wine2.png',
      'sweetness': 'Dry',
      'body': 'Full-bodied',
      'pairing': 'Beef, Venison',
      'itemcd': '4021354034066666' // 핸드크림2 바코드 (임시 zzzzz)
    },
    // Add more wine entries here
  ];

  List<Map<String, String>> filteredWines = [];
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    filteredWines = wines;

    if (kIsWeb || Platform.isMacOS || Platform.isWindows || Platform.isLinux) {
      // 웹 - 화면 로드되면 자동으로 TextField 에 포커스 (바코드 스캔하면 바로 들어가게)
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _searchFocusNode.requestFocus();
      });
    }
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
          .where((wine) =>
      wine['name']!.toLowerCase().contains(searchQuery.toLowerCase()) ||
          wine['itemcd']!.toLowerCase().contains(searchQuery.toLowerCase()))
          .toList();
    });
  }

  // Text Recognition Function
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.camera);

    if (image == null) return;

    final inputImage = InputImage.fromFile(File(image.path));
    final textRecognizer = TextRecognizer();
    final recognizedText = await textRecognizer.processImage(inputImage);

    // 인식된 텍스트를 보여주고 사용자가 선택할 수 있도록 합니다.
    showDialog(
      context: context,
      builder: (context) => SelectTextDialog(
        text: recognizedText.text,
        onTextSelected: (selectedText) {
          setState(() {
            searchQuery = selectedText;
            _controller.text = selectedText;
            _searchWines();
          });
        },
      ),
    );
    // Join text lines and remove extra whitespaces
    // String text = recognizedText.text
    //     .replaceAll('\n', ' ') // Replace newlines with spaces
    //     .replaceAll(RegExp(r'\s+'), ' '); // Remove extra whitespaces
    //
    // // Update the searchQuery and search wines
    // setState(() {
    //   searchQuery = text;
    //   _controller.text = text;
    //   _searchWines();
    // });

    textRecognizer.close();
  }

  @override
  Widget build(BuildContext context) {
    // Determine if the screen is narrow
    bool isNarrowScreen = MediaQuery
        .of(context)
        .size
        .width < MediaQuery
        .of(context)
        .size
        .height;

    return Scaffold(
      body: isNarrowScreen ? buildVerticalLayout() : buildHorizontalLayout(),
    );
  }

  Widget buildHorizontalLayout() {
    return Row(
      children: [
        // Product Grid (70% of width)
        Expanded(
          flex: 7,
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10.0,
                mainAxisSpacing: 10.0,
                childAspectRatio: 0.7,
              ),
              itemCount: filteredWines.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            WineDetailScreen(wine: filteredWines[index]),
                      ),
                    );
                  },
                  child: GridTile(
                    child: Image.asset(
                      filteredWines[index]['image']!,
                      fit: BoxFit.fitHeight,
                    ),
                    footer: GridTileBar(
                      backgroundColor: Colors.black54,
                      title: Text(filteredWines[index]['name']!),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        // AppBar and Search (30% of width)
        Expanded(
          flex: 3,
          child: Container(
            color: Color(0xFF3C3636),
            padding: EdgeInsets.all(16.0),
            child: Column(
              children: [
                Image.asset(
                  'assets/thehyundailogo.png',
                  fit: BoxFit.contain,
                ),
                SizedBox(height: 50.0),
                Padding(
                  padding: EdgeInsets.only(bottom: 16.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          focusNode: _searchFocusNode,
                          controller: _controller,
                          onChanged: (value) {
                            searchQuery = value;
                            _searchWines();
                          },
                          decoration: InputDecoration(
                            hintText: '조회할 상품을 스캔해주세요',
                            hintStyle: TextStyle(color: Colors.white),
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 10.0),
                          ),
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      SizedBox(width: 10.0),
                      IconButton(
                        icon: Icon(Icons.search),
                        onPressed: _searchWines,
                      ),
                      IconButton(
                        icon: Icon(Icons.camera_alt),
                        onPressed: _pickImage,
                      ),
                    ],
                  ),
                ),
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
    );
  }

  Widget buildVerticalLayout() {
    return Column(
      children: [
        // AppBar (20% of height)
        Container(
          height: MediaQuery
              .of(context)
              .size
              .height * 0.2,
          color: Color(0xFF3C3636),
          child: Column(
            children: [
              SizedBox(height: 20.0),
              Image.asset(
                'assets/thehyundailogo.png',
                fit: BoxFit.contain,
              ),
              SizedBox(height: 20.0),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        focusNode: _searchFocusNode,
                        controller: _controller,
                        onChanged: (value) {
                          searchQuery = value;
                          if (_debounce?.isActive ?? false) _debounce?.cancel();

                          _debounce = Timer(Duration(milliseconds: 500), () {
                            _searchWines();
                          });
                        },
                        decoration: InputDecoration(
                          hintText: '조회할 상품을 스캔해주세요',
                          hintStyle: TextStyle(color: Colors.white),
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 10.0),
                        ),
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    SizedBox(width: 10.0),
                    IconButton(
                      icon: Icon(Icons.search),
                      onPressed: _searchWines,
                    ),
                    SizedBox(width: 10.0),
                    IconButton(
                      icon: Icon(Icons.camera_alt),
                      onPressed: _pickImage,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        // Product Grid (80% of height)
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: ListView.builder(
              itemCount: filteredWines.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            WineDetailScreen(wine: filteredWines[index]),
                      ),
                    );
                  },
                  child: Card(
                    child: ListTile(
                      leading: Image.asset(
                        filteredWines[index]['image']!,
                        fit: BoxFit.cover,
                      ),
                      title: Text(filteredWines[index]['name']!),
                      subtitle: Text(
                        '${filteredWines[index]['sweetness']} - ${filteredWines[index]['body']}',
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class SelectTextDialog extends StatelessWidget {
  final String text;
  final Function(String) onTextSelected;

  SelectTextDialog({required this.text, required this.onTextSelected});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('인식된 텍스트'),
      content: SelectableText(
        text,
        onTap: () async {
          // 사용자가 선택한 텍스트를 가져옵니다.
          final selectedText = await Clipboard.getData('text/plain');
          if (selectedText != null && selectedText.text != null) {
            onTextSelected(selectedText.text!);
            Navigator.of(context).pop();
          }
        },
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('닫기'),
        ),
      ],
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
          title: Image.asset('assets/thehyundailogo.png'),
          backgroundColor: Color(0xFF3C3636)),
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
                  Text('이름: ${wine['name']}',
                      style:
                      TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  SizedBox(height: 8.0),
                  Text('당도: ${wine['sweetness']}',
                      style: TextStyle(fontSize: 18)),
                  SizedBox(height: 8.0),
                  Text('바디: ${wine['body']}', style: TextStyle(fontSize: 18)),
                  SizedBox(height: 8.0),
                  Text('페어링: ${wine['pairing']}',
                      style: TextStyle(fontSize: 18)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
