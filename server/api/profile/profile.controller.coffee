'use strict'

Profile = require './profile.model'
adopte = require '../../components/adopte'
_ = require 'underscore'

handleError = (res, err) ->
    res.send 500, err

exports.index = (req, res) ->
    Profile.find (err, profiles) ->
        return handleError(res, err) if err
        res.json profiles

exports.get = (req, res) ->
    Profile.findOne {id: req.params.id}, (err, profile) ->
        return handleError(res, err) if err
        return res.send(404) unless profile
        res.json profile

exports.listeCharme = (req, res) ->
    yesterday = new Date(Date.now() - 24 * 60 * 60 * 1000)
    Profile.find
        'visitesBot.0': { $exists: yes }
        'charmesBot.0': { $exists: no }
        'visites.0': { $exists: no }
        'charmes.0': { $exists: no }
        'derniereVisite': { $gte: yesterday },
        (err, profiles) ->
            return handleError(res, err) if err
            keptProfiles = []
            for profile in profiles
                stats = profile.derniereVisite.stats
                if isFinite(stats.charmes) and isFinite(stats.visites) and isFinite(stats.mails)
                    if (stats.charmes > 0) and (stats.visites > 0) and (stats.mails > 0)
                        if stats.visites > stats.charmes
                            profile.cvRatio = stats.charmes / stats.visites
                            keptProfiles.push profile
            profiles = _.sortBy keptProfiles, (p) -> p.cvRatio
            ids = []
            for profile in profiles
                ids.push profile.id
            res.json ids.reverse() # best charms-by-visits ratio first

exports.visite = (req, res) ->
    adopte.fetchProfile req.params.id, (err, json) ->
        return handleError(res, err) if err
        Profile.findOne {id: req.params.id}, (err, profile) ->
            return handleError(res, err) if err
            if typeof(req.param 'bot') isnt 'undefined'
                visiteParBot = yes
            else
                visiteParBot = no
            stats =
                mails: req.params.mails
                charmes: req.params.charmes
                visites: req.params.visites
                paniers: req.params.paniers
            if profile
                if visiteParBot
                    profile.visitesBot.push Date.now()
                else
                    profile.visites.push Date.now()
                profile.derniereVisite.date = Date.now()
                profile.derniereVisite.json = json
                profile.markModified "derniereVisite.json"
                profile.derniereVisite.stats = stats
                profile.save (err) ->
                    if err
                        return handleError(res, err)
                    res.json profile
                    console.log "* " + (if visiteParBot then "[BOT] " else "") + "Visite " + (profile.visites.length + profile.visitesBot.length) + " pour le profil " + profile.id
            else
                profile =
                    id: req.params.id
                    avis: null
                    charmes: []
                    charmesBot: []
                    visites: []
                    visitesBot: []
                    premiereVisite:
                        date: Date.now()
                        json: json
                        stats: stats
                    derniereVisite:
                        date: Date.now()
                        json: json
                        stats: stats
                if visiteParBot
                    profile.visitesBot.push Date.now()
                else
                    profile.visites.push Date.now()
                Profile.create profile, (err, profile) ->
                    return handleError(res, err) if err
                    res.json 201, profile
                    console.log "* " + (if visiteParBot then "[BOT] " else "") + "Premiere visite pour le profil " + profile.id

exports.charme = (req, res) ->
    Profile.findOne {id: req.params.id}, (err, profile) ->
        return handleError(res, err) if err
        if profile
            if typeof(req.param 'bot') isnt 'undefined'
                charmeParBot = yes
            else
                charmeParBot = no
            if charmeParBot
                profile.charmesBot.push Date.now()
            else
                profile.charmes.push Date.now()
            profile.save (err) ->
                return handleError(res, err) if err
                res.json profile
                console.log "* " + (if charmeParBot then "[BOT] " else "") + "Charme " + (profile.charmes.length + profile.charmesBot.length) + " pour le profil " + profile.id
        else
            res.send 404

exports.avis = (req, res) ->
    Profile.findOne {id: req.params.id}, (err, profile) ->
        return handleError(res, err) if err
        if profile
            profile.avis = req.params.avis
            profile.save (err) ->
                return handleError(res, err) if err
                res.json profile
                console.log "* Avis \"" + profile.avis + "\" pour le profil " + profile.id
        else
            res.send 404

exports.notes = (req, res) ->
    Profile.findOne {id: req.params.id}, (err, profile) ->
        return handleError(res, err) if err
        if profile
            profile.notes = req.body.notes
            profile.save (err) ->
                return handleError(res, err) if err
                res.json profile
                console.log "* Notes mises à jour pour le profil " + profile.id
        else
            res.send 404
