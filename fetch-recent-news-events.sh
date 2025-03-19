#!/bin/bash
curl https://www.vrt.be/vrtnws/_next/data/u6iWbVYnh9kHIkeff4lxk/nl/net-binnen.json | \
    # some objects are not really about events but just ads, these have no uri and can be removed
    jq -c ".pageProps.data.compositions[0].compositions[] | {title: .title.text, timestamp: .metadata[0].timestamp, tag: .tag.text, uri: .action.uri} | select(.uri != null)" \
    > recent-news-events.json

# https://jqlang.org/manual/#invoking-jq
# -s (slurp) reads all files into a single array
# https://jqlang.org/manual/#group_by
# if there's a duplicate uri, I just keep the first object
jq . news-events.json recent-news-events.json | jq -s 'group_by(.uri)[] | .[0]' | jq -c . > news-events.json