
# before

before decorator factory

## Installation

`npm install before`

## Example

```js
var before = require('before');

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
```

## API

### before(context)

Captures `context` to be used by decorator.

### before(method, outer)

Decorates `method` using `outer`.

`outer` is called with `(args, fn)` to allow
arguments mutation.

## License

MIT
