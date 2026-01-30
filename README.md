#  Pixel

The custom CLI for Pageking projects. This CLI is written for and by Pageking, usable in projects in with the [pk-theme](https://github.com/Pageking/pk-theme) and [pk-theme-child](https://github.com/Pageking/pk-theme-child) themes. 

## Installation

1.  Install [Brew](https://docs.brew.sh/Installation)
2.  Install the [1Password CLI](https://developer.1password.com/docs/cli/)
3.  Install the [GitHub CLI](https://github.com/cli/cli/blob/trunk/docs/install_macos.md)
4.  Make sure you have the [LocalWP](https://localwp.com/help-docs/getting-started/installing-local/) application

When all programs are installed, make sure you are logged in correctly in all different CLI tools. 

For 1Password, make sure you have the <a href="https://developer.1password.com/docs/ssh/agent/" target="_blank">SSH agent</a> enabled.

For Github, make sure you have authenticated with your own Pageking Github account with `gh auth login`. For more info, check the <a href="https://docs.github.com/en/github-cli/github-cli/quickstart" target="_blank">quickstart guide</a>.

##  Usage

This CLI should always be used in the `/app/public/` folder of your LocalWP folder. All commands should give an error when this requirement is not met.

### First time setup

Open a terminal and type `pixel`. You will be prompted to create a config file. After the config file is created, contact a fellow developer with a working Pixel to 
copy that config.json. It can be located at `~/.config/pixel/config.json`

##  Initializing a project

If this is a new project you're working on, always start by creating a site with the most current blueprint. You can find the ziped blueprints here: https://drive.google.com/drive/folders/1HkAeqjd-BsY8hgITraNM5OXNHbeZfGGC?usp=share_link.

When your new project in LocalWP is created, open your terminal and navigate to the project's folder. When you're in the `/app/public/` folder, type:

`pixel init`

This should setup your project by pulling the latest version of the [pk-theme](https://github.com/Pageking/pk-theme) and creating a new repo based on the name of your LocalWP project name. 
You will automatically checkout the development branch, since this is the branch you will start committing your changes to.

## Developing and testing your project

Whenever the day ends, or when you have finished a feature, you will commit your changes to the development branch. It is good practice to sync your project to the test enviroment once in while, so 
project managers and clients can review your progress. To setup your test enviroment, there are some steps required:

### Setting up the test enviroment

> [!TIP]
>  If this is your first project with Pixel, you will need to setup an SSH connection with the Plesk server. Contact a senior developer to help you with this.

1. `pixel init-test`
2. You will be prompted to enter the connection info, follow the steps below:
3. When your Plesk environment is created, navigate to the Plesk panel and create an SSL certificate.
5. Now login to the backend and enter the WP Migrate plugin license key.
6. Check both toggles next to the connection info and copy the connection info with the "Copy to clipboard" button.
7. Paste the contents of the connection info into the terminal and press Enter.
<img width="1173" height="274" alt="image" src="https://github.com/user-attachments/assets/832dc55c-439d-4e88-8227-d2af1489b2ab" />


Your project should now be running on the Plesk server. Whenever you merge **(WITH A PULL REQUEST)** your changes to the test branch, your code will automatically be deployed to the test/Plesk server.

### Syncing your project after `init-test`

If you want to sync some part of the project which is not included in the pk-theme-child (media files, plugins, database), you can use the following command:

`pixel sync-dev-to-test`

Or

`pixel sync-test-to-dev`

> [!TIP]
> You can add the following "flags" to the command for more control:
>
> 
> `--no-database` : Skip database synchronization
> 
> `--no-plugins` : Skip Plugin synchronization
> 
> `--no-media` : Skip Media/Uploads synchronization

> [!NOTE]
> If the pk-theme is updated during development, the pk-theme on the test enviroment is out-of-sync with your local one. To update the pk-theme on the test enviroment, use the `pixel test-pull-main` command.

## Deploying your project to Cloudways

Whenever you need to deploy your project to Cloudways, you need to use the following command:

`pixel init-prod`

***Without this setup, your project cannot be updated correctly!***

You will be prompted to select a Cloudways server, please choose the newest one or a CW Server {X}.

Type in the label of the Cloudways Application. This *can* be different from your project, but best practice is to name it after the project you're working on.

Follow the same steps as you did with the setup of the test environment.

### Syncing your project after `init-prod`

If you want to sync some part of the project which is not included in the pk-theme-child (media files, plugins, database), you can use the following command:

`pixel sync-dev-to-prod`

Or

`pixel sync-prod-to-dev`

> [!TIP]
> You can add the following "flags" to the command for more control:
>
> 
> `--no-database` : Skip database synchronization
> 
> `--no-plugins` : Skip Plugin synchronization
> 
> `--no-media` : Skip Media/Uploads synchronization
