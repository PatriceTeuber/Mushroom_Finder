import 'package:flutter/material.dart';
import 'markerdata/markerdata.dart';

class Appbar extends StatefulWidget implements PreferredSizeWidget {
  final List<MarkerData> Function() getCustomMarker;
  final void Function(String target_title, Color c) changeMarkerColor;

  Appbar({required this.getCustomMarker, required this.changeMarkerColor});

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
  @override
  State<Appbar> createState() => _AppbarState(getCustomMarker:getCustomMarker,changeMarkerColor:changeMarkerColor);
}

class _AppbarState extends State<Appbar> {
  final List<MarkerData> Function() getCustomMarker;
  final void Function(String target_title, Color c) changeMarkerColor;

  _AppbarState({required this.getCustomMarker,required this.changeMarkerColor});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      centerTitle: true,
      backgroundColor: Colors.transparent,
      shadowColor: Colors.transparent,
      title: Container(
        width: MediaQuery.of(context).size.width * 0.90,
        height: 60,
        child:SearchAnchor(
            viewConstraints: BoxConstraints(
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
              final List<MarkerData> data = getCustomMarker();
              final List<String> titles = data.map((markerData) => markerData.title).toSet().toList();
              final String text = controller.value.text.toLowerCase();

              final List<String> suggestionList = text.isEmpty
               ? titles // Wenn die Suchleiste leer ist, werden alle MarkerData-Objekte angezeigt
              : titles.where((title) => title.toLowerCase().contains(text)).toList();

              if (suggestionList.isEmpty) {
                return [
                  ListTile(
                    title: Center(
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