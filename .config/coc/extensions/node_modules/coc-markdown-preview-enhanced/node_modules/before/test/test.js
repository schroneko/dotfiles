
/**
 * Test.
 */

var assert = require('assert');

var before = require('../');

describe("before(context)", function(){

  it("should return a function", function(){
    var speak = {
      greeting: 'welcome',
      greet: function(a, b, fn){
        fn(null, a + ' ' + b);
      }
    };
    speak.before = before(speak);
    speak.before.should.be.a.Function;
  })

})

describe("before(method, fn)", function(){

  it("should add a before hook and run it in the context", function(done){
    var speak = {
      greeting: 'welcome',
      greet: function(a, b, fn){
        fn(null, a + ' ' + b);
      }
    };
    speak.before = before(speak);
    speak.before('greet', function(args, fn){
      args[0] = args[0] + ', ' + this.greeting;
      assert(this === speak);
      fn();
    });
    speak.greet('Hello', 'to this world!', function(err, result){
      assert(null == err);
      result.should.equal('Hello, welcome to this world!');
      done();
    });
  })

  describe("when run multiple times", function(){

    it("should add multiple before hooks", function(done){
      var speak = {
        greeting: 'welcome',
        greet: function(a, b, fn){
          fn(null, a + ' ' + b);
        }
      };
      speak.before = before(speak);
      speak.before('greet', function(args, fn){
        args[0] = args[0] + ' to this wonderful';
        assert(this === speak);
        fn();
      });
      speak.before('greet', function(args, fn){
        args[0] = args[0] + ', ' + this.greeting;
        assert(this === speak);
        fn();
      });
      speak.greet('Hello', 'world!', function(err, result){
        assert(null == err);
        result.should.equal('Hello, welcome to this wonderful world!');
        done();
      });
    })

  })

})
