#include <stdlib.h>
#include <conio.h>
#include <stdio.h>
#include <dos.h>

#include "breakout.h"

#define SCRN_WIDTH 320
#define SCRN_HEIGHT 200

struct Color {
  unsigned char red;
  unsigned char green;
  unsigned char blue;
};

struct Increment {
  signed int xtest;
  signed int ytest;
  signed int xinc;
  signed int yinc;
  signed int mousex_ptr;
};

int
main(int argc, char *argv[]) {

  char c;
  printf("                      BreakOut\n");
  printf("                       v.1.00\n");
  printf("                    by Ronnie Tam\n");
  printf("  Get READY.  Game will start IMMEDIATELY after keypress.\n\n");
  printf("              Paddle is controlled by the mouse.\n");
  printf("                  Press Any Key To Continue...");
  unsigned char old_mode = getVideoMode();
  getch();
  srand(1);  // Initialize random number generator to known value.
  setVideoMode(0x13);

  clearScreen(0);

    int x1 = 320/2 - 105;
    int x2 = x1 + 30;
    int y1 = 200/2 - 20;
    int y2 = y1 + 10;
  int i;
  for (i = 0; i < 28; i++) {
    x1 += 31;
    x2 += 31;
    //x1 += 62;
    //x2 += 62;
    if (i % 7 == 0) {
        y1 += 10;
        y2 += 10;
        x1 = 320/2 - 105;
        x2 = (320/2 - 105) + 30;
    }
    int color = random(255) + 1;
    drawFilledBox(x1, y1, x2, y2, color);
  }
/*
    int x1 = 20;
    int x2 = 50;
    int y1 = 20;
    int y2 = 30;
  int i;
  for (i = 0; i < 5; i++) {
    x1 += 30;
    y1 += 10;
    x2 += 30;
    y2 += 10;
    int color = random(255) + 1;
    drawFilledBox(x1, y1, x2, y2, color);
  }
*/

  //c = getch();  // Wait for key press.

  // Now for some sprite animation.

  int x = 160;
  int y = 20;

  int width = 8;
  int height = 8;

  char buffer[8 * 8];  // To save the background.

  char sprite[8 * 8] = { 0, 0, 1, 1, 1, 1, 0, 0,
                         0, 1, 1, 1, 1, 1, 1, 0,
                         1, 1, 1, 1, 1, 1, 1, 1,
                         1, 1, 1, 1, 1, 1, 1, 1,
                         1, 1, 1, 1, 1, 1, 1, 1,
                         1, 1, 1, 1, 1, 1, 1, 1,
                         0, 1, 1, 1, 1, 1, 1, 0,
                         0, 0, 1, 1, 1, 1, 0, 0 };
  char paddle[5 * 40] = { 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0,
                          0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0,
                          1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
                          0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0,
                          0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, };
  char pbuffer[5 * 40];
  Increment increments;
  increments.xinc = 1;
  increments.yinc = -2;
  increments.mousex_ptr = 0;
  int mousex;
  mousex = 0;
  int vector[2];
  int x2b;
  int y2b;
  int GameOver = 0;
 resetmouse(); 
    while(GameOver == 0) {    
            saveBlock(x, y, width, height, buffer);  // Save background.
            saveBlock(mousex, 195, 40, 5, pbuffer);
            setTransBlock(x, y, width, height, sprite, 0);  // Draw sprite.
            setTransBlock(mousex, 195, 40, 5, paddle, 0);
            delay(20);  // Pause while sprite is visible.
            ReDrawScreen();        
            setBlock(x, y, width, height, buffer);  // Restore background.
            setBlock(mousex, 195, 40, 5, pbuffer);
            x2b = x+8;
            y2b = y+8;    
            increments.xtest = increments.xinc;
            increments.ytest = increments.yinc;
            increments.xtest = checkxdirection(x, x2b, increments.xtest);
            increments.ytest = checkydirection(y, y2b, increments.ytest);
            GameOver = GameOverStatus(mousex, 195, x, y, &increments.xtest, &increments.ytest);
            checkbrickcollision(x, y, x2b, y2b, &increments.xtest, &increments.ytest, increments.xtest, increments.ytest);
            increments.xinc = increments.xtest;
            increments.yinc = increments.ytest;    
            mousex = checkmouseposition();
            x += increments.xinc;  
            y += increments.yinc;    
            mousex /= 2;           
  }
  
  setVideoMode(old_mode);

  if(GameOver == 1) {
          printf("      Nice try, the ball missed paddle. You lose.\n");
          printf("                 Thanks For Playing. . .\n");
          printf("                      BreakOut\n");
          printf("                        v.1.00\n");
          printf("                    by Ronnie Tam\n");
          printf("                Press Any Key To Return to DOS...");
  } else {
          printf("    Congratulations, you cleared the bricks. You win.\n");
          printf("                 Thanks For Playing. . .\n");
          printf("                      BreakOut\n");
          printf("                        v.1.00\n");
          printf("                    by Ronnie Tam\n");
          printf("                Press Any Key To Return to DOS...");
  }
          c = getch();  // Wait for key press.


  return 0;
}
