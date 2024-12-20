#!/bin/bash

#Nicholas Belev
#Computer Science - Faculty of Science
#nicholas.belev@mail.mcgill.ca

#If 2 arguments are provided
if [ $# -eq 2 ]
then
	#Exits, if first argument is not -f, as no indication is provided to show that following arg is a file
	if [ $1 != "-f" ]
	then
		echo Error: -f argument should be provided before filename.
		exit 1

	#Exits if second argument isn't a real file
	elif [ ! -f $2 ]
	then
		echo Error: no usable file was provided.
		exit 2

	else
		#Loops through second arg file, line by line
		filename=$2
		LINES=$(cat $filename)
		#Must change IFS to only look at new lines, so that it doesn't overlook spaces
		IFS=$'\n'
		for LINE in $LINES
		do
			#Runs primechk and checks return code, discarding unwanted output sentence
			"/home/2013/jdsilv2/206/mini2/primechk" $LINE > "/dev/null" 2>&1
			rtrnVal=$?
			#If code returns 0, line is only made up of digits 0-9, no spaces, and within allowable range, means a prime number is on this line, so prints it
			if [ $rtrnVal -eq 0 ] && [[ "$LINE" =~ ^[0-9]+$ ]] && [ $LINE -gt 1 ] && [ $LINE -lt 1000000000000000000 ]
			then
				echo "$LINE"
			fi
		done
		exit 0
	fi

#If 3 args provided
elif [ $# -eq 3 ]
then
	#Order 1: if first 2 args are -l and -f
	if [ $1 == "-l" ] && [ $2 == "-f" ]
	then
		#If third arg isn't a file, exits
		if [ ! -f $3 ]
		then
			echo Error: no usable file was provided.
			exit 2
		
		else
		#Loops through 3rd arg file
     			filename=$3
			currentMax=0
                	LINES=$(cat $filename)
			IFS=$'\n'
                	for LINE in $LINES
                	do
			#Runs primechk on a line and tests return value
	                      	"/home/2013/jdsilv2/206/mini2/primechk" $LINE > "/dev/null" 2>&1
                        	rtrnVal=$?
                                #If code returns 0, line is only made up of digits 0-9, no spaces, and within allowable range, means a prime number is on this line, so prints it
				if [ $rtrnVal -eq 0 ] && [[ "$LINE" =~ ^[0-9]+$ ]] && [ $LINE -gt 1 ] && [ $LINE -lt 1000000000000000000 ]
				then
					#If current prime is bigger than current max, swaps value of current max with the prime on the current line
                                	if [ $LINE -gt $currentMax ]
					then
						currentMax=$LINE
					fi
                        	fi
                	done
			#No prime found, exits
			if [ $currentMax -eq 0 ]
			then
				echo No prime numbers were found in this file.
				exit 3
			#Primes found, prints biggest, exits
			else
				echo $currentMax
				exit 0
			fi
		fi
	
	#Order 2: if first 2 args are -f and -l
	elif [ $1 == "-f" ] && [ $2 == "-l" ]
	then
		#If 3rd arg isn't file, exits
		if [ ! -f $3 ]
                then
                        echo Error: no usable file was provided.
                        exit 2
                
		else
                #Loops through 3rd arg file
                        filename=$3
                        currentMax=0
			LINES=$(cat $filename)
			IFS=$'\n'
                        for LINE in $LINES
                        do
                        #Runs primechk on a line and tests return value
                                "/home/2013/jdsilv2/206/mini2/primechk" $LINE > "/dev/null" 2>&1
                                rtrnVal=$?
                                #Same as prior - prime number checking conditions and validating range
                                if [ $rtrnVal -eq 0 ] && [[ "$LINE" =~ ^[0-9]+$ ]] && [ $LINE -gt 1 ] && [ $LINE -lt 1000000000000000000 ]
				then
                                        #If current prime is bigger than current max, swaps value of current max with the prime on the current line
                                        if [ $LINE -gt $currentMax ]
                                        then
                                                currentMax=$LINE
                                        fi
                                fi
                        done
                        #No prime found, exits
                        if [ $currentMax -eq 0 ]
                        then
                                echo No prime numbers were found in this file.
                                exit 3
                        #Max prime found, prints it, exits
                        else
                                echo $currentMax
                                exit 0
                        fi
                fi

	#Order 3: if first arg is -f and third is -l
	elif [ $1 == "-f" ] && [ $3 == "-l" ]
        then
                #If second arg isn't a file, exits
		if [ ! -f $2 ]
                then
                        echo Error: no usable file was provided.
                        exit 2
		
		else
                #Loops through 2nd arg file
                        filename=$2
			currentMax=0
                        LINES=$(cat $filename)
			IFS=$'\n'
                        for LINE in $LINES
                        do
                        #Runs primechk on a line and tests return value
                                "/home/2013/jdsilv2/206/mini2/primechk" $LINE > "/dev/null" 2>&1
                                rtrnVal=$?
                                #Same as prior - prime number checking conditions and validating range
				if [ $rtrnVal -eq 0 ] && [[ "$LINE" =~ ^[0-9]+$ ]] && [ $LINE -gt 1 ] && [ $LINE -lt 1000000000000000000 ]
				then
                                        #If current prime is bigger than current max, swaps value of current max with the prime on the current line
                                        if [ $LINE -gt $currentMax ]
                                        then
                                                currentMax=$LINE
                                        fi
                                fi
                        done
                        #No prime found, exits
                        if [ $currentMax = 0 ]
                        then
                                echo No prime numbers were found in this file.
                                exit 3
                        #Prime found, prints it, exits
                        else
                                echo $currentMax
                                exit 0
                        fi
                fi
	else
	#Since valid argument number has been provided, must mean that invalid arguments or args in the wrong order have been given, so exits
        	echo Error: mistake in argument syntax/order.
        	exit 1
	fi
else
	#Wrong number of args have been given, so exits
	echo Error: mistake in argument syntax or number of arguments provided.
	exit 1
fi
