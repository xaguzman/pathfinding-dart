import 'dart:html';
import "package:pathfinding_dart/pathfinding_grid.dart";

import "path_finder_showcase.dart";


void main() async {
  var canvas1 = querySelector("#canvas1");
  var canvas2 = querySelector("#canvas2");
  var canvas3 = querySelector("#canvas3");
  new PathFinderShowcase(canvas1, new AStarGridFinder()).run();
  new PathFinderShowcase(canvas2, new ThetaStarGridFinder()).run();
  // new PathFinderShowcase(canvas3, new JumpPointFinder()).run();
}

