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
router.get '/visite/:id/:mails/:charmes/:visites/:paniers', checkAuth, controller.visite
router.get '/charme/:id', checkAuth, controller.charme
router.get '/avis/:id/:avis', checkAuth, controller.avis
router.post '/notes/:id', checkAuth, controller.notes
router.get '/liste-charme', checkAuth, controller.listeCharme
router.get '/liste-charme-profils', checkAuth, controller.listeCharmeProfils
router.post '/bot-status', checkAuth, controller.postBotStatus
router.get '/bot-status', checkAuth, controller.getBotStatus
router.get '/:id', checkAuth, controller.get

module.exports = router
