class Point {
  float x, y;
  int a, b;
  // a is the state of the previous segment
  // b is the state of the next segment

  // States:
    // 0 == Regular line
    // 1 == Boost Line
    // 2 == Broken Line

  Point(PVector point) {
    x = point.x;
    y = point.y;
    a = 0;
    b = 0;
  }

  Point(PVector point, int both) {
    x = point.x;
    y = point.y;
    a = both;
    b = both;
  }

  Point(PVector point, int first, int last) {
    x = point.x;
    y = point.y;
    a = first;
    b = last;
  }

  boolean equals(Point o) {
    if (x == o.x && y == o.y && a==o.a && b==o.b)
      return true;
    else
      return false;
  }
}
