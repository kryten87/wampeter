global.AUTOBAHN_DEBUG = true;

wampeter  = require('../lib/router')
CLogger  = require('node-clogger')
autobahn = require('autobahn')
chai     = require('chai')
expect   = chai.expect
promised = require('chai-as-promised')
spies    = require('chai-spies')
Q        = require('q')

D = require('./done')

logger = new CLogger({name: 'router-tests'})

chai.use(spies).use(promised)

CLEANUP_DELAY = 500






















Cfg = require('./router-config')

ROUTER_CONFIG = Cfg.static
REALM_URI =     Cfg.realm

ROLE = Cfg.role

VALID_AUTHID =  Cfg.valid_authid
VALID_KEY =     Cfg.valid_key

INVALID_AUTHID = 'david.hasselhoff'
INVALID_KEY = 'xyz789'














describe('Router:Static Authorization', ()->

    router = null
    connection = null
    # session = null

    ###
    before((done_func)->
        done = D(done_func)

        router = wampeter.createRouter(ROUTER_CONFIG)

        router.createRealm(REALM_URI)

        onchallenge = (session, method, extra)->

            expect(method).to.equal('wampcra')

            # respond to the challenge
            #
            autobahn.auth_cra.sign(VALID_KEY, extra.challenge)

        connection = new autobahn.Connection({
            realm: REALM_URI
            url: 'ws://localhost:3000/wampeter'

            authmethods: ['wampcra']
            authid: VALID_AUTHID
            onchallenge: onchallenge
        })


        connection.onopen = (s)->
            expect(s).to.be.an.instanceof(autobahn.Session)
            expect(s.isOpen).to.be.true
            session = s
            setTimeout(done, CLEANUP_DELAY)

        connection.open()
    )
    ###

    after((done_func)->
        done = D(done_func)

        cleanup = ()-> router.close().then(done).catch(done).done()
        setTimeout(cleanup, CLEANUP_DELAY)
    )


    connect = (authConfig)->
        deferred = Q.defer()

        cfg = ROUTER_CONFIG
        cfg.realms[REALM_URI].roles[ROLE] = authConfig

        router = wampeter.createRouter(cfg)

        onchallenge = (session, method, extra)->
            console.log('++++++++++ onchallenge session', session)
            console.log('++++++++++ onchallenge extra', extra)
            expect(method).to.equal('wampcra')

            # respond to the challenge
            #
            autobahn.auth_cra.sign(VALID_KEY, extra.challenge)

        connection = new autobahn.Connection({
            realm: REALM_URI
            url: 'ws://localhost:3000/wampeter'

            authmethods: ['wampcra']
            authid: VALID_AUTHID
            onchallenge: onchallenge
        })


        connection.onopen = (session)->
            logger.debug('------------- onopen', session)
            expect(session).to.be.an.instanceof(autobahn.Session)
            expect(session.isOpen).to.be.true

            logger.debug('------------- onopen - resolving deferred')

            setTimeout((()->deferred.resolve(session)), CLEANUP_DELAY)
            # deferred.resolve(s)

        logger.debug('------------- opening connection')
        connection.open()

        deferred.promise













    it('should successfully call when call permitted', (done_func)->
        logger.debug('------------- in test method')
        done = D(done_func)

        config = [
            {
                uri: '*'
                allow: {
                    call: true
                    register: false
                    subscribe: false
                    publish: false
                }
            }
        ]

        connect(config)
        .then((session)->
            logger.debug('------------- in connect deferred', session)

            # attempt to call a function
            #
            session.call('com.example.authtest', ['hello inge!'], {to: 'inge'})
            .then((result)->

                console.log('------------------ RPC', result)


                done()
            ).catch((err)-> done(new Error(err))).done()



        )
    )
)
