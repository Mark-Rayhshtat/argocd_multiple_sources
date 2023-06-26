create regular codepipeline
1. GitHub Source
2. Full Clone
3. add permisssions to Codebuild role
        {
            "Effect": "Allow",
            "Action": [
                "codestar-connections:UseConnection",
                "codepipeline:ListPipelineExecutions",
                "ecr:CompleteLayerUpload",
                "ecr:GetAuthorizationToken",
                "ecr:UploadLayerPart",
                "ecr:InitiateLayerUpload",
                "ecr:BatchCheckLayerAvailability",
                "ecr:PutImage",
                "ecr:BatchGetImage"
            ],
            "Resource": "*"
        }