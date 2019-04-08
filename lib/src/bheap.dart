part of pathfinding;

abstract class BHeapNode {
	int index;
}

class BHeap<T extends BHeapNode> {
	
	int size = 0;

	List<BHeapNode> nodes;
	Comparator<T> comparator;

	BHeap (Comparator<T> comparator, { int capacity = 10 }) {
		nodes = new List<BHeapNode>()..length = capacity;
		this.comparator = comparator;
	}

	T add (T node) {
		// Expand if necessary.
		if (size == nodes.length) {
			// List<BHeapNode> newNodes =  new List<BHeapNode>(size << 1);
			// System.arraycopy(nodes, 0, newNodes, 0, size);
			// nodes = newNodes;
      nodes.length = size << 1;
		}
		// Insert at end and bubble up.
		node.index = size;
		nodes[size] = node;
		_up(size++);
		return node;
	}

	T peek () {
		if (size == 0) throw new IndexError(size, "The heap is empty.");
		return nodes[0];
	}

	T pop () {
		List<BHeapNode> nodes = this.nodes;
		BHeapNode popped = nodes[0];
		nodes[0] = nodes[--size];
		nodes[size] = null;
		if (size > 0) _down(0);
		return popped;
	}
	
	void clear () {
		for (int i = 0, n = size; i < n; i++)
			nodes[i] = null;
		size = 0;
	}
	
	void updateNode(T node, double valueComparison){
		int i = node.index;
		if (valueComparison < 0)
			_up(i);
		else
			_down(i);
	}

	void _up (int index) {
		List<BHeapNode> nodes = this.nodes;
		BHeapNode node = nodes[index];
		//float value = node.f;
		while (index > 0) {
			int parentIndex = (index - 1) >> 1;
			BHeapNode parent = nodes[parentIndex];
      if ( comparator(node, parent) < 0){       
			// if (comparator.compare( (T) node, (T) parent) < 0){
				nodes[index] = parent;
				parent.index = index;
				index = parentIndex;
			} else
				break;
		}
		nodes[index] = node;
		node.index = index;
	}

	void _down (int index) {
		List<BHeapNode> nodes = this.nodes;
		int size = this.size;

		BHeapNode node = nodes[index];
		//float value = node.getValue();

		while (true) {
			int leftIndex = 1 + (index << 1);
			if (leftIndex >= size) break;
			int rightIndex = leftIndex + 1;

			// Always have a left child.
			BHeapNode leftNode = nodes[leftIndex];
			//float leftValue = leftNode.getValue();

			// May have a right child.
			BHeapNode rightNode;
			//float rightValue;
			if (rightIndex >= size) {
				rightNode = null;
				//rightValue = isMaxHeap ? Float.MIN_VALUE : Float.MAX_VALUE;
				//rightValue = Float.MAX_VALUE;
			} else {
				rightNode = nodes[rightIndex];
				//rightValue = rightNode.getValue();
			}

			// The smallest of the three values is the parent.
      if (comparator(leftNode, rightNode) < 0){
			// if (comparator.compare( (T)leftNode, (T)rightNode) < 0){
				if (leftNode == null || comparator(leftNode, node) > 0) break;
				nodes[index] = leftNode;
				leftNode.index = index;
				index = leftIndex;
			} else {
				//if (rightValue == value || (rightValue > value ^ isMaxHeap)) break;
				if (rightNode == null || comparator( rightNode, node) > 0) break;
				nodes[index] = rightNode;
				rightNode.index = index;
				index = rightIndex;
			}
		}

		nodes[index] = node;
		node.index = index;
	}

	String toString () {
		if (size == 0) return "[]";
    var nodesStr = nodes.join(", ");
    return "[$nodesStr]";
	}
}