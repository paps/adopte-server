'use strict'

Stats = require './stats.model'

handleError = (res, err) ->
    res.send 500, err

parseDate = (d) ->
    year = parseInt d.substr 0, 4
    month = parseInt d.substr 5, 2
    day = parseInt d.substr 8, 2
    return new Date year, month - 1, day, 12

exports.add = (req, res) ->
    contacts = parseInt req.params.contacts, 10
    visites = parseInt req.params.visites, 10
    if (contacts is null) or (not isFinite(contacts)) then return handleError res, 'Invalid contacts parameter'
    if (visites is null) or (not isFinite(visites)) then return handleError res, 'Invalid visites parameter'
    if req.params.date
        date = parseDate req.params.date
    else
        date = Date.now()
    stats =
        date: date
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
                csv += s.date.toString() + ',' + s.contacts + ',' + s.visites + '\n'
            res.header 'Content-Type', 'text/csv'
            res.send 200, csv
