#!/bin/bash
counter=1
zone_counter=1
instance=0
instance=$1
#instance of zone
zones=3
#instance of source tasks
task=18
#instance of dataflow
dataflow=18
label=2
#instance of contiguity
contiguity=2
#file input
namefile="input.txt"
namefilechannel="channel.txt"
namefilenode="node.txt"
if [[ $instance -eq 0 ]] #not replicated
then
  echo -e "[ERROR]\tInvalid parameter"
  echo -e "[INFO]\tParameter of replicate must be a number greater than zero"
  echo -e "[INFO]\tHow to exceute the script? ./input.sh [parameter of replicate]" 
elif [[ $instance -ge 1 ]] #check exixts file 
then
  if [[ -f $namefile ]]
  then
    echo -e "[INFO]\tInput file exists"
    rm $namefile
    echo -e "[INFO]\tInput file removal successfully completed"
    echo -e "[INFO]\tCreating file input..."
    touch $namefile
  else
    echo -e "[INFO]\tInput file non found"
    echo -e "[INFO]\tCreating file input..."
    touch $namefile
  fi
  #create zone
  sum_zones=$(($instance-1))
  if [[ $instance -eq 1 ]]
  then
    sum_zones=0
  fi
  echo "<ZONE>"  >> $namefile
    while [ $counter -le $instance ]
    do
        #create 3 zones if the instance of replication is one
        while [ $zone_counter -le $(($zones+$sum_zones)) ] 
        do
          echo -e "${zone_counter}\t0\t" >> $namefile
        ((zone_counter++))
        done
        ((counter++))
    done
  echo "</ZONE>" >> $namefile
  #create label zone
  echo "<ZONE_LABEL>" >> $namefile
  counter=0
  zone_counter=0
  counter_zones_z=0
  echo "${zone_counter}   Environment" >> $namefile
  while [ $counter -le $instance ]
  do
        ((zone_counter++))
        sum_zones=$(($instance-1))
        if [[ $instance -eq 1 ]]
        then
          sum_zones=0
        fi
        zones_source=$(($zones+$sum_zones))
        #create 3 zones if the instance of replication is one
        while [ $zone_counter -le $(($zones+$sum_zones)) ]
        do
          echo -e "${zone_counter}\tZ${counter_zones_z}\t" >> $namefile
          ((zone_counter++))
          ((counter_zones_z++))
        done
        ((counter++))
  done
  counter=0
  source_task=3
  occured=1
  channel=0
  echo "</ZONE_LABEL>" >> $namefile


  source_task=3
  zone_contiguity=2
  zone_contiguity_parameters=2
  echo "<CONTIGUITY>" >> $namefile
  echo -e "3\t2\t1\t1\t1\t" >> $namefile
  echo -e "3\t2\t2\t1\t1\t" >> $namefile
  #create contiguity
  while [ $counter -lt $((3*$contiguity*$instance)) ]
  do
    if [[ $counter -lt $((3*$contiguity)) ]]
    then
      if [[ $channel -le 2 ]]
      then
        echo -e "1\t${zone_contiguity}\t${channel}\t1\t1\t" >> $namefile
        ((channel++))
      fi
      if [[ $channel -gt 2 ]]
      then
        channel=0
        ((zone_contiguity++))
      fi    
    else
      if [[ $(($counter)) -eq $(($((3*$contiguity*$occured)))) ]] 
      then
        ((occured++))
        ((source_task++))
      fi   
      if [[ $channel -le 2 ]]
      then
        echo -e "${source_task}\t${zone_contiguity_parameters}\t${channel}\t1\t1\t" >> $namefile
        ((channel++))
      fi
      if [[ $channel -gt 2 ]]
      then
        channel=0
        ((zone_contiguity_parameters++))
        if [[ $zone_contiguity_parameters -gt 3 ]]
        then
          zone_contiguity_parameters=2
        fi
      fi
    fi
      ((counter++))
  done
  echo "</CONTIGUITY>" >> $namefile


  counter=0
  source_task=3
  occured=1
  echo "<TASK>" >> $namefile
  echo -e "T0\t10\t2\t0\t" >> $namefile
  echo -e "T1\t10\t3\t0\t" >> $namefile
  #create task
  while [ $counter -lt $(($task*$instance)) ]
  do
    if [[ $counter -lt $task ]]
    then
      echo -e "T${label}\t1\t1\t0\t" >> $namefile
    else
      echo -e "T${label}\t1\t${source_task}\t0\t" >> $namefile
    fi
    if [[ $(($counter+1)) -eq $(($task*$occured)) ]]
    then
      ((occured++))
      ((source_task++))
    fi
    ((label++))
    ((counter++))
  done
  echo "</TASK>" >> $namefile

  echo "<DATAFLOW>" >> $namefile
  dataflowchannel=0
  label=0
  labeltask=2
  counter=0
  ##############################################
  #variable dataflow const
  delaysix_errortwo=0 #max 2 times 6 2
  delayten_errorzero=0 #max 5 times 10 0
  delayten_errortwo=0 #max 2 times 10 2
  delaytwo_errorone=0 #max 2 times 2 1
  delayfive_errorone=0 #max 2 times 5 1
  delayten_errorone=0 #max 2 times 10 1
  delaynine_errortwo=0 #max 3 times 9 2
  task0=0 #max 8 times
  task1=0 #max 10 times
  check=0
  taskdestination=0
  counter_task_destination=0
  #############################################
  #define dataflow
  while [ $counter -lt $(($dataflow*$instance)) ]
  do
    if [[ $counter -lt $dataflow ]]
    then
      if [[ $delaysix_errortwo -lt 2 ]]
      then
        echo -e "DF${label}\tT${labeltask}\tT${taskdestination}\t50\t6\t2\t" >> $namefile
        ((delaysix_errortwo++))
      elif [[ $delayten_errorzero -lt 5 ]]
      then
        echo -e "DF${label}\tT${labeltask}\tT${taskdestination}\t50\t10\t0\t" >> $namefile
        ((delayten_errorzero++))
      elif [[ $delaytwo_errorone -lt 2 ]]
      then
        echo -e "DF${label}\tT${labeltask}\tT${taskdestination}\t50\t2\t1\t" >> $namefile
        ((delaytwo_errorone++))
      elif [[ $delayfive_errorone -lt 2 ]]
      then
        echo -e "DF${label}\tT${labeltask}\tT${taskdestination}\t50\t5\t1\t" >> $namefile
        ((delayfive_errorone++))
      elif [[ $delayten_errortwo -lt 2 ]]
      then
        echo -e "DF${label}\tT${labeltask}\tT${taskdestination}\t50\t10\t2\t" >> $namefile
        ((delayten_errortwo++))
      elif [[ $delayten_errorone -lt 2 ]]
      then
        echo -e "DF${label}\tT${labeltask}\tT${taskdestination}\t50\t10\t1\t" >> $namefile
        ((delayten_errorone++))
      elif [[ $delaynine_errortwo -lt 3 ]]
      then
        echo -e "DF${label}\tT${labeltask}\tT${taskdestination}\t50\t9\t2\t" >> $namefile
        ((delaynine_errortwo++))
        check=1
      fi
      if [[ $counter_task_destination -ge 7 ]]
      then
        if [[ $taskdestination -eq 0 ]]
        then
          ((taskdestination++))
        fi
        if [[ $counter_task_destination -eq 17 ]]
        then
          taskdestination=0
          counter_task_destination=0
        fi
      fi
    else
      if [[ $check -eq 1 ]]
      then
        delaysix_errortwo=0 #max 2 times 6 2
        delayten_errorzero=0 #max 5 times 10 0
        delayten_errortwo=0 #max 2 times 10 2
        delaytwo_errorone=0 #max 2 times 2 1
        delayfive_errorone=0 #max 2 times 5 1
        delayten_errorone=0 #max 2 times 10 1
        delaynine_errortwo=0 #max 3 times 9 2
        check=0
      fi
      if [[ $delaysix_errortwo -lt 2 ]]
      then
        echo -e "DF${label}\tT${labeltask}\tT${taskdestination}\t50\t6\t2\t" >> $namefile
        ((delaysix_errortwo++))
      elif [[ $delayten_errorzero -lt 5 ]]
      then
        echo -e "DF${label}\tT${labeltask}\tT${taskdestination}\t50\t10\t0\t" >> $namefile
        ((delayten_errorzero++))
      elif [[ $delaytwo_errorone -lt 2 ]]
      then
        echo -e "DF${label}\tT${labeltask}\tT${taskdestination}\t50\t2\t1\t" >> $namefile
        ((delaytwo_errorone++))
      elif [[ $delayfive_errorone -lt 2 ]]
      then
        echo -e "DF${label}\tT${labeltask}\tT${taskdestination}\t50\t5\t1\t" >> $namefile
        ((delayfive_errorone++))
      elif [[ $delayten_errortwo -lt 2 ]]
      then
        echo -e "DF${label}\tT${labeltask}\tT${taskdestination}\t50\t10\t2\t" >> $namefile
        ((delayten_errortwo++))
      elif [[ $delayten_errorone -lt 2 ]]
      then
        echo -e "DF${label}\tT${labeltask}\tT${taskdestination}\t50\t10\t1\t" >> $namefile
        ((delayten_errorone++))
      elif [[ $delaynine_errortwo -lt 3 ]]
      then
        echo -e "DF${label}\tT${labeltask}\tT${taskdestination}\t50\t9\t2\t" >> $namefile
        ((delaynine_errortwo++))
        if [[ $delaynine_errortwo -eq 3 ]]
        then 
         check=1
        fi
      fi
      if [[ $counter_task_destination -gt 7 ]]
      then
        if [[ $taskdestination -eq 0 ]]
        then
          ((taskdestination++))
        fi
        if [[ $counter_task_destination -eq 18 ]]
        then
          taskdestination=0
          counter_task_destination=0
        fi
      fi
    fi
    if [[ $(($counter+1)) -eq $(($dataflow*$occured)) ]]
    then
      ((occured++))
      ((source_task++))
    fi
    ((label++))
    ((labeltask++))
    ((counter++))
    ((counter_task_destination++))
  done
  #create statistics
  echo "</DATAFLOW>" >> $namefile
  echo -e "[INFO]\tInput file create correctly"
  #check exixts channel files
  if [[ -f $namefilechannel ]]
  then
    echo -e "[INFO]\tChannel file exists"
    rm $namefilechannel
    echo -e "[INFO]\tChannel file removal successfully completed"
    echo -e "[INFO]\tCreating channel file..."
    touch $namefilechannel
    # LABEL|ID|COST|SIZE|ENERGY|DF_ENERGY|ENERGY COST|DELAY|ERROR|WIRELESS|POINT TO POINT|
    echo -e "OPCUACLIENTSERVER\t0\t10\t1000\t5\t50\t0\t100\t0\t1" >> $namefilechannel
    echo -e "OPCUAPUBSUBBROKERLESSHP\t1\t9\t1000\t5\t50\t0\t1\t1\t0\t0" >> $namefilechannel
    echo -e "OPCUAPUBSUBBROKERLESSPL\t2\t5\t1000\t5\t50\t0\t5\t1\t0\t0" >> $namefilechannel
  else
    echo -e "[INFO]\tChannel file non found"
    echo -e "[INFO]\tCreating channel file..."
    touch $namefilechannel
    # LABEL|ID|COST|SIZE|ENERGY|DF_ENERGY|ENERGY COST|DELAY|ERROR|WIRELESS|POINT TO POINT|
    echo -e "OPCUACLIENTSERVER\t0\t10\t1000\t5\t50\t0\t10\t0\t0\t1" >> $namefilechannel
    echo -e "OPCUAPUBSUBBROKERLESSHP\t1\t9\t1000\t5\t50\t0\t1\t1\t0\t0" >> $namefilechannel
    echo -e "OPCUAPUBSUBBROKERLESSPL\t2\t5\t1000\t5\t50\t0\t5\t1\t0\t0" >> $namefilechannel
  fi
  #check exixts node files
  if [[ -f $namefilenode ]]
  then
    echo -e "[INFO]\tNode file exists"
    rm $namefilenode
    echo -e "[INFO]\tNode file removal successfully completed"
    echo -e "[INFO]\tCreating node file..."
    touch $namefilenode
    # LABEL|ID|COST|SIZE|ENERGY|TASK ENERGY|ENERGY COST|MOBILE
    echo -e "GATEWAY\t1\t100\t1000\t500\t200\t200\t0" >> $namefilenode
  else
    echo -e "[INFO]\tNode file non found"
    echo -e "[INFO]\tCreating node file..."
    touch $namefilenode
    echo -e "GATEWAY\t1\t100\t1000\t500\t200\t200\t0" >> $namefilenode
  fi
  echo ""
  echo "STATISTICS OF INSTANCE"
  echo -e "+-------+-----------+"
  echo -e "+ Task\t+ Dataflow  +"
  echo -e "+-------+-----------+"
  echo -e "+ $(($task*$instance+2))\t+ $(($dataflow*$instance))\t    +"
  echo "+-------+-----------+"
  echo ""
  echo -e "[INFO]\tGenerate $(($task*$instance+2)) taks; $(($task*$instance)) are sources"
  echo -e "[INFO]\tGenerate $(($dataflow*$instance)) dataflow"
  echo ""
  echo -e "[INFO]\tScript created by Leonardo Testolin"
  echo ""
  #view file created
  echo "Do you want to see input.txt file? [y/n]"
  read yesno
  if [[ $yesno = "y" ]]
  then
    cat $namefile
  fi
else
  echo -e "[ERROR]\tInvalid parameter"
  echo -e "[INFO]\tParameter of replicate must be a number greater than zero"
  echo -e "[INFO]\tHow to exceute the script? ./input.sh [parameter of replicate]" 
fi

