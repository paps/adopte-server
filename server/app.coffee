###
Main application file
###
'use strict'

# Set default node environment to development
process.env.NODE_ENV = process.env.NODE_ENV or 'development'
express = require 'express'
mongoose = require 'mongoose'
config = require './config/config'
fs = require 'fs'

# Connect to database
mongoose.connect config.mongo.uri, config.mongo.options

# Populate DB with sample data
require './config/seed'  if config.seedDB

# Setup server
app = express()
if (fs.existsSync 'sslcert/server.key') and (fs.existsSync 'sslcert/server.crt')
    server = require('https').createServer
        key: (fs.readFileSync 'sslcert/server.key', 'utf8')
        cert: (fs.readFileSync 'sslcert/server.crt', 'utf8'),
        app
else
    server = require('http').createServer app
require('./config/express') app
require('./routes') app

# Start server
server.listen config.port, config.ip, -> console.log 'Express server listening on %d, in %s mode', config.port, app.get('env')

# Expose app
exports = module.exports = app
