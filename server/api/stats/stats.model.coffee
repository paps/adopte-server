'use strict'

mongoose = require 'mongoose'
Schema = mongoose.Schema

statsSchema = new Schema {
    date: Date
    contacts: Number
    visites: Number
}

module.exports = mongoose.model 'Stats', statsSchema
