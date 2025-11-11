alias ls="ls -a"
alias exp="open ."
alias profile="code ~/.oh-my-zsh/custom/profile.zsh"
alias rc="code ~/.zshrc"
alias resource="source ~/.zshrc && source ~/.oh-my-zsh/custom/profile.zsh"
alias api="cd ~/ah/PatientPortalAPI"
alias web="cd ~/ah/PatientPortalWeb"
alias pyact="source .venv/bin/activate"
alias rungit="~/ah/start_git.sh"
alias rundev="~/ah/start_dev.sh"
alias stopdev="api && docker compose stop && tmux kill-session -t dev && cd ~"
alias killtmux="tmux kill-server"
alias listtmux="tmux ls"
alias awsconfig="code ~/.aws/config"
alias awscreds="code ~/.aws/credentials"
alias op="code ."

#GIT
alias login="gh auth login"
alias st="git st"
alias pull="git pull"
alias cob="git co -b"
alias co="git co"
alias push="git push"
alias gdiff="git diff"
alias add="git add ."
alias back="git co -"
alias rebase="git rebase -i"
alias forcePush="git push -f"
alias continue="git rebase --continue"
alias emptyCommit="git commit --allow-empty"

##for pushing a new branch
alias gph="gitPushHarder"
gitPushHarder(){
    local branch=$(git branch | sed -n -e 's/^\* \(.*\)/\1/p')
    git push -u origin "$branch"
}

##prepends the jira ticket to the commit
alias gcff='git-commit-feature'
myInitials='bd'
git-commit-feature() {
    local branch=$(git branch --show-current)
    local jiraNum=$(echo "$branch" | sed -E "s|^${myInitials}/([A-Z]+-[0-9]+)_.*|\1|") # change bd in the regex to your initials
    git commit -m "[$jiraNum]: $1"
}

##git stash optional message
alias stash="git-stash"
git-stash() {
    if [ -z "$1" ]
    then
        git stash
    else
        git stash save "$1"
    fi
}

## Docker cmds
alias dockmig="docker compose run migrations"
alias dockrab="docker compose up db rabbitmq"
alias docktest="docker compose up db-test"
alias dockbuildup="docker compose up --build"
alias dockUp="docker compose up"
alias dockdown="docker compose down"

## Alembic Cmds
alias uphead="poetry run alembic upgrade head"
alias testuphead="set -a && source .env.tests && set +a && uphead"
alias downgead="poetry run alembic downgrade head"
alias createmig="poetry run alembic revision --autogenerate -m"
alias resetdev="set -a && source .env && set +a"


## aws
devAwsTargetId="i-"
uatAwsTargetId="i-"
prodAwsTargetId="i-"
toprodAwsTargetId="i-"
toUatAwsTargetId="i-"
ahAwsTargetId=""



getInstances(){
  instanceName="bastion-member-portal"
  case $1 in
    dev)
      profile="accesshope-dev"
      awsVar="devAwsTargetId"
      instanceName="bastion-member-portal"
      ;;
    uat)
      profile="accesshope-uat"
      awsVar="uatAwsTargetId"
      instanceName="PatientPortal"
      ;;
    prod)
      profile="accesshope-prod"
      awsVar="prodAwsTargetId"
      instanceName="bastion-member-portal"
      ;;
    toprod)
      profile="accesshope-to-prod"
      instanceName="OncologyPortal"
      awsVar="toprodAwsTargetId"
      ;;
    *)
      profile="accesshope-dev"
      instanceName="PatientPortal"
      awsVar="devAwsTargetId"
      ;;
  esac

  echo "Updating variable $awsVar with Instance ID from $profile"
  instanceId=$(AWS_PROFILE=$profile aws ec2 describe-instances \
  --filters Name=instance-state-name,Values=running \
  --output json | \
  awk '
    /"InstanceId":/ {instanceId = $2}
    /"Tags":/ {getline; getline; getline; key = $2 $3; getline; value = $2; print instanceId " : " key}
  ' | \
    tr -d '",' | \
    grep $instanceName | \
    awk -F' :' '{print $1}')

  if [[ -n "$instanceId" ]]; then
    echo -n "$instanceId" | pbcopy
    echo "Instance ID for $instanceName copied to clipboard: $instanceId"
    # Update the aws targetId variable in this file
    sed -i '' "s/^$awsVar=.*/$awsVar=\"$instanceId\"/" "$HOME/.oh-my-zsh/custom/profile.zsh"
    echo "$awsVar updated to $instanceId in profile.zsh"
    resource
  else
    echo "No instance found for $instanceName."
  fi
}

## Contentful
managementToken="" 
mpSpaceId=""
toSpaceId=""
alias contLogin="contentful login --management-token $managementToken"
alias contMp="contentful space use --space-id $mpSpaceId"
alias contTo="contentful space use --space-id $toSpaceId"
alias contSpaceList="contentful space list"
alias contEnvList="contentful space environment list"
alias contEnvUse="contentful space environment use --environment-id "
alias cExportMaster="contentful space export --space-id $mpSpaceId --environment-id master"
alias cExportToMaster="contentful space export --space-id $toSpaceId --environment-id master"
alias cExportDev="contentful space export --space-id $mpSpaceId --environment-id dev"
alias cImport="contentful space import \
  --space-id $mpSpaceId \
  --environment-id master \
  --upload-concurrency 1 \
  --rate-limit-delay 6000 \
  --content-file "

alias cToImportTemp="contentful space import \
    --space-id uxtd54clmpud \
    --environment-id master \
    --upload-concurrency 1 \
    --rate-limit-delay 6000 \
    --content-file "


deployContentful() {
  local target_space_alias="$1" # The argument passed, e.g., 'mp' or 'to'
  local space_id=""
  local master_env="master"
  local dev_env="dev"

  case "${target_space_alias}" in
    mp | MP)
      if [[ -z "${mpSpaceId}" ]]; then
        echo "Error: 'mpSpaceId' environment variable is not set." >&2
        echo "Please set it (e.g., 'export mpSpaceId=\"YOUR_MP_SPACE_ID\"') before calling this function." >&2
        return 1
      fi
      space_id="${mpSpaceId}"
      echo "Deploying to Marketing Platform (MP) space: ${space_id}"
      ;;
    to | TO)
      if [[ -z "${toSpaceId}" ]]; then
        echo "Error: 'toSpaceId' environment variable is not set." >&2
        echo "Please set it (e.g., 'export toSpaceId=\"YOUR_TO_SPACE_ID\"') before calling this function." >&2
        return 1
      fi
      space_id="${toSpaceId}"
      dev_env="develop"
      echo "Deploying to Talent Operations (TO) space: ${space_id}"
      ;;
    *)
      echo "Error: Invalid or missing argument." >&2
      echo "Usage: deployContentful <mp|to>" >&2
      echo "  'mp' - Deploy to the Marketing Platform Contentful space." >&2
      echo "  'to' - Deploy to the Talent Operations Contentful space." >&2
      echo "Example: deployContentful mp" >&2
      return 1
      ;;
  esac

  
  # Define a predictable filename for the dev environment export.
  # This makes it easy to reference in the import step.
  local dev_export_filename="contentful-export-${space_id}-dev-$(date +%Y-%m-%d).json"

  echo "--- Starting Contentful Dev to Master Deployment ---"
  echo "Space ID: ${space_id}"
  echo "Exporting Dev environment to: ${dev_export_filename}"
  echo "---------------------------------------------------"

  # 1. Export Master Space (for backup/reference, not directly used in import)
  echo "1. Exporting Master Space..."
  # You can add --output-file here too if you want to keep this backup
  contentful space export --space-id "${space_id}" --environment-id "${master_env}"
  local export_master_status=$?
  if [[ $export_master_status -ne 0 ]]; then
    echo "Error: Master export failed (exit code ${export_master_status}). Aborting." >&2
    return $export_master_status
  fi
  echo "Master Space Exported successfully."
  echo "---------------------------------------------------"



  # 2. Export Dev Space to the specified JSON file
  echo "2. Exporting Dev Space to '${dev_export_filename}'..."
  contentful space export \
    --space-id "${space_id}" \
    --environment-id "${dev_env}" \
    --output-file "${dev_export_filename}"


  local export_dev_status=$?
  if [[ $export_dev_status -ne 0 ]]; then
    echo "Error: Dev export failed (exit code ${export_dev_status}). Aborting." >&2
    # Clean up any partial export file if it exists
    [[ -f "${dev_export_filename}" ]] && rm -f "${dev_export_filename}"
    return $export_dev_status
  fi
  echo "Dev Space Exported successfully. File: ${dev_export_filename}"
  echo "---------------------------------------------------"

  # After export, find the most recent export file and rename it to the expected filename
  latest_export=$(ls -t contentful-export-${space_id}-dev-*.json | head -n1)
  if [[ "$latest_export" != "$dev_export_filename" ]]; then
    mv "$latest_export" "$dev_export_filename"
  fi

  echo "Dev Space Exported successfully. File: ${dev_export_filename}"
  echo "---------------------------------------------------"


  # 3. Import the Dev export file into the Master Space
  echo "3. Importing '${dev_export_filename}' into Master Space..."
  contentful space import \
    --space-id "${space_id}" \
    --environment-id "${master_env}" \
    --upload-concurrency 1 \
    --rate-limit-delay 6000 \
    --content-file "${dev_export_filename}"

  local import_status=$?
  if [[ $import_status -ne 0 ]]; then
    echo "Error: Import into Master failed (exit code ${import_status}). Please check Contentful CLI output above for details." >&2
    echo "The temporary export file '${dev_export_filename}' has NOT been removed in case you need to inspect it." >&2
    return $import_status
  fi
  echo "Successfully imported Dev content into Master Space."
  echo "---------------------------------------------------"

  # 4. Clean up the temporary export file
  # echo "Cleaning up temporary export file: '${dev_export_filename}'"
  # rm -f "${dev_export_filename}"
  
  echo "--- Contentful Dev to Master Deployment COMPLETE! ---"
  return 0 # Indicate successful completion
}



imagedownload(){
  cd ~/ah/image-transfer
  local case_number="$1"
  if [[ -z "$case_number" ]]; then
    echo "Usage: imagedownload <case_number>"
    echo "Example: imagedownload 000123"
    return 1 # Exit the function with an error code
  fi

  # --- Source S3 Details (from your existing setup) ---
  local source_bucket_name=''
  local source_aws_profile=''
  local s3_source_path=""

  # --- Destination S3 Details ---
  local destination_bucket_name='' 
  local destination_aws_profile=''
  local s3_destination_path=""

  # --- Local Storage Path ---
  # Temporary local path to store files during transfer.
  # Using mktemp -d is safer for temporary directories than a fixed path like /tmp
  local temp_local_path
  temp_local_path=$(mktemp -d -t "medical_images_transfer-${case_number}-XXXX")

  if [[ ! -d "$temp_local_path" ]]; then
    echo "Error: Failed to create temporary local directory." >&2
    return 1
  fi
  echo "Temporary local path created at: ${temp_local_path}"

  echo "Starting image transfer for case: ${case_number}"
  echo "  Source S3: ${s3_source_path} (using profile: ${source_aws_profile})"
  echo "  Destination S3: ${s3_destination_path} (using profile: ${destination_aws_profile})"
  echo "  Local temporary storage: ${temp_local_path}"

  # --- STEP 1: Download from Source S3 ---
  echo "Downloading images from source S3 bucket..."
  AWS_PROFILE="${source_aws_profile}" aws s3 cp \
    "${s3_source_path}" \
    "${temp_local_path}/" \
    --recursive \
    --no-progress # Optional: Suppress progress bar for cleaner output in logs

  if [[ $? -ne 0 ]]; then
    echo "Error: Failed to download images for case: ${case_number} from source S3." >&2
    echo "  Please check the AWS CLI output above for details and ensure source profile permissions." >&2
    rm -rf "${temp_local_path}" # Clean up temporary directory
    return 1
  fi
  echo "Successfully downloaded images to local temporary path."

  # --- STEP 2: Upload to Destination S3 ---
  echo "Uploading images to destination S3 bucket..."
  AWS_PROFILE="${destination_aws_profile}" aws s3 cp \
    "${temp_local_path}/" \
    "${s3_destination_path}" \
    --recursive \
    --no-progress \
    # --acl public-read # Optional: Make uploaded objects publicly readable. Adjust as needed!

  if [[ $? -ne 0 ]]; then
    echo "Error: Failed to upload images for case: ${case_number} to destination S3." >&2
    echo "  Please check the AWS CLI output above for details and ensure destination profile permissions." >&2
    rm -rf "${temp_local_path}" # Clean up temporary directory
    return 1
  fi
  echo "Successfully uploaded images for case: ${case_number} to destination S3."

  # --- Cleanup ---
  echo "Cleaning up local temporary files..."
  rm -rf "${temp_local_path}"
  if [[ $? -ne 0 ]]; then
    echo "Warning: Failed to remove temporary local directory '${temp_local_path}'. You may need to remove it manually." >&2
  fi
  
  echo "Image transfer complete for case: ${case_number}."
  return 0 # Indicate success
}

# Enable substitution in the prompt.
setopt prompt_subst
