"use strict"

module.exports = (config) ->

    # config.ip = "0.0.0.0"

    config.secrets.session = "xxxxxx"

    # optional
    config.mongo.uri = "mongodb://user:password@host/database"

    config.adopte =
        agent: "Mozilla/5.0 (X11; Linux x86_64; rv:31.0) Gecko/20100101 Firefox/31.0"
        auth: "Basic xxxxxxxx" # Adopte JSON api HTTP auth (meaning: base64 encoded login/pwd pair)
        key: "xxxxxxxx" # auth key for bot/greasemonkey
        serverUrl: "https://foo-bar.com:15000/" # optional, used only by stats-generator
        subscribeDate: "2014-12-20" # optional, used only by stats-generator
        proxy: null # or 'http://user:pass@proxy.server.com:3128' (for querying Adopte JSON api)
