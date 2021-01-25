#ifndef GRAPHICSH_H
#define GRAPHICSH_H

extern "C" {
  unsigned char getVideoMode();

  void setVideoMode(unsigned char mode);

  void clearScreen(unsigned char color);

  void drawHLine(int x, int y, int len, unsigned char color);

  void drawVLine(int x, int y, int len, unsigned char color);

  void drawBox(int x1, int y1, int x2, int y2, unsigned char color);

  void drawFilledBox(int x1, int y1, int x2, int y2, unsigned char color);

  void setColor(unsigned char color, unsigned char red,
		unsigned char green, unsigned char blue);

  void getColor(unsigned char color, unsigned char *red,
		unsigned char *green, unsigned char *blue);

  void saveBlock(int x, int y, int width, int height, char *buffer);

  void setBlock(int x, int y, int width, int height, char *buffer);

  void setTransBlock(int x, int y, int width, int height, char *buffer,
		     unsigned char color);

  signed int checkxdirection(int xa, int xb, int currentx);
  signed int checkydirection(int ya, int yb, int currenty);
  void checkbrickcollision(int xleft, int ytop, int xright, int ybottom, int *xincrement, int *yincrement, int xinc, int yinc);
  int GameOverStatus(int paddlex, int paddley, int ballx, int bally, int *xinc_ptr, int *yinc_ptr);
  void ReDrawScreen();
  int checkmouseposition();
  void resetmouse();

}

#endif  // MODE13H_H
