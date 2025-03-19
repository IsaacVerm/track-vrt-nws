#!/bin/bash

# the URL to fetch the events contains a dynamically changing inner part
# a separate workflow is used to fetch this inner part every couple of hours
# first get the most recent version of that dynamic part
DYNAMIC_URL_PART=$(cat dynamic-part-net-binnen-url.txt)
echo "Successfully retrieved dynamic URL part: $DYNAMIC_URL_PART"

# now I fetch the most recent events
# net-binnen.json contains the last 100 events
curl "https://www.vrt.be/vrtnws/_next/data/${DYNAMIC_URL_PART}/nl/net-binnen.json" | \
    # some objects are not really about events but just ads, these have no uri and can be removed
    jq -c ".pageProps.data.compositions[0].compositions[] | {title: .title.text, timestamp: .metadata[0].timestamp, tag: .tag.text, uri: .action.uri} | select(.uri != null)" \
    > recent-events.jsonl

# now I compare recent-news-events.jsonl with main-events
# I want to know which events are new
# these events are saved to a file called new-events.jsonl
# to determine whether an event is new I could either look at the url or the article title
# the url (called uri here) always remains the same, even if the article title changes
# however, I find these changes to the article titles themselves interesting
# so whenever the title of an article changes, I consider it a new event
# even if it still refers to the same article
# so in a sense new-events.jsonl contains duplicate events but with different titles
# -n (--null-input) is required because the data is loaded using --slurpfile, not from standard input
# so nothing like cat main-events.jsonl | ...
jq -c -n --slurpfile main main-events.jsonl --slurpfile recent recent-events.jsonl \
   '$recent | map(select(.title as $title | $main | map(.title) | index($title) | not)) | .[]' \
   > new-events.jsonl

# append new events to main events (in JSONL format)
cat new-events.jsonl >> main-events.jsonl

# have main events in JSON format as well next to JSONL format
# this is required to display the data in Datasette Lite
jq -s '.' main-events.jsonl > main-events.json