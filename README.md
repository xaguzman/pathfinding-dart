[![Build Status](https://travis-ci.org/xaguzman/pathfinding.svg?branch=master)](https://travis-ci.org/xaguzman/pathfinding)

pathfinding-dart - APACHE LICENSE 2.0
==========

A  pathfinding library written in dart, meant to be used for games.
It is generic enough to be used in different kind of graphs (though, right now it only has implementation for grid graphs).

It is a port of my java library [https://github.com/xaguzman/pathfinding]. The java version was used in my old [#1GAM january entry](https://github.com/xaguzman/shiftingislands/ "Shifting Islands Source").

__________

## Intro
The library works on a bunch of interfaces:
* NavigationNode: this basically just represents a node of a graph. contains some getters and setters meant for navigation. Right now, only implementation is GridCell
* NavigationGrap: a group of navigation nodes. Right now, only implementation is NavigationGrid
* PathFinder: the implementation for the pathfinding algorithm, current options are:
	* AStarFinder
	* AStarGridFinder
	* JumpPointFinder
	* ThetaStarFinder
	* ThetaStarGridFinder

Finders are fed with so called PathFinderOptions, which determine how the pathfinding will work (allowing diagonal movement, for example).

## How to use
You need to create a graph.
Be aware that the NavigationGrid class, expects a bidimensional array of GridCell stored as [x][y]

```dart	
//these should be stored as [x][y]
NavigationGridNode[][] nodes = new NavigationGridNode[5][5];
	
//create your cells with whatever data you need
nodes = createNodes();
	
//create a navigation grid with the cells you just created
NavigationGrid<NavigationGridNode> navGrid = new NavigationGrid(nodes);
```

Now, you need a finder which can work on your graph.

```dart
//create a finder either using the default options
AStarGridFinder<NavigationGridNode> finder = new AStarGridFinder();
	
//or create your own pathfinder options:
GridFinderOptions opt = new GridFinderOptions();
opt.allowDiagonal = false;
	
AStarGridFinder<GridCell> finder = new AStarGridFinder.withOptions(opt);
```
Once you have both, a graph and a finder, you can find paths within your graph at any time.

```dart
List<NavigationGridNode> pathToEnd = finder.findPath(0, 0, 4, 3, navGrid);
```
	
That's pretty much all there is to using the library.



