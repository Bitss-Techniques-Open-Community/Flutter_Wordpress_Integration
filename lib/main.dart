import 'package:flutter/material.dart';
import 'package:wordpress_integration_flutter/Pages.dart';

import 'Post.dart';

void main() => runApp(new MaterialApp(
    home:HomePage()));

class HomePage extends StatefulWidget{
  @override
  HomePageState createState() {
    // TODO: implement createState
    return HomePageState();
  }
}
class HomePageState extends State<HomePage>{
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return MaterialApp(
      home: Scaffold(

        appBar: AppBar(

          title: Center(child:Text("Welcome To Family"),),
          backgroundColor: Colors.green.shade700,
        ),
        body: Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.all(30),
                child: RaisedButton(
                  child: Text("Post"),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)
                  ),
                  color: Colors.green.shade400,
                  textColor: Colors.white,
                  onPressed: (){
                    Navigator.push(
                      context,
                      new MaterialPageRoute(
                        builder: (context) => new MyPostPage(),
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.all(30),
                child: RaisedButton(
                  child: Text("Pages"),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)
                  ),
                  color: Colors.green.shade400,
                  textColor: Colors.white,
                  onPressed: (){
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MyPage(),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

}






