The `curl` request in `fetch-recent-news-events.sh` looks like this:

```
curl https://www.vrt.be/vrtnws/_next/data/u6iWbVYnh9kHIkeff4lxk/nl/net-binnen.json
```

`u6iWbVYnh9kHIkeff4lxk`, the part between `data` and `nl` in the URL, updates every couple of hours.
When there's a new value, the `curl` request won't return anything anymore.
I want to update `fetch-recent-news-events.sh` and `.github/workflows/scrape.yml` so every couple of hours a script gets the new value for the URL and makes it available.

The Playwright script should open `https://www.vrt.be/vrtnws/nl/net-binnen/`. This triggers a request to `https://www.vrt.be/vrtnws/_next/data/u6iWbVYnh9kHIkeff4lxk/nl/net-binnen.json` (`u6iWbVYnh9kHIkeff4lxk` is the dynamic part). The script gets the `net-binnen.json` URl, extracts the dynamic part and returns it.