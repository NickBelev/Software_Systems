#!/bin/bash

#Nicholas Belev
#Computer Science - Faculty of Science
#nicholas.belev@mail.mcgill.ca

#Stores value of directory the code will be tested in
initDirec=$(pwd)

#Exits if any number other than two arguments are provided in the command prompt
if [ $# -ne 2 ]
then
	echo Error: 2 arguments must be provided, not $#.
	exit 1

#Exits if the first input, which should be a file, is unreadable
elif [ ! -r $1 ] 
then
        echo Error: input file cannot be read.
        exit 3

#If second argument is a file without write permission, the program exits
elif [ -f $2 ] && [ ! -w $2 ]
then
        echo Error: output file does not have write permission.
        exit 4

#Whether second argument is an existing file or has yet to be created, if it is (or will be) of .out type, program exits, as namefix cannot handle or write to .out executable files
elif [[ $2 == *.out ]]
then
	echo Error: designated output location/type is incompatible with this program.
	exit 4

#If second argument is a directory without write permission, the program exits
elif [ -d $2 ] && [ ! -w $2 ] && [ ! $2 == *'.out' ]
then
        echo Error: output directory does not have write permission.
        exit 4

#If both arguments are files and they have the same directory names and base/file-names, the program exits because outputting to the input file is not allowed
elif [ -f $1 ] && [ -f $2 ] && [ $(basename $1) == $(basename $2) ]
then
#Saves directory paths of both arguments
	cd $(dirname $1)
        inputDir1=$(pwd)
        cd $initDirec
	cd $(dirname $2)
        outputDir1=$(pwd)
        cd $initDirec

#If input and directory path are the same, it means that both arguments are referencing the same file since they have the same directory and basename, so the program exits
	if [ $inputDir1 == $outputDir1 ]
	then
		echo Error: input and output path cannot refer to the same file.
		exit 2
	fi

#If input is a file and output is a directory
elif [ -f $1 ] && [ -d $2 ]
then
#Saves directory paths of both arguments
	cd $2
	outputDir2=$(pwd)
	cd $initDirec
	cd $(dirname $1)
	inputDir2=$(pwd)
	cd $initDirec

#If the input directory path is identical to that of the ouput directory's, exit, because we can't create a file of the same name as the original, under the same directory
	if [ $inputDir2 == $outputDir2 ]
	then
        	echo Error: cannot create new file with same name as original file under same directory.
		exit 2

#Otherwise, create a new file using the second argument's directory and first argument's name and run namefix with the first argument and the newly constructed second argument
	else
		newPath=$outputDir2
		newPath+="/"
		newPath+=$(basename $1)
		
		#To protect against cases where output file has same path longname as an existing directory, verifies that new path is a file
		if [ ! -d $newPath ]
		then
			> $newPath
			"/home/2013/jdsilv2/206/mini2/namefix" $1 $newPath
		else
			echo Error: unable to verify that new output path can be safely created.
			exit 4
		fi
	fi

#All conditions have been checked, so if this point is reached, the default argument can be called on the two arguments (which are both files, even if the second may still need to be created)
else
	"/home/2013/jdsilv2/206/mini2/namefix" $1 $2
fi
