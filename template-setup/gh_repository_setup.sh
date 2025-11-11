#!/bin/bash
### BELOW PREREQUISITE CHECKLIST TO ENSURE ALL CLI'S AND EXPECTED VALUES ARE CORRECTLY SETUP 


#################### BEGIN SCRIPT LOGIC #############################
REPOSITORY_OWNER="jdschleicher"
TEMPLATE_NAME="salesforce-dx-unlocked-package-template"
DEVHUB_ALIAS="jschl-devhub"
ORG_NAME="Company"
IS_PUBLIC_REPOSITORY=true  #if repository is not a pro github account and is private then the brahcn protection rules features will not be enabled

gh_create_repo_from_dx_template() {
    echo What is the Project Name?
    read PROJECT_NAME
	PROJECT_NAME=$(echo $PROJECT_NAME | tr '[:upper:]' '[:lower:]')
    echo What is the description of this project?
    read DESCRIPTION
    
	echo_job "CREATING REPOSITORY"

	##### IF CREATING TEMPLATE IN ENTERPRISE ORGANIZATION USE --internal instead of --private as this plays into functionality aroung GitHub Actions"
	##### YOU WILL ALSO NEED TO ADJUST THE REPOSITORY_OWNER AND TEMPLATE_NAME VARIABLES ABOVE
	##### AND IN THE EVENT OF USING AN ORGANIZATION ACCOUNT USE THE BELOW LINES AND COMMENT OUT LINES 27-28
	# echo gh repo create /"$REPOSITORY_OWNER/$PROJECT_NAME/" --description \"$DESCRIPTION\" --template \"$REPOSITORY_OWNER/$TEMPLATE_NAME\" --internal
	# gh repo create "$REPOSITORY_OWNER/$PROJECT_NAME" --description "$DESCRIPTION" --template "$REPOSITORY_OWNER/$TEMPLATE_NAME" --internal 
	
	##### IN THE EVENT OF A PERSONAL ACCOUNT USE BELOW GitHub repo creation command
	echo gh repo create \"$PROJECT_NAME\" --description \"$DESCRIPTION\" --template \"$REPOSITORY_OWNER/$TEMPLATE_NAME\" --private --clone
	gh repo create "$PROJECT_NAME" --description "$DESCRIPTION" --template "$REPOSITORY_OWNER/$TEMPLATE_NAME" --private --clone

	ls
	cd $PROJECT_NAME
	ls

	echo_job "SETTING UP REPOSITORY SECRETS"
	# setup_github_repository_secrets $PROJECT_NAME

	echo_job "REPLACE TEMPLATE PLACEHOLDER VALUES WITH ENTERED PROJECT INFORMATION"
	# github_project_specific_setup $PROJECT_NAME $ORG_NAME

	echo_job "GH API SETUP OF BRANCH PROTECTION RULES FOR master AND release*"
	setup_branch_protection_rules $REPOSITORY_OWNER $PROJECT_NAME

	echo_job "INITIALIZING UNLOCKED PACKAGE SETUP"
	# initialize_dx_project $PROJECT_NAME $DESCRIPTION

	#OPEN NEW REPOSITORY IN VS CODE
	echo_job "OPENING PROJECT IN VS CODE"
	# code .

}

github_project_specific_setup(){
	PROJECT_NAME=$1
    ORG_NAME=$2

    echo_job "RENAMING PROJECT [[app_name]] AND ORG [[org]] TEMPLATE VALUES WITH CAPTURED PROJECT AND ORG VALUES"

    mv "app/[[app_name]]" "app/$PROJECT_NAME"
    git grep -l "\[\[org\]\]" | xargs sed -i "s/\[\[org\]\]/$ORG_NAME/g"
	git grep -l "\[\[app_name\]\]" | xargs sed -i "s/\[\[app_name\]\]/$PROJECT_NAME/g"
	git commit -am "initialization of project variables to template"
	git push origin 
}

initialize_dx_project() {
	packageName=$1
    description=$2
	packageType="Unlocked"
	targetdevhubusername=$DEVHUB_ALIAS
    path="app"/"$packageName"

    echo sfdx force:package:create --targetdevhubusername=$targetdevhubusername --name $packageName --packagetype $packageType --path $path --description "$description" --nonamespace
    time sfdx force:package:create --targetdevhubusername=$targetdevhubusername --name $packageName --packagetype $packageType --path $path --description "$description" --nonamespace

	git commit -am "package initialization"
	git push origin
}

setup_branch_protection_rules() {
	
	owner=$1
	repo_name=$2
	repositoryId="$(gh api graphql -f query='{repository(owner:"'$owner'",name:"'$repo_name'"){id}}' -q .data.repository.id)"

	gh api graphql -f query='
	mutation($repositoryId:ID!) {
	createBranchProtectionRule(
		input: {
			repositoryId: $repositoryId
			pattern: "master"
			requiresApprovingReviews: true
			requiredApprovingReviewCount: 1
			allowsForcePushes: false
			dismissesStaleReviews: true
			requiredStatusCheckContexts: ["master_pull_request_job"]
			requiresStatusChecks: true
		}
	) { clientMutationId }
	}' -f repositoryId="$repositoryId"

}

setup_github_repository_secrets() {

	PROJECT_NAME=$1
	PROJECT_NAME=$( echo $PROJECT_NAME | tr '[:upper:]' '[:lower:]')
	echo "PROJECT_NAME: $PROJECT_NAME"

	gh secret set UNLOCKED_PACKAGE_APP_NAME -b "$PROJECT_NAME";
	gh secret set UAT_SANDBOX_ORG_URL -b "https://theorg--uat.my.salesforce.com";
	gh secret set UAT_SANDBOX_AUTH_URL -b "org_uath_url";
	gh secret set DEVHUB_ORG_URL -b "https://devhub.my.salesforce.com";
	gh secret set DEVHUB_CLIENTID -b "connected_app_client_id";
	gh secret set CICD_DEVHUB_USERNAME -b "devhub_username@devhub.com";
	gh secret set DEVHUB_KEY -b "devhubserverkeyforconnetedapp";
	gh secret set CENTRALIZED_REPOSITORY_GITHUB_ACCESS_KEY -b "key_from_github_repository_where_centralized_cicd_logic_is_stored";
}

echo_job() {
	echo ""
	echo ""
	echo ""
	echo "***********************************************************"
	echo "***********************************************************"
	echo ""
	echo $1
	echo ""
	echo "***********************************************************"
	echo "***********************************************************"
	echo ""
	echo ""
	echo ""
}

gh_create_repo_from_dx_template