import 'package:flutter/material.dart';

void main() {
  runApp(WineApp());
}
// 메인화면 최적화 사이즈 768*768
class WineApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wine App',
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
  final List<Map<String, String>> wines = [
    {
      'name': 'Gran Corte 2018',
      'image': 'assets/wine1.png',
      'sweetness': 'Dry',
      'body': 'Full-bodied',
      'pairing': 'Steak, Lamb',
    },
    {
      'name': 'Pinot Gris 2022',
      'image': 'assets/wine2.png',
      'sweetness': 'Dry',
      'body': 'Full-bodied',
      'pairing': 'Beef, Venison',
    },
  // Add more wine entries here
  ];

  List<Map<String, String>> filteredWines = [];
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    filteredWines = wines;
  }

  void _searchWines() {
    setState(() {
      filteredWines = wines
          .where((wine) => wine['name']!.toLowerCase().contains(searchQuery.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Wine Curation'),
      ),
      body: Column(
        children: [
          // Search Bar and Button
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    onChanged: (value) {
                      searchQuery = value;
                    },
                    decoration: InputDecoration(
                      hintText: 'Search for a wine...',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 10.0),
                    ),
                  ),
                ),
                SizedBox(width: 10.0),
                ElevatedButton(
                  onPressed: _searchWines,
                  child: Text('Search'),
                ),
              ],
            ),
          ),
          // GridView for displaying wines
          Expanded(
            child: GridView.builder(
              padding: EdgeInsets.all(10.0),
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
                      height: 200.0,
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
        title: Text(wine['name']!),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Row(
          children: [
            Image.asset(
              wine['image']!,
              fit: BoxFit.fitHeight,
            ),
            SizedBox(width: 16.0),
            Expanded(
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