# Go vim/tmux Environment Installation

## Pre-Installation

Configure SSH Keys [instructions](https://docs.github.com/en/github/authenticating-to-github/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent)

```bash
ssh-keygen -t rsa -b 4096 -C "your_email@example.com" 
cat ~/.ssh/id_rsa.pub
```

After the keys are generated then copy the public key to Github.

## Installation

Clone the repository

```bash
git clone https://github.com/benjivesterby/env.git
```

Execute the installation script

```bash
./env/env.sh -i
```

## Updating your environment

Execute the script without the -i flag

```bash
./env/env.sh
```

### Current Font

`Monoid Nerd Font`
### Setting up Font in Terminal - MAC ZSH

Terminal: You must set the font in terminal properly after installation for Powerline fonts

`Preferences -> Startup Theme -> Text (tab) -> Font (Change) -> Select Font`

You must setup the fonts in the settings for ITerm in order for the chevrons to
show properly.

`Preferences -> Profiles -> User -> Text (tab) -> Font Dropdown -> Select Font`

### Setting the font for the VSCode terminal

[How To](https://dev.to/mattstratton/making-powerline-work-in-visual-studio-code-terminal-1m7)

Add setting: to VSCode json configuration

```json
{
    "terminal.integrated.fontFamily": "Monoid Nerd Font",
}
```

### GPG Configuration

After installing the env script unplug and re-plug Yubikey with the
signing key on it

Execute `gpg --card-status` to ensure that the key is visible to the gpg system.

NOTE: if the key ids are not showing properly then execute the following

```bash
gpg --card-edit
gpg/card> fetch
```
Ths will pull the public key from the keyserver. If this doesn't work it's because
the URL in the Yubikey is not set for where to pull the public key. 

Once the card status shows the keys stored on the yubikey

Add the key you want to sign with to your global git configuration.

```bash
git config --global user.signingkey <KEYID>
```

### Notes

For Ubuntu the lint script will not properly work unless you reconfigure the 
default shell from dash => bash using `sudo dpkg-reconfigure dash` and selecting
`NO` as the option to unlink dash from `/bin/sh` otherwise the list of git files
will not work in the lint script. 
