# env
Development Environment Setup and Notes

### Install TMUX

#### Linux

#### Mac

```bash
brew install tmux
```

### Install TMUX plugin manager
```bash
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
```

### Install NVIM

Source: https://github.com/neovim/neovim/wiki/Installing-Neovim

```bash
brew install neovim
```

### Setting up Font in Terminal - MAC ZSH

Terminal: You must set the font in terminal properly after installation for Powerline fonts

`Preferences -> Startup Theme -> Text (tab) -> Font (Change) -> Select Font`

You must setup the fonts in the settings for ITerm in order for the chevrons to show properly.

`Preferences -> Profiles -> User -> Text (tab) -> Font Dropdown -> Select Font`

### Setting the font for the VSCode terminal

https://dev.to/mattstratton/making-powerline-work-in-visual-studio-code-terminal-1m7

Add setting: to VSCode json configuration

```json
{
    "terminal.integrated.fontFamily": "Inconsolata for Powerline",
}
```
