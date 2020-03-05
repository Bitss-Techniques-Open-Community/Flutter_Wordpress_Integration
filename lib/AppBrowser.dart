
import 'dart:convert';

import 'package:http/http.dart'as http;
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:url_launcher/url_launcher.dart';

import 'API.dart';

class AppBrowser extends StatefulWidget{
  String url;

  AppBrowser(this.url);

  @override
  AppBrowserState createState() {
    // TODO: implement createState
    return AppBrowserState(url);
  }

}

class AppBrowserState extends State<AppBrowser>{

  Future<PageInfo> post;
  String url;
  String slugValue;
  bool loaded=false;
  AppBrowserState(this.url);
@override
  void initState() {
    // TODO: implement initState
    super.initState();
    var arr=url.split(API.BASE_URL);
    if(arr.length>0){
    slugValue=arr[1];}
    post=getPostInfo();
  }
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      
      appBar: AppBar(
        title: Text("Details"),
        backgroundColor: Colors.black54,

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
                             child:  loaded?FutureBuilder<PageInfo>(
                              future: post,
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  return Padding(
                                    padding: EdgeInsets.all(10),
                                    child: HtmlWidget(
                                      snapshot.data.pagetInfo["content"]["rendered"]+"\n\n"+snapshot.data.pagetInfo["excerpt"]["rendered"],
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
                            ):Container()
                        ),
                      ])));
        },
      )),

    );
  }
  Future<PageInfo> getPostInfo() async {
    try {
      String url = API.BASE_URL+"wp-json/wp/v2/posts?slug="+slugValue ;//+ itemID.toString();
      final response = await http.get(url);
      if (response.statusCode == 200) {
        // If the call to the server was successful, parse the JSON.
        var extractData = json.decode(response.body);
        print(extractData);
        setState(() {
          loaded=true;
        });

        return PageInfo.fromJson(json.decode(response.body));
      } else {
        // If that call was not successful, throw an error.
        throw Exception('Failed to load post');
      }
    } on Exception catch (e) {
      print("error" + '$e');
    }
  }
}

class PageInfo {
  var pagetInfo;
  PageInfo({this.pagetInfo});

  factory PageInfo.fromJson(Map<String, dynamic> json) {
    return new PageInfo(pagetInfo: json);
  }
}