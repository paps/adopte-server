'use strict'

mongoose = require 'mongoose'
Schema = mongoose.Schema

profileSchema = new Schema {
    id: Number
    charmes: [Date]
    visites: [Date]
    premiereVisite:
        date: Date
        json: {}
        stats:
            mails: Number
            charmes: Number
            visites: Number
            paniers: Number
    derniereVisite:
        date: Date
        json: {}
        stats:
            mails: Number
            charmes: Number
            visites: Number
            paniers: Number
}

module.exports = mongoose.model 'Profile', profileSchema
