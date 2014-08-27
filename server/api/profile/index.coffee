'use strict'

express = require 'express'
controller = require './profile.controller'
config = require '../../config/config'
auth = require "../../auth/auth.service"

router = express.Router()

checkAuth = (req, res, next) ->
    if (req.query.key is config.adopte.key)
        next()
    else
        res.send 401

router.get '/', checkAuth, controller.index
router.get '/:id', checkAuth, controller.get
router.get '/visite/:id/:mails/:charmes/:visites/:paniers', checkAuth, controller.visite
router.get '/charme/:id', checkAuth, controller.charme

module.exports = router
