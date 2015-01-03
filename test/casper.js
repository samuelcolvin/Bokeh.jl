casper.test.begin("simple.js rendering", 1, function(test) {
  casper.on('remote.message', function(message) {
    this.echo(message);
  });
  casper.start('test/_testing/simple.html', function() {
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