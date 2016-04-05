(function() {
  var CLEANUP_DELAY, CLogger, autobahn, chai, expect, logger, promised, spies, wampeter;

  global.AUTOBAHN_DEBUG = true;

  wampeter = require('../lib/router');

  CLogger = require('node-clogger');

  autobahn = require('autobahn');

  chai = require('chai');

  expect = chai.expect;

  promised = require('chai-as-promised');

  spies = require('chai-spies');

  logger = new CLogger({
    name: 'router-tests'
  });

  chai.use(spies).use(promised);

  CLEANUP_DELAY = 500;

  describe('Router:Session', function() {
    var INVALID_AUTHID, INVALID_KEY, VALID_AUTHID, VALID_KEY, connection, router, session;
    router = null;
    connection = null;
    session = null;
    VALID_AUTHID = 'nicolas.cage';
    VALID_KEY = 'abc123';
    INVALID_AUTHID = 'david.hasselhoff';
    INVALID_KEY = 'xyz789';
    before(function(done) {
      var obj;
      router = wampeter.createRouter({
        port: 3000,
        auth: {
          wampcra: {
            type: 'static',
            users: (
              obj = {},
              obj["" + VALID_AUTHID] = {
                secret: VALID_KEY,
                role: 'frontend'
              },
              obj
            )
          }
        }
      });
      router.createRealm('com.to.inge.world');
      return setTimeout((function() {
        return done();
      }), CLEANUP_DELAY);
    });
    after(function(done) {
      return setTimeout((function() {
        return router.close().then(done)["catch"](done).done();
      }), CLEANUP_DELAY);
    });
    return it('should establish a new session via static wamp-cra authentication', function(done) {
      var onchallenge;
      onchallenge = function(session, method, extra) {
        expect(method).to.equal('wampcra');
        return autobahn.auth_cra.sign(VALID_KEY, extra.challenge);
      };
      connection = new autobahn.Connection({
        realm: 'com.to.inge.world',
        url: 'ws://localhost:3000/wampeter',
        authmethods: ['wampcra'],
        authid: VALID_AUTHID,
        onchallenge: onchallenge
      });
      connection.onopen = function(s) {
        expect(s).to.be.an["instanceof"](autobahn.Session);
        expect(s.isOpen).to.be["true"];
        session = s;
        return done();
      };
      return connection.open();
    });
  });

}).call(this);