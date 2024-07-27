import 'dart:typed_data';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:instagram_clone/resources/storage_methods.dart';
import 'package:instagram_clone/models/user.dart' as model;

class AuthMethods{
  final FirebaseAuth _auth=FirebaseAuth.instance;
  final FirebaseFirestore _firestore=FirebaseFirestore.instance;

  Future<model.User> getUserDetails() async{
    User currentUser = _auth.currentUser!;
    DocumentSnapshot snap=await _firestore.collection('users').doc(currentUser.uid).get();
    return model.User.fromSnap(snap);
  }

// sign up user
  Future<String> signUpUser({
    required String email,
    required String password,
    required String username,
    required String bio,
    required Uint8List file,
  }) async {
    String res="Some error occured";
    try{
      if(email.isNotEmpty || password.isNotEmpty || username.isNotEmpty || bio.isNotEmpty || file.isNotEmpty){
// register user
        UserCredential cred = await _auth.createUserWithEmailAndPassword(email: email, password: password);
        print(cred.user!.uid);
        String photoUrl= await StorageMethods()
            .uploadImageToStorage('profilePics', file, false);
// add user to our database
        model.User user=model.User(
          username:username,
          uid:cred.user!.uid,
          email:email,
          bio:bio,
          photoUrl:photoUrl,
          following:[],
          followers:[],
        );

        await _firestore.collection('users').doc(cred.user!.uid).set(user.toJson(),);

        res="success";
      }
    } on FirebaseAuthException catch(err){
      if(err.code=='invalid-email'){
        res="The email is badly formatted.";
      }
      else if(err.code=='weak-password'){
        res="Password should be at least 6 characters";
      }
    }

    catch(err){
      res=err.toString();
    }
    return res;
  }


// logging in user
  Future<String> loginUser({
    required String email,
    required String password
  }) async {
    String res="Some error occured";
    try{
      if(email.isNotEmpty || password.isNotEmpty){
        await _auth.signInWithEmailAndPassword(email: email, password: password);
        res="success";
      } else{
        res="Please enter all the fields";
      }
    } on FirebaseAuthException catch(e){
      if(e.code=='user-note-found'){
        res="Kindly sign up first";
      }
      else if(e.code=='wrong-password'){
        res='Password is incorrect';
      }
    }
    catch(err){
      res=err.toString();
    }
    return res;
  }

  Future<void> signOut() async{
    await _auth.signOut();
  }
}
