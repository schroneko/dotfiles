
/*!
 *
 * before
 *
 * before decorator factory
 *
 * MIT
 *
 */

/**
 * Module dependencies.
 */

var slice = [].slice;

/**
 * Expose `before`.
 */

module.exports = before;

/**
 * Captures `context` to be used by decorator.
 *
 * @param {Object} [context]
 * @return {Function}
 * @api public
 */

function before(context){
  return decorator;

  /**
   * Decorates `method` using `outer`.
   *
   * @param {Function} outer
   * @return {Object} this
   * @api public
   */

  function decorator(method, outer){
    var inner = context[method];
    context[method] = function(){
      var args = slice.call(arguments);
      var fn = args[args.length - 1];
      return outer.call(context, args, function(err){
        if (err) return fn(err);
        inner.apply(context, args);
      });
    };
    return this;
  }
}
