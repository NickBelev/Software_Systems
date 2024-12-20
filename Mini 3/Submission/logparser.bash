#!/bin/bash

#Log Parser Script - Mini 3

#Nicholas Belev
#nicholas.belev@mail.mcgill.ca
#Faculty of Science - Computer Science

# exits if incorrect number of args provided
if [ $# != 1 ]
then
	echo "Error: incorrect number of arguments provided."
	exit 1

# exits if arg is not a directory, redirects to standard error
elif [ ! -d $1 ]
then
	echo "Error: $1 is not a valid directory name." 2>/dev/null
	exit 2

# runs the parser
else

#------------------------------------
# This portion will create logdata.csv

	> 'logdata.csv'
	# instantiates shell variables of type associative array
	declare -A deliverees receivers receivers_hostport_only

	# find receivers in files in given directory
	for file in $1/*.log; do
    		filename=$(basename "$file" .log)
    		
		# our receiver is the log file name that generated the current file, with an exchange of . for :
    		receiver="${filename/./:}"
    		while read line; do
			# constructs broadcaster names
        		namepart1=$(awk -F: '{print $8}' <<< $line)
   		     	namepart2=$(awk -F: '{print $9}' <<< $line)
        		broadcaster="${namepart1}:${namepart2}"

			# gets ID, last field, and cleans off the bracket
        		id=$(awk -F: '{print $NF}' <<< $line)
        		tempMessageID="${id/]/}"
	        	id="$tempMessageID"

        		receive_time="$(awk -F'[ ]' '{print $4}' <<< $line)"

			# makes reception key to later match with broadcaster, msg ID, and receive node
        		receiver_key="${broadcaster},${id},${receiver}"

			# puts this key into an associative array for later comparison
	        	receivers[$receiver_key]="${receive_time}"

		        # placeholder for receiver ID in associative array which will be used uniquely, so is assigned to 0, until a real value is determined
        		receivers_hostport_only[$receiver]=0

		# only scans lines of reception messages
	    	done <<< "$( grep "Received a message from. message" $file)"
	done

	# find deliveries in given directory, (variable deliveree/[s] spelled wrong for artistic expression)
	for file in $1/*.log; do

    		filename=$(basename "$file" .log)
    		# our receiver is the log file name that generated the file, when we swap the . for :
    		deliveree="${filename/./:}"
		while read line; do
		
			# constructs broadcaster name by combining before and after the colon
        		namepart1=$(awk -F: '{print $6}' <<< $line)
        		tempnamepart="${namepart1/ /}"
        		namepart1="$tempnamepart"
	        	namepart2=$(awk -F: '{print $7}' <<< $line)
        		broadcaster="${namepart1}:${namepart2}"

			# gets message ID
			id=$(awk -F: '{print $5}' <<< $line)
	        	tempMessageID="${id/ from /}"
        		id="$tempMessageID"

			# gets deliver time
        		deliver_time="$(awk -F'[ ]' '{print $4}' <<< $line)"

			# makes delivery key to match with broadcaster, msg ID, and delivery node
        		deliveree_key="${broadcaster},${id},${deliveree}"

			# within map array deliverees, that has the specific delivery key matching the current broadcast, msg ID, and deliver process, extracts deliver time
        		deliverees[$deliveree_key]="${deliver_time}"
		
		# only scans lines of delivery messages
    		done <<< "$( grep "deliver INFO: Received" $file)"
	done

	# find broadcasters and append information from prevouus two map arrays
	for file in $1/*.log; do
    		filename=$(basename "$file" .log)
    		process="${filename/./:}"

    		# goes through all lines for broadcaster from all files
    		while read line; do
        		broadcaster="$process"

        		id="$(awk -F: '{print $5}' <<< $line)"
        		tempMessageID="${id/ /}"
        		id="$tempMessageID"

        		broadcast_time="$(awk -F'[ ]' '{print $4}' <<< $line)"

        		for i in "${!receivers_hostport_only[@]}"; do
				#makes keys to look for later when extracting receive and delivery time when a match of broadcaster, id, and receiver (assigned to i)
				receiver_key="${broadcaster},${id},${i}"
                		deliveree_key="${broadcaster},${id},${i}"
				
				# excludes potentially erroneous empty communication lines
                		if [[ "$id" != '' ]]
                		then
					# prints a CSV line, with appropriate variables and associative array extractions, and writes it to logdata
                        		echo "$broadcaster,$id,${i},$broadcast_time,${receivers[$receiver_key]},${deliverees[$deliveree_key]}" >> 'logdata.csv'
                		fi
        		done

		# only reads broadcast message lines
    		done <<< "$( grep "Broadcast message request received" $file)"
	done

	# ensures resultant data is sorted, first by broadcast node, then by message number, and lastly by receiver node
	sort -t ',' -k1,1 -k2,2n -k3,3 -o logdata.csv logdata.csv

#------------------------------------
# this portion creates stats.csv

        # instantiates shell variable of type associative array
        declare -A broadcasters_hostport_only all_counts delivered_counts broadcaster_counts
        
	# constructed full path for logdata out of paranoia that it might read the wrong file... idk
	fileR=$(pwd)
        fileR+='/logdata.csv'
        
	# find broadcasters and append information from prevouus two map arrays
	while read line; do

		broadcaster="$(awk -F',' '{print $1}' <<< $line)"

		# placeholder in associative array for unique broadcaster IDs which will be used by key only later; value corresponding to key-value pair is set to dummy value of 0 to make the neccessary insertion
		broadcasters_hostport_only[$broadcaster]=0
	done < $fileR

        # nested loop to go through all broadcaster receiver combinations and initialize their message transmission counts
        for i in "${!broadcasters_hostport_only[@]}"; do

                for j in "${!receivers_hostport_only[@]}"; do
                        combined_key="${i},${j}"
                        # these associative arrays are variables to store the counts of all and delivered messages per broadcaster-recceiver conbination
                        all_counts[$combined_key]=0
                        delivered_counts[$combined_key]=0
                done

                # set a separate storage for counts for each broadcaster and initialize to zero per broadcaster
                broadcaster_key="${i}"
                broadcaster_counts[$broadcaster_key]=0
        done

        # loop from the output of the logs summary logdata.csv to extract relevant counts that will need later to be reported in stats.csv
	while read line; do
                broadcaster="$(awk -F',' '{print $1}' <<< $line)"
                receiver="$(awk -F',' '{print $3}' <<< $line)"

                combined_key="${broadcaster},${receiver}"
                broadcaster_key="${broadcaster}"

                # store prior values from arrays
                previous_all_count_value=${all_counts[$combined_key]}
                previous_delivered_count_value=${delivered_counts[$combined_key]}
                previous_broadcaster_count_value=${broadcaster_counts[$broadcaster_key]}

                # increment values for the fact that a new matching instance is found
                new_all_count_value=$((previous_all_count_value+1))
                
		# ensures delivery number is only incremented when a receiving node has a full delivery time field
		checker="$(awk -F',' '{print $NF}' <<< $line)"
		if [[ $checker != '' ]]; then
			new_delivered_count_value=$((previous_delivered_count_value+1))
		else
			new_delivered_count_value=$((previous_delivered_count_value))
		fi

		new_broadcaster_count_value=$((previous_broadcaster_count_value+1))

                # record the new values back into the arrays in the same positions
                all_counts[$combined_key]=$new_all_count_value
                delivered_counts[$combined_key]=$new_delivered_count_value
                broadcaster_counts[$broadcaster_key]=$new_broadcaster_count_value
        
	done < $fileR

        # actually constructs stats.csv file:

        # starting with stats.csv file header
        headerline='broadcaster,nummsgs'

        for j in "${!receivers_hostport_only[@]}"; do

                # the item j is the value not the key in this case
                headerline+=','
                headerline+="${j}"
        done

        echo "$headerline" > 'stats.csv'

        # output all records stored in the associative array to stats.csv
        for i in "${!broadcasters_hostport_only[@]}"; do

                output_line="${i}"
                output_line+=','

                broadcaster_key="${i}"
                broadcaster_count_value=${broadcaster_counts[$broadcaster_key]}
		numReceivers=${#receivers_hostport_only[@]}
		broadcaster_count_value=$(echo "$broadcaster_count_value / $numReceivers" | bc)

                output_line+="${broadcaster_count_value}"

                for j in "${!receivers_hostport_only[@]}"; do

                        combined_key="${i},${j}"
                        output_line+=','

                        all_count_value=${all_counts[$combined_key]}
                        delivered_count_value=${delivered_counts[$combined_key]}

			hundred=100
			percentage_delivered=$(echo "$delivered_count_value / $all_count_value" | bc -l)
			percentage_delivered=$(echo "$percentage_delivered * $hundred" | bc -l | sed -e 's/[0]*$//g')
                        percentage_delivered=$(echo "$percentage_delivered" | sed -e 's/[.]*$//g')
			output_line+="${percentage_delivered}"
                	#output_line+="${all_count_value}"
		done
		
		# writes the constructed line to stats.csv
                echo "$output_line" >> 'stats.csv'
        done

	# sorts rows by node number (hopefully won't sort the header to a different location; would have used tail to prevent that, but it is not an allowed command)
	sort -t ',' -k1,1 -o stats.csv stats.csv

#------------------------------------
# this portion produces stats.html using stats.csv
	
	# hardcoded html heading and title written to stats.html
	echo '<HTML>' > 'stats.html'
	echo '<BODY>' >> 'stats.html'
	echo '<H2>GC Efficiency</H2>' >> 'stats.html'
	echo '<TABLE>' >> 'stats.html'

	firstLine="true"
	# goes through stats.csv line by line
	while read line; do
		# for first line, will print header with TH tags
		echo -n '<TR>' >> 'stats.html'
		if [ $firstLine = true ]; then
    			counter=1
			# finds number of commas which correlates to number of args
	                limit=$(awk -F "," '{print NF}' <<< $line)

        	        while [ $counter -le $limit ]; do
                	        echo -n '<TH>' >> 'stats.html'
                	        echo -n $(awk -v c=$counter -F, '{print $c}' <<< $line) >> 'stats.html'
                        	echo -n '</TH>' >> 'stats.html'
				counter=$((counter+1))
			done
			firstLine="false"
		# for subsequent lines, will print line with TD tags 
		else
			counter=1
                	limit=$(awk -F "," '{print NF}' <<< $line)
	
                	while [ $counter -le $limit ]; do
                        	echo -n '<TD>' >> 'stats.html'
                        	echo -n $(awk -v c=$counter -F, '{print $c}' <<< $line) >> 'stats.html'
                        	echo -n '</TD>' >> 'stats.html'
                        	counter=$((counter+1))  
	       		done
		fi
		echo '</TR>' >> 'stats.html'
	done < 'stats.csv'
	
	# hardcoded closing tags written
	echo '</TABLE>' >> 'stats.html'
	echo '</BODY>' >> 'stats.html'
	echo '</HTML>' >> 'stats.html'

#------------------------------------

	# successfully exits after creating all needed files
	exit 0
fi
