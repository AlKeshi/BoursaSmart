import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart'; // For date formatting
import 'package:unsplash_client/unsplash_client.dart';

// **News Model**
class News {
  final int id;
  final String title;
  final String description;
  final String date;
  final String createdAt;
  String? imageUrl; // Remains as String?

  News({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.createdAt,
    this.imageUrl, // Initialize as null
  });

  // Factory constructor to create a News instance from JSON
  factory News.fromJson(Map<String, dynamic> json) {
    return News(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      date: json['date'],
      createdAt: json['created_at'],
    );
  }
}


class NewsPage extends StatefulWidget {
  const NewsPage({Key? key}) : super(key: key);

  @override
  _NewsPageState createState() => _NewsPageState();
}

class _NewsPageState extends State<NewsPage> {
  // List to hold fetched news items
  List<News> _newsItems = [];
  bool _isLoading = true; // Indicates if data is being loaded
  String? _error; // Holds error message if any

  // Initialize the Unsplash client
  late final UnsplashClient _unsplashClient;

  @override
  void initState() {
    super.initState();
    // Initialize the UnsplashClient with your credentials
    _unsplashClient = UnsplashClient(
      settings: ClientSettings(
        credentials: AppCredentials(
          accessKey: 'PY34WeaX9cXc4yvvKCYuGOznnI5AK5m-Riuk_s-Y9bk', // Replace with your Access Key
          secretKey: 'doggtPugyLHFkKY5dzSN-wJiGF8s1pErtjRGkCVRDac', // Replace with your Secret Key
        ),
      ),
    );
    fetchNews(); // Fetch news when the widget is initialized
  }

  @override
  void dispose() {
    _unsplashClient.close(); // Close the client to free up resources
    super.dispose();
  }

  // Function to fetch news from the API and fetch corresponding images
  Future<void> fetchNews() async {
    // **Update the API URL based on your testing environment**
    // Example for Android Emulator:
    final String apiUrl = 'http://127.0.0.1:8000/api/news/';

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        // Decode the response body bytes using UTF-8
        final String utf8Body = utf8.decode(response.bodyBytes);
        final List<dynamic> data = json.decode(utf8Body);

        // Parse JSON data into a list of News objects
        final List<News> newsList =
            data.map((json) => News.fromJson(json)).toList();

        // Fetch image URLs for each news item
        await _fetchImagesForNews(newsList);

        setState(() {
          _newsItems = newsList;
          _isLoading = false;
        });
      } else {
        // Handle non-200 responses
        setState(() {
          _error =
              'Failed to load news. Status Code: ${response.statusCode}';
          _isLoading = false;
        });
      }
    } catch (e) {
      // Handle exceptions (e.g., network issues)
      setState(() {
        _error = 'An error occurred: $e';
        _isLoading = false;
      });
    }
  }

  // Function to fetch images for a list of news items
  Future<void> _fetchImagesForNews(List<News> newsList) async {
    // Limit the number of concurrent image fetches to avoid rate limiting
    const int maxConcurrent = 5;
    int current = 0;

    while (current < newsList.length) {
      final int end = (current + maxConcurrent > newsList.length)
          ? newsList.length
          : current + maxConcurrent;
      final batch = newsList.sublist(current, end);

      // Fetch images concurrently in batches
      await Future.wait(batch.map((news) async {
        try {
          final searchResults =
              await _unsplashClient.search.photos(news.title).goAndGet();
          if (searchResults.results.isNotEmpty) {
            setState(() {
              news.imageUrl = searchResults.results.first.urls.regular.toString();
              print(news.imageUrl);
            });
          } else {
            setState(() {
              news.imageUrl = null; // Optionally set to a default image URL
            });
          }
        } catch (e) {
          setState(() {
            news.imageUrl = null; // Optionally set to a default image URL
          });
        }
      }));

      current += maxConcurrent;
    }
  }

  // Refresh indicator to pull-to-refresh
  Future<void> _refreshNews() async {
    setState(() {
      _isLoading = true;
      _error = null;
      _newsItems.clear();
    });
    await fetchNews();
  }

  // Function to format date
  String _formatDate(String dateStr) {
    try {
      DateTime parsedDate = DateTime.parse(dateStr);
      return DateFormat('dd MMM yyyy').format(parsedDate);
    } catch (e) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFF121212), // Dark background color for consistency
      appBar: AppBar(
        title: Row(
          children: const [
            Icon(Icons.newspaper, color: Colors.white),
            SizedBox(width: 8),
            Text(
              'Latest News',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF1E1E1E),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor:
                    AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : _error != null
              ? Center(
                  child: Text(
                    _error!,
                    style:
                        const TextStyle(color: Colors.red, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                )
              : _newsItems.isEmpty
                  ? const Center(
                      child: Text(
                        'No news available at the moment.',
                        style:
                            TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _refreshNews,
                      child: ListView.builder(
                        itemCount: _newsItems.length,
                        itemBuilder: (context, index) {
                          final newsItem = _newsItems[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 8.0, horizontal: 16.0),
                            child: GestureDetector(
                              onTap: () {
                                // Navigate to the detailed news page
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        NewsDetailPage(newsItem: newsItem),
                                  ),
                                );
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color:
                                      const Color(0xFF1E1E1E), // Card color
                                  borderRadius:
                                      BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black
                                          .withOpacity(0.5),
                                      spreadRadius: 1,
                                      blurRadius: 5,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    // News Image with Fallback
                                    ClipRRect(
                                      borderRadius:
                                          const BorderRadius.only(
                                        topLeft:
                                            Radius.circular(12),
                                        topRight:
                                            Radius.circular(12),
                                      ),
                                      child: newsItem.imageUrl != null
                                          ? Image.network(
                                              newsItem.imageUrl!,
                                              width: double.infinity,
                                              height: 200,
                                              fit: BoxFit.cover,
                                              loadingBuilder: (context,
                                                  child, progress) {
                                                if (progress == null)
                                                  return child;
                                                return Container(
                                                  width: double.infinity,
                                                  height: 200,
                                                  color:
                                                      Colors.grey[800],
                                                  child: const Center(
                                                    child:
                                                        CircularProgressIndicator(
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                );
                                              },
                                              errorBuilder: (context,
                                                  error, stackTrace) {
                                                return Container(
                                                  width: double.infinity,
                                                  height: 200,
                                                  color:
                                                      Colors.grey[800],
                                                  child: const Icon(
                                                    Icons.broken_image,
                                                    color:
                                                        Colors.white,
                                                    size: 50,
                                                  ),
                                                );
                                              },
                                            )
                                          : Container(
                                              width: double.infinity,
                                              height: 200,
                                              color: Colors.grey[800],
                                              child: const Icon(
                                                Icons.broken_image,
                                                color: Colors.white,
                                                size: 50,
                                              ),
                                            ),
                                    ),
                                    Padding(
                                      padding:
                                          const EdgeInsets.all(
                                              16.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment
                                                .start,
                                        children: [
                                          // Title with Newspaper Icon
                                          Row(
                                            children: [
                                              const Icon(
                                                Icons.newspaper,
                                                color: Colors.white,
                                                size: 20,
                                              ),
                                              const SizedBox(
                                                  width: 8),
                                              Expanded(
                                                child: Text(
                                                  newsItem.title,
                                                  style:
                                                      const TextStyle(
                                                    color:
                                                        Colors.white,
                                                    fontSize: 18,
                                                    fontWeight:
                                                        FontWeight
                                                            .bold,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(
                                              height: 8),
                                          // Description (truncated)
                                          Text(
                                            newsItem.description,
                                            maxLines: 2,
                                            overflow:
                                                TextOverflow
                                                    .ellipsis,
                                            style: const TextStyle(
                                              color: Colors.grey,
                                              fontSize: 14,
                                            ),
                                          ),
                                          const SizedBox(
                                              height: 8),
                                          // Date with Calendar Icon
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment
                                                    .spaceBetween,
                                            children: [
                                              Row(
                                                children: [
                                                  const Icon(
                                                    Icons
                                                        .calendar_today,
                                                    color: Colors.grey,
                                                    size: 16,
                                                  ),
                                                  const SizedBox(
                                                      width: 4),
                                                  Text(
                                                    _formatDate(
                                                        newsItem
                                                            .date),
                                                    style:
                                                        const TextStyle(
                                                      color: Colors
                                                          .grey,
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const Icon(
                                                Icons
                                                    .arrow_forward_ios,
                                                color: Colors.grey,
                                                size: 16,
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
    );
  }
}

// **Detailed News Page**
class NewsDetailPage extends StatelessWidget {
  final News newsItem;

  const NewsDetailPage({Key? key, required this.newsItem})
      : super(key: key);

  // Function to format date
  String _formatDate(String dateStr) {
    try {
      DateTime parsedDate = DateTime.parse(dateStr);
      return DateFormat('dd MMM yyyy').format(parsedDate);
    } catch (e) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFF121212), // Dark background color
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.article, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                newsItem.title,
                style: const TextStyle(fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF1E1E1E),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            // News Image with Fallback
            ClipRRect(
              borderRadius: BorderRadius.circular(12.0),
              child: newsItem.imageUrl != null
                  ? Image.network(
                      newsItem.imageUrl!,
                      width: double.infinity,
                      height: 250,
                      fit: BoxFit.cover,
                      loadingBuilder:
                          (context, child, progress) {
                        if (progress == null) return child;
                        return Container(
                          width: double.infinity,
                          height: 250,
                          color: Colors.grey[800],
                          child: const Center(
                            child:
                                CircularProgressIndicator(
                              color: Colors.white,
                            ),
                          ),
                        );
                      },
                      errorBuilder:
                          (context, error, stackTrace) {
                        return Container(
                          width: double.infinity,
                          height: 250,
                          color: Colors.grey[800],
                          child: const Icon(
                            Icons.broken_image,
                            color: Colors.white,
                            size: 50,
                          ),
                        );
                      },
                    )
                  : Container(
                      width: double.infinity,
                      height: 250,
                      color: Colors.grey[800],
                      child: const Icon(
                        Icons.broken_image,
                        color: Colors.white,
                        size: 50,
                      ),
                    ),
            ),
            const SizedBox(height: 16),
            // Date with Calendar Icon
            Row(
              children: [
                const Icon(
                  Icons.calendar_today,
                  color: Colors.grey,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  _formatDate(newsItem.date),
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            // Title with Article Icon
            Row(
              children: [
                const Icon(
                  Icons.article,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    newsItem.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Description
            Text(
              newsItem.description,
              style: const TextStyle(
                  color: Colors.white70, fontSize: 16),
            ),
            const SizedBox(height: 20),
            // Full Content
            Text(
              newsItem.createdAt, // Assuming 'created_at' contains the full content
              style: const TextStyle(
                  color: Colors.white70, fontSize: 16),
            ),
            const SizedBox(height: 20),
            // Decorative Icon
            Align(
              alignment: Alignment.centerRight,
              child: Icon(
                Icons.auto_awesome,
                color: Colors.blueAccent
                    .withOpacity(0.5),
                size: 50,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
