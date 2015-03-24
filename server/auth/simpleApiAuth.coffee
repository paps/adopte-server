'use strict'

config = require '../config/config'

module.exports = (req, res, next) ->
    if (req.query.key is config.adopte.key)
        next()
    else
        res.send 401
