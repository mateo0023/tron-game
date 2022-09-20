ArrayList<Player> players = new ArrayList<Player>();

int DEFAULT_AMMOUNT = 2;

int initial_players = 0;

PVector winSize;

PShape grid;

int[][] PLAYERS_CTRLS = {
  {'W', 'A', 'S', 'D', 'E'}, 
  {'I', 'J', 'K', 'L', 'O'}, 
  {UP, LEFT, DOWN, RIGHT, '/'}
};

color[] PLAYERS_CLRS = {#FF0000, #1010F8, #10FF4F};

boolean game_live = false;

void setup() {
  size(900, 900);//, P2D);
  frameRate(60);
  surface.setResizable(true);
  winSize = new PVector(width, height);
  
  updateGrid();
}

void draw() {
  if (game_live) {
    for (int i=0; i < players.size(); i++) {
      Player p = players.get(i);
      p.move();
    }

    for (int i=0; i < players.size(); i++) {
      Player p = players.get(i);
      p.crashedOnto(players);
    } 

    for (int i=players.size()-1; i >= 0; i--) {
      Player p = players.get(i);
      if (! p.alive) {
        players.remove(i);
      }
    }

    if ((players.size() < 2 && initial_players != 1) || players.size() == 0) {
      game_live = false;
    }
  }

  if (game_live) {
    if (! winSize.equals(new PVector(width, height))){
      winSize = new PVector(width, height);
      updateGrid();
    }
    background(0);
    shape(grid, 0, 0);
    for (int i=0; i < players.size(); i++) {
      Player p = players.get(i);
      p.display();
    }
  } else if (players.size() == 1 && initial_players != 1) {
    fill(0);
    background(255);
    textSize(50);
    textAlign(CENTER);
    text("Game Over", width/2, height/2);

    Player p = players.get(0);

    textSize(40);
    text("Player " + str(p.id) + " won!", width/2, height/2 + 45);
  }

  if (! game_live) {
    if (players.size() !=1)
      background(255);

    fill(0);
    textSize(40);
    textAlign(LEFT);
    text("Click 1, 2 or 3 to choose the ammount of players.", 10, height/5);
    textSize(30);

    ellipseMode(CORNERS);
    strokeWeight(0);

    for (int i=0; i< 3; i++) {
      fill(PLAYERS_CLRS[i]);
      ellipse(10, height/5 + 40 * (i+1), 10 + 20, height/5 + 40  * (i+1) - 20);

      String tmp = "Player " + str(i+1) + " Controls: ";

      if (PLAYERS_CTRLS[i] != PLAYERS_CTRLS[2]) {
        for (int iter=0; iter<PLAYERS_CTRLS[i].length-1; iter++) {
          tmp+= char(int(PLAYERS_CTRLS[i][iter]));
        }
        tmp += " - Boost: \"" + char(PLAYERS_CTRLS[i][4]) + "\"";
      } else {
        tmp+= "Arrows - Boost: \"" + char(PLAYERS_CTRLS[2][4]) + "\"";
      }

      fill(0);
      text(tmp, 40, height/5 + 40 * (i+1));
    }
  }
}

void keyPressed() {
  for (int i=0; i < players.size(); i++) {
    Player p = players.get(i);
    if (keyCode == p.ctrl_boost)
      p.setBoost(true);
    else
      p.turn(keyCode);
  }
  if ( ! game_live) {
    if (key == '\n') {
      startGame(DEFAULT_AMMOUNT);
    } else if (key == '1' || key == '2' || key == '3') {
      startGame(keyCode - int('1') + 1);
    }
  }
}

void keyReleased() {
  for (int i=0; i < players.size(); i++) {
    Player p = players.get(i);
    if (keyCode == p.ctrl_boost)
      p.setBoost(false, true);
  }
}

void mousePressed() {
  if (!game_live)
    startGame(DEFAULT_AMMOUNT);
}

void startGame(int ammount) {
  initial_players = ammount;

  players = new ArrayList<Player>();

  for (int i=0; i < ammount; i++) {
    players.add(new Player(width * (i+1) / (ammount+1), height/2, i+1, PLAYERS_CLRS[i], PLAYERS_CTRLS[i]));
  }
  game_live = true;
}

void updateGrid() {
  grid = createShape();
  grid.beginShape();
  grid.noFill();
  grid.strokeWeight(1.75 / (1.0 + exp(-0.001*(dist(0, 0, width, height) - 1000.0))));
  grid.stroke(250, 100);
  
  float big = (width > height) ? width : height;
  
  float px = big / 40;

  for (int x=0; x < big; x+=px) {
    grid.vertex(x, 0);
    grid.vertex(x, height);
    grid.vertex(x, 0);
  }
  for (int y=0; y < big; y+=px) {
    grid.vertex(0, y);
    grid.vertex(width, y);
    grid.vertex(0, y);
  }
  grid.endShape(CLOSE);
}
