'use strict'

config = require '../config/config'

module.export = (req, res, next) ->
    if (req.query.key is config.adopte.key)
        next()
    else
        res.send 401
