gulp      = require 'gulp'
remove    = require 'gulp-rimraf'
streams   = require 'streamqueue'
coffee    = require 'gulp-coffee'
concat    = require 'gulp-concat'
uglify    = require 'gulp-uglify'
plumber   = require 'gulp-plumber'
prefixer  = require 'gulp-autoprefixer'
postcss   = require 'gulp-postcss'
csswring  = require 'csswring'
htmlace   = require 'gulp-html-replace'
htmlify   = require 'gulp-minify-html'
jasmine   = require 'gulp-jasmine'
connect   = require 'gulp-connect'

buildDir  = 'dist/'
srcDir    = 'src/'
testDir   = 'tests/'
modules   = 'node_modules/'
coffeeDir = srcDir + 'scripts/'

coffees   = '**/*.coffee'
jsTests   = '**/*Test.js'
htmlFiles = '**/*.html'
cssFiles  = '**/*.css'
jsFiles   = '**/*.js'

cssvendor = modules + 'bootstrap/dist/css/bootstrap.css'
jsvendors = [ modules + 'jquery/dist/jquery.js'
              modules + 'bootstrap/dist/js/bootstrap.js'
              modules + 'angular/angular.js' ]
styles    = [ srcDir + cssFiles ]
scripts   = [ srcDir + coffees ]
htmls     = [ srcDir + htmlFiles ]

gulp.task 'clean', ->
  gulp.src buildDir
    .pipe remove force: true

gulp.task 'css', ->
  streams
      objectMode: true,
      gulp.src cssvendor
      gulp.src styles
    .pipe plumber()
    .pipe prefixer()
    .pipe plumber()
    .pipe concat 'index.css'
    .pipe plumber()
    .pipe postcss [ csswring removeAllComments: true ]
    .pipe gulp.dest buildDir

processCoffee = (scripts) ->
  gulp.src scripts
    .pipe plumber()
    .pipe coffee bare: true
    .on 'error', -> console?.log error

gulp.task 'js', ->
  streams
      objectMode: true,
      gulp.src(jsvendors),
      processCoffee scripts
    .pipe plumber()
    .pipe concat 'index.js'
    .pipe plumber()
    .pipe uglify()
    .pipe gulp.dest buildDir

gulp.task 'html', ->
  gulp.src htmls
    .pipe plumber()
    .pipe htmlace
      css: '<link rel="stylesheet" href="index.css">'
      js: '<script src="index.js"></script>'
    .pipe plumber()
    .pipe htmlify
      quotes: true
      conditionals: true
      spare: true
    .pipe gulp.dest buildDir

gulp.task 'default', ['css', 'js', 'html']

gulp.task 'connect', ->
  connect.server
    root: buildDir
    livereload: true

gulp.task 'serve', ['default', 'connect']

gulp.task 'html-dev', ->
  gulp.src htmls
    .pipe gulp.dest buildDir
    .pipe connect.reload()


gulp.task 'css-dev', ->
  streams
      objectMode: true,
      gulp.src cssvendor
      gulp.src styles
    .pipe gulp.dest buildDir
    .pipe connect.reload()

devScripts = [ srcDir + coffees
               testDir + coffees ]
gulp.task 'js-dev', ->
  streams
      objectMode: true,
      gulp.src(jsvendors),
      processCoffee devScripts
    .pipe gulp.dest buildDir
    .pipe connect.reload()

gulp.task 'jasmine', ->
  gulp.src buildDir + jsTests
    .pipe plumber()
    .pipe jasmine
      coffee: false # test compiled js
      autotest: true

gulp.task 'watch', ['connect'], ->
  gulp.watch devScripts, ['js-dev']
  gulp.watch buildDir + '**/*', ['jasmine']
  gulp.watch srcDir + cssFiles, ['css-dev']
  gulp.watch htmls, ['html-dev']

gulp.task 'dev', ['css-dev', 'html-dev', 'js-dev', 'jasmine']