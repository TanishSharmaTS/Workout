import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;
import 'package:url_launcher/url_launcher.dart';

class Article {
  final String title;
  final String url;
  final String date;
  final String description;
  final String? imageUrl;


  Article({
    required this.title,
    required this.url,
    required this.date,
    required this.description,
    this.imageUrl,

  });
}

class DiscoverPage extends StatefulWidget {
  @override
  _DiscoverPageState createState() => _DiscoverPageState();
}

class _DiscoverPageState extends State<DiscoverPage> {
  List<Article> articles = [];
  List<Article> healthArticles = [];


  @override
  void initState() {
    super.initState();
    fetchArticles();
    fetchHealthArticles();

  }

  Future<void> fetchArticles() async {
    final response = await http.get(Uri.parse('https://www.webmd.com/fitness-exercise/news/default.htm'));

    if (response.statusCode == 200) {
      var document = parser.parse(response.body);
      var items = document.querySelectorAll('.list > li'); // Select only `li` elements within `.list`

      setState(() {
        articles = items.take(10).map((element) {
          final linkElement = element.querySelector('a');
          final titleElement = element.querySelector('.title');
          final dateElement = element.querySelector('.tag');
          final descElement = element.querySelector('.desc');

          return Article(
            title: titleElement?.text ?? '',
            url: linkElement?.attributes['href'] ?? '',
            date: dateElement?.text ?? '',
            description: descElement?.text ?? '',
          );
        }).toList();
      });
    }
  }

  Future<void> fetchHealthArticles() async {
    final response = await http.get(Uri.parse('https://www.healthline.com/nutrition'));

    if (response.statusCode == 200) {
      var document = parser.parse(response.body);
      var items = document.querySelectorAll('.css-8sm3l3');

      setState(() {
        healthArticles = items.take(10).map((element) {
          final linkElement = element.querySelector('a.css-1yf5qft');
          final titleElement = element.querySelector('.css-1yf5qft');
          final descElement = element.querySelector('.css-onvglr');
          final imageElement = element.querySelector('img.css-10vopkp'); // Specifically targets the img inside lazy-image

          return Article(
            title: titleElement?.text ?? '',
            url: linkElement?.attributes['href'] ?? '',
            date: '', // No date available in this example
            description: descElement?.text ?? '',
            imageUrl: imageElement?.attributes['src'],
          );
        }).toList();
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // Number of tabs
      child: Scaffold(
        appBar: AppBar(
          title: Text('Discover'),
          bottom: TabBar(
            tabs: [
              Tab(text: 'News'), // First tab for articles
              Tab(text: 'Nutrition'), // Second tab for your custom content
            ],
          ),
        ),
        backgroundColor: Colors.white,
        body: TabBarView(
          children: [
            // First tab - Nutrition

            healthArticles.isEmpty
                ? Center(child: CircularProgressIndicator())
                : ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: healthArticles.length,
              itemBuilder: (context, index) {
                final article = healthArticles[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: InkWell(
                    onTap: () => _launchURL(article.url),
                    child: Card(
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      shadowColor: Colors.grey.withOpacity(0.5),
                      elevation: 6,
                      child: Container(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Title (bold)
                            Text(
                              article.title,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            SizedBox(height: 8),
                            // Description
                            Text(
                              article.description,
                              style: TextStyle(
                                color: Colors.grey[700],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),


            // Second tab - News Articles
            articles.isEmpty
                ? Center(child: CircularProgressIndicator())
                : ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: articles.length,
              itemBuilder: (context, index) {
                final article = articles[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: InkWell(
                    onTap: () => _launchURL(article.url),
                    child: Card(
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      shadowColor: Colors.grey.withOpacity(0.5),
                      elevation: 6,
                      child: Container(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              article.title,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              '${article.description}',
                              style: TextStyle(
                                color: Colors.grey[700],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw 'Could not launch $url';
    }
  }
}
