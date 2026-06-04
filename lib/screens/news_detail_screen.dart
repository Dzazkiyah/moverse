import 'package:flutter/material.dart';

class NewsDetailScreen extends StatelessWidget {
  final Map<String, String> news;
  const NewsDetailScreen({super.key, required this.news});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 260,
            pinned: true,
            backgroundColor: const Color(0xFF0A4F66),
            leading: Padding(
              padding: const EdgeInsets.all(8),
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.arrow_back_ios_new,
                      color: Color(0xFF0A4F66), size: 16),
                ),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: news['image'] != null
                  ? Image.asset(
                      news['image']!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFF1A6B8A), Color(0xFF0A1628)],
                          ),
                        ),
                      ),
                    )
                  : Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF1A6B8A), Color(0xFF0A1628)],
                        ),
                      ),
                    ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(news['title'] ?? '',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0A1628),
                        height: 1.3,
                      )),
                  const SizedBox(height: 12),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(news['author'] ?? '',
                          style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF0ABFDB),
                              fontWeight: FontWeight.w600)),
                      Row(children: [
                        const Icon(Icons.access_time,
                            size: 13, color: Color(0xFF9CA3AF)),
                        const SizedBox(width: 4),
                        Text(news['date'] ?? '',
                            style: const TextStyle(
                                fontSize: 12, color: Color(0xFF9CA3AF))),
                      ]),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Divider(color: Color(0xFFE5E7EB)),
                  const SizedBox(height: 20),

                  Text(news['content'] ?? '',
                      style: const TextStyle(
                        fontSize: 15,
                        color: Color(0xFF374151),
                        height: 1.7,
                      )),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}