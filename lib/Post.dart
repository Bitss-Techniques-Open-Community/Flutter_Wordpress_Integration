import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart'as http;
import 'API.dart';
import 'PostDetails.dart';

class MyPostPage extends StatefulWidget {

  @override
  MyPostPageState createState() {
    // TODO: implement createState
    return MyPostPageState();
  }
}

class MyPostPageState extends State<MyPostPage> {
  List<String> postId = new List();
  List<String> postTitles = new List();
  List<String> postDate = new List();
  List<String> postThumbnail = new List();
  Future<Posts> post;
  bool dataLoaded = false;
  bool imageLoaded = false;
  bool isLoading = false;
  bool recordFinish = false;
  static int MAX_VALUE_LIST;// = 3;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    MAX_VALUE_LIST=3;
    dataLoaded=false;
    postThumbnail.clear();
    post = getAllPost();

  }

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      backgroundColor: Colors.white70,
      appBar: AppBar(
          backgroundColor: Colors.black54,
          title: Text("All posts"),
          leading:IconButton(
            onPressed: (){Navigator.pop(context);},
            icon: Icon(Icons.arrow_back),
          )
      ),
      body: Center(

        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Expanded(
                  child: NotificationListener<ScrollNotification>(
                    onNotification: (ScrollNotification scrollInfo) {
                      if (!isLoading &&
                          scrollInfo.metrics.pixels ==
                              scrollInfo.metrics.maxScrollExtent) {
                        _loadData();
                        // start loading data
                        setState(() {
                          isLoading = true;
                        });
                      }
                      //return ;
                    },
                    child: dataLoaded
                        ? ListView.builder(
                        itemCount: MAX_VALUE_LIST,
                        itemBuilder: (context, int index) {
                          return new Card(
                            color: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius:
                              BorderRadius.all(Radius.circular(10)),
                            ),
                            child: ListTile(
                              leading: new CircleAvatar(
                                maxRadius: 25,
                                child: new Image(
                                    image: (postThumbnail[index] != null &&
                                        postThumbnail[index] != "")
                                        ? new NetworkImage(postThumbnail[index])
                                        : new AssetImage("assets/na.png"),
                                    width: 40.0,
                                    height: 40.0),
                                backgroundColor: Colors.transparent,
                              ),
                              title: new Padding(
                                padding: new EdgeInsets.all(5.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      postTitles[index].toString(),
                                      style: new TextStyle(
                                          fontSize: 16.0,
                                          color: Colors.black87,
                                          fontStyle: FontStyle.italic),
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: <Widget>[
                                        Padding(
                                          padding: EdgeInsets.all(5),
                                          child: Text(
                                            date(postDate[index]),
                                            style: new TextStyle(
                                                fontSize: 12.0,
                                                color: Colors.black54,
                                                fontStyle: FontStyle.italic),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => PostDetail(
                                      postId[index].toString(),
                                      postTitles[index].toString(),
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        })
                        : Center(child: CircularProgressIndicator(),),
                  )),
              recordFinish
                  ? Text("No more record.",style: TextStyle(color: Colors.black54),)
                  : Container(
                height: isLoading ? 50.0 : 0,
                color: Colors.transparent,
                child: Center(
                  child: new CircularProgressIndicator(backgroundColor: Colors.blue.shade600,),
                ),
              ),
            ],
          ),
        ),
      ),
    ) ;

  }

  date(String postDate) {
    var myDatetime = DateTime.parse(postDate);
    var formatter = new DateFormat().add_yMMMd();
    String formatted = formatter.format(myDatetime);
    print("date" + formatted);
    return formatted;
  }
  Future _loadData() async {
    try {
      // perform fetching data delay
      await new Future.delayed(new Duration(seconds: 2));
      print("load more");
      // update data and loading status
      setState(() {
        isLoading = false;
        if (MAX_VALUE_LIST < postTitles.length) {
          if (MAX_VALUE_LIST + 3 <= postTitles.length) {
            MAX_VALUE_LIST = MAX_VALUE_LIST + 3;
          } else {
            int size = postTitles.length - MAX_VALUE_LIST;
            MAX_VALUE_LIST = MAX_VALUE_LIST + size;
            recordFinish = true;
          }
        }
      });
    } on Exception catch (_) {}
  }


  Future<void> getImagePost(String mediaID) async {
    try {
      final respose =
      await http.get(API.BASE_URL+"wp-json/wp/v2/media/" + mediaID);
      if (respose.statusCode == 200) {
        var extract = json.decode(respose.body);
        postThumbnail.add(extract["media_details"]["sizes"]["thumbnail"]
        ["source_url"]
            .toString());
        setState(() {
          imageLoaded = true;
        });
      } else {
        postThumbnail.add("");
      }
    } on Exception catch (_) {}
  }

  Future<Posts> getAllPost() async {
    try {
      final response = await http.get(API.BASE_URL+API.Post);
      if (response.statusCode == 200) {
        // If the call to the server was successful, parse the JSON.
        var extractData = json.decode(response.body);
        print(extractData);
        int i;
        for (i = 0; i < extractData.length; i++) {
          await new Future.delayed(new Duration(milliseconds: 500));
          getImagePost(extractData[i]["featured_media"].toString());
          postId.add(extractData[i]["id"].toString());
          postTitles.add(extractData[i]["title"]["rendered"].toString());
          postDate.add(extractData[i]["date"].toString());


        }
        if(i==extractData.length){
          setState(() {
            dataLoaded = true;
          });
        }
        return Posts.fromJson(json.decode(response.body));
      } else {
        // If that call was not successful, throw an error.
        throw Exception('Failed to load post');
      }
    } on Exception catch (e) {
      print("error" + '$e');
    }
  }
}

class Posts {
  var postInfo;
  Posts({this.postInfo});
  factory Posts.fromJson(Object json) {
    return new Posts(postInfo: json);
  }
}