"use strict"

needle = require "needle"
config = require "../config/config"

httpOptions =
    json: yes
    headers:
        'User-Agent': config.adopte.agent
        'Authorization': config.adopte.auth

exports.fetchProfile = (id, done) ->
    needle.request "get", "http://www.adopteunmec.com/api/users/" + id, null, httpOptions, (err, res) ->
        if err
            done 'Adopte error: ' + err.toString()
        else if res.statusCode != 200
            done 'Adopte returned HTTP ' + res.statusCode
        else
            done null, res.body
