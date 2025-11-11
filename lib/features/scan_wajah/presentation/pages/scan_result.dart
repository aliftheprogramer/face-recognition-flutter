import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import '../../../../widget/primary_button.dart';
import '../../../../widget/secondary_button.dart';

class ScanResultPage extends StatelessWidget {
	final List<XFile> files;
	const ScanResultPage({super.key, required this.files});

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
					children: [
									Expanded(
										child: GridView.builder(
								gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
									crossAxisCount: 3,
									mainAxisSpacing: 12,
									crossAxisSpacing: 12,
								),
								itemCount: files.length,
												itemBuilder: (context, index) {
													final f = files[index];
													return FutureBuilder<Uint8List>(
														future: f.readAsBytes(),
														builder: (context, snapshot) {
															Widget img;
															if (snapshot.hasData) {
																img = Image.memory(snapshot.data!, fit: BoxFit.cover);
															} else {
																img = const Center(child: CircularProgressIndicator(strokeWidth: 2));
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
																				child: Icon(Icons.close, color: Colors.white, size: 16),
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
						const SizedBox(height: 16),
						Row(
							children: [
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
										onPressed: () {
											// TODO: Implement save logic (upload / local storage)
											Navigator.pop(context);
										},
									),
								),
							],
						),
					],
				),
			),
		);
	}

		// Images rendered via FutureBuilder above for portability.
}
