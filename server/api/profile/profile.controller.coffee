'use strict'

Profile = require './profile.model'

handleError = (res, err) ->
    res.send 500, err

exports.index = (req, res) ->
    Profile.find (err, profiles) ->
        if err then return handleError res, err
        res.json 200, profiles
