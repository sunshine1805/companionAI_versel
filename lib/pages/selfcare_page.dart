import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';

class SelfCarePage extends StatelessWidget {
  const SelfCarePage({super.key});

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  // Extract YouTube video ID from URL
  String? _getYouTubeVideoId(String url) {
    final uri = Uri.parse(url);
    if (uri.host.contains('youtube.com')) {
      return uri.queryParameters['v'];
    } else if (uri.host.contains('youtu.be')) {
      return uri.pathSegments.first;
    }
    return null;
  }

  // Get YouTube thumbnail URL
  String _getYouTubeThumbnail(String url) {
    final videoId = _getYouTubeVideoId(url);
    if (videoId != null) {
      return 'https://img.youtube.com/vi/$videoId/hqdefault.jpg';
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Self-Care Resources'),
        backgroundColor: const Color(0xFF9C88D9),
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFF5F0FF),
              Color(0xFFE8F5E9),
            ],
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Header
            const Text(
              'Take Care of Yourself',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Explore videos, articles, and resources to support your mental wellbeing',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),

            // Mental Health Videos Section
            _buildSectionHeader('Helpful Videos', Icons.play_circle_outline),
            const SizedBox(height: 12),
            _buildVideoCard(
              context,
              title: 'Understanding Anxiety',
              channel: 'Psych2Go',
              duration: '5:32',
              url: 'https://www.youtube.com/watch?v=jryCoo0BrRk',
            ),
            _buildVideoCard(
              context,
              title: 'Stress Management Techniques',
              channel: 'TEDx',
              duration: '15:47',
              url: 'https://www.youtube.com/watch?v=hnpQrMqDoqE',
            ),
            _buildVideoCard(
              context,
              title: 'Mindfulness Meditation for Students',
              channel: 'Goodful',
              duration: '10:00',
              url: 'https://www.youtube.com/watch?v=ZToicYcHIOU',
            ),
            _buildVideoCard(
              context,
              title: 'Overcoming Academic Burnout',
              channel: 'Med School Insiders',
              duration: '12:25',
              url: 'https://www.youtube.com/watch?v=jXXonaWJcWM',
            ),

            const SizedBox(height: 32),

            // Articles Section
            _buildSectionHeader('Recommended Articles', Icons.article_outlined),
            const SizedBox(height: 12),
            _buildArticleCard(
              context,
              title: 'Managing Academic Stress',
              source: 'Mind.org.uk',
              description: 'Practical tips for handling university pressure',
              url: 'https://www.mind.org.uk/information-support/tips-for-everyday-living/student-life/',
              imageUrl: 'https://www.mind.org.uk/media/12140026/student-life.jpg',
            ),
            _buildArticleCard(
              context,
              title: 'Mental Health in Malaysia',
              source: 'Malaysian Mental Health Association',
              description: 'Understanding mental health resources available',
              url: 'https://www.mmha.org.my/',
              imageUrl: 'https://www.mmha.org.my/images/logo.png',
            ),
            _buildArticleCard(
              context,
              title: 'Self-Care for Students',
              source: 'Psychology Today',
              description: 'Building healthy habits during university',
              url: 'https://www.psychologytoday.com/us/blog/the-college-wellness-guide',
              imageUrl: null,
            ),
            _buildArticleCard(
              context,
              title: 'Coping with Loneliness',
              source: 'Headspace',
              description: 'Strategies for feeling connected',
              url: 'https://www.headspace.com/articles/loneliness',
              imageUrl: null,
            ),

            const SizedBox(height: 32),

            // Quick Tips Section
            _buildSectionHeader('Quick Self-Care Tips', Icons.lightbulb_outline),
            const SizedBox(height: 12),
            _buildTipCard('Practice deep breathing for 5 minutes daily'),
            _buildTipCard('Maintain a regular sleep schedule (7-9 hours)'),
            _buildTipCard('Stay physically active - even a 10-minute walk helps'),
            _buildTipCard('Connect with friends or family regularly'),
            _buildTipCard('Set boundaries with social media and screen time'),
            _buildTipCard('Keep a gratitude journal'),
            _buildTipCard('Don\'t hesitate to ask for help when needed'),

            const SizedBox(height: 32),

            // Support Resources
            _buildSectionHeader('Need More Support?', Icons.support_agent),
            const SizedBox(height: 12),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Professional Help Available',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildContactRow(
                      'QIU Counselling Unit',
                      'Contact your campus counsellor',
                      Icons.school,
                    ),
                    const Divider(height: 24),
                    _buildContactRow(
                      'Befrienders KL',
                      '03-7627 2929 (24/7)',
                      Icons.phone,
                    ),
                    const Divider(height: 24),
                    _buildContactRow(
                      'Emergency',
                      '999',
                      Icons.emergency,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF9C88D9)),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildVideoCard(
    BuildContext context, {
    required String title,
    required String channel,
    required String duration,
    required String url,
  }) {
    final thumbnailUrl = _getYouTubeThumbnail(url);
    
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => _launchURL(url),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Video Thumbnail
              Container(
                width: 120,
                height: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey[300],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: thumbnailUrl.isNotEmpty
                      ? Stack(
                          children: [
                            CachedNetworkImage(
                              imageUrl: thumbnailUrl,
                              width: 120,
                              height: 80,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                color: Colors.deepPurple.shade100,
                                child: const Center(
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                              ),
                              errorWidget: (context, url, error) => Container(
                                color: Colors.deepPurple.shade100,
                                child: const Icon(
                                  Icons.play_circle_outline,
                                  size: 32,
                                  color: Colors.deepPurple,
                                ),
                              ),
                            ),
                            Center(
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.7),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.play_arrow,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                            ),
                          ],
                        )
                      : Container(
                          color: Colors.deepPurple.shade100,
                          child: const Icon(
                            Icons.play_circle_outline,
                            size: 32,
                            color: Colors.deepPurple,
                          ),
                        ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      channel,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      duration,
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.open_in_new, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildArticleCard(
    BuildContext context, {
    required String title,
    required String source,
    required String description,
    required String url,
    String? imageUrl,
  }) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => _launchURL(url),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Article Image/Icon
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.blue.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: imageUrl != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: CachedNetworkImage(
                          imageUrl: imageUrl,
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => const Center(
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          errorWidget: (context, url, error) => const Icon(
                            Icons.article,
                            size: 28,
                            color: Colors.blue,
                          ),
                        ),
                      )
                    : const Icon(
                        Icons.article,
                        size: 28,
                        color: Colors.blue,
                      ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      source,
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.open_in_new, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTipCard(String tip) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            const Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                tip,
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactRow(String title, String subtitle, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Colors.red),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}