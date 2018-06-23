#!/usr/bin/env coffee

endl = require 'endl'
yargs = require 'yargs'
{ parse } = require 'url'
{ _extend } = require 'util'
ProgressBar = require 'progress'

yargsMainOptions =
  't':
    type: 'string'
    alias: 'type'
    default: 'c'
    describe: 'Find type: c or x (cheerio or xpath)'
  'i':
    type: 'string'
    alias: 'index'
    default: '0'
    describe: 'Change currently selected element index of found elements'
  'T':
    type: 'boolean'
    alias: 'text'
    default: false
    describe: 'Use text of element'
  'a':
    type: 'string'
    alias: 'attr'
    default: 'href'
    describe: 'Use an attribute of element',
  'm':
    type: 'string'
    alias: 'mode'
    default: 'urlBasename'
    describe: 'File name modes: urlBasename, contentType, contentDisposition (You can combine them with + character)'
  'd':
    type: 'string'
    alias: 'dir'
    default: ''
    describe: 'Sets download directory'
  'f':
    type: 'string'
    alias: 'filename'
    default: ''
    describe: 'Sets file name if no file name mode is specified'
  'r':
    type: 'boolean'
    alias: 'referrer'
    default: true
    describe: 'Uses page URL as referrer in download request'

yargsExtractOptions =
  'to':
    type: 'string'
    default: ''
    describe: 'Extraction directory for compressed files'
  'cd':
    type: 'string'
    default: false
    describe: 'Change directory of compressed file (Normal mode)'
  'cdr':
    type: 'string'
    default: false
    describe: 'Change directory of compressed file (Regex mode)'
  'glob':
    type: 'string'
    default: false
    describe: 'File glob for extracting compressed file'
  'mep':
    type: 'boolean'
    default: true
    describe: 'Maintain entry path for compressed files'
  'or':
    type: 'boolean'
    alias: 'overwrite'
    default: true
    describe: 'Overwrite files when extracting'

yargsExecuteOptions =
  'args':
    type: 'string'
    default: ''
    describe: 'Arguments when executing file (Seperate arguments with "|", ex: "Hello|World|100")'

downloadCommandUsage = 'Usage: endl d (Page URL) (Find Query) [options]'

downloadFile = (yargs, options, numRequired) ->
  argv = yargs
    .usage downloadCommandUsage
    .option options
    .argv

  return yargs.showHelp() if argv._.length < numRequired

  [command, url, find] = argv._

  return endl.load(url) if command == 'l'

  useText = argv.T
  attr = argv.a
  index = parseInt(argv.i, 10)

  if argv.f.length > 0
    useFilename = true
  else
    useFilename = false

  if argv.t == 'c'
    useCheerio = true
  else
    useCheerio = false

  downloadOptions = {}
  downloadOptions.filenameMode = {}

  if argv.f == ''
    argv.m.split('+').forEach (i) ->
      i = i.trim()
      downloadOptions.filenameMode[i] = true
  else
    downloadOptions.filenameMode['predefined'] = argv.f

  if command[0] == 'd'
    containerPromise = (endl.page(url)[if useCheerio then 'find' else 'findXpath'])(find)
    containerPromise.then (container) ->
      attrInstance = container.index(index)[if useText then 'text' else 'attr'](attr)

      bar = null
      downloadEnd = (data) ->
        bar.update 1
        console.log "Download URL: #{data.url}"
        console.log "File is saved to: #{data.file}"

        if command == 'de'
          execOptions =
            args: argv.args.split('|')

          console.log "Executing file with arguments: #{execOptions.args.join(', ')}"
          file.execute execOptions

        if command == 'dx'
          extractOptions =
            to: argv.to
            cd: argv.cd
            cdRegex: argv.cdr
            maintainEntryPath: argv.mep
            fileGlob: argv.glob
            overwrite: argv.or

          file.extract extractOptions, (extractData) ->
            console.log "Total number of files extracted:", extractData.length

      file = attrInstance.download downloadOptions,
        progress: (state) ->
          if bar == null
            bar = new ProgressBar 'Downloading [:bar] <:current/:total> <:rate/bps> <:etas>',
              total: state.size.total
              current: state.size.transferred
          else
            bar.update state.percent,
              current: state.size.transferred
        error: (err) -> console.error err
        end: downloadEnd

argv = yargs
.usage('Usage: endl <command>')
.command 'd', 'Loads a page, finds an element, downloads a link', (yargs) ->
  downloadFile yargs, yargsMainOptions, 3
.command 'de', 'Same as d, but executes the file with arguments', (yargs) ->
  downloadFile yargs, _extend(yargsMainOptions, yargsExecuteOptions), 3
.command 'dx', 'Same as d, but extracts the file with options', (yargs) ->
  downloadFile yargs, _extend(yargsMainOptions, yargsExtractOptions), 3
.command 'l', 'Loads a JSON or YAML file', (yargs) ->
  downloadCommandUsage = 'Usage: endl l <file>'
  downloadFile yargs, {}, 2
.demand 1, 'You should provide a command'
.help 'help'
.version -> require('../package.json').version
.argv
