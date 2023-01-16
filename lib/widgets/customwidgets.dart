import 'package:flutter/material.dart';

class CustomBottomNavigationBar extends StatefulWidget {
  final dynamic onSelect;
  const CustomBottomNavigationBar({super.key, this.onSelect});

  @override
  State<CustomBottomNavigationBar> createState() =>
      _CustomBottomNavigationBarState();
}

class _CustomBottomNavigationBarState extends State<CustomBottomNavigationBar> {
  int _cuurentIndex = 0;
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsetsDirectional.all(5.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
        gradient: const LinearGradient(
          colors: [
            Color.fromARGB(255, 8, 107, 102),
            Color.fromARGB(255, 26, 218, 154)
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: BottomNavigationBar(
        onTap: (index) {
          setState(() {
            _cuurentIndex = index;
          });
          widget.onSelect(index);
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.transparent,
        currentIndex: _cuurentIndex,
        showUnselectedLabels: true,
        elevation: 0.0,
        unselectedItemColor: const Color.fromARGB(255, 5, 37, 32),
        selectedItemColor: Colors.white,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "home",
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.sports_soccer), label: "matches"),
          BottomNavigationBarItem(icon: Icon(Icons.star), label: "leagues"),
          BottomNavigationBarItem(
              icon: Icon(Icons.line_style), label: "linesup"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "account"),
        ],
      ),
    );
  }
}

dynamic CustomAppBar({required context,required league}) {
  return AppBar(
    leading: Padding(
      padding: const EdgeInsets.all(8.0),
      child: Image.network(league["logo"]),
    ),
    actions: [IconButton(onPressed: (){Navigator.pop(context);}, icon: const Icon(Icons.close))],
    backgroundColor: const Color.fromARGB(255, 8, 107, 102),
    automaticallyImplyLeading: false,
    title:  Text(league["name"]),
    centerTitle: true,
    bottom: const TabBar(
      labelPadding: EdgeInsets.all(10.0),
      indicatorColor: Colors.white,
      tabs: [
        Text(
          "standings",
          style: TextStyle(fontSize: 20.0),
        ),
        Text(
          "matches",
          style: TextStyle(fontSize: 20.0),
        ),
        Text(
          "top scorers",
          style: TextStyle(fontSize: 20.0),
        ),
      ],
    ),
  );
}

class NotAvailable extends StatelessWidget {
  const NotAvailable({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Icon(
              Icons.emoji_emotions_outlined,
              size: 60.0,
              color: Colors.grey,
            ),
          ),
          Text(
            "this futuer is not available",
            style: TextStyle(color: Colors.grey, fontSize: 22.0),
          ),
        ],
      ),
    );
  }
}

class ErrorMsg extends StatelessWidget {
  const ErrorMsg({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Icon(
              Icons.error_outline,
              size: 60.0,
              color: Colors.grey,
            ),
          ),
          Text(
            "Oops somthing is wrong",
            style: TextStyle(color: Colors.grey, fontSize: 22.0),
          ),
        ],
      ),
    );
  }
}
