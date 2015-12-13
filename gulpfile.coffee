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
srcmaps   = require 'gulp-sourcemaps'
srcDir    = 'src/'
buildDir  = 'dist/'
modules   = 'node_modules/'
coffees   = '**/*.coffee'
cssFiles  = '**/*.css'
htmls     = [ srcDir + '**/*.html' ]

log = (error) ->
  console.log [
    "BUILD FAILED: #{error.name ? ''}".red.underline
    '\u0007' # beep
    "#{error.code ? ''}"
    "#{error.message ? error}"
    "in #{error.filename ? ''}"
    "gulp plugin: #{error.plugin ? ''}"
  ].join '\n'
  this.end()

css = ->
  streams
    objectMode: true,
    gulp.src modules + 'bootstrap/dist/css/bootstrap.css'
    gulp.src srcDir + cssFiles

js = (scripts) ->
  streams
    objectMode: true,
    gulp.src modules + 'jquery/dist/jquery.js'
    gulp.src modules + 'bootstrap/dist/js/bootstrap.js'
    gulp.src modules + 'angular/angular.js'
    gulp.src(scripts)
      .pipe(coffee bare: true)
        .on 'error', log

gulp.task 'clean', ->
  gulp.src(buildDir)
    .pipe remove force: true

gulp.task 'css', ->
  css()
    .pipe(srcmaps.init())
    .pipe(plumber())
    .pipe(prefixer())
    .pipe(plumber())
    .pipe(concat 'index.css')
    .pipe(plumber())
    .pipe(postcss [ csswring removeAllComments: true ])
    .pipe(srcmaps.write('debug'))
    .pipe(gulp.dest buildDir)
    .pipe connect.reload()

gulp.task 'js', ['css'], ->
  js(srcDir + coffees)
    .pipe(srcmaps.init())
    .pipe(plumber())
    .pipe(concat 'index.js')
    .pipe(plumber())
    .pipe(uglify())
    .pipe(srcmaps.write('debug'))
    .pipe(gulp.dest buildDir)
    .pipe connect.reload()

gulp.task 'html', ->
  gulp.src(htmls)
    .pipe(plumber())
    .pipe htmlace
      css: 'index.css'
      js: 'index.js'
    .pipe(plumber())
    .pipe htmlify
      quotes: true
      conditionals: true
      spare: true
    .pipe(gulp.dest buildDir)
    .pipe connect.reload()

gulp.task 'default', ['css', 'js', 'html']

gulp.task 'connect', ->
  connect.server
    root: buildDir
    livereload: true

gulp.task 'serve', ['default', 'connect']

gulp.task 'css-dev', ->
  css()
    .pipe(gulp.dest buildDir)
    .pipe connect.reload()

devScripts = [ srcDir + coffees
               'tests/' + coffees ]
gulp.task 'js-dev', ->
  js(devScripts)
    .pipe(gulp.dest buildDir)
    .pipe connect.reload()

gulp.task 'html-dev', ->
  gulp.src(htmls)
    .pipe(gulp.dest buildDir)
    .pipe connect.reload()

gulp.task 'test', ->
  gulp.src(buildDir + '**/*Test.js')
    .pipe(plumber())
    .pipe jasmine
      coffee: false # test compiled js
      autotest: true
      match: '*Test.js'

gulp.task 'dev', ['css-dev', 'html-dev', 'js-dev']

gulp.task 'watch', ['dev', 'connect'], ->
  gulp.watch buildDir + '**/*', ['test']
  gulp.watch srcDir + cssFiles, ['css-dev']
  gulp.watch devScripts, ['js-dev']
  gulp.watch htmls, ['html-dev']
