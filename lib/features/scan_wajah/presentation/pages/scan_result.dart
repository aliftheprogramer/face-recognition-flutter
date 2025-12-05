import 'dart:io' show File;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:typed_data';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:gii_dace_recognition/common/bloc/navigation/navigation_cubit.dart'
    as nav;
import 'package:gii_dace_recognition/common/pages/main_screen.dart'
    as main_screen;
import '../../../../widget/primary_button.dart';
import '../../../../widget/secondary_button.dart';
import '../../../../core/services/services_locator.dart';
import '../../../../features/auth/data/source/auth_local_service.dart';
import '../../domain/usecase/register_face_usecase.dart';
import '../../domain/usecase/register_face_bytes_usecase.dart';
import 'package:gii_dace_recognition/features/scan_wajah/domain/entity/face_recognition_entity.dart';

class ScanResultPage extends StatefulWidget {
  final List<XFile> files;
  const ScanResultPage({super.key, required this.files});

  @override
  State<ScanResultPage> createState() => _ScanResultPageState();
}

class _ScanResultPageState extends State<ScanResultPage> {
  bool _loading = false;

  Future<void> _uploadFirstImage(BuildContext context) async {
    if (widget.files.isEmpty) return;
    final userJson = sl<AuthLocalService>().getUserJson();
    if (userJson == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('User tidak ditemukan. Silakan login terlebih dahulu.'),
        ),
      );
      return;
    }

    String userId;
    try {
      final m = jsonDecode(userJson) as Map<String, dynamic>;
      userId =
          (m['id'] ?? m['user_id'] ?? m['uid'] ?? m['userId'])?.toString() ??
          '';
    } catch (_) {
      userId = '';
    }

    if (userId.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('User id tidak tersedia.')));
      return;
    }

    setState(() => _loading = true);

    final file = File(widget.files.first.path);
    try {
      final res = kIsWeb
          ? await sl<RegisterFaceBytesUsecase>().call(
              param: {
                'userId': userId,
                'bytes': await widget.files.first.readAsBytes(),
                'filename': widget.files.first.name.isNotEmpty
                    ? widget.files.first.name
                    : 'face.jpg',
              },
            )
          : await sl<RegisterFaceUsecase>().call(
              param: {'userId': userId, 'file': file},
            );
      if (!mounted) return;
      res.fold(
        (err) {
          if (mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('Gagal upload: $err')));
          }
        },
        (FaceRecognitionEntity ent) async {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Foto berhasil disimpan')),
            );
            // Navigate to MainScreen and show Profile tab
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (_) => const main_screen.MainScreen(
                  initialTab: nav.NavigationTab.profil,
                ),
              ),
              (route) => false,
            );
          }
        },
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Terjadi error: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Hasil Scan', style: TextStyle(color: Colors.black)),
        centerTitle: false,
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  await Future.delayed(const Duration(milliseconds: 300));
                  if (mounted) setState(() {});
                },
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                  ),
                  itemCount: widget.files.length,
                  itemBuilder: (context, index) {
                    final f = widget.files[index];
                    return FutureBuilder<Uint8List>(
                      future: f.readAsBytes(),
                      builder: (context, snapshot) {
                        Widget img;
                        if (snapshot.hasData) {
                          img = Image.memory(snapshot.data!, fit: BoxFit.cover);
                        } else {
                          img = const Center(
                            child: CircularProgressIndicator(strokeWidth: 2),
                          );
                        }
                        return Stack(
                          children: [
                            Positioned.fill(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: img,
                              ),
                            ),
                            Positioned(
                              top: 4,
                              right: 4,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.black54,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Padding(
                                  padding: EdgeInsets.all(2.0),
                                  child: Icon(
                                    Icons.close,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: <Widget>[
                Expanded(
                  child: SecondaryButton(
                    text: 'Ambil foto ulang',
                    icon: const Icon(Icons.refresh),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: PrimaryButton(
                    text: 'Simpan',
                    icon: const Icon(Icons.save),
                    onPressed: _loading
                        ? null
                        : () => _uploadFirstImage(context),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
