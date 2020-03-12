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

  //Future<Posts> post;
  Future<Posts> serach;
  bool dataLoaded = false;
  bool imageLoaded = false;
  bool isLoading = false;
  bool recordFinish = false;
  bool searching = false;
  bool isSearch = false;
  static int MAX_VALUE_LIST; // = 3;
  var searchController = new TextEditingController(text: '');
  List<String> postTitle;
  List<String> postDate;
  var postCategory;
  List<String> postThumbnail;
  List<String>postId;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    MAX_VALUE_LIST = 10;
    dataLoaded = false;
    searching = false;
    isSearch = false;
    postTitle = new List();
    postDate = new List();
    postCategory = new List();
    postThumbnail= new List();
    postId=new List();
    searchController.text="";
    pageCount=1;
    //postThumbnail.clear();
    getAllCategory();
    getAllPost();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.green.shade50,
        body:NestedScrollView(
          headerSliverBuilder: (BuildContext context,bool innerBoxScroll){
            return <Widget>[
              SliverAppBar(
                backgroundColor: Colors.green.shade700,
                expandedHeight: MediaQuery.of(context).size.height/3,
                floating: false,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                    centerTitle: true,
                    title: Text("",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16.0,
                        )),
                    background: Image.network(
                      "https://priyanka.guru/wp-content/uploads/mother-1171569_1920-1-1024x683.jpg",
                      fit: BoxFit.cover,
                    )),
                title: !isSearch
                    ? Text("All posts")
                    :   Expanded(
                  child: Container(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Expanded(
                              flex: 7,
                              child: TextField(
                                decoration: InputDecoration(
                                  //icon: Icon(Icons.search,color: Colors.white,),
                                  hintText: "Search post here",
                                  hintStyle: TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                                style: TextStyle(color: Colors.white),
                                controller: searchController,
                                onChanged: searchClear,
                                textInputAction: TextInputAction.go,
                                cursorColor: Colors.white,
                                textAlign: TextAlign.start,

                              ),
                            ),
                            Expanded(
                              flex: 3,
                              child: RaisedButton.icon(
                                icon: Icon(Icons.search),
                                color: Colors.green.shade100,
                                label: Container(),
                                onPressed: ()=>searchPost(searchController.text),
                              ),
                            ),

                          ],
                        ),

                      ],
                    ),
                  ),
                ),


                leading: IconButton(
                  onPressed: () {
                    Navigator.pop(this.context);
                  },
                  icon: Icon(Icons.arrow_back),
                ),
                actions: <Widget>[
                  isSearch
                      ? IconButton(
                    icon: Icon(
                      Icons.cancel,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      Utility.showMsg("search");
                      setState(() {
                        this.isSearch = false;
                      });
                    },
                  )
                      : IconButton(
                    icon: Icon(
                      Icons.search,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      Utility.showMsg("search");
                      setState(() {
                        this.isSearch = true;
                      });
                    },
                  ),
                ],
              ),
            ];
          },
          body: Center(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  //  title.length<0?
                  (!searching )
                      ? Expanded(
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
                      child: dataLoaded?
                      ListView.builder(
                          itemCount: (postTitle.length==postThumbnail.length)?postTitle.length:postThumbnail.length,
                          itemBuilder: (context, int index) {
                            //var data = snap.data.postInfo[index];
                            return new Card(
                                color: Colors.white,
                                elevation: 5,
                                clipBehavior: Clip.antiAlias,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.all(
                                      Radius.circular(10)),
                                ),
                                child: ListTile(
                                  leading: Image(
                                    image: (
                                        postThumbnail[index].toString() !=
                                            "")
                                        ? new NetworkImage(
                                        postThumbnail[index])
                                        : new AssetImage(
                                        "assets/na.png"),
                                    width: MediaQuery.of(context)
                                        .size
                                        .width *
                                        0.25,
                                    height: MediaQuery.of(context)
                                        .size
                                        .height *
                                        0.25,
                                    fit: BoxFit.fill,
                                  ),

                                  title: new Padding(
                                    padding:
                                    new EdgeInsets.all(2.0),
                                    child: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment
                                          .stretch,
                                      children: <Widget>[
                                        Text(
                                          postTitle[index].toString(),
                                          // postTitles[index].toString(),
                                          style: new TextStyle(
                                              fontSize: 18.0,
                                              color: Colors.black87,
                                              fontWeight:
                                              FontWeight.bold,
                                              fontStyle:
                                              FontStyle.italic),
                                        ),
                                        Column(
                                          crossAxisAlignment:
                                          CrossAxisAlignment
                                              .start,
                                          children: <Widget>[
                                            Padding(
                                              padding:
                                              EdgeInsets.all(2),
                                              child: Wrap(
                                                children:
                                                _buildButtonsWithNames(
                                                    postCategory[index]
                                                ),
                                              ),
                                            )
                                          ],
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                          MainAxisAlignment.end,
                                          children: <Widget>[
                                            Text(
                                              date(postDate[index].toString()),
                                              style: new TextStyle(
                                                  fontSize: 12.0,
                                                  color: Colors
                                                      .black54,
                                                  fontStyle:
                                                  FontStyle
                                                      .italic),
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
                                        builder: (context) =>
                                            PostDetail(
                                                postId[index]
                                                    .toString(),
                                                postTitle[index]
                                                    .toString()),
                                      ),
                                    );
                                  },
                                ));
                          })
                          :Center(child: CircularProgressIndicator(),),


                    ),

                  )
                      :(searchTitle.length >0 && !notFound )
                      ? Expanded(
                      child:  ListView.builder(
                          itemCount: searchTitle.length,
                          itemBuilder: (context, int index) {
                            return new Card(
                              color: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.all(
                                    Radius.circular(10)),
                              ),
                              child: ListTile(
                                leading: new CircleAvatar(
                                  maxRadius: 25,
                                  child: new Image(
                                      image: (
                                          thumbnailSearch[index].toString() !="")
                                          ? new NetworkImage(
                                          thumbnailSearch[index])
                                          : new AssetImage(
                                          "assets/dummy.png"),
                                      width: 40.0,
                                      height: 40.0),
                                  backgroundColor: Colors.transparent,
                                ),
                                title: new Padding(
                                  padding: new EdgeInsets.all(5.0),
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text(
                                        searchTitle[index].toString(),
                                        style: new TextStyle(
                                            fontSize: 16.0,
                                            color: Colors.black87,
                                            fontStyle:
                                            FontStyle.italic),
                                      ),
                             Row(
                               mainAxisAlignment: MainAxisAlignment.end,
                               children: <Widget>[
                                 Padding(
                                   padding: EdgeInsets.all(5),
                                   child: Text(
                                     date(searchDate[index]),
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
                                        searchId[index].toString(),
                                        searchTitle[index].toString(),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            );
                          })


                  ):
                      Expanded(
                        child:Center(
                          child: Text("No match found."),
                        ) ,
                      )
                        ,
//              :Center(child:
//                  Padding(
//                       padding: EdgeInsets.all(25),
//                       child: Text("Sorry!! No record match."),
//                    )
//              ),

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
        )



      ),
    );
  }

  List<Widget> _buildButtonsWithNames(postInfo) {
    List<Padding> buttonsList = new List<Padding>();
    String catName = "";
    for (int i = 0; i < postInfo.length; i++) {
      for (int catID = 0; catID < extractAllCategory.length; catID++) {
        if (postInfo[i].toString() ==
            extractAllCategory[catID]["id"].toString()) {
          catName = extractAllCategory[catID]["name"];
          buttonsList.add(new Padding(
              padding: EdgeInsets.all(1),
              child: new FlatButton(
                onPressed: () {
                  Utility.showMsg(extractAllCategory[catID]["name"].toString());
                  print(extractAllCategory[catID]["name"].toString());
                },
                child: Text(
                  catName,
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
                color: Colors.green.shade300,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),),
              ),),);
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
       });
      if(pageCount<8) {
        pageCount = pageCount + 1;
        getAllPost();
      }else{
        setState(() {
          recordFinish=true;
        });
      }

    } on Exception catch (_) {}
  }

  Future<void> getImagePost(String mediaID) async {
    try {
      final respose = await http.get(API.BASE_URL + "wp-json/wp/v2/media/" + mediaID);
      if (respose.statusCode == 200) {
        var extractImage = json.decode(respose.body);
        String imagePath="";
        if(extractImage["media_details"]["sizes"]["medium"]!=null) {
          imagePath = extractImage["media_details"]["sizes"]["medium"]["source_url"]
              .toString();
          postThumbnail.add(imagePath);
        }else {
          postThumbnail.add("");
        }
       // print(extractImage["media_details"]["sizes"]["medium"]["source_url"].toString());
        if(postThumbnail.length==postTitle.length) {
          setState(() {
            dataLoaded = true;
          });
        }
      }else{
        print("error"+respose.body+"media ID="+mediaID);
      }
    } on Exception catch (e) {
      //postThumbnail.add("");
      print(e);
    }
  }
  static int pageCount=1;
  var extractDataPost;

  int totlPost;
  Future<void> getAllPost() async {
    try {
      final response = await http.get(API.BASE_URL + API.Post+",per_page=10&page="+pageCount.toString());
      if (response.statusCode == 200) {
        // If the call to the server was successful, parse the JSON.
        extractDataPost = json.decode(response.body);
        //print(extractDataPost);
        int i;

        for (i = 0; i < extractDataPost.length; i++) {
          if(extractDataPost[i]["title"]["rendered"].toString()!="" && extractDataPost[i]["title"]["rendered"].toString()!=null) {
            postId.add(extractDataPost[i]["id"].toString());
            postTitle.add(extractDataPost[i]["title"]["rendered"].toString());
            postDate.add(extractDataPost[i]["date"].toString());
            postCategory.add(extractDataPost[i]["categories"]);
            await new Future.delayed(new Duration(milliseconds: 425));
            if(extractDataPost[i]["featured_media"].toString()!="0") {
              getImagePost(extractDataPost[i]["featured_media"].toString());
            }else{
              postThumbnail.add("");
            }
          }
        }
        //print("response"+pageCount.toString()+extractDataPost);
        //return Posts.fromJson(json.decode(response.body));
      } else {
        // If that call was not successful, throw an error.
        throw Exception('Failed to load post');
      }
    } on Exception catch (e) {
      print("getAllPost() error" + '$e');
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
        //saveData(extractAllCategory);
        print(extractDataPost);
      } else {
        // If that call was not successful, throw an error.
        throw Exception('Failed to load post');
      }
    } on Exception catch (e) {
      print("getAllCategory() error" + '$e');
    }
  }

  saveData(var category) async {
    final pref = await SharedPreferences.getInstance();
    pref.setString("all_category", category);
  }
  var thumbnailSearch;
  var searchTitle;
  var searchId;
  var searchDate;
  var searchCategory;
  void _change(String value) {





    thumbnailSearch = new List();
    searchTitle = new List();
    searchId = new List();

    if(value==""){
      setState(() {
        searching=false;
      });
    }

    setState(() {
      searching=false;
    });
    if(!value.isEmpty) {
      for (int i = 0; i < extractDataPost.length; i++) {
        if (extractDataPost[i]["title"]["rendered"]
            .toString()
            .toLowerCase()
            .contains(value.toLowerCase())) {
          searchTitle.add(extractDataPost[i]["title"]["rendered"].toString());
          searchId.add(extractDataPost[i]["id"].toString());
          thumbnailSearch.add(postThumbnail[i]);
          setState(() {
            searching = true;
            //searchController.text=value;
          });
        }
      }
    }
    //Utility.showMsg(value);
  }

  var searchPosts;
  bool notFound=false;
  Future<void> searchPost(String value) async {
    setState(() {
      searching=false;
      notFound=false;
    });
    try {
      final response = await http.get(API.BASE_URL + API.SEARCHPOST+searchController.text);
      if (response.statusCode == 200) {
        // If the call to the server was successful, parse the JSON.
        thumbnailSearch = new List();
        searchTitle = new List();
        searchId = new List();
        searchDate=new List();
        searchCategory=new List();
        searchPosts = json.decode(response.body);
        if(searchPosts.length<=0){
          setState(() {
            searching=true;
            notFound=true;
          });
        }
        for(int i=0;i<searchPosts.length;i++){
          if(searchPosts[i]["title"]["rendered"].toString()!="" && searchPosts[i]["title"]["rendered"].toString()!=null) {
            searchId.add(searchPosts[i]["id"].toString());
            searchTitle.add(searchPosts[i]["title"]["rendered"].toString());
            searchDate.add(searchPosts[i]["date"].toString());
            searchCategory.add(searchPosts[i]["categories"]);
            await new Future.delayed(new Duration(milliseconds: 425));
            if(searchPosts[i]["featured_media"].toString()!="0") {
              getSearchImagePost(searchPosts[i]["featured_media"].toString());
            }else{
              thumbnailSearch.add("");
            }
          }
        }


        //print(extractDataPost);
      } else {
        // If that call was not successful, throw an error.
        throw Exception('Failed to load post');
      }
    } on Exception catch (e) {
      print("getAllCategory() error" + '$e');
    }
  }
  Future<void> getSearchImagePost(String mediaID) async {
    try {
      final respose = await http.get(API.BASE_URL + "wp-json/wp/v2/media/" + mediaID);
      if (respose.statusCode == 200) {
        var extractImage = json.decode(respose.body);
        String imagePath="";
        if(extractImage["media_details"]["sizes"]["medium"]!=null) {
          imagePath = extractImage["media_details"]["sizes"]["medium"]["source_url"]
              .toString();
          thumbnailSearch.add(imagePath);
        }else {
          thumbnailSearch.add("");
        }
        // print(extractImage["media_details"]["sizes"]["medium"]["source_url"].toString());
        if(thumbnailSearch.length==searchTitle.length) {
          setState(() {
            searching = true;
          });
        }
      }else{
        print("error"+respose.body+"media ID="+mediaID);
      }
    } on Exception catch (e) {
      //postThumbnail.add("");
      print(e);
    }
  }

  void searchClear(String value) {
    if(searchController.text.isEmpty){
      setState(() {
        searching=false;
      });
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
