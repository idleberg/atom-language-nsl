meta = require '../package.json'

# Dependencies
{spawn} = require 'child_process'
os = require 'os'

module.exports =
  config:
    pathToJar:
      title: "Path To JAR"
      description: "Specify the full path to `nsL.jar`"
      type: "string"
      default: ""
      order: 0
    customArguments:
      title: "Custom Arguments"
      description: "Specify your preferred arguments for nsL Assembler"
      type: "string"
      default: "/nomake /nopause"
      order: 1
    showBuildNotifications:
      title: "Show Build Notifications"
      type: "boolean"
      default: true
      order: 2
  subscriptions: null

  activate: (state) ->
    require('atom-package-deps').install(meta.name)

    {CompositeDisposable} = require 'atom'

    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    # Register commands
    @subscriptions.add atom.commands.add 'atom-workspace', 'nsl-assembler:save-&-transpile': => @buildScript(@consolePanel)

  deactivate: ->
    @subscriptions?.dispose()
    @subscriptions = null

  consumeConsolePanel: (@consolePanel) ->

  buildScript: (consolePanel) ->
    editor = atom.workspace.getActiveTextEditor()

    unless editor?
      atom.notifications.addWarning("**#{meta.name}**: No active editor", dismissable: false)
      return

    script = editor.getPath()
    scope  = editor.getGrammar().scopeName

    if script? and scope.startsWith 'source.nsl'
      editor.save() if editor.isModified()
      
      nslJar  = atom.config.get('language-nsl.pathToJar')

      if not nslJar
        atom.notifications.addError("**#{meta.name}**: no valid `nsL.jar` was specified in your config", dismissable: false)
        return

      defaultArguments = ["-jar", "#{nslJar}"]
      customArguments = atom.config.get('language-nsl.customArguments').trim().split(" ")
      customArguments.push(script)
      args = defaultArguments.concat(customArguments)

      consolePanel.clear()

      # Let's go
      nslCmd = spawn "java", args
      hasError = false

      nslCmd.stdout.on 'data', (data) ->
        consolePanel.log(data.toString())

      nslCmd.stderr.on 'data', (data) ->
        hasError = true
        consolePanel.error(data.toString())

      nslCmd.on 'close', ( errorCode ) ->
        if errorCode is 0 and hasError is false
          return atom.notifications.addSuccess("Transpiled successfully", dismissable: false) if atom.config.get('language-nsl.showBuildNotifications')

        return atom.notifications.addError("Transpile failed", dismissable: false) if atom.config.get('language-nsl.showBuildNotifications')
    else
      # Something went wrong
      atom.beep()
