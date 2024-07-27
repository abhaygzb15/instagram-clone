// import 'dart:js_interop';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:instagram_clone/resources/auth_methods.dart';
import 'package:instagram_clone/resources/firestore_methods.dart';
import 'package:instagram_clone/screens/login_screen.dart';
import 'package:instagram_clone/utils/colors.dart';
import 'package:instagram_clone/utils/utils.dart';
import '../widgets/follow_button.dart';

class ProfileScreen extends StatefulWidget {
  final String uid;
  const ProfileScreen({super.key,required this.uid});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // var userData={};
  var userData = <String, dynamic>{}; // Initialize as an empty map
  int postLen=0;
  int followers=0;
  int following=0;
  bool isFollowing=false;
  bool isLoading =false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getData();
  }

  getData() async {
    setState(() {
      isLoading=true;
    });
    try {
      var userSnap = await FirebaseFirestore.instance.collection('users').doc(widget.uid).get();

      //get post length
      var postSnap=await FirebaseFirestore.instance.collection('posts').where('uid',
          isEqualTo:FirebaseAuth.instance.currentUser!.uid).get();
      postLen=postSnap.docs.length;
      if (userSnap.exists) {
        userData = userSnap.data()! as Map<String, dynamic>;
        followers=userSnap.data()!['followers'].length;
        following=userSnap.data()!['following'].length;
        isFollowing=userSnap
        .data()!['followers']
        .contains(FirebaseAuth.instance.currentUser!.uid);
        setState(() {});
      } else {
        showSnackBar(context as String, "User not found" as BuildContext);
      }
    } catch (e) {
      showSnackBar(context as String, "Failed to fetch user data" as BuildContext);
    }
    setState(() {
      isLoading=false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
    ? const Center(
    child: CircularProgressIndicator(),
    )
    : Scaffold(
      appBar: AppBar(
        backgroundColor: mobileBackgroundColor,
        title: Row(
          children: [
            userData.containsKey('username')
                ? Text(
              userData['username'],
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            )
                : const Text(''),
            const Spacer(), // Adds space to the right
          ],
        ),
        centerTitle: false,
      ),
      body: ListView(
        children: [
          Padding(
            // padding: const EdgeInsets.all(16),
            padding: const EdgeInsets.only(top: 0,bottom: 10,left: 16,right: 16),
            child: Column(
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.grey,
                      backgroundImage: NetworkImage(
                        userData['photoUrl'],
                      ),
                      radius: 50,
                    ),
                    Expanded(
                      flex: 1,
                      child: Column(
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(flex:1,child: buildStatColumn(postLen, 'posts')),
                              Expanded(child: buildStatColumn(followers, 'followers')),
                              Expanded(child: buildStatColumn(following, 'following')),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              FirebaseAuth.instance.currentUser!.uid==widget.uid?
                              Container(
                                width: 252,
                                height: 60,
                                child :FollowButton(
                                text: 'Sign Out',
                                backgroundColor: Colors.blue,
                                textColor: primaryColor,
                                borderColor: Colors.black,
                                function: () async {
                                  await AuthMethods().signOut();
                                  Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const LoginScreen(),
                                  ),
                                  );
                                },
                              ),
                              ) :
                                  isFollowing ?
                                  Container(
                                    width: 250,
                                    height: 60,
                                    child :FollowButton(
                                      text: 'Unfollow',
                                      backgroundColor: Colors.white,
                                      textColor: Colors.black,
                                      borderColor: Colors.grey,
                                      function: () async {
                                        await FireStoreMethods().followUser(FirebaseAuth.instance.currentUser!.uid, userData['uid'],
                                        );
                                        setState(() {
                                          isFollowing=false;
                                          followers--;
                                        });
                                      },
                                    ),
                                  ) :
                                  Container(
                                    width: 250,
                                    height: 60,
                                    child :FollowButton(
                                      text: 'Follow',
                                      backgroundColor: Colors.blue,
                                      textColor: Colors.white,
                                      borderColor: Colors.blue,
                                      function: () async {
                                        await FireStoreMethods().followUser(FirebaseAuth.instance.currentUser!.uid, userData['uid'],);
                                        setState(() {
                                          isFollowing=true;
                                          followers++;
                                        });
                                        },
                                    ),
                                  )
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Container(
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.only(left: 4,top: 2),
                  child: Text(
                    userData['username'],
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.only(left:4),
                  child: Text(
                    userData['bio'],
                  ),
                ),
              ],
            ),
          ),
          const Divider(),
          FutureBuilder(
              future: FirebaseFirestore.instance.collection('posts').where('uid',isEqualTo: widget.uid).get(),
              builder: (context,snapshot){
                if(snapshot.connectionState==ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(2),
                    shrinkWrap: true,
                    itemCount: (snapshot.data! as dynamic).docs.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 5,
                      mainAxisSpacing: 5,
                      childAspectRatio: 1,
                    ),
                    itemBuilder: (context,index){
                      DocumentSnapshot snap =(snapshot.data! as dynamic).docs[index];
                     return Container(
                       child: Image(
                         image: NetworkImage(
                           snap['postUrl']
                         ),
                         fit: BoxFit.cover,
                       ),
                     );
                      },
                );
              },
          )
        ],
      ),
    );
  }

  Column buildStatColumn(int num, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          num.toString(),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Container(
          margin: const EdgeInsets.only(top: 4),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w400,
              color: Colors.grey,
            ),
          ),
        ),
      ],
    );
  }
}
