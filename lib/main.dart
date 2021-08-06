import "dart:async";
import "dart:io";

import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";
import 'package:flutter/services.dart';
import "package:path_provider/path_provider.dart";
import "package:ppk_flutter/ppk_flutter.dart";

const String _pdfDocument = "pdfs/430508_m_slr2-5_product_reference_en.pdf";
void main() {
  runApp(MyApp());
}


class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: HomePage());
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  String _frameworkVersion = '';

  PPKConfiguration configuration = PPKConfiguration(
    scrollDirection: PPKScrollDirection.vertical,
    pageTransition: PPKPageTransition.scrollContinuous,
    spreadFitting: PPKSpreadFitting.fill,
    userInterfaceViewMode: PPKUserInterfaceViewMode.automaticNoFirstLastPage, 
    searchMode: PPKSearchMode.inline,
    thumbnailBarMode: PPKThumbnailBarMode.floatingScrubberBar,
    pageLabelEnabled: true,
    documentLabelEnabled: PPKAdaptiveConditional.no,
    pageIndex: 0,
    editableAnnotationTypes: [
      PPKAnnotationType.circle,
      PPKAnnotationType.ink,
      PPKAnnotationType.freeText
    ],
    textSelectionEnabled: false,
    appearanceMode: PPKAppearanceMode.deflt,
    rightBarButtonItems: [
      
      PPKBarButtonItem.bookmarkButtonItem,
      PPKBarButtonItem.activityButtonItem,
      PPKBarButtonItem.annotationButtonItem,
      PPKBarButtonItem.thumbnailsButtonItem,
      PPKBarButtonItem.outlineButtonItem,
    ],
    leftBarButtonItems: [
      PPKBarButtonItem.settingsButtonItem,
    ],
    allowToolbarTitleChange: false,
    toolbarTitle: "",
    documentInfoOptions: [
      PPKDocumentInfoViewOption.outline,
      PPKDocumentInfoViewOption.annotations,
      PPKDocumentInfoViewOption.embeddedFiles,
      PPKDocumentInfoViewOption.bookmarks,
      PPKDocumentInfoViewOption.documentInfo,
      PPKDocumentInfoViewOption.security,
    ],
    settingsOptions: [
      PPKSettingsOption.theme,           // Android only
      PPKSettingsOption.appearance,      // iOS only, same as theme above
      PPKSettingsOption.pageTransition,  // both
      PPKSettingsOption.brightness,      // iOS only
      PPKSettingsOption.pageMode,        // iOS only
      PPKSettingsOption.spreadFitting,   // iOS only
      PPKSettingsOption.scrollDirection, // both
    ],
    showBackActionButton: true,
    showForwardActionButton: true,
    showBackForwardActionButtonLabels: false,
    pageMode: PPKPageMode.single,
    firstPageAlwaysSingle: true
    // to add
  );

  Future<File> extractAsset(String assetPath) async {
    final bytes = await DefaultAssetBundle.of(context).load(assetPath);
    final list = bytes.buffer.asUint8List();

    final tempDir = await getTemporaryDirectory();
    final tempDocumentPath = '${tempDir.path}/$assetPath';

    final file = await File(tempDocumentPath).create(recursive: true);
    file.writeAsBytesSync(list);
    return file;
  }

  void _showDocumentWithConfiguration(File document, { PPKConfiguration? configuration}) async {
    try {
      if (Platform.isIOS) {
        Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => Scaffold(
            appBar: AppBar(title: Text("Document")),
            body: SafeArea(
              bottom: false,
              child: PPKWidget(documentPath: document.path, configuration: configuration),
            ),
          ),
        ));
      } else {
        // PspdfkitWidget is only supported in iOS at the moment.
        // Support for Android is coming soon.
      }
    } on PlatformException catch (e) {
      print("Failed to present document: '${e.message}'.");
    }
  }

  void showDocument() async {
    try {
      final extractedDocument = await extractAsset(_pdfDocument);
      _showDocumentWithConfiguration(extractedDocument);
    } on PlatformException catch (e) {
      print("Failed to present document: '${e.message}'.");
    }
  }

  void applyCustomConfiguration() async {
    try {
      final extractedDocument = await extractAsset(_pdfDocument);
      _showDocumentWithConfiguration(extractedDocument, configuration: configuration);
    } on PlatformException catch (e) {
      print("Failed to present image document: '${e.message}'.");
    }
  }


  void onWidgetCreated(PPKWidget view) async {
  }

  void showDocumentGlobal() async {
    try {
      final extractedDocument = await extractAsset(_pdfDocument);
      await PPKProxy.instance.present(extractedDocument.path, );
    } on PlatformException catch (e) {
      print("Failed to present document: '${e.message}'.");
    }
  }

  void applyCustomConfigurationGlobal() async {
    try {
      final extractedDocument = await extractAsset(_pdfDocument);
      await PPKProxy.instance.present(extractedDocument.path, configuration: configuration);
    } on PlatformException catch (e) {
      print("Failed to present document: '${e.message}'.");
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addObserver(this);
    initPlatformState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance?.removeObserver(this);
    super.dispose();
  }

  String frameworkVersion() {
    return 'PPK using PSPDFKit version $_frameworkVersion\n';
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  void initPlatformState() async {
    String? frameworkVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      frameworkVersion = await PPKProxy.instance.pspdfkitVersion;
    } on PlatformException {
      frameworkVersion = 'Failed to get platform version. ';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _frameworkVersion = frameworkVersion ?? '';
    });

    // By default, this example doesn't set a license key, but instead runs in trial mode (which is the default, and which requires no
    // specific initialization). If you want to use a different license key for evaluation (e.g. a production license), you can uncomment
    // the next line and set the license key.
    // await Pspdfkit.setLicenseKey("YOUR_LICENSE_KEY_GOES_HERE");
    print("PSPDFKit Version $_frameworkVersion");
  }

  void flutterPdfActivityOnPauseHandler() {
    print('flutterPdfActivityOnPauseHandler');
  }

  void pdfViewControllerWillDismissHandler() {
    print('pdfViewControllerWillDismissHandler');
  }

  void pdfViewControllerDidDismissHandler() {
    print('pdfViewControllerDidDismissHandler');
  }

  @override
  Widget build(BuildContext context) {
    PPKProxy.instance.pdfActivityOnPause = () => flutterPdfActivityOnPauseHandler();
    PPKProxy.instance.pdfViewControllerWillDismiss = () => pdfViewControllerWillDismissHandler();
    PPKProxy.instance.pdfViewControllerDidDismiss = () => pdfViewControllerDidDismissHandler();
    return Scaffold(
        appBar: AppBar(title: Text("PPKTest")),
        body: Container(
          child: ListView(
            children: <Widget>[
              ListTile(
                title: Text("View Widget (iOS only)"),
                onTap: showDocument,
              ),
              ListTile(
                title: Text("Config Widget (iOS only)"),
                onTap: applyCustomConfiguration,
              ),
              ListTile(
                title: Text("View Global"),
                onTap: showDocumentGlobal,
              ),
              ListTile(
                title: Text("Config Global"),
                onTap: applyCustomConfigurationGlobal,
              ),
            ],
          ),
        ),
    );
  }
}
