import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_nfc_kit/flutter_nfc_kit.dart';
import 'dart:io' show Platform;
import 'dart:convert';

class NFCScreen extends StatefulWidget {
  @override
  _NFCScreenState createState() => _NFCScreenState();
}

class _NFCScreenState extends State<NFCScreen> {
  String _status = 'Ready to scan';

  Future<void> _startNFCScan() async {
    setState(() {
      _status = 'Starting NFC scan...';
    });

    try {
      if (Platform.isAndroid) {
        var availability = await FlutterNfcKit.nfcAvailability;
        if (availability != NFCAvailability.available) {
          setState(() {
            _status = 'NFC not available on this Android device';
          });
          return;
        }
      }

      // Start NFC polling
      var tag = await FlutterNfcKit.poll(
        timeout: Duration(seconds: 20),
        iosMultipleTagMessage: "Multiple tags found!",
        iosAlertMessage: "Hold your device near an NFC tag",
      );

      setState(() {
        _status = 'Tag detected: ${jsonEncode(tag)}';
      });

      // Read NDEF records if available
      if (tag.ndefAvailable!) {
        var records = await FlutterNfcKit.readNDEFRecords(cached: false);
        setState(() {
          _status += '\n\nNDEF Records:';
          for (var record in records) {
            _status += '\n${record.toString()}';
          }
        });
      }
    } on PlatformException catch (e) {
      setState(() {
        if (e.code == '406' && Platform.isIOS) {
          _status = 'NFC is not available or not enabled on this iOS device.\n'
              'Make sure your device supports NFC and it\'s enabled in Settings.';
        } else {
          _status =
              'PlatformException ${e.code}: ${e.message}\nDetails: ${e.details}';
        }
      });
    } catch (e) {
      setState(() {
        _status = 'Error: ${e.toString()}';
      });
    } finally {
      // Always finish the NFC session
      await FlutterNfcKit.finish();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('NFC Scanner'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(_status, textAlign: TextAlign.center),
            ),
            ElevatedButton(
              onPressed: _startNFCScan,
              child: Text('Start NFC Scan'),
            ),
          ],
        ),
      ),
    );
  }
}
