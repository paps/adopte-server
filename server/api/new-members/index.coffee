'use strict'

express = require 'express'
controller = require './new-members.controller'
auth = require '../../auth/simpleApiAuth'

router = express.Router()

router.get '/add/:id', auth, controller.add
router.get '/get-biggest', auth, controller.getBiggest

module.exports = router
