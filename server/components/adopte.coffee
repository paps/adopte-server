"use strict"

needle = require "needle"
config = require "../config/config"

httpOptions =
    json: yes
    headers:
        'User-Agent': config.adopte.agent
        'Authorization': config.adopte.auth
    proxy: config.adopte.proxy

exports.fetchProfile = (id, done) ->
    needle.request "get", "http://www.adopteunmec.com/api/users/" + id, null, httpOptions, (err, res) ->
        if err
            done 'Adopte error: ' + err.toString()
        else if res.statusCode != 200
            done 'Adopte returned HTTP ' + res.statusCode
        else
            if (typeof res.body) is 'object' and (res.body isnt null) and Object.keys(res.body).length > 30
                delete res.body.$ref # lol
                done null, res.body
            else
                done 'Adopte returned a weird json'
