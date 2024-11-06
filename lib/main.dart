import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false,
      title: 'QR Code Generator',
      theme: ThemeData(
        primarySwatch: Colors.purple,
        fontFamily: 'Roboto',

      ),
      home: QRCodeGeneratorPage(),
    );
  }
}

class QRCodeGeneratorPage extends StatefulWidget {
  @override
  _QRCodeGeneratorPageState createState() => _QRCodeGeneratorPageState();
}

class _QRCodeGeneratorPageState extends State<QRCodeGeneratorPage> {
  final TextEditingController _controller = TextEditingController();
  String _qrData = "";

  void _generateQRCode() {
    setState(() {
      _qrData = _controller.text;
    });
  }

  Future<void> _downloadQRCode() async {
    if (_qrData.isEmpty) return;

    final pdf = pw.Document();
    final qrImage = await QrPainter(
      data: _qrData,
      version: QrVersions.auto,
      gapless: false,
    ).toImageData(200);

    final image = pw.MemoryImage(qrImage!.buffer.asUint8List());

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Center(
            child: pw.Image(image),
          );
        },
      ),
    );

    await Printing.sharePdf(bytes: await pdf.save(), filename: 'qrcode.pdf');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('QR Code Generator'),
        backgroundColor: Colors.purple[700],
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: 'Enter text',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: _generateQRCode,
              child: Text('Generate QR Code'),
              style: ElevatedButton.styleFrom(
                primary: Colors.purple[700],
              ),
            ),
            SizedBox(height: 20.0),
            if (_qrData.isNotEmpty)
              Column(
                children: [
                  SizedBox(height: 20.0),
                  ElevatedButton(
                    onPressed: _downloadQRCode,
                    child: Text('Download QR Code as PDF'),
                    style: ElevatedButton.styleFrom(
                      primary: Colors.purple[700],
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
