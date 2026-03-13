import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'chat_page.dart';
import 'journal_page.dart';
import 'profile_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      const DashboardPage(),
      const ChatPage(),
      const JournalPage(),
      const ProfilePage(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          type: BottomNavigationBarType.fixed,
          selectedItemColor: const Color(0xFF6B9B8E),
          unselectedItemColor: Colors.grey,
          backgroundColor: Colors.white,
          elevation: 0,
          selectedFontSize: 12,
          unselectedFontSize: 12,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.chat_bubble_outline),
              activeIcon: Icon(Icons.chat_bubble),
              label: 'Chat',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.book_outlined),
              activeIcon: Icon(Icons.book),
              label: 'Journal',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}

// Dashboard Page with Feedback
class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  void _showFeedbackForm(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const FeedbackDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/background.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFFF5F0FF).withOpacity(0.7),
              const Color(0xFFE8F5E9).withOpacity(0.7),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          'assets/images/logo.png',
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(
                              Icons.favorite,
                              color: Color(0xFF6B9B8E),
                              size: 28,
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'CompanionAI',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2D3748),
                            ),
                          ),
                          if (user?.email != null)
                            Text(
                              user!.email!.split('@')[0],
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[600],
                              ),
                            ),
                        ],
                      ),
                    ),
                    // Feedback button
                    Container(
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.blue.shade200),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.feedback, color: Colors.blue),
                        onPressed: () => _showFeedbackForm(context),
                        tooltip: 'Give Feedback',
                      ),
                    ),
                    // SOS button
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.emergency, color: Colors.red),
                        onPressed: () => Navigator.pushNamed(context, '/sos'),
                        tooltip: 'SOS',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),

                const Text(
                  'Hi there! 👋',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D3748),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'How are you feeling today?',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 30),

                // Motivational Quote
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF9C88D9), Color(0xFF6B9B8E)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF9C88D9).withOpacity(0.3),
                        blurRadius: 15,
                        spreadRadius: 2,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.format_quote,
                            color: Colors.white.withOpacity(0.8),
                            size: 24,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Daily Motivation',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        '"You are stronger than you think, braver than you believe, and loved more than you know."',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontStyle: FontStyle.italic,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),

                const Text(
                  'What would you like to do?',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D3748),
                  ),
                ),
                const SizedBox(height: 16),

                // Widget Grid
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.1,
                  children: [
                    _buildFeatureWidget(
                      context,
                      icon: Icons.chat_bubble_rounded,
                      title: 'Talk to AI',
                      subtitle: 'Chat support',
                      color: const Color(0xFF9C88D9),
                      onTap: () {
                        final homeState =
                            context.findAncestorStateOfType<_HomePageState>();
                        homeState?.setState(() {
                          homeState._currentIndex = 1;
                        });
                      },
                    ),
                    _buildFeatureWidget(
                      context,
                      icon: Icons.book_rounded,
                      title: 'Journal',
                      subtitle: 'Write feelings',
                      color: const Color(0xFF6B9B8E),
                      onTap: () {
                        final homeState =
                            context.findAncestorStateOfType<_HomePageState>();
                        homeState?.setState(() {
                          homeState._currentIndex = 2;
                        });
                      },
                    ),
                    _buildFeatureWidget(
                      context,
                      icon: Icons.self_improvement_rounded,
                      title: 'Self-Care',
                      subtitle: 'Resources',
                      color: const Color(0xFFE89AC7),
                      onTap: () => Navigator.pushNamed(context, '/selfcare'),
                    ),
                    _buildFeatureWidget(
                      context,
                      icon: Icons.analytics_outlined,
                      title: 'Insights',
                      subtitle: 'Your progress',
                      color: const Color(0xFF7EC8E3),
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Coming Soon!'),
                            content: const Text(
                              'Insights feature will show your mood trends, journal statistics, and progress over time.',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('OK'),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 30),

                // Quick Tips
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(
                            Icons.tips_and_updates,
                            color: Color(0xFFFFA726),
                            size: 24,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Quick Tips',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildQuickTip('Take 5 deep breaths', Icons.air),
                      _buildQuickTip('Drink water', Icons.water_drop),
                      _buildQuickTip(
                          'Stretch for 2 minutes', Icons.accessibility_new),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureWidget(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.2),
              blurRadius: 10,
              spreadRadius: 2,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 36, color: color),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D3748),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickTip(String text, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 18, color: const Color(0xFF6B9B8E)),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 14))),
        ],
      ),
    );
  }
}

// UAT Feedback Dialog
class FeedbackDialog extends StatefulWidget {
  const FeedbackDialog({super.key});

  @override
  State<FeedbackDialog> createState() => _FeedbackDialogState();
}

class _FeedbackDialogState extends State<FeedbackDialog> {
  final TextEditingController _bugsController = TextEditingController();
  final TextEditingController _suggestionsController = TextEditingController();
  bool _isSending = false;
  int _currentStep = 0;

  // UAT Ratings: 1–5 scale per question
  // Section 1: Usability
  int _easeOfUse = 0;
  int _navigationClarity = 0;
  int _visualDesign = 0;

  // Section 2: Functionality
  int _chatFeature = 0;
  int _journalFeature = 0;
  int _sosFeature = 0;

  // Section 3: Performance & Reliability
  int _appSpeed = 0;
  int _stability = 0;

  // Section 4: Overall Satisfaction
  int _overallSatisfaction = 0;
  String _wouldRecommend = '';
  String _taskCompletion = '';

  @override
  void dispose() {
    _bugsController.dispose();
    _suggestionsController.dispose();
    super.dispose();
  }

  bool _isStepValid() {
    switch (_currentStep) {
      case 0:
        return _easeOfUse > 0 && _navigationClarity > 0 && _visualDesign > 0;
      case 1:
        return _chatFeature > 0 && _journalFeature > 0 && _sosFeature > 0;
      case 2:
        return _appSpeed > 0 && _stability > 0;
      case 3:
        return _overallSatisfaction > 0 &&
            _wouldRecommend.isNotEmpty &&
            _taskCompletion.isNotEmpty;
      default:
        return true;
    }
  }

  Future<void> _submitFeedback() async {
    setState(() => _isSending = true);

    try {
      final user = FirebaseAuth.instance.currentUser;

      await FirebaseFirestore.instance.collection('uat_feedback').add({
        'user_id': user?.uid,
        'user_email': user?.email,
        'timestamp': FieldValue.serverTimestamp(),
        // Usability
        'ease_of_use': _easeOfUse,
        'navigation_clarity': _navigationClarity,
        'visual_design': _visualDesign,
        // Functionality
        'chat_feature_rating': _chatFeature,
        'journal_feature_rating': _journalFeature,
        'sos_feature_rating': _sosFeature,
        // Performance
        'app_speed': _appSpeed,
        'stability': _stability,
        // Overall
        'overall_satisfaction': _overallSatisfaction,
        'would_recommend': _wouldRecommend,
        'task_completion': _taskCompletion,
        // Open-ended
        'bugs_encountered': _bugsController.text.trim(),
        'suggestions': _suggestionsController.text.trim(),
      });

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Thank you for completing the UAT survey! 🙏'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to submit: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  Widget _buildRatingRow(String label, int value, ValueChanged<int> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(fontSize: 13, color: Color(0xFF4A5568))),
          const SizedBox(height: 4),
          Row(
            children: List.generate(5, (i) {
              return GestureDetector(
                onTap: () => onChanged(i + 1),
                child: Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: Icon(
                    i < value ? Icons.star_rounded : Icons.star_outline_rounded,
                    color: Colors.amber,
                    size: 28,
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildChoiceRow(
      String label, List<String> options, String selected, ValueChanged<String> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(fontSize: 13, color: Color(0xFF4A5568))),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            children: options.map((opt) {
              final isSelected = selected == opt;
              return ChoiceChip(
                label: Text(opt, style: const TextStyle(fontSize: 12)),
                selected: isSelected,
                onSelected: (_) => onChanged(opt),
                selectedColor: const Color(0xFF6B9B8E),
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : const Color(0xFF4A5568),
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
                backgroundColor: Colors.grey[100],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                side: BorderSide(
                  color: isSelected ? const Color(0xFF6B9B8E) : Colors.grey.shade300,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionHeader('🖥️ Usability', 'Rate how easy the app is to use'),
            _buildRatingRow(
                'The app is easy to navigate and use',
                _easeOfUse,
                (v) => setState(() => _easeOfUse = v)),
            _buildRatingRow(
                'Menu and screen labels are clear and understandable',
                _navigationClarity,
                (v) => setState(() => _navigationClarity = v)),
            _buildRatingRow(
                'The visual design is appealing and comfortable',
                _visualDesign,
                (v) => setState(() => _visualDesign = v)),
          ],
        );
      case 1:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionHeader('⚙️ Feature Functionality', 'Rate each feature you have tried'),
            _buildRatingRow(
                'AI Chat – helpful and responsive',
                _chatFeature,
                (v) => setState(() => _chatFeature = v)),
            _buildRatingRow(
                'Journal – easy to write and save entries',
                _journalFeature,
                (v) => setState(() => _journalFeature = v)),
            _buildRatingRow(
                'SOS Button – accessible in an emergency',
                _sosFeature,
                (v) => setState(() => _sosFeature = v)),
          ],
        );
      case 2:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionHeader('🚀 Performance & Reliability', 'How well does the app perform?'),
            _buildRatingRow(
                'The app loads and responds quickly',
                _appSpeed,
                (v) => setState(() => _appSpeed = v)),
            _buildRatingRow(
                'The app runs without crashes or errors',
                _stability,
                (v) => setState(() => _stability = v)),
            const SizedBox(height: 12),
            const Text('Bugs or issues you encountered (if any):',
                style: TextStyle(fontSize: 13, color: Color(0xFF4A5568))),
            const SizedBox(height: 6),
            TextField(
              controller: _bugsController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Describe any bugs, glitches, or unexpected behaviour...',
                hintStyle: const TextStyle(fontSize: 12),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                filled: true,
                fillColor: Colors.grey[50],
                contentPadding: const EdgeInsets.all(12),
              ),
            ),
          ],
        );
      case 3:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionHeader('⭐ Overall Satisfaction', 'Your overall experience'),
            _buildRatingRow(
                'Overall, how satisfied are you with CompanionAI?',
                _overallSatisfaction,
                (v) => setState(() => _overallSatisfaction = v)),
            const SizedBox(height: 8),
            _buildChoiceRow(
              'Were you able to complete your intended tasks?',
              ['Yes, fully', 'Partially', 'No'],
              _taskCompletion,
              (v) => setState(() => _taskCompletion = v),
            ),
            _buildChoiceRow(
              'Would you recommend this app to others?',
              ['Definitely', 'Maybe', 'No'],
              _wouldRecommend,
              (v) => setState(() => _wouldRecommend = v),
            ),
            const SizedBox(height: 10),
            const Text('Suggestions for improvement:',
                style: TextStyle(fontSize: 13, color: Color(0xFF4A5568))),
            const SizedBox(height: 6),
            TextField(
              controller: _suggestionsController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'What features would you add or improve?',
                hintStyle: const TextStyle(fontSize: 12),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                filled: true,
                fillColor: Colors.grey[50],
                contentPadding: const EdgeInsets.all(12),
              ),
            ),
          ],
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _sectionHeader(String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF2D3748))),
          Text(subtitle,
              style: TextStyle(fontSize: 12, color: Colors.grey[600])),
          const SizedBox(height: 4),
          const Divider(),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final steps = ['Usability', 'Features', 'Performance', 'Overall'];
    final isLastStep = _currentStep == steps.length - 1;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.assignment_turned_in, color: Colors.blue),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('UAT Feedback Survey',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                      Text('User Acceptance Testing',
                          style: TextStyle(fontSize: 11, color: Colors.grey)),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Step Indicator
            Row(
              children: List.generate(steps.length, (i) {
                final isActive = i == _currentStep;
                final isDone = i < _currentStep;
                return Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            Container(
                              height: 4,
                              decoration: BoxDecoration(
                                color: isDone || isActive
                                    ? const Color(0xFF6B9B8E)
                                    : Colors.grey[200],
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              steps[i],
                              style: TextStyle(
                                fontSize: 9,
                                color: isActive
                                    ? const Color(0xFF6B9B8E)
                                    : Colors.grey,
                                fontWeight: isActive
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (i < steps.length - 1) const SizedBox(width: 4),
                    ],
                  ),
                );
              }),
            ),
            const SizedBox(height: 16),

            // Step Content
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.45,
              ),
              child: SingleChildScrollView(
                child: _buildStepContent(),
              ),
            ),
            const SizedBox(height: 16),

            // Navigation Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (_currentStep > 0)
                  TextButton.icon(
                    onPressed: () => setState(() => _currentStep--),
                    icon: const Icon(Icons.arrow_back, size: 16),
                    label: const Text('Back'),
                  )
                else
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                ElevatedButton.icon(
                  onPressed: _isStepValid()
                      ? () {
                          if (isLastStep) {
                            _submitFeedback();
                          } else {
                            setState(() => _currentStep++);
                          }
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6B9B8E),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  icon: _isSending
                      ? const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2))
                      : Icon(isLastStep ? Icons.check : Icons.arrow_forward,
                          size: 16),
                  label: Text(isLastStep ? 'Submit' : 'Next'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}