import 'package:flutter/material.dart';

import '../../../../widget/primary_button.dart';
import '../../../../widget/secondary_button.dart';
import 'scanning_face.dart';

class StartScan extends StatelessWidget {
  const StartScan({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Main content: center area
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24.0,
                    vertical: 32.0,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Clipped dummy image (requested: width:94, height:94, border-radius:134)
                      SizedBox(
                        width: 94,
                        height: 94,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(134),
                          child: Image.asset(
                            'assets/mukaorang.png',
                            width: 94,
                            height: 94,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const ColoredBox(
                                color: Colors.grey,
                                child: Center(
                                  child: Icon(
                                    Icons.person,
                                    color: Colors.white,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Title text: scan wajahmu
                      const Text(
                        'Scan wajahmu',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Visby CF',
                          fontWeight: FontWeight.w700,
                          fontSize: 30,
                          height: 1.2, // 120% line-height
                          letterSpacing: 0,
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Subtitle text
                      const Text(
                        'Ambil foto barumu atau gunakan foto yang lama',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Visby CF',
                          fontWeight: FontWeight.w400,
                          fontSize: 14,
                          height: 1.2,
                          letterSpacing: 0,
                        ),
                      ),

                      const SizedBox(height: 24),

                      PrimaryButton(
                        text: "Ambil dari kamera",
                        icon: const Icon(
                          Icons.camera_alt_outlined,
                          size: 24,
                          color: Colors.white,
                        ),
                        backgroundColor: const Color(0xFF2D64F0),
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const ScanningFacePage(),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 20),

                      SecondaryButton(
                        text: "Ambil dari penyimpanan",
                        icon: const Icon(Icons.photo_outlined, size: 24),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Footer (anchored at bottom)
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 22.0,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Text(
                    'Dengan masuk ke Aplikasi, anda setuju dengan',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Visby CF',
                      fontWeight: FontWeight.w400,
                      fontSize: 14,
                      height: 1.0, // 100% line-height
                      letterSpacing: -0.14, // approx -1% of 14px
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Ketentuan dan kebijakan privasi kami',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Visby CF',
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      height: 1.0,
                      letterSpacing: -0.14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
