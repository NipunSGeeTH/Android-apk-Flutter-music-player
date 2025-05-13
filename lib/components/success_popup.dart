// components/success_popup.dart - Success message popup
import 'package:flutter/material.dart';

class SuccessPopup extends StatelessWidget {
  final String message;
  final Duration displayDuration;
  final VoidCallback onDismiss;

  const SuccessPopup({
    super.key,
    required this.message,
    this.displayDuration = const Duration(seconds: 2),
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    // Auto-dismiss after specified duration
    Future.delayed(displayDuration, onDismiss);
    
    return Center(
      child: AnimatedOpacity(
        opacity: 1.0,
        duration: const Duration(milliseconds: 300), // Shorter duration for smoother appearance
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.blueAccent.withOpacity(0.9),
                  Colors.purpleAccent.withOpacity(0.9),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black54,
                  blurRadius: 15.0,
                  spreadRadius: 2.0,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle, color: Colors.white, size: 60),
                const SizedBox(height: 15),
                Text(
                  message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}