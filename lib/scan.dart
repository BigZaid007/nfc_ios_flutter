import 'package:flutter/material.dart';
import 'package:flutter_nfc_kit/flutter_nfc_kit.dart';

class ScanScreen extends StatefulWidget {
  @override
  _ScanScreenState createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  String _scanResult = 'Tap the button to start scanning';

  Future<void> _startScan() async {
    setState(() {
      _scanResult = 'Scanning...';
    });

    try {
      var availability = await FlutterNfcKit.nfcAvailability;
      if (availability != NFCAvailability.available) {
        setState(() {
          _scanResult = 'NFC not available on this device';
        });
        return;
      }

      var tag = await FlutterNfcKit.poll();
      setState(() {
        _scanResult = 'Scan successful!\n\n'
            'Tag ID: ${tag.id}\n'
            'Tag Type: ${tag.type}\n'
            'Standard: ${tag.standard}\n'
            'ATQA: ${tag.atqa}\n'
            'SAK: ${tag.sak}\n'
            'Historical Bytes: ${tag.historicalBytes}\n'
            'Protocol Info: ${tag.protocolInfo}\n'
            'Application Data: ${tag.applicationData}\n'
            'Higher Layer Response: ${tag.hiLayerResponse}\n'
            'Manufacturer: ${tag.manufacturer}\n'
            'System Code: ${tag.systemCode}\n'
            'DSF ID: ${tag.dsfId}\n'
            'NFCA Content: ${tag.ndefAvailable}\n'
            'NDEFM Content: ${tag.ndefAvailable}\n'
            'NFCV Content: ${tag.ndefAvailable}';
      });
    } catch (e) {
      setState(() {
        _scanResult = 'Scan failed: ${e.toString()}';
      });
    } finally {
      await FlutterNfcKit.finish();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('NFC Scan'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                _scanResult,
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ),
            ElevatedButton(
              onPressed: _startScan,
              child: Text('Start NFC Scan'),
            ),
          ],
        ),
      ),
    );
  }
}
