import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:projeto/services/api.dart';
import 'package:projeto/services/functions.dart';
import 'package:projeto/routes/pokemon_detail.dart';
import 'package:draggable_scrollbar/draggable_scrollbar.dart';
import 'package:cached_network_image/cached_network_image.dart';

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with WidgetsBindingObserver {
  List<dynamic> pokemonGlobalList = [];
  List<dynamic> pokemonList = [];
  List<dynamic> filteredList = [];
  List<dynamic> originalList = [];
  List<dynamic> typesList = [];
  String searchText = "";
  bool isLoading = false;
  Icon searchIcon = Icon(
    Icons.search,
    color: Colors.black.withOpacity(0.33),
  );
  int pokemonListCount = 0;
  ScrollController _pokemonListController = ScrollController();
  TextEditingController controller = TextEditingController(text: "");

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        statusBarColor: Colors.transparent, // Android System bar
        statusBarBrightness: Brightness.light, // iOS System Bar
        systemNavigationBarDividerColor:
            Colors.black.withOpacity(0.075), // Android Navigation Bar Divider
        systemNavigationBarColor: Colors.white, // Android Navigation Bar
        systemNavigationBarIconBrightness: Brightness.dark, // Android Navigation Bar Icons
      ));
    }
  }

  _fetchPokemonList() async {
    setState(() {
      isLoading = true;
    });

    final pokemonResponse = await http.get(Uri.parse(apiUrl));
    final typesResponse = await http.get(Uri.parse(typesApiUrl));
    if (pokemonResponse.statusCode == 200 && typesResponse.statusCode == 200) {
      final pokemonJsonResponse = json.decode(pokemonResponse.body);
      final typesJsonResponse = json.decode(typesResponse.body);
      pokemonList = pokemonJsonResponse;
      originalList = pokemonJsonResponse;
      typesList = typesJsonResponse;
    } else {
      throw Exception("Falho ao carregar as informações.");
    }

    setState(() {
      filteredList = pokemonList;
      originalList = pokemonList;
      pokemonListCount = pokemonList.length;
      typesList = typesList;
      isLoading = false;
    });
  }

  Widget _pokemonList() {
    return isLoading
        ? const Center(
            child: CircularProgressIndicator(),
          )
        : DraggableScrollbar.semicircle(
            controller: _pokemonListController,
            child: ListView.builder(
                controller: _pokemonListController,
                padding: EdgeInsets.all(0),
                keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                // itemCount: filteredList.length,
                itemCount: filteredList.length,
                itemBuilder: (context, index) {
                  return pokemonCard(
                    name: filteredList[index]["name"]["japanese"].toString(),
                    types: filteredList[index]["type"],
                    pokemonId: filteredList[index]["id"],
                    hires: filteredList[index]["thumbnail"].toString(),
                    primaryType: filteredList[index]["type"][0].toString(),
                  );
                }),
          );
  }

  Widget _pokemonListSearchBar() {
    return Container(
      height: 50.0,
      margin: const EdgeInsets.only(
        top: 10.0,
        bottom: 15.0,
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: (text) {
                _filterPokemonList(text);
              },
              decoration: InputDecoration(
                prefixIcon: searchIcon,
                border: new OutlineInputBorder(
                  borderRadius: const BorderRadius.all(
                    const Radius.circular(100.0),
                  ),
                  borderSide: BorderSide(
                    width: 0,
                    style: BorderStyle.none,
                  ),
                ),
                contentPadding: EdgeInsets.symmetric(
                  vertical: 10.0,
                  horizontal: 15.0,
                ),
                hintText: "Pesquisar um pokemon",
                filled: true,
                fillColor: Colors.black.withOpacity(0.075),
                hintStyle: TextStyle(color: Colors.black.withOpacity(0.33)),
              ),
              style: TextStyle(
                color: Colors.black.withOpacity(0.66),
                fontSize: 16.0,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          /*Container(
            margin: const EdgeInsets.only(
              left: 10.0,
            ),
            child: ClipOval(
              child: Material(
                borderRadius: BorderRadius.circular(100),
                child: PopupMenuButton(
                  icon: Icon(
                    Icons.tune,
                    color: Colors.red,
                  ),
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      child: Text("All Generations"),
                      value: 0,
                    ),
                    PopupMenuItem(
                      child: Text("Generation I"),
                      value: 1,
                    ),
                    PopupMenuItem(
                      child: Text("Generation II"),
                      value: 2,
                    ),
                    PopupMenuItem(
                      child: Text("Generation III"),
                      value: 3,
                    ),
                    PopupMenuItem(
                      child: Text("Generation IV"),
                      value: 4,
                    ),
                    PopupMenuItem(
                      child: Text("Generation V"),
                      value: 5,
                    ),
                  ],
                  onSelected: (int index) {
                    if (index == 0) {
                      setState(() {
                        filteredList = pokemonList;
                      });
                    } else if (index == 1) {
                      setState(() {
                        filteredList = originalList;
                        filteredList = filteredList.removeRange(151, 809);
                      });
                    } else if (index == 2) {
                      setState(() {
                        filteredList.skip(151).take(251);
                        // filteredList.removeRange(0, 151);
                      });
                    }
                    print('index is $index');
                  },
                ),
              ),
            ),
          ),*/
        ],
      ),
    );
  }

  _filterPokemonList(String text) {
    setState(() {
      if (this.searchIcon.icon ==
          Icon(
            Icons.search,
            color: Colors.black.withOpacity(0.33),
          )) {
        this.searchIcon = new Icon(
          Icons.cancel_outlined,
          color: Colors.black.withOpacity(0.33),
        );
      } else {
        this.searchIcon = new Icon(
          Icons.search,
          color: Colors.black.withOpacity(0.33),
        );
      }
    });
    if (text.isEmpty) {
      setState(() {
        searchText = "";
        filteredList = pokemonList;
      });
    } else if (text.isNotEmpty) {
      List tempList = [];
      for (int i = 0; i < filteredList.length; i++) {
        if (filteredList[i]['name']['chinese']
            .toString()
            .toLowerCase()
            .contains(searchText.toString().toLowerCase())) {
          tempList.add(filteredList[i]);
        }
      }
      filteredList = tempList;
      setState(() {
        searchText = text.toString();
      });
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addObserver(this);
    _fetchPokemonList();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion(
      value: SystemUiOverlayStyle(
        statusBarIconBrightness: Brightness.dark,
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            Positioned(
              left: 0,
              top: 0,
              child: Container(
                width: MediaQuery.of(context).size.height * 0.5,
                height: MediaQuery.of(context).size.height * 0.5,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage("assets/img/pokeball-bg-escuro.png"),
                  ),
                ),
              ),
            ),
            SafeArea(
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: 768.0,
                  ),
                  child: Container(
                    child: Column(
                      children: [
                        Container(
                          margin: const EdgeInsets.only(
                            right: 15.0,
                            left: 15.0,
                            top: 15.0,
                          ),
                          child: Column(
                            children: [
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  "Pokédex",
                                  style: TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.red,
                                  ),
                                ),
                              ),
                              _pokemonListSearchBar(),
                            ],
                          ),
                        ),
                        Expanded(
                          child: _pokemonList(),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget pokemonCard({
    required String name,
    required String primaryType,
    required List<dynamic> types,
    required int pokemonId,
    required String hires,
  }) {
    return Card(
      clipBehavior: Clip.antiAliasWithSaveLayer,
      elevation: 0,
      margin: const EdgeInsets.only(
        left: 20.0,
        right: 20.0,
        bottom: 15.0,
      ),
      child: Material(
        shape: RoundedRectangleBorder(
          side: const BorderSide(color: Colors.transparent, width: 0),
          borderRadius: BorderRadius.circular(10),
        ),
        clipBehavior: Clip.antiAliasWithSaveLayer,
        color: getPrimaryTypeColor(primaryType),
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PokemonDetailPage(pokemonId - 1, pokemonList, typesList),
              ),
            );
          },
          child: Stack(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    color: Colors.white.withOpacity(0.15),
                    child: Container(
                      margin: const EdgeInsets.only(
                        top: 15.0,
                        bottom: 15.0,
                        right: 15.0,
                        left: 15.0,
                      ),
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: CachedNetworkImageProvider(hires),
                          alignment: Alignment.center,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(
                      left: 15.0,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: const EdgeInsets.only(
                            top: 0.0,
                            bottom: 5.0,
                          ),
                          child: Text(
                            name,
                            style: TextStyle(
                              fontSize: 22,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Container(
                          width: 160,
                          height: 22.5,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: types.length,
                            itemBuilder: (context, index) {
                              final type = types[index];
                              return Card(
                                clipBehavior: Clip.antiAliasWithSaveLayer,
                                shape: RoundedRectangleBorder(
                                  side: const BorderSide(color: Colors.transparent, width: 0),
                                  borderRadius: BorderRadius.circular(50),
                                ),
                                elevation: 2,
                                margin: const EdgeInsets.only(
                                  right: 10.0,
                                ),
                                color: getPrimaryTypeColor(types[index]),
                                child: Container(
                                  color: Colors.black.withOpacity(0.1),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 5.0,
                                    horizontal: 10.0,
                                  ),
                                  child: Text(
                                    types[index].toString().toUpperCase(),
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 0.5,
                                      fontSize: 11.0,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
              Positioned(
                right: 15,
                bottom: 25,
                child: Text(
                  "#" + pokemonId.toString().padLeft(3, '0'),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 32,
                    color: Colors.white.withOpacity(0.5),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
