import 'dart:math';
import 'package:flutter/material.dart';
import '../models/flashcard.dart';
import 'package:google_fonts/google_fonts.dart';

class FlashcardWidget extends StatefulWidget {
  final Flashcard card;

  const FlashcardWidget({
    required Key key, // Make key required to ensure it resets on card change
    required this.card,
  }) : super(key: key);

  @override
  State<FlashcardWidget> createState() => FlashcardWidgetState();
}

class FlashcardWidgetState extends State<FlashcardWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _isFront = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: pi).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void flip() {
    if (_isFront) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
    setState(() {
      _isFront = !_isFront;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: flip,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          final angle = _animation.value;
          final isBack = angle > pi / 2;

          return Transform(
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY(angle),
            alignment: Alignment.center,
            child: isBack
                ? Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()..rotateY(pi),
                    child: _buildCardContent(widget.card.answer, isAnswer: true),
                  )
                : _buildCardContent(widget.card.question, isAnswer: false),
          );
        },
      ),
    );
  }

  Widget _buildCardContent(String text, {required bool isAnswer}) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 350, maxHeight: 400),
      decoration: BoxDecoration(
        color: isAnswer ? const Color(0xFFFFF9C4) : Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(
          color: isAnswer ? Colors.amber.shade200 : Colors.orange.shade100,
          width: 2,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: isAnswer ? Colors.amber.shade100 : Colors.orange.shade50,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              isAnswer ? 'ANSWER' : 'QUESTION',
              style: GoogleFonts.outfit(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: isAnswer ? Colors.amber.shade900 : Colors.orange.shade900,
                letterSpacing: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 32),
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                child: Text(
                  text,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(
                    fontSize: 26,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade800,
                    height: 1.3,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          if (!isAnswer)
            ElevatedButton.icon(
              onPressed: flip,
              icon: const Icon(Icons.auto_awesome_rounded, size: 18),
              label: Text(
                'SHOW ANSWER',
                style: GoogleFonts.outfit(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                  fontSize: 12,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber.shade700,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
          if (isAnswer)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.visibility_rounded,
                  color: Colors.amber.shade300,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Answer revealed',
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    color: Colors.amber.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
