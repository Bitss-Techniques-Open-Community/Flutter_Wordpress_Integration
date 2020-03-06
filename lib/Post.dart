import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wordpress_integration_flutter/Util.dart';
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
  List<String> postThumbnail = new List();
  Future<Posts> post;
  bool dataLoaded = false;
  bool imageLoaded = false;
  bool isLoading = false;
  bool recordFinish = false;
  static int MAX_VALUE_LIST; // = 3;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    MAX_VALUE_LIST = 3;
    dataLoaded = false;
    postThumbnail.clear();
    getAllCategory();
    post = getAllPost();

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white70,
      appBar: AppBar(
          backgroundColor: Colors.black54,
          title: Text("All posts"),
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(Icons.arrow_back),
          )),
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
                    ? FutureBuilder<Posts>(
                        future: post,
                        builder: (context, snap) {
                          if (snap.hasData) {
                            return ListView.builder(
                                itemCount: MAX_VALUE_LIST,
                                itemBuilder: (context, int index) {
                                  return new Card(
                                    color: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(10)),
                                    ),
                                    child: ListTile(
                                      leading:    ConstrainedBox(
                                        constraints: BoxConstraints(
                                          maxWidth: 150,
                                          maxHeight: 150,
                                        ),
                                        child: Image(
                                            image: (postThumbnail[index] !=
                                                null &&
                                                postThumbnail[index] != "")
                                                ? new NetworkImage(
                                                postThumbnail[index])
                                                : new AssetImage(
                                                "assets/na.png"),
                                            width: 100.0,
                                            height: 150.0,fit: BoxFit.fill,),

                                      ) ,



                                      title: new Padding(
                                        padding: new EdgeInsets.all(5.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Text(
                                              snap
                                                  .data
                                                  .postInfo[index]["title"]
                                                      ["rendered"]
                                                  .toString(),
                                              // postTitles[index].toString(),
                                              style: new TextStyle(
                                                  fontSize: 18.0,
                                                  color: Colors.black87,fontWeight: FontWeight.bold,
                                                  fontStyle: FontStyle.italic),
                                            ),
                                            Column(
                                              children: <Widget>[
                                                Padding(
                                                  padding: EdgeInsets.all(2),
                                                  child: Wrap(
                                                    children:
                                                        _buildButtonsWithNames(
                                                            snap.data.postInfo[
                                                                    index]
                                                                ["categories"],snap.data.postInfo[
                                                        index]["id"]),
                                                  ),
                                                )
                                              ],
                                            ),
                                            Row(

                                              mainAxisAlignment: MainAxisAlignment.end,
                                              children: <Widget>[
                                                Text(
                                                    date(snap.data
                                                            .postInfo[index]
                                                        ["date"]),
                                                    style: new TextStyle(
                                                        fontSize: 12.0,
                                                        color: Colors.black54,
                                                        fontStyle:
                                                            FontStyle.italic),
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
                                                snap.data.postInfo[index]["id"]
                                                    .toString(),
                                                snap
                                                    .data
                                                    .postInfo[index]["title"]
                                                        ["rendered"]
                                                    .toString()),
                                          ),
                                        );
                                      },
                                    ),
                                  );
                                });
                          } else if (snap.hasError) {
                            return Center(
                              child: Text("Something is wrong"),
                            );
                          }
                          return Center(
                            child: CircularProgressIndicator(),
                          );
                        },
                      )
                    : Center(
                        child: CircularProgressIndicator(),
                      ),
              )),
              recordFinish
                  ? Text(
                      "No more record.",
                      style: TextStyle(color: Colors.black54),
                    )
                  : Container(
                      height: isLoading ? 50.0 : 0,
                      color: Colors.transparent,
                      child: Center(
                        child: new CircularProgressIndicator(
                          backgroundColor: Colors.blue.shade600,
                        ),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildButtonsWithNames(postInfo,index) {
    List<Padding> buttonsList = new List<Padding>();
    String catName="";

    for ( int i =0;i< postInfo.length;i++) {
      for (int catID = 0; catID < extractAllCategory.length; catID++) {
        if (postInfo[i].toString() == extractAllCategory[catID]["id"].toString()) {
            catName = extractAllCategory[catID]["name"];
          buttonsList.add(new Padding(
              padding: EdgeInsets.all(1),
                  child: new FlatButton(onPressed: (){
                    Utility.showMsg(catName);
                    print(catName.toString());
                  },
                    child: Text(
                       catName, style: TextStyle(color: Colors.white,fontSize: 12),),
                    color: Colors.black54,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  )
              ));
        } else {
          continue;
        }
      }
      continue;
    }
    return buttonsList;
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
        if (MAX_VALUE_LIST < extractDataPost.length) {
          if (MAX_VALUE_LIST + 3 <= extractDataPost.length) {
            MAX_VALUE_LIST = MAX_VALUE_LIST + 3;
          } else {
            int size = extractDataPost.length - MAX_VALUE_LIST;
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
          await http.get(API.BASE_URL + "wp-json/wp/v2/media/" + mediaID);
      if (respose.statusCode == 200) {
        var extractImage = json.decode(respose.body);
        postThumbnail.add(extractImage["media_details"]["sizes"]["thumbnail"]
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

  var extractDataPost;
  Future<Posts> getAllPost() async {
    try {
      final response = await http.get(API.BASE_URL + API.Post);
      if (response.statusCode == 200) {
        // If the call to the server was successful, parse the JSON.
        extractDataPost = json.decode(response.body);
        print(extractDataPost);
        int i;
        for (i = 0; i < extractDataPost.length; i++) {
          await new Future.delayed(new Duration(milliseconds: 500));
          getImagePost(extractDataPost[i]["featured_media"].toString());
        }
        if (i == extractDataPost.length) {
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
  var extractAllCategory;
  Future<void> getAllCategory() async {
    try {
      final response = await http.get(API.BASE_URL + API.ALL_CATEGORY);
      if (response.statusCode == 200) {
        // If the call to the server was successful, parse the JSON.
        extractAllCategory = json.decode(response.body);
        await Future.delayed(Duration(milliseconds: 500));
        saveData(extractAllCategory);
        print(extractDataPost);
      } else {
        // If that call was not successful, throw an error.
        throw Exception('Failed to load post');
      }
    } on Exception catch (e) {
      print("error" + '$e');
    }
  }
  saveData(var category)async{
    final pref= await SharedPreferences.getInstance();
    pref.setString("all_category", category);

  }
}

class Posts {
  var postInfo;
  Posts({this.postInfo});
  factory Posts.fromJson(Object json) {
    return new Posts(postInfo: json);
  }
}
