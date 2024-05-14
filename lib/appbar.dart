import 'package:flutter/material.dart';
import 'package:mushroom_finder/pointdata/pointdata.dart';

class Appbar extends StatefulWidget implements PreferredSizeWidget {
  final List<PointData> Function() getCustomMarker;
  final void Function(String target_title, Color c) changeMarkerColor;

  Appbar({required this.getCustomMarker, required this.changeMarkerColor});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 16);
  @override
  State<Appbar> createState() => _AppbarState(getCustomMarker:getCustomMarker,changeMarkerColor:changeMarkerColor);
}

class _AppbarState extends State<Appbar> {
  final List<PointData> Function() getCustomMarker;
  final void Function(String target_title, Color c) changeMarkerColor;

  _AppbarState({required this.getCustomMarker,required this.changeMarkerColor});

  @override
  Widget build(BuildContext context) {
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
            viewHintText: 'Suche nach Pilzen ...',
            viewOnSubmitted:(String title){
              changeMarkerColor(title, Colors.green);
            },
            headerHintStyle: const TextStyle(color: Colors.grey),
            isFullScreen: false,
            builder: (BuildContext context, SearchController controller) {
              return SearchBar(
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
                //leading: const Icon(
                //  Icons.search,
                //  color: Colors.black, // Make the search icon black
                //),
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
                      changeMarkerColor(controller.value.text,Colors.black);
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
               ? titles /// Wenn die Suchleiste leer ist, werden alle PointData-Objekte angezeigt
              : titles.where((title) => title.toLowerCase().contains(text)).toList();

              if (suggestionList.isEmpty) {
                return [
                  ListTile(
                    title: const Center(
                      child: Text(
                        'Bisher keine Pilze markiert',
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
                    titleTextStyle: const TextStyle(color: Colors.black, fontSize: 19),
                    onTap: () {
                    setState(() {
                        controller.closeView(title);
                        FocusScope.of(context).unfocus();
                       });
                    changeMarkerColor(title, Colors.green);
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