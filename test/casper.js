var fs = require('fs');

casper.test.begin("simple.js rendering", 2, function(test) {
  var filepath = '/tmp/bokeh_js_testing/simple.html';
  test.assert(fs.exists(filepath), filepath + ' does not exist');
  casper.on('remote.message', function(message) {
    this.echo(message);
  });
  casper.start(filepath, function() {
  	// we should probably set page titles but we don't yet.
    //this.echo('title: "' + this.getTitle() + '"');
    // once we do we should add a test.
  });

  casper.waitForSelector('canvas');
  casper.then(function() {
  	test.assertExists('canvas', 'canvas found');
  });

  casper.run(function() {
    test.done();
  });
});