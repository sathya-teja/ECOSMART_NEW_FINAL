import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'dart:io'; // For file operations
import 'package:path_provider/path_provider.dart'; // To get the app's documents directory
import 'package:http/http.dart' as http; // For sending HTTP requests
import 'package:http_parser/http_parser.dart'; // For setting content type of the request
import 'package:mime_type/mime_type.dart'; // To determine the MIME type of the file
import 'package:image_picker/image_picker.dart'; // For picking images from gallery or camera

class CaptureWasteScreen extends StatefulWidget {
  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CaptureWasteScreen> {
  late CameraController _controller;
  late List<CameraDescription> _cameras;
  late CameraDescription _camera;
  late File _imageFile;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      // Fetch available cameras
      _cameras = await availableCameras();
      _camera = _cameras.first; // Choose the first available camera

      // Initialize the camera controller
      _controller = CameraController(_camera, ResolutionPreset.high);

      // Initialize the controller
      await _controller.initialize();

      // Check if the controller has been initialized, and call setState
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      print("Error initializing camera: $e");
    }
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose(); // Dispose the controller when done
  }

  Future<void> _takePicture() async {
    if (!_controller.value.isInitialized) {
      return;
    }
    try {
      final XFile picture = await _controller.takePicture();
      final directory = await getApplicationDocumentsDirectory(); // Get app's document directory
      final String path = '${directory.path}/captured_image.jpg'; // Save image with a custom name
      final File imageFile = File(path);

      // Move the captured image to a desired directory
      await imageFile.writeAsBytes(await picture.readAsBytes());

      print('Image saved at: $path');
      
      // Send the image to the API
      await _sendImageToAPI(imageFile);

    } catch (e) {
      print("Error capturing image: $e");
    }
  }

  // Function to send image to API
  Future<void> _sendImageToAPI(File imageFile) async {
    try {
      var uri = Uri.parse('https://localhost:3000/upload'); // Replace with your API endpoint

      // Get the MIME type of the file
      String? mimeType = mime(imageFile.path);
      String mimeTypeMain = mimeType?.split('/')[0] ?? 'application';
      String mimeTypeSub = mimeType?.split('/')[1] ?? 'octet-stream';

      var request = http.MultipartRequest('POST', uri)
        ..files.add(await http.MultipartFile.fromPath(
          'image', // The field name expected by the server
          imageFile.path,
          contentType: MediaType(mimeTypeMain, mimeTypeSub),
        ));

      // Send the request and await response
      var response = await request.send();

      // Check if the request was successful
      if (response.statusCode == 200) {
        print('Image successfully uploaded to the API.');
      } else {
        print('Failed to upload image. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print("Error uploading image: $e");
    }
  }

  // Function to pick an image from the gallery
  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });

      // Send the image to the API
      await _sendImageToAPI(_imageFile);
    } else {
      print('No image selected.');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_controller.value.isInitialized) {
      // Show a loading indicator while the camera is initializing
      return Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(title: Text("Capture or Pick Image")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Camera preview with fixed size
            Container(
              height: 300,  // Fixed height for the camera container
              width: double.infinity,  // Full width of the screen
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CameraPreview(_controller),
              ),
            ),
            SizedBox(height: 20),
            // Button to capture image from the camera
            ElevatedButton(
              onPressed: _takePicture,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,  // Button background color
                foregroundColor: Colors.white,  // Text color
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 5,  // Shadow effect
              ),
              child: Text(
                "Capture Image",
                style: TextStyle(fontSize: 18),
              ),
            ),
            SizedBox(height: 20),
            // Button to pick an image from the gallery
            ElevatedButton(
              onPressed: _pickImage,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,  // Button background color
                foregroundColor: Colors.white,  // Text color
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 5,  // Shadow effect
              ),
              child: Text(
                "Pick Image from Gallery",
                style: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
