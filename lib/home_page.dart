import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rive/rive.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  List<SMIInput<bool>?> inputs = [];
  List<Artboard> artboards = [];
  List<String> assetPaths = [
    "assets/composer.riv",
    "assets/fire.riv",
    "assets/land.riv",
    "assets/mediation.riv",
    "assets/profile.riv",
  ];

  int currentActiveIndex = 0;

  initializeArtboard() async {
    for (var path in assetPaths) {
      final data = await rootBundle.load(path);

      final file = RiveFile.import(data);
      final artboard = file.mainArtboard;
      SMIInput<bool>? input;

      final controller =
          StateMachineController.fromArtboard(artboard, "State Machine 1");
      if (controller != null) {
        artboard.addController(controller);
        input = controller.findInput<bool>("status");
        input!.value = true;
      }
      inputs.add(input);
      artboards.add(artboard);
    }
  }

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    await initializeArtboard();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: artboards.map((artboard) {
            final index = artboards.indexOf(artboard);
            return Expanded(
              child: BottomAppBarItem(
                  artboard: artboard,
                  currentIndex: currentActiveIndex,
                  tabIndex: index,
                  input: inputs[index],
                  onpress: () {
                    setState(() {
                      currentActiveIndex = index;
                    });
                  }),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class BottomAppBarItem extends StatelessWidget {
  const BottomAppBarItem({
    super.key,
    required this.artboard,
    required this.onpress,
    required this.currentIndex,
    required this.tabIndex,
    this.input,
  });

  final Artboard? artboard;
  final VoidCallback onpress;
  final int currentIndex;
  final int tabIndex;
  final SMIInput<bool>? input;

  @override
  Widget build(BuildContext context) {
    if (input != null) {
      input!.value = currentIndex == tabIndex;
    }
    return SizedBox(
      width: 100,
      height: 100,
      child: GestureDetector(
        onTap: onpress,
        child: artboard == null ? const SizedBox() : Rive(artboard: artboard!),
      ),
    );
  }
}
