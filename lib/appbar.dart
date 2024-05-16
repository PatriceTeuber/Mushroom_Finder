import 'package:flutter/material.dart';
import 'package:mushroom_finder/pointdata/pointdata.dart';

class Appbar extends StatefulWidget implements PreferredSizeWidget {
  final List<PointData> Function() getCustomMarker;
  final void Function(String title) CreateSearch;
  final void Function() DeleteSearch;

  const Appbar({Key? key,required this.getCustomMarker, required this.CreateSearch,required this.DeleteSearch}): super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 16);
  @override
  State<Appbar> createState() => _AppbarState();
}

class _AppbarState extends State<Appbar> {
  late List<PointData> Function() getCustomMarker;
  late void Function(String title) CreateSearch;
  late void Function() DeleteSearch;
  late close controll;

  @override
  void initState() {
    super.initState();
     getCustomMarker = widget.getCustomMarker;
     CreateSearch = widget.CreateSearch;
     DeleteSearch = widget.DeleteSearch;
  }


  @override
  Widget build(BuildContext context) {

    final SearchController tempController = SearchController();
    controll = close(controller:tempController);

    return AppBar(
      centerTitle: true,
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      shadowColor: Colors.transparent,
      title: SizedBox(
        width: MediaQuery.of(context).size.width * 0.9,
        height: 50,
        child:SearchAnchor(
            viewConstraints: const BoxConstraints(
              minHeight: kToolbarHeight,
              maxHeight: kToolbarHeight * 5,
            ),
            headerTextStyle: const TextStyle(color: Colors.black,fontSize: 19),
            viewHintText: 'Suche nach Pilzen ...',
            headerHintStyle: const TextStyle(color: Colors.grey,fontSize: 19),
            viewOnSubmitted:(String title){
              CreateSearch(title);
              controll.CloseView(title);
            },
            isFullScreen: false,
            builder: (BuildContext context, SearchController controller) {
              controll.controller = controller;
              return SearchBar(
                textStyle:MaterialStateProperty.all(
                    const TextStyle(color: Colors.black, fontSize: 19)
                ),
                hintText:'Suche nach Pilzen ...',
                hintStyle:  MaterialStateProperty.all(
                     const TextStyle(color: Colors.black, fontSize: 19)
                ),
                controller: controller,
                padding: const MaterialStatePropertyAll<EdgeInsets>(
                    EdgeInsets.symmetric(horizontal: 16.0)),
                onTap: () {
                  controller.openView();
                },
                onChanged: (_) {
                  controller.openView();
                },
                leading:IconButton(
                    icon: const Icon(Icons.search),
                    color: Colors.black,
                    onPressed: () {
                      controller.openView();}
                ),
                trailing:  [
                  IconButton(
                    icon: const Icon(Icons.clear),
                    color: Colors.black,
                    onPressed: () {
                      DeleteSearch();
                      controller.clear();
                      FocusScope.of(context).unfocus();
                    },
                  ),
                ],
              );
            },
          suggestionsBuilder:
              (BuildContext context, SearchController controller) {
              final List<PointData> data = getCustomMarker();
              final List<String> titles = data.map((pointData) => pointData.title).toSet().toList();
              final String text = controller.value.text.toLowerCase();

              final List<String> suggestionList = text.isEmpty
               ? titles : titles.where((title) => title.toLowerCase().contains(text)).toList();

              if (suggestionList.isEmpty) {
                return [
                  ListTile(
                    title: const Center(
                      child: Text(
                        'keine Pilze',
                        style: TextStyle(color: Colors.red, fontSize: 19),
                      ),
                    ),
                    onTap: () {},
                  )
                ];
              }
              List<ListTile> test = suggestionList.map((title) {
                  return ListTile(
                    title: Text(title),
                    titleTextStyle: const TextStyle(color: Colors.black, fontSize: 19, inherit:false),
                    onTap: () {
                    setState(() {
                        controller.closeView(title);
                        FocusScope.of(context).unfocus();
                       });
                    CreateSearch(title);
                    },
                  );
                 }).toList();
               return test;
            },
        ),
      ),
    );
  }
}

// Hack
class close{
  SearchController controller;
  close({required this.controller});

  void CloseView(String text){
      controller.closeView(text);
  }
}