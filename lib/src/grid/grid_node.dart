part of pathfinding_grid;

/// A node within a [NavigationGrid]. It contains an [x,y] coordinate
class NavigationGridNode extends NavigationNode {
  int x, y;

  NavigationGridNode([this.x = 0, this.y = 0]);

  String toString() => "[$x, $y]";
}