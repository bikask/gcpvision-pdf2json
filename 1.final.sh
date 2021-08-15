PDFS=$(ls -1 | grep ".pdf" | wc -l)

if [ -f ".torque" ];
then
  echo "Already pending downloads. Please complete that by running download.sh"
  exit 1
fi

if [ $PDFS -ne 1 ]
then
 echo "more than one pdfs. uhhh.... need only one file to proceed"
 exit
fi

NEW_NAME=$(date +%Y_%m_%d_%H%M%S)
mv *.pdf $NEW_NAME".pdf"
echo "reading pdf successful"

BUCKET_NAME=$(gsutil ls | head -n 1)

export BUCK=$BUCKET_NAME
echo "============================="
echo "initiating upload now"
gsutil cp $NEW_NAME".pdf" $BUCKET_NAME"in"
RESPONSE=$(gcloud ml vision detect-text-pdf $BUCKET_NAME"in/"$NEW_NAME".pdf" $BUCKET_NAME"out/"$NEW_NAME)
if [ $? == 0 ]
then
  echo "vision api is running. run 2.sh for details about the vision extraction"
  echo $RESPONSE > uploadstatus
  echo $NEW_NAME > .torque
fi
