
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
    imgLoad=false;
    slugValue="";
    var arrUrl=url.split("priyanka.guru/");
    if(arrUrl.length>0){
      slugValue=arrUrl[1];
      if(slugValue.contains("/")){
        var slugBreak=slugValue.split("/");
        if(slugBreak.length>0){
          if(slugBreak[1]!="") {
            slugValue = slugBreak[1];
          }else{
            slugValue=slugBreak[0];
          }
        }
      }
    }
    //getPostImage(slugValue);
    post=getPostInfo(slugValue);

  }
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.green.shade50,
          body:NestedScrollView(

            headerSliverBuilder: (BuildContext context,bool innerBoxScrol){
              return <Widget>[
                SliverAppBar(
                  backgroundColor: Colors.green.shade700,
                  expandedHeight: MediaQuery.of(context).size.height/3,
                  floating: false,
                  pinned: true,
                  flexibleSpace: FlexibleSpaceBar(
                      centerTitle: true,
                      background: imgLoad?Image.network(
                        imageUrl,
                        fit: BoxFit.fill,
                      ):Image.network(
                          "https://priyanka.guru/wp-content/uploads/mother-1171569_1920-1-1024x683.jpg",
                          fit: BoxFit.fill,
                          )),
                  title: infoloded? Text(title,maxLines: 2,) :Text("Details"),
                  leading: IconButton(
                    onPressed: () {
                      Navigator.pop(this.context);
                    },
                    icon: Icon(Icons.arrow_back),
                  ),
                ),
              ];
            },


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
                                          enableCaching: true,
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
                          ]
                      )
                  )
              );
            },
          )),
        ),
      ),
    );
  }
  Future<PageInfo>
  getPostInfo(String slugValue) async {
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
          featuredMedia=extractData[0]["featured_media"].toString();
          getPostImage(featuredMedia);
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
  String featuredMedia;
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
          featuredMedia=extractData[0]["featured_media"].toString();
          getPostImage(featuredMedia);
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
  String imageUrl;
  bool imgLoad=false;
  Future<void> getPostImage(String featureMediaId) async{
    try {
      String url = API.BASE_URL+"wp-json/wp/v2/media/"+featureMediaId ;//+ itemID.toString();
      final response = await http.get(url);
      if (response.statusCode == 200) {
        // If the call to the server was successful, parse the JSON.
        var extractData = json.decode(response.body);
        print(extractData);
        if(extractData.length>0){
          setState(() {
            imgLoad=true;
          });
          imageUrl=extractData["media_details"]["sizes"]["full"]["source_url"];
          print(imageUrl);
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