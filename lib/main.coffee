meta = require "../package.json"

module.exports =
  config:
    pathToJar:
      title: "Path To JAR"
      description: "Specify the full path to `nsL.jar`"
      type: "string"
      default: ""
      order: 0
    mutePathWarning:
      title: "Mute Path Warning"
      description: "When enabled, warnings about missing path to `nsL.jar` will be muted"
      type: "boolean"
      default: false
      order: 1
    customArguments:
      title: "Custom Arguments"
      description: "Specify your preferred arguments for nsL Assembler"
      type: "string"
      default: "/nomake /nopause"
      order: 2
    alwaysShowOutput:
      title: "Always Show Output"
      description: "Displays compiler output in console panel. When deactivated, it will only show on errors"
      type: "boolean"
      default: true
      order: 3
    showBuildNotifications:
      title: "Show Build Notifications"
      description: "Displays color-coded notifications that close automatically after 5 seconds"
      type: "boolean"
      default: true
      order: 4
    clearConsole:
      title: "Clear Console"
      description: "When `console-panel` isn't available, build logs will be printed using `console.log()`. This setting clears the console prior to building."
      type: "boolean"
      default: true
      order: 5
    manageDependencies:
      title: "Manage Dependencies"
      description: "When enabled, third-party dependencies will be installed automatically"
      type: "boolean"
      default: true
      order: 6
  subscriptions: null

  activate: (state) ->
    require("atom-package-deps").install(meta.name)

    {CompositeDisposable} = require "atom"

    # Events subscribed to in atom"s system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    # Register commands
    @subscriptions.add atom.commands.add "atom-workspace", "nsl-assembler:save-&-transpile": => @buildScript(@consolePanel)

    @satisfyDependencies() if atom.config.get("#{meta.name}.manageDependencies") and atom.inSpecMode is false
    @isPathSetup() if atom.config.get("#{meta.name}.mutePathWarning") is false

  deactivate: ->
    @subscriptions?.dispose()
    @subscriptions = null

  satisfyDependencies: () ->
    require("atom-package-deps").install(meta.name)

    for k, v of meta["package-deps"]
      if atom.packages.isPackageDisabled(v)
        console.log "Enabling package '#{v}'" if atom.inDevMode()
        atom.packages.enablePackage(v)

  isPathSetup: () ->
    { access, constants} = require "fs"

    pathToJar = atom.config.get("#{meta.name}.pathToJar")

    access pathToJar, constants.R_OK | constants.W_OK, (error) ->
      if error
        notification = atom.notifications.addWarning(
          "**#{meta.name}**: No valid \`nsL.jar\` was specified in your settings",
          dismissable: true,
          buttons: [
            {
              text: 'Open Settings'
              onDidClick: ->
                atom.workspace.open("atom://config/packages/#{meta.name}");
                notification.dismiss();
            },
            {
              text: 'Ignore',
              onDidClick: ->
                atom.config.set("#{meta.name}.mutePathWarning", true);
                notification.dismiss();
            }
          ]
        )

  consumeConsolePanel: (@consolePanel) ->

  buildScript: (consolePanel) ->
    {spawn} = require "child_process"

    editor = atom.workspace.getActiveTextEditor()

    unless editor?
      atom.notifications.addWarning("**#{meta.name}**: No active editor", dismissable: false)
      return

    script = editor.getPath()
    scope  = editor.getGrammar().scopeName

    if script? and scope.startsWith "source.nsl"
      editor.save() if editor.isModified()

      nslJar  = atom.config.get("#{meta.name}.pathToJar")
      defaultArguments = ["-jar", "#{nslJar}"]
      customArguments = atom.config.get("#{meta.name}.customArguments").trim().split(" ")
      customArguments.push(script)
      args = defaultArguments.concat(customArguments)

      try
        consolePanel.clear()
      catch
        console.clear() if atom.config.get("#{meta.name}.clearConsole")

      # Let's go
      nslCmd = spawn "java", args
      hasError = false

      nslCmd.stdout.on "data", (data) ->
        try
          consolePanel.log(data.toString()) if atom.config.get("#{meta.name}.alwaysShowOutput")
        catch
          console.log(data.toString())

      nslCmd.stderr.on "data", (data) ->
        hasError = true
        try
          consolePanel.error(data.toString())
        catch
          console.error(data.toString())

      nslCmd.on "close", ( errorCode ) ->
        if errorCode is 0 and hasError is false
          return atom.notifications.addSuccess("Transpiled successfully", dismissable: false) if atom.config.get("#{meta.name}.showBuildNotifications")

        return atom.notifications.addError("Transpile failed", dismissable: false) if atom.config.get("#{meta.name}.showBuildNotifications")
    else
      # Something went wrong
      atom.beep()
