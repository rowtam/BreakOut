README.TXT
Ronnie Tam
CS306 Final Project
12/10/99
BreakOut/BlockOut (Initially, I thought this game was called Pong)

Features:
-Double buffered graphics
        Double buffering is a technique where you wait until
        the CRT gun is at the bottom of the screen.  During the
        period when the CRT gun is moving back to the top (and
        thus not writing to the screen), you update the video
        memory.
-Mouse controlled paddle
-Computer speaker beeps on impacts that differ from wall hits
 and brick hits.

  This is the readme for this game.  I hope you're having
  fun playing this game.  It is highly addictive and highly
  extendable for limitless hours of fun.  After the game was
  completed, I played this for 4 hours straight with 4 different
  levels.  It was really fun, so don't get addicted.

  By simply modifying the C-code, you can get a limitless number of
  brick configurations.  Thus making the game more fun.

  This game follows the specifications which I wrote in my proposal
  and preliminary progress report.

  In addition, this game adheres very strictly to the rules of the game
  breakout.

  Here are the specs:

  * The ball deflects off all walls and bricks assuming the environment
  in which it exists is a vacuum and that there is 100% conservation of
  momentum.

  * As in a typical game of breakout or pong, the user maintains
  full control of the angle at which the ball is deflected off the paddle.
  How?  To deflect the ball further to the left, simply make sure that
  the ball impacts the left of the paddle.  A hit directly in the middle
  will cause the ball to go straight up and a hit on the right will cause
  a deflection further to the right.  Although you could have 40 different 
  angles moving from 0 to 360 degrees for impacts respectively from pixel 0
  to pixel 40 of the paddle, most games of breakout have 4 discrete angles.
  I have decided to use 5 discrete angles off of the paddle.

  * Note that the laws of conservation of momentum do not apply when
  the ball hits the paddle.  Why?  Because if the ball were allowed
  to deflect at an angle off the paddle conforming to the laws of
  momentum , the game would get boring since every game would have
  the same ball movement regardless of paddle movement.  Thus after
  playing several times, the user would be able to anticipate the ball
  movements, thus defeating the purpose of the game.

  However, if the ball hits the wall at 45 degrees, it should deflect
  at 135 degrees.

  * The point of the game is to destroy all the bricks and make sure
  the ball never touches the ground (bottom of the screen)

The Internal Structure of the Game

  THE BRICKS

  The bricks are placed on the screen using a modified "draw_filled_box"
  assembly routine.  Inside the modified routine, I call a procedure
  that places the X,Y coordinate in two different arrays.  I also keep
  a third array that keeps track of whether the brick has been hit.  As
  bricks are hit, the respective bits are set in the third array.  Thus
  we know to ignore those that have been hit.

  THE PADDLE

  The paddle is placed on the screen using setBlock.  A checkmouseposition
  assembly routine is used to keep track of where the paddle moves.
  Another routine, named GameOverStatus checks to see if the "hitbottom"
  flag is set and if so, it checks for impact with the paddle.  In addition,
  if the paddle is hit, then the ball deflection angle is modified with
  respect to where the paddle was impacted (as explained in the specs
  above).

  THE DEFLECTION

  When the ball hits the wall, it is deflected at 180-incident angle, thus
  complying with the laws of conservation of momentum.
  The algorithm:
        IF one-more-step in the current direction causes an overlap
                then check for initial x and y overlap,
                IF NO initial x overlap, then DEFLECT X increment
                IF NO initial y overlap, then DEFLECT Y increment

  Note that this algorithm is contrary to what one might think.  Notice
  that we deflect only if there is NO INITIAL overlap, but overlap after
  moving one step.  Thus, if the ball hits the bottom of a brick,
  only the y-increment is deflected, but not the x, since x-overlap already
  existed initially.  One example of an instance where deflection of both
  x and y occur is when the ball hits the corner of a brick.

  The only time the angle should change is when the ball impacts the paddle.

Final Note:
  Breakout has always been one of my favorite games.  I've tried to model
  this game so that the play and ball speed are similar to other Breakout
  type games like DX-Ball.

Thanks for reading,
and thanks for playing.

---------
12/10/99
Author:
Ronnie Tam
Revision 1.0
