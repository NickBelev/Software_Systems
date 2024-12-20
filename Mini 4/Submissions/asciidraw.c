#include <stdio.h>
#include <string.h>
#include <math.h>
//Nicholas Belev
//nicholas.belev@mail.mcgill.ca
//Faculty of Science - Computer Science
//ASCII DRAW ASSIGNMENT

int main() {
  //initializes rather large arrays to store user input
  char user_command_input[2000];
  char input_copy[2000];
  char command[1000];

  //for drawing use
  int x1, x2, y1, y2, radius;
  //starting value to initialize while loop
  strcpy(command, "somethingthatcanneverbe");

  //set the default pixel symbol
  char pixel_symbol = '*';

  //to be assigned in set grid
  int grid_size_x, grid_size_y;
  //makeshift boolean to check if grid is set
  int grid_set = 0;

  //maximum canvas size with extra dimensions for axes; allows for null termiating character
  char grid_content[1000][1001];

  //runs as long as END hasnt been inputted
  while (strcmp(command, "END") != 0) {

    //gets raw user input line
    fgets(user_command_input, 2000, stdin);
    strcpy(input_copy, user_command_input);

    if (input_copy[0] == '\n') {
      printf("Empty command; try again.\n");
    } 
    
    else {
      //if there is a space, find first argument space delimited
      if (strchr(user_command_input, ' ') != NULL) {
        //not DISPLAY OR END commands
        strcpy(command, strtok(input_copy, " "));
      }
      //if no space, it ends with a /n (END or DISPLAY) so use \n delimiter
      else {
        strcpy(command, strtok(input_copy, "\n"));
      }

      //changes draw character to user input
      if (strcmp(command, "CHAR") == 0) {
        sscanf(strtok(NULL, "\n"), "%c", & pixel_symbol);
      }

      //if setting grid
      else if (strcmp(command, "GRID") == 0) {
        //if grid was already set, don't allow it again
        if (grid_set == 1) {
          printf("GRID was already set to %d,%d.\n", grid_size_x, grid_size_y);
        } else {
          grid_set = 1;

          //read and store dimension x
          sscanf(strtok(NULL, " "), "%04d", & grid_size_x);
          //read and store dimension y
          sscanf(strtok(NULL, "\n"), "%04d", & grid_size_y);

          //assign grid to be filled with spaces
          for (int i = 0; i < grid_size_y; i++) {
            for (int j = 0; j < grid_size_x; j++) {
              if (j == grid_size_x - 1) {
                grid_content[i][j] = '\0'; //null terminated is important!
              } else {
                grid_content[i][j] = ' ';
              }
            }
          }
        }
      }

      //if line
      else if ((strcmp(command, "LINE") == 0) && (grid_set == 1)) {
        //read first argument - x1
        sscanf(user_command_input, "LINE %d,%d %d,%d", & x1, & y1, & x2, & y2);
        //sscanf (strtok (NULL, ","), "%04d", &x1);
        //read second argument - y1
        //sscanf (strtok (NULL, " "), "%04d", &y1);
        //read third argument - x2
        //sscanf (strtok (NULL, ","), "%04d", &x2);
        //read fourth argument - y2
        //sscanf (strtok (NULL, "\n"), "%04d", &y2);

        //draw the two points just cuz why not & takes care of single pixel line case
        if (x1 >= 0 && x1 < grid_size_x && y1 >= 0 && y1 <= grid_size_y) {
          grid_content[y1][x1] = pixel_symbol;
        }
        if (x2 >= 0 && x2 < grid_size_x && y2 >= 0 && y2 <= grid_size_y) {
          grid_content[y2][x2] = pixel_symbol;
        }
        //if vertical line
        if (x1 == x2) {
          //checks which end to start from
          if (y1 >= y2) {
            for (int i = y2; i <= y1; i++) {
              grid_content[i][x1] = pixel_symbol;
            }
          } else {
            for (int i = y1; i <= y2; i++) {
              grid_content[i][x1] = pixel_symbol;
            }
          }
        }
        //if horizontal line
        else if (y1 == y2) {
          if (x1 >= x2) {
            for (int i = x2; i <= x1; i++) {
              grid_content[y1][i] = pixel_symbol;
            }
          } else {
            for (int i = x1; i <= x2; i++) {
              grid_content[y1][i] = pixel_symbol;
            }
          }
        }
        //normal sloped; throwback to middle school :)
        else {
          //figures out leftmost point to start from (so we can only do ++ incrementing)
          int start_x;
          int end_x;
          if (x2 > x1) {
            start_x = x1;
            end_x = x2;
          } else {
            start_x = x2;
            end_x = x1;
          }
          //slope
          float yb = y2, ya = y1, xb = x2, xa = x1, m, b;
          m = ((yb - ya) / (xb - xa));
          //y-intercept rearranged
          b = (ya - (m * xa));

          //saves last y value to know how many lines to print symbols on to catch up to y_now
          float s_x = start_x;
          float y_old = ((m * s_x) + b);
          float y_old_rnd, y_now, y_rnd;
          int y_o_f, y_f;

          //goes through all x between the start and end point, inclusive
          for (int i = start_x; i <= end_x; i++) {
            //rounds last y value to int
            y_old_rnd = rint(y_old);
            y_o_f = (int) y_old_rnd;
            //gets current y value as float and rounds it to int
            float ii = i;
            y_now = ((m * ii) + b);
            y_rnd = rint(y_now);
            y_f = (int) y_rnd;

            //if positive slope, print connected line for each increment upwards with ++
            if (m > 0) {
              for (int j = y_o_f; j <= y_f; j++) {
                if (i >= 0 && i < grid_size_x && j >= 0 && j <= grid_size_y) {
                  grid_content[j][i] = pixel_symbol;
                }
              }
            }
            //if negative slope, prints trail downwards --
            else if (m < 0) {
              for (int j = y_o_f; j >= y_f; j--) {
                if (i >= 0 && i < grid_size_x && j >= 0 && j <= grid_size_y) {
                  grid_content[j][i] = pixel_symbol;
                }
              }
            }

            y_old = y_now;
          }
          //reassigns old y to this run's value
        }
      }

      //if rectangle
      else if ((strcmp(command, "RECTANGLE") == 0) && (grid_set == 1)) {
        //read first argument - x1
        sscanf(strtok(NULL, ","), "%04d", & x1);
        //read second argument - y1
        sscanf(strtok(NULL, " "), "%04d", & y1);
        //read third argument - x2
        sscanf(strtok(NULL, ","), "%04d", & x2);
        //read fourth argument - y2
        sscanf(strtok(NULL, "\n"), "%04d", & y2);

        for (int y = y1; y >= y2; y--) {
          //fills in vertical lines with symbol
          if ((x1 <= grid_size_x - 1) && (y <= grid_size_y - 1)) {
            grid_content[y][x1] = pixel_symbol;
          }
          if ((x2 <= grid_size_x - 1) && (y <= grid_size_y - 1)) {
            grid_content[y][x2] = pixel_symbol;
          }
        }
        for (int x = x1; x <= x2; x++) {
          //fills in horizontal lines with symbol, as long as theyre in bounds of
          if ((x <= grid_size_x - 1) && (y1 <= grid_size_y - 1)) {
            grid_content[y1][x] = pixel_symbol;
          }
          if ((x <= grid_size_x - 1) && (y2 <= grid_size_y - 1)) {
            grid_content[y2][x] = pixel_symbol;
          }
        }
      }

      //if circle
      else if ((strcmp(command, "CIRCLE") == 0) && (grid_set == 1)) {
        //read first argument - x1
        sscanf(strtok(NULL, ","), "%04d", & x1);
        //read second argument - y1
        sscanf(strtok(NULL, " "), "%04d", & y1);
        //read fourth argument - r
        sscanf(strtok(NULL, "\n"), "%04d", & radius);

        static
        const double PI = 3.1415926535;
        double xf1, yf1, angle, o;
	
	//plots 4 required points just to be sure!! I'm paranoid like that.
        if ((y1 + radius >= 0) && (radius + y1 < grid_size_y))
        { 
          grid_content[y1 + radius][x1] = pixel_symbol;
        }
        if ((y1 - radius >= 0) && (y1 - radius < grid_size_y))
        { 
          grid_content[y1 - radius][x1] = pixel_symbol;
        }
        if ((x1 - radius >= 0) && (x1 - radius < grid_size_x))
        {
          grid_content[y1][x1 - radius] = pixel_symbol;
        }
	if ((x1 + radius >= 0) && (x1 + radius < grid_size_x))
        {
          grid_content[y1][x1 + radius] = pixel_symbol;
        }
	
	//accurate up to a 3600 point circle which should be good enough considering
	for (o = 0; o < 360; o += 0.1) {
      	  //determines x and y increments as doubles using trig and angle
          angle = o;
          xf1 = radius * cos(angle * PI / 180);
          yf1 = radius * sin(angle * PI / 180);
	  //rounds to nearest int for nice looking circle
	  int xf = rint(xf1);
	  int yf = rint(yf1);

          if (((y1 + yf >= 0) && (yf + y1 < grid_size_y)) && ((x1 + xf >= 0) && (xf + x1 < grid_size_x))) {
            //appends and integer rounds these increments to form coords of next point on circle
            int yy = y1 + yf;
            int xx = x1 + xf;
            grid_content[yy][xx] = pixel_symbol;
          } 
	}  
      }

      //if command given is display
      else if ((strcmp(command, "DISPLAY") == 0) && (grid_set == 1)) {
        //prints canvas along with y axis in front of each line
        for (int i = grid_size_y - 1; i >= 0; i--) {
          //find y axis end digit for TA testing convenience
          int n = i % 10;
          printf("%d ", n);
          //print elements up to last one in canvas, excludes terminating \0
          for (int j = 0; j < grid_size_x; j++) {
            printf("%c", grid_content[i][j]);
          }
          printf("\n");
        }
        printf("  ");
        //prints x axis
        for (int i = 0; i < grid_size_x; i++) {
          int n = i % 10;
          printf("%d", n);
        }
        printf("\n");
      }

      //Last case, invalid inputs and ending
      else {
        //If input is END
        //Assumes that nobody will try to break the command by entering arguments after
        //As it would still end the program (however, the PDF promises all commands that are real
        //will be used correctly)
        if (strcmp(command, "END") == 0) {
          //Knows to end and print termination message
          char z[100] = "\nProgram was terminated.\n";
          printf("%s", z);
        }
        //Unknown command warning
        else if (grid_set == 0) {
          if ((strcmp(command, "CHAR") != 0) && (strcmp(command, "GRID") != 0) && (strcmp(command, "LINE") != 0) && (strcmp(command, "RECTANGLE") != 0) && (strcmp(command, "DISPLAY") != 0) && (strcmp(command, "CIRCLE") != 0)) {
            //Unallowed command warning
            char z[100] = "Error; did not understand: ";
            printf("%s %s", z, user_command_input);
          } else {
            //Grid hasn't been set yet message
            char z[100] = "Only CHAR command is allowed before the grid size is set.\n";
            printf("%s", z);
          }
        } else {
          if ((strcmp(command, "CHAR") != 0) && (strcmp(command, "GRID") != 0) && (strcmp(command, "LINE") != 0) && (strcmp(command, "RECTANGLE") != 0) && (strcmp(command, "DISPLAY") != 0) && (strcmp(command, "CIRCLE") != 0)) {
            //Unallowed command warning after grid is set
            char z[100] = "Error; did not understand: ";
            printf("%s %s", z, user_command_input);
          }
        }
      }
    }
  }
  //Termination code
  return 0;
}
