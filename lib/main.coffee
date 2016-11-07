meta = require '../package.json'

# Dependencies
{exec} = require 'child_process'
os = require 'os'

module.exports = NslCore =
  config:
    pathToJar:
      title: "Path To JAR"
      description: "Specify the full path to `nsL.jar`"
      type: "string"
      default: ""
      order: 0
    customArguments:
      title: "Custom Arguments"
      description: "Specify your preferred arguments for BridleNSIS"
      type: "string"
      default: "/nopause /nomake"
      order: 1
  subscriptions: null

  activate: (state) ->
    require('atom-package-deps').install(meta.name)

    {CompositeDisposable} = require 'atom'

    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    # Register commands
    @subscriptions.add atom.commands.add 'atom-workspace', 'nsl-assembler:save-&-transpile': => @buildScript()

  deactivate: ->
    @subscriptions?.dispose()
    @subscriptions = null

  buildScript: ->
    editor = atom.workspace.getActiveTextEditor()

    unless editor?
      atom.notifications.addWarning("**#{meta.name}**: No active editor", dismissable: false)
      return

    script = editor.getPath()
    scope  = editor.getGrammar().scopeName

    if script? and scope.startsWith 'source.nsl'
      editor.save() if editor.isModified()

      @getPath (javaBin) ->
        nslJar  = atom.config.get('language-nsl.pathToJar')

        if not nslJar
          atom.notifications.addError("**#{meta.name}**: no valid `nsL.jar` was specified in your config", dismissable: false)
          return

        defaultArguments = ["java", "-jar", "\"#{nslJar}\""]
        customArguments = atom.config.get('language-nsl.customArguments').trim().split(" ")
        customArguments.push("\"#{script}\"")

        nslCmd = defaultArguments.concat(customArguments).join(" ")

        exec nslCmd, (error, stdout, stderr) ->
          if error or stderr
            if error
              atom.notifications.addError("Transpiling failed", detail: error, dismissable: true)

            if stderr
              atom.notifications.addError("Transpiling failed", detail: stderr, dismissable: true)

            return

          atom.notifications.addSuccess("Transpiled successfully", detail: stdout, dismissable: false)
    else
      # Something went wrong
      atom.beep()

  getPath: (callback) ->
    if os.platform() is 'win32'
      whichJava  = "where java"
    else
      whichJava  = "which java"

    # Find Java
    exec whichJava, (error, stdout, stderr) ->
      if error isnt null
        atom.notifications.addError("**#{meta.name}**: Java is not in your `PATH` [environmental variable](http://superuser.com/a/284351/195953)", dismissable: true)
      else
        callback stdout
      return
