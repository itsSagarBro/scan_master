import 'package:bloc/bloc.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:scan_master/utils/get_lauch_url.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wifi_iot/wifi_iot.dart';

part 'scanned_result_event.dart';
part 'scanned_result_state.dart';

class ScannedResultBloc extends Bloc<ScannedResultEvent, ScannedResultState> {
  ScannedResultBloc() : super(ScannedResultState.initial()) {
    on<OnActionClick>((event, emit) async {
      switch (event.barcode.type) {
        case BarcodeType.wifi:
          await WiFiForIoTPlugin.findAndConnect(event.barcode.wifi!.ssid!,
              password: event.barcode.wifi!.password!,
              joinOnce: false,
              timeoutInSeconds: 10);
          break;
        default:
          launchUrl(Uri.parse(getLaunchUrl(event.barcode)));
          break;
      }
    });

    on<OnDownloadClick>((event, emit) async {
      try {
        await state.screenshotController?.capture().then((image) async {
          if (image != null) {
            String fileName = "${event.name} ${DateTime.now().toString()}";
            fileName = fileName.replaceAll(":", "-").replaceAll(".", "-");
            await ImageGallerySaver.saveImage(image, name: fileName);
          }
        });

        Fluttertoast.showToast(msg: "QR Downloaded");
      } catch (e) {
        Fluttertoast.showToast(msg: "Cannot download QR");
      }
    });

    on<OnShareClick>((event, emit) async {
      await state.screenshotController?.capture().then((image) async {
        if (image != null) {
          await Share.shareXFiles([
            XFile.fromData(image,
                mimeType: "jpg",
                name: "${event.value} ${DateTime.now().millisecondsSinceEpoch}")
          ], subject: event.value, text: event.value);
        }
      });
    });

    on<OnCopyClick>(
        (event, emit) => Clipboard.setData(ClipboardData(text: event.value)));
  }
}
