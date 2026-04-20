import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/flashcard_provider.dart';
import '../widgets/flashcard_widget.dart';

class QuizView extends StatefulWidget {
  const QuizView({super.key});

  @override
  State<QuizView> createState() => _QuizViewState();
}

class _QuizViewState extends State<QuizView> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<FlashcardProvider>(context, listen: false);
    _pageController = PageController(initialPage: provider.currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FlashcardProvider>(
      builder: (context, provider, child) {
        final cards = provider.cards;

        if (provider.isLoading) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.amber),
          );
        }

        // Ensure PageController is in sync with Provider index
        // This is important if cards are deleted/added from the Library
        if (_pageController.hasClients) {
          final currentPage = _pageController.page?.round() ?? 0;
          if (currentPage != provider.currentIndex && provider.currentIndex < cards.length) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (_pageController.hasClients) {
                _pageController.jumpToPage(provider.currentIndex);
              }
            });
          }
        }

        if (cards.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.style_rounded, size: 80, color: Colors.amber.shade200),
                const SizedBox(height: 16),
                Text(
                  'No cards to quiz!',
                  style: GoogleFonts.outfit(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Add some in the Library tab.',
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    color: Colors.grey.shade400,
                  ),
                ),
              ],
            ),
          );
        }

        return LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Column(
                    children: [
                      // Progress Bar & Counter
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 30),
                        child: Row(
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: LinearProgressIndicator(
                                  value: (provider.currentIndex + 1) / cards.length,
                                  backgroundColor: Colors.orange.shade50,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.amber.shade600),
                                  minHeight: 8,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Text(
                              '${provider.currentIndex + 1}/${cards.length}',
                              style: GoogleFonts.outfit(
                                fontWeight: FontWeight.bold,
                                color: Colors.amber.shade900,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 40),
                      
                      // Swipeable Flashcards
                      SizedBox(
                        height: 450,
                        child: PageView.builder(
                          controller: _pageController,
                          itemCount: cards.length,
                          onPageChanged: (index) {
                            // Sync current index but without triggering a rebuild 
                            // that would reset the PageView itself.
                            // We can use a silent update or just let the provider handle it.
                            provider.setIndex(index);
                          },
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 30),
                              child: FlashcardWidget(
                                key: ValueKey(cards[index].id),
                                card: cards[index],
                              ),
                            );
                          },
                        ),
                      ),
                      
                      const SizedBox(height: 48),
                      
                      // Navigation Hint
                      Text(
                        'SWIPE FOR NEXT / PREV',
                        style: GoogleFonts.outfit(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: Colors.amber.shade800.withOpacity(0.5),
                          letterSpacing: 2,
                        ),
                      ),
                      
                      const SizedBox(height: 40),
                      
                      // Manual Navigation Buttons (Optional but helpful)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 30),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildNavButton(
                              icon: Icons.chevron_left_rounded,
                              label: 'PREV',
                              onPressed: () {
                                if (provider.currentIndex > 0) {
                                  _pageController.previousPage(
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeInOut,
                                  );
                                }
                              },
                            ),
                            _buildNavButton(
                              icon: Icons.chevron_right_rounded,
                              label: 'NEXT',
                              isRight: true,
                              onPressed: () {
                                if (provider.currentIndex < cards.length - 1) {
                                  _pageController.nextPage(
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeInOut,
                                  );
                                }
                              },
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
        );
      },
    );
  }

  Widget _buildNavButton({
    required IconData icon, 
    required String label, 
    required VoidCallback onPressed,
    bool isRight = false,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(15),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!isRight) Icon(icon, color: Colors.amber.shade800, size: 28),
            const SizedBox(width: 4),
            Text(
              label,
              style: GoogleFonts.outfit(
                fontWeight: FontWeight.w900,
                color: Colors.amber.shade900,
                fontSize: 14,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(width: 4),
            if (isRight) Icon(icon, color: Colors.amber.shade800, size: 28),
          ],
        ),
      ),
    );
  }
}
