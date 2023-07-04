LOG_GROUP=/aws-glue/jobs/output
LOG_STREAM=$(aws logs describe-log-streams --log-group-name $LOG_GROUP --max-items 1 --order-by LastEventTime --descending --query logStreams[].logStreamName --output text | head -n 1)
aws logs get-log-events --log-group-name $LOG_GROUP --log-stream-name $LOG_STREAM --query events[].message --output text