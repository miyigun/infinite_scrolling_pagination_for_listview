import 'package:flutter/material.dart';

import 'dart:convert' as convert;
import 'package:http/http.dart' as http;

class Home extends StatefulWidget {
  const Home({super.key, required this.title});

  final String title;

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final controller=ScrollController();
  List<String> items = [];
  bool hasMore=true;
  int page=1;
  bool isLoading=false;

  @override
  void initState() {
    super.initState();

    fetch();

    controller.addListener(() {
      if (controller.position.maxScrollExtent==controller.offset){
        fetch();
      }
    });
  }

  @override
  void dispose() {
    super.dispose();

    controller.dispose();
  }

  Future fetch() async {
    if (isLoading) return;
    isLoading=true;

    const limit=25;

    final url = Uri.parse("https://jsonplaceholder.typicode.com/posts?_limit=$limit&_page=$page");
    final response = await http.get(url);

    if (response.statusCode==200){
      final List newItems = convert.jsonDecode(response.body);

      setState(() {
        page++;
        isLoading=false;

        if (newItems.length<limit) {
          hasMore=false;
        }

        items.addAll(newItems.map<String>((item) {
          final number = item["id"];

          return 'Item $number';
        }).toList());
      });
    }
  }

  Future refresh() async {

    setState(() {
      isLoading=false;
      hasMore=true;
      page=0;
      items.clear();
    });

    fetch();

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text(
            "Infinite Scroll ListView",
          ),
        ),
        body: RefreshIndicator(
                onRefresh: refresh,
                child: ListView.builder(
                  controller: controller,
                    padding: const EdgeInsets.all(8),
                    itemCount: items.length+1,
                    itemBuilder: (context, index) {
                      if(index<items.length){
                        final item = items[index];

                        return ListTile(
                          title: Text(item),
                        );
                      } else {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 32),
                          child: Center(
                            child: hasMore
                              ? const CircularProgressIndicator(color: Colors.red)
                                : const Text("No more data to load!"),
                          ),
                        );
                      }
                    }),
              ));
  }
}
