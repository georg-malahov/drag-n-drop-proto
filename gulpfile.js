var bsync    = require('browser-sync'),
		gulp     = require('gulp');

gulp.task('sync', function() {
	var files = [
		"./_site/*.html",
		"./_site/**/*.html",
		"./_site/**/*.html"
	];

	var options = {
		notify: true,
		open: false,
		ghostMode: false,
		injectChanges: true,
		logLevel: 'debug',
		minify: false,
		codeSync: true,
		reloadDelay: 1000,
		proxy: "localhost:4000"
	};

	bsync.init(files, options, function (err, inj) {
		if (err) throw Error(err);
	});
});