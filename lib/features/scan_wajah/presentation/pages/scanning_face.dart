import 'dart:async';
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import '../../../../widget/primary_button.dart';
import '../../../../widget/secondary_button.dart';
import 'scan_result.dart';

class ScanningFacePage extends StatefulWidget {
	const ScanningFacePage({super.key});

	@override
	State<ScanningFacePage> createState() => _ScanningFacePageState();
}

class _ScanningFacePageState extends State<ScanningFacePage> with WidgetsBindingObserver {
	CameraController? _controller;
	List<CameraDescription> _cameras = [];
	bool _initializing = true;
	bool _flashOn = false;
	int _cameraIndex = 0; // 0: back, 1: front typically
	final List<XFile> _captures = [];

	@override
	void initState() {
		super.initState();
		WidgetsBinding.instance.addObserver(this);
		_initCamera();
	}

	Future<void> _initCamera() async {
		try {
			_cameras = await availableCameras();
			if (_cameras.isEmpty) {
				setState(() { _initializing = false; });
				return;
			}
			await _startController(_cameras[_cameraIndex]);
		} catch (e) {
			debugPrint('Camera init error: $e');
			setState(() { _initializing = false; });
		}
	}

	Future<void> _startController(CameraDescription description) async {
		final old = _controller;
		_controller = CameraController(
			description,
			ResolutionPreset.medium,
			enableAudio: false,
			imageFormatGroup: ImageFormatGroup.yuv420,
		);
		try {
			await _controller!.initialize();
			if (_flashOn) {
				await _controller!.setFlashMode(FlashMode.torch).catchError((_){});
			}
		} catch (e) {
			debugPrint('Controller start error: $e');
		} finally {
			old?.dispose();
			if (mounted) setState(() { _initializing = false; });
		}
	}

	@override
	void didChangeAppLifecycleState(AppLifecycleState state) {
		if (_controller == null || !_controller!.value.isInitialized) return;
		if (state == AppLifecycleState.inactive) {
			_controller?.dispose();
		} else if (state == AppLifecycleState.resumed) {
			_startController(_cameras[_cameraIndex]);
		}
	}

	Future<void> _toggleFlash() async {
		if (_controller == null) return;
		_flashOn = !_flashOn;
		try {
			await _controller!.setFlashMode(_flashOn ? FlashMode.torch : FlashMode.off);
		} catch (_) {}
		if (mounted) setState(() {});
	}

	Future<void> _switchCamera() async {
		if (_cameras.length < 2) return;
		_cameraIndex = (_cameraIndex + 1) % _cameras.length;
		setState(() { _initializing = true; });
		await _startController(_cameras[_cameraIndex]);
	}

	Future<void> _capture() async {
		final ctrl = _controller;
		if (ctrl == null || !ctrl.value.isInitialized || ctrl.value.isTakingPicture) return;
		try {
			final file = await ctrl.takePicture();
			setState(() { _captures.add(file); });
		} catch (e) {
			debugPrint('Capture error: $e');
		}
	}

	void _openResult() {
		if (_captures.isEmpty) return;
		Navigator.of(context).push(
			MaterialPageRoute(
				builder: (_) => ScanResultPage(files: _captures),
			),
		);
	}

	@override
	void dispose() {
		WidgetsBinding.instance.removeObserver(this);
		_controller?.dispose();
		super.dispose();
	}

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			backgroundColor: Colors.black,
			body: SafeArea(
				child: Column(
					children: [
						// Top bar
						Padding(
							padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
							child: Row(
								children: [
									IconButton(
										onPressed: () => Navigator.pop(context),
										icon: const Icon(Icons.arrow_back, color: Colors.white),
									),
									const SizedBox(width: 8),
									const Text('Arahkan wajah ke dalam lingkaran', style: TextStyle(color: Colors.white, fontSize: 14)),
								],
							),
						),
						Expanded(
							child: Center(
								child: AspectRatio(
									aspectRatio: _controller?.value.aspectRatio ?? 3/4,
									child: _initializing
											? const Center(child: CircularProgressIndicator())
											: _controller == null
													? const Center(child: Text('Camera not available', style: TextStyle(color: Colors.white)))
													: Stack(
															fit: StackFit.expand,
															children: [
																CameraPreview(_controller!),
																// Circular guideline overlay
																LayoutBuilder(
																	builder: (context, constraints) {
																		final size = constraints.biggest;
																		final diameter = size.shortestSide * 0.75;
																		return Center(
																			child: Container(
																				width: diameter,
																				height: diameter,
																				decoration: BoxDecoration(
																					shape: BoxShape.circle,
																					border: Border.all(color: Colors.white.withOpacity(0.8), width: 3, style: BorderStyle.solid),
																				),
																			),
																		);
																	},
																),
															],
														),
								),
							),
						),
						// Bottom controls
						Padding(
							padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
							child: Column(
								mainAxisSize: MainAxisSize.min,
								children: [
									// Thumbnails row
									if (_captures.isNotEmpty)
										SizedBox(
											height: 72,
											child: ListView.separated(
												scrollDirection: Axis.horizontal,
												itemCount: _captures.length,
												separatorBuilder: (_, __) => const SizedBox(width: 8),
												itemBuilder: (context, index) {
													final f = _captures[index];
													return FutureBuilder<Uint8List>(
														future: f.readAsBytes(),
														builder: (context, snapshot) {
															Widget content;
															if (snapshot.hasData) {
																content = Image.memory(
																	snapshot.data!,
																	width: 64,
																	height: 72,
																	fit: BoxFit.cover,
																);
															} else {
																content = const SizedBox(
																	width: 64,
																	height: 72,
																	child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
																);
															}
															return Stack(
																children: [
																	ClipRRect(
																		borderRadius: BorderRadius.circular(8),
																		child: content,
																	),
																	Positioned(
																		top: 0,
																		right: 0,
																		child: GestureDetector(
																			onTap: () => setState(() { _captures.removeAt(index); }),
																			child: Container(
																				decoration: BoxDecoration(
																					color: Colors.black54,
																					borderRadius: BorderRadius.circular(10),
																				),
																				padding: const EdgeInsets.all(2),
																				child: const Icon(Icons.close, color: Colors.white, size: 16),
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
									const SizedBox(height: 12),
									Row(
										mainAxisAlignment: MainAxisAlignment.center,
										children: [
											IconButton(
												onPressed: _toggleFlash,
												icon: Icon(_flashOn ? Icons.flash_on : Icons.flash_off, color: Colors.white),
											),
											const SizedBox(width: 24),
											GestureDetector(
												onTap: _capture,
												child: Container(
													width: 72,
													height: 72,
													decoration: BoxDecoration(
														color: Colors.white,
														shape: BoxShape.circle,
														border: Border.all(color: Colors.white, width: 4),
													),
												),
											),
											const SizedBox(width: 24),
											IconButton(
												onPressed: _switchCamera,
												icon: const Icon(Icons.cameraswitch, color: Colors.white),
											),
										],
									),
									const SizedBox(height: 16),
									Row(
										children: [
											Expanded(
												child: SecondaryButton(
													text: 'Ambil ulang',
													icon: const Icon(Icons.refresh),
													onPressed: () => setState(() { _captures.clear(); }),
												),
											),
											const SizedBox(width: 12),
											Expanded(
												child: PrimaryButton(
													text: 'Simpan',
													icon: const Icon(Icons.check),
													onPressed: _openResult,
												),
											),
										],
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
