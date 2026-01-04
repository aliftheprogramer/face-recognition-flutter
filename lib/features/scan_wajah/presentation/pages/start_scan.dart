import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';

import '../../../../widget/primary_button.dart';
import '../../../../widget/secondary_button.dart';
import '../../../../core/services/services_locator.dart';
import '../../../../core/constant/api_urls.dart';
import '../../../../common/bloc/auth/auth_cubit.dart';
import '../../../../common/bloc/auth/auth_state.dart';
import '../../../auth/data/source/auth_local_service.dart';
import 'scanning_face.dart';

class StartScan extends StatefulWidget {
  const StartScan({super.key});

  @override
  State<StartScan> createState() => _StartScanState();
}

class _StartScanState extends State<StartScan> {
  final _logger = Logger();
  String? _userPhotoUrl;

  @override
  void initState() {
    super.initState();
    _loadUserPhoto();
  }

  void _loadUserPhoto() {
    try {
      _logger.i('🔍 StartScan: Memulai load foto user...');

      // Cek apakah user authenticated
      final authState = context.read<AuthStateCubit>().state;
      _logger.i('🔐 Auth State: ${authState.runtimeType}');

      if (authState is! Authenticated) {
        _logger.w('⚠️ User tidak authenticated, menggunakan foto default');
        return;
      }

      // Ambil data user dari local storage
      final userJson = sl<AuthLocalService>().getUserJson();
      if (userJson == null) {
        _logger.w('⚠️ User JSON tidak ditemukan di local storage');
        return;
      }

      final user = jsonDecode(userJson) as Map<String, dynamic>;
      _logger.i('👤 User data berhasil di-decode');
      _logger.d('📄 User data: $user');

      // Cek apakah ada foto dari field avatar/photo/photo_url
      final avatar = user['avatar'] ?? user['photo'] ?? user['photo_url'];
      _logger.i('🖼️ Avatar field: $avatar');

      if (avatar != null && avatar is String && avatar.isNotEmpty) {
        _logger.i('✅ Foto ditemukan dari field avatar/photo: $avatar');
        setState(() {
          _userPhotoUrl = avatar;
        });
        return;
      }

      // Jika tidak ada, cek dari faces array
      final faces = user['faces'];
      _logger.i('👥 Faces array: $faces');

      if (faces is List && faces.isNotEmpty) {
        _logger.i('📊 Jumlah faces: ${faces.length}');
        final first = faces.first;
        _logger.d('🎭 Face pertama: $first');

        final filepath = first['filepath'] as String?;
        _logger.i('📁 Filepath: $filepath');

        if (filepath != null && filepath.isNotEmpty) {
          final base = ApiUrls.baseUrl.replaceFirst('/api/v1', '');
          final fullUrl = filepath.startsWith('http')
              ? filepath
              : '$base/$filepath';
          _logger.i('✅ Foto wajah ditemukan: $fullUrl');

          setState(() {
            _userPhotoUrl = fullUrl;
          });
        } else {
          _logger.w('⚠️ Filepath kosong atau null');
        }
      } else {
        _logger.w('⚠️ Faces array kosong atau bukan List');
      }

      if (_userPhotoUrl == null) {
        _logger.w(
          '❌ Tidak ada foto user yang ditemukan, menggunakan foto default',
        );
      }
    } catch (e, stackTrace) {
      _logger.e('❌ Error saat load foto user: $e');
      _logger.e('Stack trace: $stackTrace');
      // Jika ada error, biarkan null sehingga menggunakan fallback
    }
  }

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
                          child: _userPhotoUrl != null
                              ? Image.network(
                                  _userPhotoUrl!,
                                  width: 94,
                                  height: 94,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Image.asset(
                                      'assets/mukaorang.png',
                                      width: 94,
                                      height: 94,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) {
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
                                    );
                                  },
                                )
                              : Image.asset(
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
