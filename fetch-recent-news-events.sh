#!/bin/bash
# first I fetch the most recent events
# net-binnen.json contains the last 100 events
curl https://www.vrt.be/vrtnws/_next/data/u6iWbVYnh9kHIkeff4lxk/nl/net-binnen.json | \
    # some objects are not really about events but just ads, these have no uri and can be removed
    jq -c ".pageProps.data.compositions[0].compositions[] | {title: .title.text, timestamp: .metadata[0].timestamp, tag: .tag.text, uri: .action.uri} | select(.uri != null)" \
    > recent-events.json

# now I compare recent-news-events.json with main-events
# I want to know which events are new
# these events are saved to a file called new-events.json
# to determine whether an event is new I could either look at the url or the article title
# the url (called uri here) always remains the same, even if the article title changes
# however, I find these changes to the article titles themselves interesting
# so whenever the title of an article changes, I consider it a new event
# even if it still refers to the same article
# so in a sense new-events.json contains duplicate events but with different titles
# -n (--null-input) is required because the data is loaded using --slurpfile, not from standard input
# so nothing like cat main-events.json | ...
jq -c -n --slurpfile main main-events.json --slurpfile recent recent-events.json \
   '$recent | map(select(.title as $title | $main | map(.title) | index($title) | not)) | .[]' \
   > new-events.json

# concatenate main-events.json and new-events.json and save the result to main-events.json
cat new-events.json >> main-events.json