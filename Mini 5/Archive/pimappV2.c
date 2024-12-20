#include <stdlib.h>
#include <stdio.h>
#include <string.h>

//Nicholas Belev
//nicholas.belev@mail.mcgill.ca
//Faculty of Science - Computer Science
//MINI 5 - University Personnel Information System

//Default structure for our nodes, accounting for all variables required.
// You MUST use the exact structure. No modification allowed.

typedef struct PersonalInfoRecord {
  char id[10];
  char ptype;
  char name[31];

  union {
    struct {
      char dept[31];
      int hireyear;
      char tenured;
    }
    prof;
    struct {
      char faculty[31];
      int admyear;
    }
    stud;
  }
  info;

  //definition for the reference to  next node
  struct PersonalInfoRecord * next;
}
PersonalInfoRecord;

// Use this in your code as
// PersonalInfoRecord pir; PersonalInfoRecord *pirp; etc ...

//Fill in a node provided as an argument with data of input string
void buildNode(struct PersonalInfoRecord * data, char * str) {
  //Ignores the first argument which should be I, assuming no invalid data is tested, as per the ASSUMPTIONS section
  strsep( & str, ",");
  strcpy(data -> id, strcat(strsep( & str, ","), "\0")); //putting null terminator for string reading, in all cases
  char buffer[100];
  strcpy(buffer, strsep( & str, ","));
  data -> ptype = buffer[0];
  strcpy(data -> name, strcat(strsep( & str, ","), "\0"));
  //If third argument indicates type Professor
  if (data -> ptype == 'P') {
    strcpy(data -> info.prof.dept, strcat(strsep( & str, ","), "\0"));
    data -> info.prof.hireyear = atoi(strsep( & str, ",")); //Input converted to int
    char buffer2[100];
    strcpy(buffer2, strsep( & str, "\n"));
    data -> info.prof.tenured = buffer2[0]; //not a string but a char
  }
  //Else it's a student, so fill in corresponding fields
  else {
    strcpy(data -> info.stud.faculty, strcat(strsep( & str, ","), "\0"));
    data -> info.stud.admyear = atoi(strsep( & str, "\n")); //convert input str to int
  }
  data -> next = NULL; //avoid unpredictable behavior by assigning a next to current node
}

//Finds node to delete and reassigns pointers to get rid of it; frees space
void deleteNode(struct PersonalInfoRecord ** head, char idDel[10]) {
  // Store head node
  struct PersonalInfoRecord * temp = * head, * prev;

  // If head node is the one that needs to be deleted
  if (temp != NULL && (strcmp(temp -> id, idDel) == 0)) {
    if (temp -> next == NULL) { //if there is only one node left and it's being deleted
      free(temp);
      temp = NULL;
      * head = NULL;
    } else {
      * head = temp -> next; // Changed head to following node
      free(temp); // Free space of old head cuz its getting eliminated
    }
  }
  // Keep searching while the list isn't at an end and current id doesnt match To-Be-Deleted id
  else {
    prev = temp;
    while (temp != NULL && (strcmp(temp -> id, idDel) != 0)) {
      prev = temp;
      temp = temp -> next; //iterate through list
    }
    if (temp != NULL) {
      prev -> next = temp -> next; //Some pointer skipping magic to get rid of pointers to temp and unlink it
      free(temp); // Free memory of node we eradicated
    }
  }
}

//Given the head (which I will initialize first in main), will figure out where to insert a new node
void insertNode(struct PersonalInfoRecord ** head, struct PersonalInfoRecord ** newBoy) {
  //setting temporary null pointer, just to be explicit
  ( * newBoy) -> next = NULL;
  struct PersonalInfoRecord * temp = * head, * prev;

  prev = temp;

  //Edge case where new node should come before the head
  if (((atoi(temp -> id)) > (atoi(( * newBoy) -> id)))) {
    ( * newBoy) -> next = * head;
    * head = * newBoy;
  } else {
    //gets to the right spot to insert the current node
    while (temp != NULL && (atoi(temp -> id) < (atoi(( * newBoy) -> id)))) {
      prev = temp;
      temp = temp -> next;
    }
    //if new node won't be at the end of the list
    if (temp != NULL) {
      ( * newBoy) -> next = temp;
    }
    prev -> next = * newBoy;
  }
}

//To change fields, if this is deemed necessary by main logic
void editNode(struct PersonalInfoRecord ** head, char * str) {
  char iDD[20];
  strsep( & str, ","); //gets rid of I
  strcpy(iDD, strcat(strsep( & str, ","), "\0")); //saves input line's id to str
  struct PersonalInfoRecord * curr = * head;
  while (strcmp(curr -> id, iDD) != 0) {
    curr = curr -> next; //gets us to the node we need to update
  }
  char tp[10];
  strcpy(tp, strsep( & str, ","));
  char type = tp[0]; //gets either a P or S, presumably as this will not change.

  char nameche[31];
  strcpy(nameche, strcat(strsep( & str, ","), "\0")); //get new name with appended null terminator
  if (strcmp(nameche, "\0") != 0) {
    strcpy(curr -> name, nameche);
  }

  //if professor
  if (type == 'P') {
    char dep[31];
    strcpy(dep, strcat(strsep( & str, ","), "\0")); //get department
    //if department field in update is not null, change field value accordingly; this logic applies for all similar
    //following instances
    if (strcmp(dep, "\0") != 0) {
      strcpy(curr -> info.prof.dept, dep);
    }
    char hire[10];
    strcpy(hire, strsep( & str, ",")); //save new hireyear keep as string
    if (strcmp(hire, "") != 0) {
      curr -> info.prof.hireyear = atoi(hire); //set hireyear to new int-ified hireyear
    }
    char tnr[5];
    strcpy(tnr, strsep( & str, "\n"));
    char tenu = tnr[0]; //get new char Y or N representing tenured OR null if nothing is there
    if (tenu != '\0') {
      curr -> info.prof.tenured = tenu;
    }
  } else { //else it's  a student

    char fac[31];
    strcpy(fac, strcat(strsep( & str, ","), "\0")); //get faculty with appended null terminator
    if (strcmp(fac, "\0") != 0) {
      strcpy(curr -> info.stud.faculty, fac);
    }
    char admY[10];
    strcpy(admY, strsep( & str, "\n")); //get amdission year keep as string
    if (strcmp(admY, "") != 0) {
      curr -> info.stud.admyear = atoi(admY); //set admyear to new int-ified admyear
    }
  }
}

//figures out if the input line is a new node or a means to edit an old node
int idExists(struct PersonalInfoRecord ** head, char * str) {
  char str2[10];
  struct PersonalInfoRecord * curr = * head;
  strsep( & str, ","); //gets rid of I
  strcpy(str2, strcat(strsep( & str, ","), "\0")); //save id to str2

  while (curr != NULL) {
    if (strcmp(curr -> id, str2) == 0) {
      return 1; //if the inputted line has an ID matching that of an existing node's return true
    }
    curr = curr -> next;
  }
  return 0; //no match found
}

//Prints toString of every node with each
void printList(struct PersonalInfoRecord * curr) {
  if (curr == NULL) {
    putc('\n', stdout);
  } else if (strcmp(curr -> id, "\0") == 0) {
    putc('\n', stdout);
  } else {
    while (curr != NULL) {
      printf("%s,%c,%s,", curr -> id, curr -> ptype, curr -> name);
      //if it's a professor node, use these field replacements
      if (curr -> ptype == 'P') {
        printf("%s,%d,%c\n", curr -> info.prof.dept, curr -> info.prof.hireyear, curr -> info.prof.tenured);
      }
      //Else student (assuming correct usage, as implied by the PDF ASSUMPTIONS section, use these field replacements
      else {
        printf("%s,%d\n", curr -> info.stud.faculty, curr -> info.stud.admyear);
      }
      //go to next PersonalInfoRecord in linked list
      curr = curr -> next;
    }
  }
}

//checks whether file can be written to
int fileWrite(const char * filename) {
  FILE * document;
  if ((document = fopen(filename, "w"))) {
    fclose(document); //can be ooened for writing
    return 1;
  }
  return 0; //couldn't open it so file is unwritable
}

//Main function of the program that gets user input, checks validity, calls functions, writes to file
int main(int argc, char * argv[]) {

  //if arguments provided is not 1, exit with code 1
  if (argc != 2) {
    printf("Error, please pass the database filename as the argument.\n");
    printf("Usage ./pimapp <dbfile>\n");
    return 1;
  }

  //create head node and allocate space for it; assign temp node to traverse linked list
  struct PersonalInfoRecord * theHead = (struct PersonalInfoRecord * ) malloc(sizeof(struct PersonalInfoRecord));
  int headSet = 0; //check if we've made head yet

  char inputbuffer[100]; // to store each input line; I assume lines won't be longer than 99 characters then

  //char input[100];
  char * input;

  char inputbuffer2[100];

  while (fgets(inputbuffer, 100, stdin) != NULL) // Get each input line.
  {
    strcpy(inputbuffer2, inputbuffer);
    input = inputbuffer2;

    if (strncmp(input, "END", 3) == 0) break; // We are asked to terminate if input is the word END

    //If we need to delete a node, aka input starts with D
    else if (strncmp(input, "D", 1) == 0) {
      strsep( & input, ","); //get rid of D and comma
      deleteNode( & theHead, strsep( & input, "\n"));
    }
    //if first field is I
    else if (input[0] == 'I') {
      if (headSet == 0) {
        //Assuming no invalid commands or order of commands, delete cannot be called before the first node
        //exists, so first we make the head, if it hasn't been made yet
        buildNode(theHead, input);
        headSet = 1;
      }
      //if we've deleted the head and are now adding a new node, we need to resurrect the head
      else if (theHead == NULL) {
        theHead = (struct PersonalInfoRecord * ) malloc(sizeof(struct PersonalInfoRecord));
        buildNode(theHead, input);
      }

      //if id is already present amongst the nodes, call to update the fields
      else if (idExists( & theHead, input)) {
        strcpy(inputbuffer2, inputbuffer);
        input = inputbuffer2;

        editNode( & theHead, input);
      }
      //new node to be added to existing list
      else {

        strcpy(inputbuffer2, inputbuffer);
        input = inputbuffer2;

        struct PersonalInfoRecord * newNode = (struct PersonalInfoRecord * ) malloc(sizeof(struct PersonalInfoRecord));
        buildNode(newNode, input); //fills in the data for the current new node
        insertNode( & theHead, & newNode); //sets up the pointers and connects the new node into the right spot.
      }
    }
    //if List command is called
    else if (strncmp(input, "LIST", 4) == 0) {
      printList(theHead);
    } else {
      printf("Invalid input provided.\n");
    }
  } //done with while loop, so time to try to write to a file

    //file exists but can't be written to
    if (fileWrite(argv[1]) == 0) {
      fprintf(stderr, "Error, unable to open %s for writing.\n", argv[1]);//prints error message to standard error, as directed
      return 3;//correct return code for if file could not be written to
    }
    //Similar to printList but repurposed for argv aka the file it will fprintf all the lines to
    struct PersonalInfoRecord * curr = theHead;
    FILE * output;
    //conditions for an empty linked list to be written to file
    if (curr == NULL || strcmp(curr -> id, "\0") == 0) {
      fclose(fopen(argv[1], "w"));
    } else {
      output = fopen(argv[1], "w"); //gets and opens file as pointer to output
      while (curr != NULL) {
        fprintf(output, "%s,%c,%s,", curr -> id, curr -> ptype, curr -> name);
        //if it's a professor node, use these field replacements
        if (curr -> ptype == 'P') {
          fprintf(output, "%s,%d,%c\n", curr -> info.prof.dept, curr -> info.prof.hireyear, curr -> info.prof.tenured);
        }
        //Else student (assuming correct usage, as implied by the PDF ASSUMPTIONS section, use these field replacements
        else {
          fprintf(output, "%s,%d\n", curr -> info.stud.faculty, curr -> info.stud.admyear);
        }
        //go to next PersonalInfoRecord in linked list
        curr = curr -> next;
      }
      fclose(output); //closes file
    }
  return 0; // Appropriate return code assuming everything worked out.
}
