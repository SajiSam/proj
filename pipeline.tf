resource "aws_codepipeline" "static_web_pipeline" {
  name     = "static-web-pipeline"
  role_arn = data.aws_iam_role.pipeline_role.arn
  tags     = {
    Environment = var.env
  }

  artifact_store {
    location = var.artifacts_bucket_name
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      category = "Source"
      configuration = {
        "Branch"               = var.repository_branch
        "Owner"                = var.repository_owner
        "PollForSourceChanges" = "false"
        "Repo"                 = var.repository_name
      }
      input_artifacts = []
      name            = "Source"
      output_artifacts = [
        "SourceArtifact",
      ]
      owner     = "ThirdParty"
      provider  = "GitHub"
      run_order = 1
      version   = "1"
    }
  }
    stage {
      name = "CreateChangeSet"
      action {
          category  = "Deploy"
          owner     = "AWS"
          provider  = "CloudFormation"
          version   = "1"
          run_order = 2
          configuration = {
              ActionMode = "CHANGE_SET_REPLACE"
              TemplatePath = "SourceArtifact::sam-templated.yaml"
              StackName = "MyStack"
          }
          input_artifacts = [ "SourceArtifact" ]
        }
    }

    stage {
      name = "ExecuteChangeSet"
      action {
          category  = "Deploy"
          owner     = "AWS"
          provider  = "CloudFormation"
          version   = "1"
          run_order = 2
          configuration = {
              ActionMode = "CHANGE_SET_EXECUTE"
              StackName = "MyStack"
          }
          input_artifacts = [ "SourceArtifact" ]
    }    

}