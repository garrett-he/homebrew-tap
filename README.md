# Garrett's Homebrew Tap

A personal [Homebrew](https://brew.sh) tap for formulae and casks.

## Installation

Tap this repository to make its packages available to Homebrew:

```sh
brew tap garrett-he/tap
```

You can also install a package directly without tapping first — Homebrew will add the
tap automatically:

```sh
brew install garrett-he/tap/<formula>
```

## Usage

Once the tap is installed, install packages by name:

```sh
brew install <formula>
```

Keep the tap and its packages up to date with:

```sh
brew update && brew upgrade
```

### Using a Brewfile

To declare this tap and its packages in a `Brewfile` for `brew bundle`:

```ruby
tap "garrett-he/tap"
brew "<formula>"
```

## Documentation

Run `brew help` or `man brew` for general usage, or visit the
[Homebrew documentation](https://docs.brew.sh) for more details.
