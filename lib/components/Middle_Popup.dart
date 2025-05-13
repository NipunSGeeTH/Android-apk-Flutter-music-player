 // Popup function
  import 'package:flutter/material.dart';

  
import 'package:flutter/gestures.dart';



import 'package:url_launcher/url_launcher.dart';

  
  void showPopup(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: const Color.fromARGB(255, 0, 0, 0),
          elevation: 0,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.deepPurple.shade800,
                  Colors.deepPurple.shade500,
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.8),
                  spreadRadius: 2,
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'App',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 1, 0, 28).withOpacity(0.8),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'Design and Developed by',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          height: 1.5,
                        ),
                      ),

                      ShaderMask(
                        shaderCallback:
                            (bounds) => LinearGradient(
                              colors: [
                                Colors.red,
                                Colors.orange,
                                Colors.yellow,
                                Colors.green,
                                Colors.blue,
                                const Color.fromARGB(255, 231, 122, 250),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ).createShader(bounds),
                        child: const Text(
                          'NipunSGeeTH',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: 18,
                          ),
                        ),
                      ),

                      const Text(
                        '🇱🇰',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          height: 1.5,
                        ),
                      ),

                      Text.rich(
                        TextSpan(
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            height: 1.5,
                          ),
                          children: [
                            // Wrap the disclaimer in a separate SelectableText.rich widget
                            WidgetSpan(
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                child: Text.rich(
                                  TextSpan(
                                    text:
                                        '\n'
                                        '• All rights of the music belong to their respective owners\n'
                                        '• This is a demonstration project for understanding app development\n'
                                        '• Use this app responsibly and respect copyright laws\n',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.white,
                                    ),
                                  ),
                                  textAlign: TextAlign.left,
                                ),
                              ),
                            ),
                            const TextSpan(
                              text: 'Special Thanks To:\n ',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color.fromARGB(255, 243, 4, 203),
                              ),
                            ),
                            const TextSpan(
                              text:
                                  '• UOM \n'
                                  '• My Family\n'
                                  '• Friends ',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white,
                                height: 1.5,
                              ),
                            ),

                            const TextSpan(text: '\n\nContact Me : '),
                            TextSpan(
                              text: 'LinkedIn',
                              style: const TextStyle(
                                color: Colors.lightBlue,
                                decoration: TextDecoration.underline,
                                fontWeight: FontWeight.bold,
                              ),
                              recognizer:
                                  TapGestureRecognizer()
                                    ..onTap = () async {
                                      final Uri _url = Uri.parse(
                                        'https://www.linkedin.com/in/nipunsgeeth',
                                      );

                                      if (!await launchUrl(_url)) {
                                        throw Exception(
                                          'Could not launch $_url',
                                        );
                                      }
                                    },
                            ),
                            const TextSpan(text: '    '),

                            TextSpan(
                              text: 'WhatsApp\n',
                              style: const TextStyle(
                                color: Colors.lightBlue,
                                decoration: TextDecoration.underline,
                                fontWeight: FontWeight.bold,
                              ),
                              recognizer:
                                  TapGestureRecognizer()
                                    ..onTap = () async {
                                      final Uri _url = Uri.parse(
                                        'https://wa.me/+94760858499',
                                      );

                                      if (!await launchUrl(_url)) {
                                        throw Exception(
                                          'Could not launch $_url',
                                        );
                                      }
                                    },
                            ),

                            const TextSpan(text: '\n\nCrafted with '),
                            const TextSpan(
                              text: 'Love ❤️',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.pinkAccent,
                              ),
                            ),
                          ],
                        ),
                        textAlign:
                            TextAlign.center, // This keeps other text centered
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                    foregroundColor: Colors.deepPurple.shade800,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 5,
                  ),
                  child: const Text(
                    'Close',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }