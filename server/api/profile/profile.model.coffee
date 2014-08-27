'use strict'

mongoose = require 'mongoose'
Schema = mongoose.Schema

profileSchema = new Schema {
    numero: Number
    femme: Boolean
    pseudo: String
    nbCharmes: Number
    position:
        lat: Number
        lng: Number
    dateDernierCharme: Date
    datePremiereVisite: Date
    dateDerniereVisite: Date
    statsDebut:
        popularite: Number
        mails: Number
        charmes: Number
        visites: Number
        panier: Number
        bonus: Number
        score: Number
    statsCourantes:
        popularite: Number
        mails: Number
        charmes: Number
        visites: Number
        panier: Number
        bonus: Number
        score: Number
}

module.exports = mongoose.model 'Profile', profileSchema
