#!/bin/bash
set -e
echo "Create list of updated applications"
echo "--------------------------------------------------------------"
# aws codepipeline list-pipeline-executions --pipeline-name codepipeline-argocd-test --region us-east-1
start_hash=$(aws codepipeline list-pipeline-executions --pipeline-name codepipeline-argocd-test --region us-east-1 --query 'pipelineExecutionSummaries[?(status==`InProgress` || status==`Succeeded`)]'| jq -r .[0].sourceRevisions[0].revisionId)
echo $start_hash
end_hash=$(aws codepipeline list-pipeline-executions --pipeline-name codepipeline-argocd-test --region us-east-1 --query 'pipelineExecutionSummaries[?(status==`InProgress` || status==`Succeeded`)]'| jq -r .[1].sourceRevisions[0].revisionId)
echo $end_hash
git diff --name-only $start_hash $end_hash > changes.log
cat changes.log
apps=$(python3 -c "with open('changes.log') as f:lines = set(line.split('/')[1] for line in f if line.split('/')[0] == 'helm' and not line.split('/')[2].startswith('value') and len(line.split('/')) >= 3);[print(line) for line in lines]")
echo "List of Apps: $apps"
set +e
if [ -z "$apps" ]; then 
  echo "no changes in any application"
else
  for app in "${apps[@]}"
  do
    echo "App: $app"
    helm package $app
    aws ecr get-login-password \
     --region us-east-1 | helm registry login \
     --username AWS \
     --password-stdin 581349712378.dkr.ecr.us-east-1.amazonaws.com
    file=$(ls $app-*.tgz)
    helm push $file oci://581349712378.dkr.ecr.us-east-1.amazonaws.com/
  done
fi