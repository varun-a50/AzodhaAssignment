import 'package:flutter/material.dart';

class GradientBorderButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const GradientBorderButton(
      {super.key, required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color.fromARGB(255, 53, 39, 249),
            Color.fromARGB(255, 0, 255, 153),
          ], // Your gradient colors
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12), // Border radius if needed
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.black,
          backgroundColor: Colors.white, // Text color
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(12), // Match with outer border radius
          ),
          elevation: 0, // Remove shadow to only show border
        ),
        onPressed: onPressed,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Text(
            text,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
        ),
      ),
    );
  }
}
