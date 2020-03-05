import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

import 'API.dart';
import 'AppBrowser.dart';

class PostDetail extends StatefulWidget {
  var itemTitle, itemID;
  PostDetail(this.itemID, this.itemTitle);

  @override
  PostDetailState createState() {
    // TODO: implement createState
    return PostDetailState(itemID: itemID, itemTitle: itemTitle);
  }
}

class PostDetailState extends State<PostDetail> {
  var htmlContent;
  var itemTitle, itemID;
  Future<PostInfo> post;
  
  PostDetailState({this.itemID, this.itemTitle});
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    post = getPostInfo();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    try {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.black54,
          title: Text(
            itemTitle,
          ),
          leading: IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: Icon(Icons.arrow_back),
          ),
        ),
        body: Container(child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            return SingleChildScrollView(
                child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Expanded(
                              child: FutureBuilder<PostInfo>(
                            future: post,
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                return Padding(
                                  padding: EdgeInsets.all(10),
                                  child: HtmlWidget(
                                    snapshot.data.postInfo["content"]["rendered"]+"\n\n"+snapshot.data.postInfo["excerpt"]["rendered"],
                                    enableCaching: false,
                                    hyperlinkColor: Colors.blue,
                                    onTapUrl: (url) => url.contains(API.BASE_URL)?Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => AppBrowser(url),


                                      ),
                                    ): showDialog(
                                      context: context,
                                      builder: (_) => AlertDialog(
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                        content: Text(url),
                                        actions: <Widget>[
                                          FlatButton(
                                            child: Text("Open"),
                                            onPressed: () {
                                              launch(url);

                                            },
                                          )
                                        ],
                                      ),
                                    ),
                                    //html: htmlContent,
                                  ),
                                );
                              } else if (snapshot.hasError) {
                                return Center(
                                  child: Text("No Data available"),
                                );
                              }
                              return Center(
                                child: CircularProgressIndicator(),
                              );
                            },
                          )),
                        ])));
          },
        )),
      );
    } on Exception catch (_) {
      return null;
    }
  }

  Future<PostInfo> getPostInfo() async {
    try {
      String url = API.BASE_URL+API.POST_INFO + itemID.toString();
      final response = await http.get(url);
      if (response.statusCode == 200) {
        // If the call to the server was successful, parse the JSON.
        var extractData = json.decode(response.body);
        print(extractData);
        return PostInfo.fromJson(json.decode(response.body));
      } else {
        // If that call was not successful, throw an error.
        throw Exception('Failed to load post');
      }
    } on Exception catch (e) {
      print("error" + '$e');
    }
  }
}

class PostInfo {
  var postInfo;
  PostInfo({this.postInfo});

  factory PostInfo.fromJson(Map<String, dynamic> json) {
    return new PostInfo(postInfo: json);
  }
}
