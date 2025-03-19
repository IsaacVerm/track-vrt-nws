# Explanation of the Bash Script

This script fetches and processes news events from VRT (a Belgian broadcaster) and tracks new events by comparing with previously saved events. Here's a breakdown of each step:

## Step 1: Fetching Recent Events
```bash
curl https://www.vrt.be/vrtnws/_next/data/u6iWbVYnh9kHIkeff4lxk/nl/net-binnen.json | \
    jq -c ".pageProps.data.compositions[0].compositions[] | {title: .title.text, timestamp: .metadata[0].timestamp, tag: .tag.text, uri: .action.uri} | select(.uri != null)" \
    > recent-events.json
```

- Uses `curl` to fetch JSON data from VRT's "net binnen" (recent news) endpoint
- Pipes the data to `jq` which:
  - Extracts each item from the compositions array
  - For each item, creates a new object with only the title, timestamp, tag, and uri fields
  - Filters out items that have no URI (these are identified as advertisements)
  - `-c` flag makes the output compact (one JSON object per line)
- Saves the resulting filtered data to `recent-events.json`

## Step 2: Identifying New Events
```bash
jq -c -n --slurpfile main main-events.json --slurpfile recent recent-events.json \
   '$recent | map(select(.uri as $uri | $main | map(.uri) | index($uri) | not)) | .[]' \
   > new-events.json
```

- Uses `jq` with the following flags and options:
  - `-c`: Output compact format
  - `-n`: Don't read input (null input mode)
  - `--slurpfile main main-events.json`: Load the main events file into the `$main` variable
  - `--slurpfile recent recent-events.json`: Load recent events into the `$recent` variable
- The jq expression does the following:
  - Takes all recent events (`$recent`)
  - Maps through them, selecting only events whose URI is not found in the main events file
  - `.[]` outputs each new event as a separate JSON object
- Saves these newly identified events to `new-events.json`

## Step 3: Updating Main Events List
```bash
cat new-events.json >> main-events.json
```

- Uses `cat` to read the content of `new-events.json`
- The `>>` operator appends this content to `main-events.json` without overwriting existing content
- This effectively adds all newly discovered events to the main tracking file

The overall purpose of this script is to maintain an ongoing record of news events by periodically checking for new items and adding them to a master list.
