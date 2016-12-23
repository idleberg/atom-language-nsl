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
    alwaysShowOutput:
      title: "Always Show Output"
      description: "Displays compiler output in console panel. When deactivated, it will only show on errors"
      type: "boolean"
      default: true
      order: 2
    showBuildNotifications:
      title: "Show Build Notifications"
      description: "Displays color-coded notifications that close automatically after 5 seconds"
      type: "boolean"
      default: true
      order: 3
    clearConsole:
      title: "Clear Console"
      description: "When `console-panel` isn't available, build logs will be printed using `console.log()`. This setting clears the console prior to building."
      type: "boolean"
      default: true
      order: 4
    manageDependencies:
      title: "Manage Dependencies"
      description: "When enabled, this will automatically install third-party dependencies"
      type: "boolean"
      default: true
      order: 5
  subscriptions: null

  activate: (state) ->
    require('atom-package-deps').install(meta.name)

    {CompositeDisposable} = require 'atom'

    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    # Register commands
    @subscriptions.add atom.commands.add 'atom-workspace', 'nsl-assembler:save-&-transpile': => @buildScript(@consolePanel)

    if atom.config.get('language-nsl.manageDependencies')
      @setupPackageDeps()

  deactivate: ->
    @subscriptions?.dispose()
    @subscriptions = null

  setupPackageDeps: () ->
    require('atom-package-deps').install(meta.name)

    for k, v of meta["package-deps"]
      if atom.packages.isPackageDisabled(v)
        console.log "Enabling package '#{v}'" if atom.inDevMode()
        atom.packages.enablePackage(v)

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

      try
        consolePanel.clear()
      catch
        console.clear() if atom.config.get('language-nsl.clearConsole')

      # Let's go
      nslCmd = spawn "java", args
      hasError = false

      nslCmd.stdout.on 'data', (data) ->
        try
          consolePanel.log(data.toString()) if atom.config.get('language-nsl.alwaysShowOutput')
        catch
          console.log(data.toString())

      nslCmd.stderr.on 'data', (data) ->
        hasError = true
        try
          consolePanel.error(data.toString()) if atom.config.get('language-nsl.alwaysShowOutput')
        catch
          console.error(data.toString())

      nslCmd.on 'close', ( errorCode ) ->
        if errorCode is 0 and hasError is false
          return atom.notifications.addSuccess("Transpiled successfully", dismissable: false) if atom.config.get('language-nsl.showBuildNotifications')

        return atom.notifications.addError("Transpile failed", dismissable: false) if atom.config.get('language-nsl.showBuildNotifications')
    else
      # Something went wrong
      atom.beep()
