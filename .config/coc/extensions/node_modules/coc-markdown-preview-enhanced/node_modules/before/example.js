
/**
 * Example.
 */

var before = require('./');

// an object with some method
var speak = {
  greeting: 'welcome',
  greet: function(a, b, fn){
    fn(null, a + ' ' + b);
  }
};

// factory before hook method
speak.before = before(speak);

// before greet
speak.before('greet', function(args, fn){
  args[0] = args[0] + ' to this wonderful';
  fn();
});

// one more, this will run first
speak.before('greet', function(args, fn){
  args[0] = args[0] + ', ' + this.greeting;
  fn();
});

// runs mutation hooks, then greets
speak.greet('Human', 'world!', function(err, result){
  console.log(result); // => Human, welcome to this wonderful world!
});
