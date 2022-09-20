class Player {
  PVector head;
  ArrayList<Point> turns;

  float MAX_BOOST = 100;
  float BOOST_RATE = 2.5;
  
  float head_rad = 10.0 / (1.0 + exp(-0.001*(dist(0, 0, width, height) - 1000.0))) + 4;
  float head_pm = head_rad / 4.5;
  
  float stroke = head_rad / 3.5;

  float speed = dist(0, 0, width, height) / (frameRate * 3.5) ; // It takes 3.5 seconds to move across the screen
  float heading = DOWN;
  color bike_color = #FF0000;
  boolean alive = true;

  float boost_level = 100;

  boolean boosting = false;
  boolean boost_lock = false;

  int id;

  int ctrl_up = UP;
  int ctrl_down = DOWN;
  int ctrl_right = RIGHT;
  int ctrl_left = LEFT;
  int ctrl_boost = '/';

  Player(int x, int y, int player_id, color c, int[] ctrls) {
    head = new PVector(x, y);
    turns = new ArrayList<Point>();
    turns.add(new Point(head));

    bike_color = c;
    id = player_id;

    setControls(ctrls);
  }

  void setControls(int u, int l, int d, int r, int b) {
    ctrl_up = u;
    ctrl_down = d;
    ctrl_right = r;
    ctrl_left = l;
    ctrl_boost = b;
  }

  void setControls(int[] uldrb) {
    ctrl_up = uldrb[0];
    ctrl_left = uldrb[1];
    ctrl_down = uldrb[2];
    ctrl_right = uldrb[3];
    ctrl_boost = uldrb[4];
  }

  void move() {
    if (boosting) {
      boost_level -= MAX_BOOST * 2 / frameRate; // Takes 1/2 seconds to empty the boost
      if (boost_level <= 0)
        setBoost(false);

      if (heading == UP)
        head.y -= speed * BOOST_RATE;
      else if (heading == DOWN)
        head.y += speed * BOOST_RATE;
      else if (heading == RIGHT)
        head.x += speed * BOOST_RATE;
      else if (heading == LEFT)
        head.x -= speed * BOOST_RATE;
    } else {
      boost_level += MAX_BOOST / (frameRate * 3); // Takes 3 seconds for refil
      if(++boost_level > MAX_BOOST)
        boost_level = MAX_BOOST;

      if (heading == UP)
        head.y -= speed;
      else if (heading == DOWN)
        head.y += speed;
      else if (heading == RIGHT)
        head.x += speed;
      else if (heading == LEFT)
        head.x -= speed;
    }
  }

  void display() {
    stroke(bike_color);

    for (int i=1; i < turns.size(); i++) {
      Point prev = turns.get(i-1);
      Point curr = turns.get(i);

      if (prev.b == 1 && curr.a == 1) {
        strokeWeight(stroke);
        line(prev.x, prev.y, curr.x, curr.y);
      } else if (prev.b == 0 && curr.a == 0) {
        strokeWeight(stroke*2);
        line(prev.x, prev.y, curr.x, curr.y);
      }
    }


    Point prev = turns.get(turns.size()-1);

    if (boosting) {
      strokeWeight(stroke);
      if(heading == UP)
        line(prev.x, prev.y, head.x, head.y - head_rad - head_pm);
      else if(heading == DOWN)
        line(prev.x, prev.y, head.x, head.y + head_rad + head_pm);
      else if(heading == LEFT)
        line(prev.x, prev.y, head.x + head_rad + head_pm, head.y);
      else if(heading == RIGHT)
        line(prev.x, prev.y, head.x - head_rad - head_pm, head.y);
    } else {
      strokeWeight(stroke*2);
      if(heading == UP)
        line(prev.x, prev.y, head.x, head.y + head_rad);
      else if(heading == DOWN)
        line(prev.x, prev.y, head.x, head.y - head_rad);
      else if(heading == LEFT)
        line(prev.x, prev.y, head.x + head_rad, head.y);
      else if(heading == RIGHT)
        line(prev.x, prev.y, head.x - head_rad, head.y);
    }
    
    fill(color(bike_color, int(map(boost_level, 0, MAX_BOOST, 100, 255))));
    ellipseMode(CENTER);
    ellipseMode(RADIUS);
    if (boosting){
      if (heading == UP || heading == DOWN)
        ellipse(head.x, head.y, head_rad - head_pm, head_rad + head_pm);
      else
        ellipse(head.x, head.y, head_rad + head_pm, head_rad - head_pm);
    } else {
      ellipse(head.x, head.y, head_rad, head_rad);
    }
    
    strokeCap(ROUND);
    rect(10 * id + 30 * (id-1), 10, 30, boost_level);
  }

  void setBoost(boolean state) {
    if (!boost_lock && state && boost_level > 0 && ! boosting && boost_level/MAX_BOOST >= 0.25) {
      boosting = true;
      boost_lock = true;
      turns.add(new Point(head, 0, 1));
    } else if ( !state && boosting) {
      boosting = false;
      turns.add(new Point(head, 1, 0));
    }
  }
  
  void setBoost(boolean state, boolean unlock) {
    if (!boost_lock && state && boost_level > 0 && ! boosting) {
      boosting = true;
      boost_lock = true;
      turns.add(new Point(head, 0, 1));
    } else if ( !state && boosting) {
      boosting = false;
      turns.add(new Point(head, 1, 0));
    }
    
    if(unlock)
      boost_lock = false;
    else
      boost_lock = true;
  }

  void turn(int dir) {
    int z = (boosting) ? 1 : 0;

    if (dir == ctrl_up && heading != DOWN) {
      heading = UP;
      turns.add(new Point(head, z) );
    } else if (dir == ctrl_down && heading != UP) {
      heading = DOWN;
      turns.add(new Point(head, z) );
    } else if (dir == ctrl_right && heading != LEFT) {
      heading = RIGHT;
      turns.add(new Point(head, z) );
    } else if (dir == ctrl_left && heading != RIGHT) {
      heading = LEFT;
      turns.add(new Point(head, z) );
    }
  }

  void breakSection(int i, int f) {
    Point prev = turns.get(i);
    Point curr = turns.get(f);
    
    if (prev.b == 1 && curr.a == 1) {
      prev.b = 2;
      curr.a = 2;
    }
  }

  boolean isSame(Player other) {
    if (id == other.id && turns.equals(other.turns) && head.equals(other.head)) {
      return true;
    } else {
      return false;
    }
  }

  boolean crashed(Point prev, Point cur) {
    Point my_pre = turns.get(turns.size()-1);
    if (heading == RIGHT || heading == LEFT) {
      if (prev.x == cur.x) {
        if (((head.x >= prev.x && my_pre.x < prev.x) || (head.x <= prev.x && my_pre.x > prev.x)) &&
          ((head.y > prev.y && head.y < cur.y) || ((head.y < prev.y && head.y > cur.y)))) {
          return true;
        }
      }
    } else if (heading == UP || heading == DOWN) {
      if (prev.y == cur.y) {
        if (((head.y >= prev.y && my_pre.y < prev.y) || (head.y <= prev.y && my_pre.y > prev.y)) && 
          ((head.x > prev.x && head.x < cur.x) || ((head.x < prev.x && head.x > cur.x)))) {
          return true;
        }
      }
    }
    return false;
  }

  boolean crashedOnto(Player other) {
    for (int i=1; i < other.turns.size(); i++) {
      Point prev = other.turns.get(i-1);
      Point curr = other.turns.get(i);

      if (crashed(prev, curr)) {
        if (prev.b == 1 && curr.a == 1 && boosting) {
          other.breakSection(i-1, i);
          boost_level = 0;
          setBoost(false);
        } else if (!(prev.b == 2 && curr.a == 2)) {
          alive = false;
          return true;
        }
      }
    }


    if (! isSame(other)) {
      Point prev = other.turns.get(other.turns.size()-1);
      Point cur = new Point(other.head);

      if (crashed(prev, cur) && !(boosting && other.boosting)) {
        alive = false;
        return true;
      }
    } else if (head.x <= 0 || head.x >= width || head.y <= 0 || head.y >= height) {
      alive = false;
      return true;
    }
    return false;
  }

  boolean crashedOnto(Player[] others) {
    for (Player other : others) {
      if (crashedOnto(other))
        return true;
    }
    return false;
  }

  boolean crashedOnto(ArrayList<Player> others) {
    for (int i=0; i < others.size(); i++) {
      if (crashedOnto(others.get(i)))
        return true;
    }
    return false;
  }
}
