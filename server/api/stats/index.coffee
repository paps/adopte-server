'use strict'

express = require 'express'
controller = require './stats.controller'
auth = require '../../auth/simpleApiAuth'

router = express.Router()

router.get '/', auth, controller.index

module.exports = router
