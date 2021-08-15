BUCKET_NAME=$(gsutil ls | head -n 1)

if [ -f ".torque" -a -f "uploadstatus" ];
then
  echo "reading from temporary files"
else
  echo "temporary file(s) not found. Please run upload.sh first and then download.sh"
  exit 1
fi

if [ $? == 0 ]
then
  OPERATION_URI=$(tail uploadstatus | awk -F : '{ print $NF }' | sed 's/["\} ]//g')
  echo "==========================="
  echo "found uri"
  echo $OPERATION_URI
  BASE="https://vision.googleapis.com/v1/"
  OPERONE="${BASE}${OPERATION_URI}"
  TOKEN=$(gcloud auth application-default print-access-token)
  echo "checking the status of the vision api"
  STATUS=$(curl -s -X GET -H "Authorization: Bearer $TOKEN" -H "Content-Type: application/json" ${OPERONE})
  if [ $? == 0 ]
  then
    #echo $STATUS
    FINAL_STATUS=$(echo $STATUS | awk -F , '{ print $3}' | awk -F : '{ print $NF }' | sed 's/[:,\" ]//g')
    echo "status is : "$FINAL_STATUS
    echo "==========================="
    if [ "$FINAL_STATUS" == "DONE" ]
    then
      PREFIX=$(tail .torque)
      mkdir -p $PREFIX
      gsutil -m -o "Boto:parallel_thread_count=2" -o "Boto:parallel_process_count=2" cp $BUCKET_NAME"out/"$PREFIX"*" $PREFIX"/"
      if [ $? == 0 ]
      then
        #gsutil delete $BUCKET_NAME"out/output-1-to-2.json" #manually delete the files in out/
        #echo "cloud source deleted too"
        echo "Download is complete. Clearing all temporary files"
        rm -rf uploadstatus .torque
      fi
     else
       echo "Transformtion did not complete yet. Try after 1 minute"
    fi
    if [ "$FINAL_STATUS" == "ACCESS_DENIED" ]
    then 
      echo "could not connect to vision apis. \
         1. Check network connections \
         2. Check the variable GOOGLE_APPLICATION_CREDENTIALS. \
         refer - https://cloud.google.com/vision/docs/setup#linux-or-macos "
    fi
  fi
fi
