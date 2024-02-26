import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_signaturepad/signaturepad.dart';

class CreateAndSaveSign extends StatefulWidget {
  const CreateAndSaveSign({super.key});

  @override
  State<CreateAndSaveSign> createState() => _CreateAndSaveSignState();
}

class _CreateAndSaveSignState extends State<CreateAndSaveSign> {
  final GlobalKey<SfSignaturePadState> signatureGlobalKey = GlobalKey();

  void onClear() {
    signatureGlobalKey.currentState!.clear();
  }

  Future<void> _saveImage(BuildContext context) async {
    final data = await signatureGlobalKey.currentState!.toImage(pixelRatio: 3.0);
    final bytes = await data.toByteData(format: ui.ImageByteFormat.png);

    String? message;
    // ignore: use_build_context_synchronously
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    try {
      // Get temporary directory
      final dir = await getTemporaryDirectory();

      // Create an image name
      var filename = '${dir.path}/image.png';

      // Save to filesystem
      final file = File(filename);

      await file.writeAsBytes(bytes!.buffer.asUint8List());

      // Ask the user to save it
      final params = SaveFileDialogParams(sourceFilePath: file.path);
      final finalPath = await FlutterFileDialog.saveFile(params: params);

      if (finalPath != null) {
        message = 'Image saved to disk';
      }
    } catch (e) {
      message = 'An error occurred while saving the image';
    }

    if (message != null) {
      scaffoldMessenger.showSnackBar(SnackBar(content: Text(message)));
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (BuildContext context) {
            return Scaffold(
              appBar: AppBar(),
              body: Center(
                child: Container(
                  color: Colors.grey[300],
                  child: Image.memory(bytes!.buffer.asUint8List()),
                ),
              ),
            );
          },
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Save image to disk'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
              ),
              child: SfSignaturePad(
                  key: signatureGlobalKey, //
                  backgroundColor: Colors.white, //
                  strokeColor: Colors.black, //
                  minimumStrokeWidth: 4.0, //
                  maximumStrokeWidth: 4.0),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton(
                onPressed: () => _saveImage(context),
                child: const Text('Save'),
              ),
              TextButton(
                onPressed: onClear,
                child: const Text('Clear'),
              )
            ],
          )
        ],
      ),
    );
  }
}
