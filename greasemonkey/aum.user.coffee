###
// ==UserScript==
// @name        aum
// @namespace   adopte.un.mec
// @include     http://www.adopteunmec.com/*
// @include     https://www.adopteunmec.com/*
// @version     2
// @grant       none
// @require     config.js
// ==/UserScript==
###

round = (n, decimals) -> (Math.round n * Math.pow(10, decimals)) / (Math.pow 10, decimals)

# --------------------------------------------------------------------------------------------------------------------------

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

# --------------------------------------------------------------------------------------------------------------------------

processProfile = (profile) ->
    visites = []
    for visite in profile.visites
        visites.push new Date(visite)
    profile.visites = visites
    charmes = []
    for charme in profile.charmes
        charmes.push new Date(charme)
    profile.charmes = charmes
    profile.derniereVisite.date = new Date(profile.derniereVisite.date)
    profile.premiereVisite.date = new Date(profile.premiereVisite.date)
    profile.secondesEntreVisites = round ((profile.derniereVisite.date - profile.premiereVisite.date) / 1000), 2
    profile.statsOffset =
        mails: profile.derniereVisite.stats.mails - profile.premiereVisite.stats.mails
        charmes: profile.derniereVisite.stats.charmes - profile.premiereVisite.stats.charmes
        visites: profile.derniereVisite.stats.visites - profile.premiereVisite.stats.visites
        paniers: profile.derniereVisite.stats.paniers - profile.premiereVisite.stats.paniers
    profile.charmeRate = round (profile.derniereVisite.stats.charmes / profile.derniereVisite.stats.visites) * 100, 2
    profile.mailRate = round (profile.derniereVisite.stats.mails / profile.derniereVisite.stats.charmes) * 100, 2
    profile.visitesParHeure = round ((3600 * profile.statsOffset.visites) / profile.secondesEntreVisites), 2
    if profile.visitesParHeure is NaN then profile.visitesParHeure = 0
    if profile.visitesParHeure > 0
        profile.ageEnHeures = round profile.derniereVisite.stats.visites / profile.visitesParHeure, 2
        if profile.ageEnHeures < 72
            profile.ageStr = round(profile.ageEnHeures, 1) + 'H'
        else if profile.ageEnHeures < 24 * 60
            profile.ageStr = round(profile.ageEnHeures / 24, 1) + 'J'
        else if profile.ageEnHeures < 24 * 30 * 12
            profile.ageStr = round(profile.ageEnHeures / (24 * 30), 1) + 'M'
        else
            profile.ageStr = round(profile.ageEnHeures / (24 * 30 * 12), 1) + 'Y'
    else
        profile.ageEnHeures = 0
        profile.ageStr = '?'
    console.log '>>> AuM processed profile: %j', profile
    return profile

# --------------------------------------------------------------------------------------------------------------------------

processThumbs = () ->

    processedLinks = []

    linkIsProcessed = (elem) ->
        for l in processedLinks
            if l.is elem
                return yes
        return no

    findNewThumbs = () ->
        nbLinks = 0
        ($ 'a').each () ->
            if $(this).attr 'href'
                link = $(this).attr('href')
                if (link.indexOf '/profile/') >= 0
                    link = (link.replace /[^\d.]/g, '').replace /\./g, ''
                    profileId = parseInt link
                    if (profileId > 100) and (profileId isnt Infinity)
                        if $(this).children('img').length
                            if ($(this).offset().top > 0) and ($(this).offset().left > 0) and $(this).is ':visible'
                                if not linkIsProcessed $(this)
                                    ++nbLinks
                                    processedLinks.push $(this)
                                    newThumb $(this), profileId
        if nbLinks > 0
            console.log '>>> ' + nbLinks + ' new profile thumbnails'

    newThumb = (elem, profileId) ->
        $.ajax(
            type: 'GET'
            dataType: 'json'
            url: aumConfig.host + 'api/profiles/' + profileId + '?key=' + aumConfig.key
        ).done((profile) ->
            profile = processProfile profile
            drawInfoBox profile, elem
        ).fail((jqXhr, textStatus, err) ->
            if jqXhr.status isnt 404
                alert 'Query to AuM Management Server failed, see console'
                console.log '>>> Ajax failure: %j', { jqXhr: jqXhr, textStatus: textStatus, err: err }
        )

    setInterval findNewThumbs, 1500

# --------------------------------------------------------------------------------------------------------------------------

pageProfileMec = () ->

    ($ 'blockquote.title').css('font-family', 'Arial').css('font-size', '14px')

# --------------------------------------------------------------------------------------------------------------------------

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
        status = $('<div>').text 'Enregistrement du charme...'
        ($ 'a.charm').after status
        $.ajax(
            type: 'GET'
            dataType: 'json'
            url: aumConfig.host + 'api/profiles/charme/' + profileId + '?key=' + aumConfig.key
        ).done((profile) ->
            status.text 'Charme enregistré.'
        ).fail((jqXhr, textStatus, err) ->
            alert 'Query to AuM Management Server failed, see console'
            console.log '>>> Ajax failure: %j', { jqXhr: jqXhr, textStatus: textStatus, err: err }
        )

    requestStatus = ($ '<div>').text 'Recuperation du profil...'
    ($ 'a.charm').after requestStatus
    $.ajax(
        type: 'GET'
        dataType: 'json'
        url: aumConfig.host + 'api/profiles/visite/' + profileId + '/' + points.mails + '/' + points.charmes + '/' + points.visites + '/' + points.paniers + '?key=' + aumConfig.key
    ).done((profile) ->
        profile = processProfile profile
        drawInfoBox profile, ($ '#user-pics')
        drawProfileBox profile
        avisBox profile
    ).fail((jqXhr, textStatus, err) ->
        alert 'Query to AuM Management Server failed, see console'
        console.log '>>> Ajax failure: %j', { jqXhr: jqXhr, textStatus: textStatus, err: err }
    ).always () ->
        requestStatus.remove()

# --------------------------------------------------------------------------------------------------------------------------

drawProfileBox = (profile) ->
    pre = ($ '<pre>')
        .css('position', 'absolute')
        .css('overflow', 'auto')
        .css('z-index', '1000')
        .css('width', '255px')
        .css('height', '500px')
        .css('top', (($ '#content').offset().top + 180) + 'px')
        .css('left', (($ '#content').offset().left - 258) + 'px')
        .css('background-color', '#fff')
        .css('border', '1px solid #ccc')
        .css('padding', '2px')
        .css('font-family', 'Monospace')
        .css('font-size', '10px')
    pre.text """
        Age estimé: #{profile.ageStr}

        Visites par heure: #{profile.visitesParHeure}

        Date de naissance: #{profile.derniereVisite.json.birthdate}

        Derniere connexion:
        #{profile.derniereVisite.json.last_cnx}

        Premiere visite:
        #{profile.premiereVisite.date.toString()}

        Derniere visite:
        #{profile.derniereVisite.date.toString()}

        Charmes:
        #{(JSON.stringify profile.charmes).replace /,/g, ',\n'}

        Visites:
        #{(JSON.stringify profile.visites).replace /,/g, ',\n'}
        """
    ($ 'body').append pre

# --------------------------------------------------------------------------------------------------------------------------

avisBox = (profile) ->
    div = ($ '<div>')
        .css('position', 'absolute')
        .css('z-index', '1000')
        .css('width', '170px')
        .css('top', (($ '#content').offset().top + 80) + 'px')
        .css('left', (($ '#content').offset().left - 220) + 'px')
        .css('background-color', '#fff')
        .css('border', '1px solid #ccc')
        .css('padding', '2px')
        .css('font-family', 'Monospace')
        .css('font-size', '10px')
    div.append ($ '<div>').text('Avis:')
    avisNope = ($ '<button>').text('Nope')
    div.append ($ '<div>').append avisNope
    avisNormal = ($ '<button>').text('Normal')
    div.append ($ '<div>').append avisNormal
    avisExcellent = ($ '<button>').text('Excellent')
    div.append ($ '<div>').append avisExcellent
    status = ($ '<div>')
    div.append status

    setAvis = (avis) ->
        status.text 'Enregistrement de l\'avis...'
        $.ajax(
            type: 'GET'
            dataType: 'json'
            url: aumConfig.host + 'api/profiles/avis/' + profile.id + '/' + avis + '?key=' + aumConfig.key
        ).done((profile) ->
            status.text 'Avis enregistré.'
        ).fail((jqXhr, textStatus, err) ->
            alert 'Query to AuM Management Server failed, see console'
            console.log '>>> Ajax failure: %j', { jqXhr: jqXhr, textStatus: textStatus, err: err }
        )

    avisNope.click () -> setAvis 'nope'
    avisExcellent.click () -> setAvis 'excellent'
    avisNormal.click () -> setAvis 'normal'

    ($ 'body').append div

# --------------------------------------------------------------------------------------------------------------------------

drawInfoBox = (profile, elem) ->
    div = ($ '<div>')
        .css('position', 'absolute')
        .css('text-align', 'right')
        .css('overflow', 'hidden')
        .css('z-index', '1000')
        .css('width', '40')
        .css('top', elem.offset().top + 'px')
        .css('left', (elem.offset().left - 46) + 'px')
        .css('padding', '2px')
        .css('font-family', 'Monospace')
        .css('font-size', '10px')
    if profile.avis is 'nope'
        div
            .css('background-color', '#474747')
            .css('border', '1px solid #d8ff00')
            .css('color', '#fff')
            .css('text-align', 'center')
        div.append ($ '<div>').text ':-/'
    else
        div.css('background-color', '#fff')
        if profile.avis is 'excellent'
            div.css('border', '1px solid #00d8ff')
        else
            div.css('border', '1px solid #ccc')
        div.append ($ '<div>').css('background-color', (if profile.visites.length > 5 then '#ff4b4b' else '#ffffff')).attr('title', 'Nombre de mes visites').html 'V&nbsp;' + profile.visites.length
        div.append ($ '<div>').css('background-color', (if profile.charmes.length > 0 then '#ff21b8' else '#d3fbff')).attr('title', 'Nombre de mes charmes').html 'C&nbsp;' + profile.charmes.length
        div.append ($ '<div>').css('background-color', (if profile.ageStr is '?' then '#e9ffe6' else '#8eff96')).attr('title', 'Estimation de l\'age du profil (en heures: ' + profile.ageEnHeures + ')').html 'A&nbsp;' + profile.ageStr
        div.append ($ '<div>').css('background-color', (if profile.charmeRate < 27 then '#ffe8fe' else '#ff47f4')).attr('title', '% de charmes par visites').html 'C&nbsp;/&nbsp;V<br />' + profile.charmeRate + '%'
        div.append ($ '<div>').css('background-color', (if profile.mailRate > 10 then '#fcffe0' else '#eaff00')).attr('title', '% de mails par charmes').html 'M&nbsp;/&nbsp;C<br />' + profile.mailRate + '%'
    ($ 'body').append div

# --------------------------------------------------------------------------------------------------------------------------

showConfigBox = () ->
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

# --------------------------------------------------------------------------------------------------------------------------

betterMail = () ->
    setup = () ->
        ($ '#msg-content').focus()
        ($ '#msg-content').css('height', '30px').keypress (e) ->
            if e.altKey or e.shiftKey or e.ctrlKey or e.metaKey
                return
            if e.which is 13
                e.preventDefault()
                ($ '#send-message').click()
    rebuild = () ->
        if ($ '#msg-content').length
            height = parseInt ($ '#msg-content').css('height')
            if height > 40
                setup()
    setInterval (() -> rebuild()), 300

# --------------------------------------------------------------------------------------------------------------------------

($ document).ready () ->

    if ($ '#flash-points').length
        ($ '#flash-points').remove()
    if ($ '#search-engine .fields').length
        ($ '#search-engine .fields').hide()
    if ($ '#profile-complete-rate').length
        ($ '#profile-complete-rate').hide()
    betterTitle()
    showConfigBox()

    if ($ '#view_description_girl').length
        pageProfileMeuf()
    else if ($ '#view_description_boy').length
        pageProfileMec()
    else if ((document.URL.indexOf '.com/visits') > 0) or ((document.URL.indexOf '.com/mySearch/results') > 0)
        processThumbs()
    else if ((document.URL.indexOf '.com/messages') > 0)
        betterMail()

    ($ 'body').css('background', 'rgb(223, 239, 254)')
