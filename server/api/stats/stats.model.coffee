'use strict'

mongoose = require 'mongoose'
Schema = mongoose.Schema

statsSchema = new Schema {
    date: [Date]
    charmes: Number
    mails: Number
}

module.exports = mongoose.model 'Stats', statsSchema
