#!/bin/zsh
# performs a search on firefox

os_type=$(uname -s)

if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    firefox --new-tab --url "http://localhost:6060/?q=$1"
elif [[ "$OSTYPE" == "darwin"* ]]; then
    /Applications/Firefox.app/Contents/MacOS/firefox --new-tab --url "https://searxng.site/searxng/?q=$1"
else
    echo "Unsupported operating system: $OSTYPE"
fi
