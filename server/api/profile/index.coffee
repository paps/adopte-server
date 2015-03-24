'use strict'

express = require 'express'
controller = require './profile.controller'
auth = require '../../auth/simpleApiAuth'

router = express.Router()

router.get '/', auth, controller.index
router.get '/visite/:id/:mails/:charmes/:visites/:paniers', auth, controller.visite
router.get '/charme/:id', auth, controller.charme
router.get '/avis/:id/:avis', auth, controller.avis
router.post '/notes/:id', auth, controller.notes
router.post '/liste-visite', auth, controller.listeVisite
router.get '/liste-charme', auth, controller.listeCharme
router.get '/liste-charme-profils', auth, controller.listeCharmeProfils
router.post '/bot-status', auth, controller.postBotStatus
router.get '/bot-status', auth, controller.getBotStatus
router.get '/:id', auth, controller.get

module.exports = router
