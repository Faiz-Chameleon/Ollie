import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../utils/analiytics.dart';
import '../utils/string.dart';
import '../utils/theme/theme_constants.dart';

class WebViewScreen extends StatefulWidget {
  String url = "";
  String screenName = "";

  WebViewScreen({Key? key, required this.url, required this.screenName})
      : super(key: key);

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class ValidationTexts {
  static const String noHint = "";
}

class _WebViewScreenState extends State<WebViewScreen> {
  WebViewController? controller;

  @override
  void initState() {
    super.initState();

    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            // Update loading bar.
          },
          onPageStarted: (String url) {},
          onPageFinished: (String url) {},
          onWebResourceError: (WebResourceError error) {},
          onNavigationRequest: (NavigationRequest request) {
            if (request.url.startsWith('https://www.youtube.com/')) {
              return NavigationDecision.prevent;
            }else if (request.url.contains('https://tellygence.tv')) {
              // showToast(StringK.kThankYouForFeedback);
              Navigator.pop(context);
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));

    publishAmplitudeEvent(eventType: 'WebView $kScreenView');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appBgColor,
      appBar: AppBar(
        backgroundColor: appBgColor,
        elevation: 0.0,
        leading: InkWell(
          onTap: () {
            Navigator.pop(context);
          },
          child: const Icon(
            Icons.arrow_back_ios,
            color: Colors.white,
          ),
        ),
        title: Text(widget.screenName, style: whiteColor20BoldTextStyle,),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // TGAppBar(screenTitle: widget.screenName),
            Expanded(child: WebViewWidget(controller: controller!)),
          ],
        ),
      ),
    );
  }
}
