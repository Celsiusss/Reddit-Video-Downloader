import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

const String THREAD_EXP = r'https:\/\/www\.reddit\.com\/r\/.+\/comments\/.+';
const String VIDEO_EXP = r'https:\/\/v\.redd\.it\/.+';
const String VIDEO2_EXP = r'https:\/\/www\.reddit\.com\/video\/.+';

class Utils {

  static bool isThreadUrl(String url) {
    RegExp exp = new RegExp(THREAD_EXP);
    return exp.firstMatch(url) != null;
  }

  static String parseThreadUrl(String url) {
    // Remove query params
    RegExp noParamsExp = new RegExp(r'[^\?]*');
    RegExpMatch urlMatch = noParamsExp.firstMatch(url);

    String redditUrl = urlMatch.group(0);

    if (!redditUrl.endsWith('/')) {
      redditUrl += '/';
    }
    redditUrl += '.json';

    return redditUrl;
  }

  static RedditUrls getUrlType(String url) {
    RegExp threadExp = new RegExp(THREAD_EXP);
    RegExp videoExp = new RegExp(VIDEO_EXP);
    RegExp video2Exp = new RegExp(VIDEO2_EXP);

    if (threadExp.firstMatch(url) != null) {
      return RedditUrls.THREAD;
    } else if (videoExp.firstMatch(url) != null) {
      return RedditUrls.VIDEO;
    } else if (video2Exp.firstMatch(url) != null) {
      return RedditUrls.VIDEO2;
    } else {
      return RedditUrls.INVALID;
    }
  }

  static Future<String> getThreadUrlFromVideoUrl(String url) async {

    final client = new http.Client();
    final request = new http.Request('GET', Uri.parse(url))
      ..followRedirects = false;
    final response = await client.send(request);


    String redirectUrl = response.headers['location'];
    debugPrint(redirectUrl);
    if (isThreadUrl(redirectUrl)) {
      return redirectUrl;
    } else {
      final secondRequest = new http.Request('GET', Uri.parse(redirectUrl))
        ..followRedirects = false;
      final secondResponse = await client.send(secondRequest);
      String secondRedirectUrl = secondResponse.headers['location'];
      debugPrint(secondRedirectUrl);
      if (isThreadUrl(secondRedirectUrl)) {
        return secondRedirectUrl;
      } else {
        return null;
      }
    }

  }

}

enum RedditUrls {
  THREAD,
  VIDEO,
  VIDEO2,
  INVALID
}
