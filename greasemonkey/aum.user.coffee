###
// ==UserScript==
// @name        aum
// @namespace   http://www.adopteunmec.com/
// @include     http://www.adopteunmec.com/*
// @include     https://www.adopteunmec.com/*
// @version     2
// @grant       none
// @require     config.js
// ==/UserScript==
###


round = (n, decimals) -> (Math.round n * Math.pow(10, decimals)) / (Math.pow 10, decimals)


betterTitle = () ->
    titleEl = document.getElementsByTagName('title')[0]
    setTitle = () ->
        nbMails = parseInt ($ '#mails a').text()
        nbPaniers = parseInt ($ '#basket a').text()
        nbVisites = parseInt ($ '#visites a').text()
        nbChats = parseInt ($ '#chat a').text()
        titleEl.innerHTML = 'AuM (' + nbMails + ', ' + nbPaniers + ', ' + nbVisites + ', ' + nbChats + ')'
    docEl = document.documentElement
    docEl.addEventListener 'DOMSubtreeModified', (evt) ->
        t = evt.target
        if (t == titleEl || (t.parentNode && t.parentNode == titleEl))
            setTitle()
    setTitle()
    setInterval (() -> setTitle()), 3000


pageProfileMec = () ->

    ($ 'blockquote.title').css('font-family', 'Arial').css('font-size', '14px')


pageProfileMeuf = () ->

    ($ 'blockquote.title').css('font-family', 'Arial').css('font-size', '14px')

    removeX = (elem) -> elem.text elem.text().replace(' x', '')

    profileId = parseInt ($ '#member-id').text().replace 'ID.', ''

    ($ '#popularity > h2').text 'Popularité++'
    ($ 'td.equals').remove()
    ($ 'td.count').remove()
    ($ 'tr.total > th').text 'Score'
    ($ '#popularity table tr td:contains(" x ") strong').remove()

    points =
        mails: parseInt (removeX $ '#popularity table tr td:eq(0)').text()
        charmes: parseInt (removeX $ '#popularity table tr td:eq(1)').text()
        visites: parseInt (removeX $ '#popularity table tr td:eq(2)').text()
        paniers: parseInt (removeX $ '#popularity table tr td:eq(3)').text()

    charmeRate = ($ '<tr>')
    charmeRate.append ($ '<th>').text 'C / V'
    charmeRate.append ($ '<td>').text (round (points.charmes / points.visites) * 100, 2) + ' %'
    ($ '#popularity > table').append charmeRate

    mailRate = ($ '<tr>')
    mailRate.append ($ '<th>').text 'M / C'
    mailRate.append ($ '<td>').text (round (points.mails / points.charmes) * 100, 2) + ' %'
    ($ '#popularity > table').append mailRate

    ($ 'a.charm').click () ->
        alert 'Charme !'

    $.ajax(
        type: 'GET'
        dataType: 'json'
        url: aumConfig.host + 'api/profiles/visite/' + profileId + '/' + points.mails + '/' + points.charmes + '/' + points.visites + '/' + points.paniers + '?key=' + aumConfig.key
    ).done((profile) ->
        drawInfoBox profile, 300, 300
    ).fail((jqXhr, textStatus, err) ->
        alert 'Query to AuM Management Server failed, see console'
        console.log '>>> Ajax failure: %j', { jqXhr: jqXhr, textStatus: textStatus, err: err }
    )



drawInfoBox = (json, posX, posY) ->
    div = ($ '<div>')
        .css('position', 'absolute')
        .css('top', posX + 'px')
        .css('left', posY + '10px')
        .css('background-color', '#e2e2e2')
        .css('border', '1px solid #ccc')
        .css('padding', '2px')
        .css('font-family', 'Monospace')
    div.append ($ '<span>').text '100'
    div.append ($ '<br />')
    div.append ($ '<span>').text '200'
    div.append ($ '<br />')
    ($ 'body').append div


configurator = () ->
    div = ($ '<div>')
        .css('position', 'absolute')
        .css('top', '10px')
        .css('left', '10px')
        .css('background-color', '#aaa')
        .css('border', '1px solid #888')
        .css('padding', '4px')
        .css('font-family', 'Monospace')
    host = ($ '<input>').val(aumConfig.host).attr('type', 'text').css('width', '150px')
    key = ($ '<input>').val(aumConfig.key).attr('type', 'text').css('width', '150px')
    div.append ($ '<span>').text 'AuM Management Server'
    div.append ($ '<br />')
    div.append ($ '<span>').text 'host'
    div.append host
    div.append ($ '<br />')
    div.append ($ '<span>').text 'key '
    div.append key
    ($ 'body').append div


($ document).ready () ->

    if ($ '#flash-points').length
        ($ '#flash-points').remove()
    if ($ '#search-engine .fields').length
        ($ '#search-engine .fields').hide()
    if ($ '#profile-complete-rate').length
        ($ '#profile-complete-rate').hide()
    betterTitle()
    configurator()

    if ($ '#view_description_girl').length
        pageProfileMeuf()
    else if ($ '#view_description_boy').length
        pageProfileMec()

    ($ 'body').css('background', 'rgb(223, 239, 254)')
