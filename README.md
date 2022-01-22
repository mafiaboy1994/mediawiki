# MediaWiki Azure deplopyment

This is a readme for MediaWiki Azure deployment

## Pre-Req

Install the following:
Linux OR WSL (Windows Sub-Linux)
GIT
PHP




## Download Source Files

1. Download Source files from mediawiki's website - https://www.mediawiki.org/wiki/Download
2. Extract ZIP in WSL Environment into a mediawiki folder
3. CD into current mediawiki local directory
```bash
cd mediawiki
```

## Git Repo
1. Create Repo for storing files for commits, pull & push etc
2. Initalize a new repo from an exsisting project, in my case the mediawiki source files downloaded in the previous step in the mediawiki folder
```bash
git init -b
```
3. Stage and commit all the files in the project which again my case is the local directory
```bash
git add . && git commit - "initial commit"
```
The above command adds all the files in the current directory which is what the (.) is for and then we commit them to the local git repo with the initial commit as this is the first time we are uploading the files

4. Now I've created the mediawiki public repo for deploying this project into azure
5. Set the local github configs to connect my user name and email to the git session
```bash
git config --global user.name "John Doe"
git config --global user.email "johndoe@example.com"
```

6.Add the URL for the remote repo which you can get from viewing your repo on GitHub and this will be where the local repo will be pushed too!
```bash 
git remote add origin <REMOTE_URL>
git remote -v

#Pushing git changes
1. Push changes in the local repo to the remote repo specified in the previous step
```bash
git push origin main
```

## Azure Resources setup
Now we have the local repo pushed to github. We now need to push this to Azure.
However before we do that we will need to setup the Azure resources, which include:
* Resource Group for all the resources
* Azure Web App (Azure App Service)
* Azure App Service Plan (Contains the web app)
* Azure MySQL Database Flexible
* Azure Virtual Network
* Azure NSG

You can choose whichever MySQL configuration you want but I chose flexible in the interest of keeping this project within the Azure Well Architectured framework
Also to make this highly available in production you would look to also include:
* Azure Application Gateway
* Web Application Firewall
* Segregation of virtual network for both frontend(web app) and backend(MySQL)

1. Create RG 
```bash
az group -g <RG Name> --location uksouth -n <RG Name>

2. Configure deployment user. This will be used to deploy resources in Azure fo rthis project. The username we choose much be unique within Azure and for local Git pushes mustn't contain the '@' symbol. The password must be at least
8 characters long, with letters, numbers and symbols ideally.
```bash
az webapp deployment user set --user-name <username> --password <password>
```
The JSON output shows the password as NULL. If you get a 'Conflict'.Details: 409 Error then change the username. If you get a 'Bad Request'. Details: 400 error, then use a stronger password.

3. Create the App Service Plan
```bash
az appservice plan create --name <name of app service plan> -g <RG Name> --sku <Sku> --is-linux
```
When this has been created, the Azure CLI will show the JSON output of this.

4. Create the web app
```bash
az webapp create -g <RG Name> --plan <App Service Plan name from previous step> --name <App Name> --runtime 'PHP|7.4' --deployment-local-git
```
Once this completes you can browse to your new web app page with the URL it gives you in the outputted JSON format under the JSON defaultHostName property
It will also give you the local git is configured with URL, save this as you will need for the below section when we push the local repo to azure remote.

5. Finally, we want to setup an Azure MySQL Flexible database, I did this from the portal but you can do this from the CLI also!
Make sure to remember what password you use, as well as taking a note of the URL as this will be used to connect the app to the DB



## Pushing git to Azure
Now we've deployed the resources, we will need to push the local repo to the Azure web app

1. Set the default deployment branch for the App Service App to 'main'
```bash
az webapp config appsettings set --name <app name> -g <RG name> --settings DEPLOYMENT_BRANCH='main'
```
2. Add an Azure remote to the local git repo
```bash
git remote add azure <DeploymentLocalGitURL-from-previous-section>
```
3. Push to the Azure remote to deploy mediawiki to the azure app
```bash
git push azure main
```
This may take a while!


#Extensions Required
I had to add the following Application settings and ini configurations for installing APCU

1. Add the following Application setting to point to the INI file we will create for APCU which is caching for mediawiki
NAME: PHP_INI_SCAN_DIR
VALUE: /usr/local/etc/php/conf.d:/home/site/ini

2. SSH into the app service on azure using the SSH option under Development Tools section
3. Create a temporary new folder to store the compiled apcu.so file extension
```bash 
mkdir -p /tmp/pear/temp
```
4. Now we will download the bundled source using pecl to configure and build the .so extension file
```bash
pecl bundle apcu
cd apcu
phpize
./configure
make
```
5. After a successful configure and make, a new directory called modules will have been created with an apcu.la and apcu.so file. Move the .so file into your home directory, for example /home/site/ext
```bash
mkdir -p /home/site/ext
cp /tmp/pear/temp/apcu/modules/apcu.so /home/site/ext
```
6. With the new extension moved to location where it will persist after a restart, an .ini file is needed so that PHP can load this extension when it starts up (REMEMBER the application setting we added on the app!)
SO create a new directory for your .ini file
```bash
mkdir -p /home/site/ini
echo "extension=/home/site/ext/apcu.so" > /home/site/ini/apcu.ini
This will now load on reboot as we've pointed it to this location in step 1 when we added the application setting on the app in azure.

#Verify APCU
Verify APCU is installed:
```bash
php -i | grep apc
```

That's it for facilitating the media wiki install


## Installing MediaWIki
Simply navigate to your public URL for the web app and specify the Database host which is the URL shown on your MySQL resource and the username and password you specified when you created the MySQL for Azure resource.
You may have issues connecting the DB due to MySQL SSL connection requirements.
You can turn off this in the server parameters for testing as MediaWiki doesn't support SSL MySQL connections out of the box. However you can modify it to allow this, which I will add to this repo in due course


Thanks,
MafiaBoy1994
























