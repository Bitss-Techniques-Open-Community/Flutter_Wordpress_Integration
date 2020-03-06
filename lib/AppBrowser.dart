
import 'dart:convert';
import 'package:http/http.dart'as http;
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:url_launcher/url_launcher.dart';

import 'API.dart';

class SubDetails extends StatefulWidget{
  String url;
  SubDetails(this.url);
  @override
  SubDetailsState createState() {
    // TODO: implement createState
    return SubDetailsState(url);
  }
}

class SubDetailsState extends State<SubDetails>{

  bool postLoad;
  bool infoloded;
  Future<PageInfo> post;
  Future<PageInfo> page;
  String url;
  String slugValue="";
  String title="";
  SubDetailsState(this.url);
@override
  void initState() {
    // TODO: implement initState
    super.initState();
    postLoad=false;
    infoloded=false;
    var arrUrl=url.split("priyanka.guru/");
    if(arrUrl.length>0){
      slugValue=arrUrl[1];
    }
    post=getPostInfo(slugValue);
  }
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: infoloded? Text(title) :Text("Details"),
          backgroundColor: Colors.black54,
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed:()
            {
              Navigator.of(context).pop();
            },
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
                              child:  FutureBuilder<PageInfo>(
                                future:postLoad? post:page,
                                builder: (context, snapshot) {
                                  if (snapshot.hasData) {
                                    return Padding(
                                      padding: EdgeInsets.all(10),
                                      child: HtmlWidget(
                                        snapshot.data.pagetInfo["content"]["rendered"]+"\n\n"+snapshot.data.pagetInfo["excerpt"]["rendered"],
                                        enableCaching: false,
                                        hyperlinkColor: Colors.blue,
                                        onTapUrl: (url) => (url.contains(API.BASE_URL)|| url.contains("http://priyanka.guru/") )? Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => SubDetails(url),

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
                              )
                          ),
                        ])));
          },
        )),

      ),
    );
  }
  Future<PageInfo> getPostInfo(String slugValue) async {
    try {
      String url = API.BASE_URL+"wp-json/wp/v2/posts?slug="+slugValue ;//+ itemID.toString();
      final response = await http.get(url);
      if (response.statusCode == 200) {
        // If the call to the server was successful, parse the JSON.
        var extractData = json.decode(response.body);
        print(extractData);
        if(extractData.length>0){
          setState(() {
            postLoad=true;
            infoloded=true;
          });
          title=extractData[0]["title"]["rendered"];
          return PageInfo.fromJson(extractData[0]);
        }else{
          page=getPagesInformation(slugValue);
        }

      } else {
        // If that call was not successful, throw an error.
        throw Exception('Failed to load post');
      }
    } on Exception catch (e) {
      print("error" + '$e');
    }
  }

  Future<PageInfo> getPagesInformation(String slugValue) async{
    try {
      String url = API.BASE_URL+"wp-json/wp/v2/pages?slug="+slugValue ;//+ itemID.toString();
      final response = await http.get(url);
      if (response.statusCode == 200) {
        // If the call to the server was successful, parse the JSON.
        var extractData = json.decode(response.body);
        print(extractData);
        if(extractData.length>0){
          setState(() {
            postLoad=false;
            infoloded=true;
          });
          title=extractData[0]["title"]["rendered"];

          return PageInfo.fromJson(extractData[0]);
        }

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

  factory PageInfo.fromJson(Map<String,dynamic> json) {
    return new PageInfo(pagetInfo: json);
  }
}