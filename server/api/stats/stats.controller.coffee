'use strict'

Stats = require './stats.model'

handleError = (res, err) ->
    res.send 500, err

exports.add = (req, res) ->
    contacts = parseInt req.params.contacts, 10
    visites = parseInt req.params.visites, 10
    if (contacts is null) or (not isFinite(contacts)) then return handleError res, 'Invalid contacts parameter'
    if (visites is null) or (not isFinite(visites)) then return handleError res, 'Invalid visites parameter'
    stats =
        date: Date.now()
        contacts: contacts
        visites: visites
    Stats.create stats, (err, stats) ->
        return handleError(res, err) if err
        res.json 201, stats
        console.log "* Nouvelles stats: " + stats.contacts + " contacts, " + stats.visites + " visites"

exports.csv = (req, res) ->
    Stats.find
        $query: {}
        $orderby:
            date: 1,
        (err, stats) ->
            return handleError(res, err) if err
            csv = ''
            for s in stats
                csv += (s.date.getTime() / 1000) + ',' + s.contacts + ',' + s.visites + '\n'
            res.send 200, csv
