#!/bin/bash
curl https://www.vrt.be/vrtnws/_next/data/lOVEAve2b6oRA8in28B4v/nl/net-binnen.json | \
    # some objects are not really about events but just ads, these have no uri and can be removed
    jq -c ".pageProps.data.compositions[0].compositions[] | {title: .title.text, timestamp: .metadata[0].timestamp, tag: .tag.text, uri: .action.uri} | select(.uri != null)" \
    > recent-news-events.json