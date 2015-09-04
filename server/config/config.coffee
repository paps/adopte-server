"use strict"

path = require("path")

config =
    # Dev mode
    env: process.env.NODE_ENV

    # Root path of server
    root: path.normalize(__dirname + "/../..")

    # Server port
    port: process.env.PORT or 29029

    # Should we populate the DB with sample data?
    seedDB: false

    # Secret for session, set later in config.local
    secrets:
        session: "adopte-server-secret"

    # List of user roles
    userRoles: [
        "guest"
        "user"
        "admin"
    ]

    # MongoDB connection options
    mongo:
        uri: "mongodb://localhost/adopteserver"
        options:
            db:
                safe: true

require("./config.local") config

module.exports = config
