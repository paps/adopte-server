'use strict'

express = require 'express'
controller = require './stats.controller'
auth = require '../../auth/simpleApiAuth'

router = express.Router()

router.get '/add/:contacts/:visites', auth, controller.add
router.get '/csv', auth, controller.csv

module.exports = router
