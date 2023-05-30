import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: "モンテカルロ・シミュレーション"),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final int N = 20;
  int count = 0;
  int changeCount = 0;
  late List<Cell> cells;
  late Timer timer;

  @override
  void initState() {
    super.initState();
    cells = List.generate(N * N, (index) => Cell(index));
  }

  void updateCellsFromRandom() {
    List<int> indexRandomList = List.generate(N * N, (index) => index);
    for (int index in indexRandomList) {
      Cell cell = cells[index];
      int newAngle = Random().nextInt(360);
      double energy = calcEnergy(cell, newAngle);

      if (energy < cell.energy) {
        setState(() {
          changeCount++;
          cell.angle = newAngle;
          cell.energy = energy;
        });
      }
    }
    setState(() {
      count++;
    });
  }

  void updateCellsFromIndex() {
    for (Cell cell in cells) {
      int newAngle = Random().nextInt(360);
      double energy = calcEnergy(cell, newAngle);

      if (energy < cell.energy) {
        setState(() {
          cell.angle = newAngle;
          cell.energy = energy;
        });
      }
    }
    setState(() {
      count++;
    });
  }

  void resetCells() {
    setState(() {
      cells = List.generate(N * N, (index) => Cell(index));
    });
  }

  double calcEnergy(Cell cell, int angle) {
    double energy = 0;

    // top
    if (cell.index - N >= 0) {
      energy -= cos((angle - cells[cell.index - N].angle) * pi / 180);
    }
    // bottom
    if (cell.index + N < N * N) {
      energy -= cos((angle - cells[cell.index + N].angle) * pi / 180);
    }

    // left
    if (cell.index % N != 0) {
      energy -= cos((angle - cells[cell.index - 1].angle) * pi / 180);
    }

    // right
    if (cell.index % N != N - 1) {
      energy -= cos((angle - cells[cell.index + 1].angle) * pi / 180);
    }

    return energy;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          // mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Padding(padding: EdgeInsets.all(20)),
            Text("N = $N"),
            Text("交換回数：$changeCount回"),
            const Padding(padding: EdgeInsets.all(20)),
            for (int i = 0; i < N; i++)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (int j = 0; j < N; j++)
                    Transform.rotate(
                      angle: cells[i * N + j].angle * pi / 180,
                      child: const Icon(Icons.arrow_forward),
                    ),
                ],
              )
          ],
        ),
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: () {
              timer.cancel();
            },
            child: const Icon(Icons.stop),
          ),
          FloatingActionButton(
            onPressed: () {
              setState(() {
                timer =
                    Timer.periodic(const Duration(milliseconds: 100), (timer) {
                  updateCellsFromRandom();
                });
              });
            },
            child: const Icon(Icons.play_arrow),
          ),
          FloatingActionButton(
            onPressed: () {
              timer.cancel();
              resetCells();
              changeCount = 0;
            },
            child: const Icon(Icons.change_circle_outlined),
          ),
        ],
      ),
    );
  }
}

class Cell {
  int index;
  int angle = Random().nextInt(360);
  double energy = 0;

  Cell(this.index);
}
