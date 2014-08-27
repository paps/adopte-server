'use strict'

mongoose = require 'mongoose'
Schema = mongoose.Schema

profileSchema = new Schema {
    id: Number
    charmes: [Date]
    premiereVisite:
        date: Date
        json: {}
    derniereVisite:
        date: Date
        json: {}
}

module.exports = mongoose.model 'Profile', profileSchema
