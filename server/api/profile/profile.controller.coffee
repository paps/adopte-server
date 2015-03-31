'use strict'

Profile = require './profile.model'
NewMembers = require './../new-members/new-members.model'
adopte = require '../../components/adopte'
_ = require 'underscore'
async = require 'async'
shuffle = require('knuth-shuffle').knuthShuffle

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

getGoodProfiles = (done) ->
    days = 3
    dateLimit = new Date(Date.now() - (24 * 60 * 60 * 1000) * days)
    timer = Date.now()
    Profile.find
        'avis': { $ne: 'nope' } # ignore bad profiles
        #'visitesBot.0': { $exists: yes } # only charm bot-visited profiles
        'charmesBot.0': { $exists: no } # never charm a profile twice
        'charmes.0': { $exists: no } # never charm a profile twice
        #'visites.0': { $exists: no } # commented to allow bot-charms to already human-visited profiles
        'derniereVisite.date': { $gte: dateLimit }, # only get profiles that were visited recently
        (err, profiles) ->
            return done(err) if err
            console.log ' >> getGoodProfiles MongoDB query: ' + (Date.now() - timer) + 'ms'
            timer = Date.now()
            goodProfiles = []
            for profile in profiles
                stats = profile.derniereVisite.stats
                if isFinite(stats.charmes) and isFinite(stats.visites) and isFinite(stats.mails)
                    if (stats.charmes > 0) and (stats.visites > 0) and (stats.mails > 0)
                        if stats.visites > stats.charmes
                            profile.cvRatio = stats.charmes / stats.visites
                            if 0.05 < profile.cvRatio < 0.8
                                if stats.mails <= 20
                                    goodProfiles.push profile
            # sort by C/V ratio
            goodProfiles = _.sortBy goodProfiles, (p) -> p.cvRatio
            # reverse to get best first
            done null, goodProfiles.reverse()
            console.log ' >> getGoodProfiles trim+sort+reverse: ' + (Date.now() - timer) + 'ms'

# returns a list of IDs
exports.listeCharme = (req, res) ->
    getGoodProfiles (err, profiles) ->
        return handleError(res, err) if err
        ids = []
        for profile in profiles
            ids.push profile.id
        res.json ids.slice 0, 200

# returns the best 30 profiles
exports.listeCharmeProfils = (req, res) ->
    getGoodProfiles (err, profiles) ->
        return handleError(res, err) if err
        res.json profiles.slice 0, 30

# returns all profiles that were charmed < 24h ago
exports.listeCharmeProfilsHier = (req, res) ->
    days = 1
    dateLimit = new Date(Date.now() - (24 * 60 * 60 * 1000) * days)
    Profile.find
        'avis': { $ne: 'nope' } # ignore bad profiles
        $or: [
            { 'charmesBot': { $elemMatch: { $gte: dateLimit } } },
            { 'charmes': { $elemMatch: { $gte: dateLimit } } },
        ],
        (err, profiles) ->
            return handleError(res, err) if err
            for profile in profiles
                profile.cvRatio = 0
                stats = profile.derniereVisite.stats
                if isFinite(stats.charmes) and isFinite(stats.visites) and isFinite(stats.mails)
                    if (stats.charmes > 0) and (stats.visites > 0) and (stats.mails > 0)
                        if stats.visites > stats.charmes
                            profile.cvRatio = stats.charmes / stats.visites
            # sort by C/V ratio
            profiles = _.sortBy profiles, (p) -> p.cvRatio
            # reverse to get best first
            res.json profiles.reverse()

exports.nouvellesInscrites = (req, res) ->
    days = 1
    dateLimit = new Date(Date.now() - (24 * 60 * 60 * 1000) * days)
    NewMembers.findOne
        $query:
            'date': { $lte: dateLimit }
        $orderby:
            id: -1,
        (err, newMember) ->
            return handleError(res, err) if err
            Profile.find
                'avis': { $ne: 'nope' } # ignore bad profiles
                'id': { $gte: newMember.id, $lt: 200000000 },
                'visites.0': { $exists: no }
                (err, profiles) ->
                    return handleError(res, err) if err
                    res.json shuffle profiles

exports.visite = (req, res) ->
    adopte.fetchProfile req.params.id, (adopteErr, json) ->
        Profile.findOne {id: req.params.id}, (err, profile) ->
            return handleError(res, err) if err
            if typeof(req.param 'bot') isnt 'undefined'
                visiteParBot = yes
            else
                visiteParBot = no
            stats =
                mails: parseInt req.params.mails, 10
                charmes: parseInt req.params.charmes, 10
                visites: parseInt req.params.visites, 10
                paniers: parseInt req.params.paniers, 10
            if (stats.mails is null) or (not isFinite(stats.mails)) then return handleError res, 'Invalid mails parameter'
            if (stats.charmes is null) or (not isFinite(stats.charmes)) then return handleError res, 'Invalid charmes parameter'
            if (stats.visites is null) or (not isFinite(stats.visites)) then return handleError res, 'Invalid visites parameter'
            if (stats.paniers is null) or (not isFinite(stats.paniers)) then return handleError res, 'Invalid paniers parameter'
            if profile
                if visiteParBot
                    profile.visitesBot.push Date.now()
                else
                    profile.visites.push Date.now()
                profile.derniereVisite.date = Date.now()
                if adopteErr
                    console.log "* " + (if visiteParBot then "[BOT] " else "") + "AuM n'a pas retourné de JSON valide mais profil " + profile.id + " deja dans la base (" + adopteErr + ")"
                else
                    profile.derniereVisite.json = json
                profile.markModified "derniereVisite.json"
                profile.derniereVisite.stats = stats
                profile.save (err) ->
                    if err
                        return handleError(res, err)
                    res.json profile
                    console.log "* " + (if visiteParBot then "[BOT] " else "") + "Visite " + (profile.visites.length + profile.visitesBot.length) + " pour le profil " + profile.id
            else if adopteErr
                return handleError res, adopteErr
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

botStatusText = ''
botStatusTime = 0

exports.postBotStatus = (req, res) ->
    s = req.param 'status'
    if (typeof s) is 'string'
        botStatusTime = Date.now()
        botStatusText = s
        res.send 200
        console.log "* [BOT] New status: " + s
    else
        res.send 400

exports.getBotStatus = (req, res) ->
    if botStatusText.length and botStatusTime > 0
        res.json 200,
            text: botStatusText
            seconds: Math.round((Date.now() - botStatusTime) / 1000)
    else
        res.send 404

exports.listeVisite = (req, res) ->
    ids = req.param 'ids'
    if (typeof ids) isnt 'string'
        res.send 400
        return
    days = 5
    dateLimit = new Date(Date.now() - (24 * 60 * 60 * 1000) * days)
    idsToVisit = []
    ids = ids.split ','
    idIterator = (id, done) ->
        id = parseInt id, 10
        if isFinite(id) and id > 100
            Profile.findOne {id: id}, (err, profile) ->
                if err
                    console.log '* ' + id + ': Error: ' + err.toString()
                    return done null
                else
                    if profile
                        days = Math.round((Date.now() - profile.derniereVisite.date.getTime()) / (24 * 60 * 60 * 1000))
                        if profile.derniereVisite.date.getTime() < dateLimit.getTime()
                            console.log '* ' + id + ': Visited ' + days + ' days ago -> visiting'
                            idsToVisit.push id
                        else
                            console.log '* ' + id + ': Visited ' + days + ' days ago'
                    else
                        console.log '* ' + id + ': Not found -> visiting'
                        idsToVisit.push id
                    done null
        else
            console.log '* Invalid profile ID ' + id
            done null
    async.eachSeries ids, idIterator, () ->
        console.log '* Returning ' + idsToVisit.length + ' IDs to visit'
        res.json 200, idsToVisit
