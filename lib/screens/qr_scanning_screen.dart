import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import '../services/firebase_service.dart';

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({super.key});

  @override
  _QRScannerScreenState createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  late QRViewController controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  
  // To handle when the scanner is active or not
  bool isScanning = true;

  // Method to handle the QR scan result
  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) async {
      // Get QR code value (may be null)
      String qrCode = scanData.code ?? '';

      if (qrCode.isNotEmpty) {
        // Handle the QR code value (e.g., save the disposal to Firebase)
        bool success = await _firebaseService.recordDisposal(qrCode);
        
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Waste disposal recorded!'))
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error recording disposal.'))
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No valid QR code detected.'))
        );
      }
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Scan QR Code"),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // QR Scanner Widget
          SizedBox(
            height: 300.0,
            width: 300.0,
            child: QRView(
              key: qrKey,
              onQRViewCreated: _onQRViewCreated,
            ),
          ),
          const SizedBox(height: 20),
          // Start or stop scanning button
          ElevatedButton(
            onPressed: () {
              setState(() {
                isScanning = !isScanning;
                if (isScanning) {
                  controller.resumeCamera();
                } else {
                  controller.pauseCamera();
                }
              });
            },
            child: Text(isScanning ? "Pause Scanning" : "Resume Scanning"),
          ),
        ],
      ),
    );
  }
}
