#!/bin/bash
set -e
echo "Create list of updated applications"
echo "--------------------------------------------------------------"
# aws codepipeline list-pipeline-executions --pipeline-name pipeline-deploy-service01-api-${env} --region eu-central-1
start_hash=$(aws codepipeline list-pipeline-executions --pipeline-name pipeline-deploy-service01-api-${env} --region eu-central-1 --query 'pipelineExecutionSummaries[?(status==`InProgress` || status==`Succeeded`)]'| jq -r .[0].sourceRevisions[0].revisionId)
echo $start_hash
end_hash=$(aws codepipeline list-pipeline-executions --pipeline-name pipeline-deploy-service01-api-${env} --region eu-central-1 --query 'pipelineExecutionSummaries[?(status==`InProgress` || status==`Succeeded`)]'| jq -r .[1].sourceRevisions[0].revisionId)
echo $end_hash
git diff --name-only $start_hash $end_hash > changes.log
cat changes.log
apps=$(python3 -c "with open('changes.log') as f:lines = set(line.split('/')[1] for line in f if line.split('/')[0] == 'src' and len(line.split('/')) >= 3);[print(line) for line in lines]")
echo "List of Apps: $apps"
# git log --pretty=oneline
# git status
# pwd
if [ -z "$apps" ]; then 
  echo "no changes in any application"
else
  for app in "${apps[@]}"
  do
    echo "App: $app"
  done
fi