import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:watcha_pedia/main.dart';

import 'book.dart';

class BookService extends ChangeNotifier {
  BookService() {
    loadlikedBookList();
  }
  List<Book> bookList = []; // 책 목록
  List<Book> likedBookList = [];

  void toggleLikeBook({required Book book}) {
    String bookId = book.id;
    if (likedBookList.map((book) => book.id).contains(bookId)) {
      likedBookList.removeWhere((book) => book.id == bookId);
    } else {
      likedBookList.add(book);
    }
    notifyListeners();
    print(likedBookList);
  }

  void search(String q) async {
    bookList.clear(); // 검색 버튼 누를때 이전 데이터들을 지워주기

    if (q.isNotEmpty) {
      Response res = await Dio().get(
        "https://www.googleapis.com/books/v1/volumes?q=$q&startIndex=0&maxResults=40",
      );
      List items = res.data["items"];

      for (Map<String, dynamic> item in items) {
        String subTitleString = "";
        String authorsString = "";
        String publishedDate = item['volumeInfo']['publishedDate'] ?? "";
        List authList = item['volumeInfo']['authors'] ?? [];
        bool isFirst = true;
        for (String auth in authList) {
          if (isFirst) {
            authorsString += auth;
          } else {
            authorsString += ", $auth";
          }
          isFirst = false;
        }

        subTitleString = "$authorsString\n$publishedDate";
        Book book = Book(
          id: item['id'],
          title: item['volumeInfo']['title'] ?? "",
          subtitle: subTitleString, //item['volumeInfo']['subtitle'] ?? "",
          thumbnail: item['volumeInfo']['imageLinks']?['thumbnail'] ??
              "https://thumbs.dreamstime.com/b/no-image-available-icon-flat-vector-no-image-available-icon-flat-vector-illustration-132482953.jpg",
          previewLink: item['volumeInfo']['previewLink'] ?? "",
        );
        bookList.add(book);
      }
    }
    notifyListeners();
  }

  savelikedBookList() {
    List bookJsonList = likedBookList.map((book) => book.toJson()).toList();
    // [{"content": "1"}, {"content": "2"}]

    String jsonString = jsonEncode(bookJsonList);
    // '[{"content": "1"}, {"content": "2"}]'

    prefs.setString('likedBookList', jsonString);
  }

  loadlikedBookList() {
    String? jsonString = prefs.getString('likedBookList');
    // '[{"content": "1"}, {"content": "2"}]'

    if (jsonString == null) return; // null 이면 로드하지 않음

    List bookJsonList = jsonDecode(jsonString);
    // [{"content": "1"}, {"content": "2"}]

    likedBookList = bookJsonList.map((json) => Book.fromJson(json)).toList();
  }
}
