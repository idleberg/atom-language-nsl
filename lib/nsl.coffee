module.exports = Nsl =

  transpile: (consolePanel) ->
    { spawn } = require "child_process"
    { notifyOnSucess } = require "./util"

    editor = atom.workspace.getActiveTextEditor()

    unless editor?
      atom.notifications.addWarning("**language-nsl**: No active editor", dismissable: false)
      return

    script = editor.getPath()
    scope  = editor.getGrammar().scopeName

    if script? and scope.startsWith "source.nsl"
      editor.save() if editor.isModified()

      nslJar  = atom.config.get("language-nsl.pathToJar")
      defaultArguments = ["-jar", "#{nslJar}"]
      customArguments = atom.config.get("language-nsl.customArguments").trim().split(" ")
      customArguments.push(script)
      args = defaultArguments.concat(customArguments)

      try
        consolePanel.clear()
      catch
        console.clear() if atom.config.get("language-nsl.clearConsole")

      # Let's go
      nslCmd = spawn "java", args
      hasError = false

      nslCmd.stdout.on "data", (data) ->
        try
          consolePanel.log(data.toString()) if atom.config.get("language-nsl.alwaysShowOutput")
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
          return notifyOnSucess() if atom.config.get("language-nsl.showBuildNotifications")
        else
          atom.notifications.addError("Transpile failed", dismissable: false) if atom.config.get("language-nsl.showBuildNotifications")
    else
      # Something went wrong
      atom.beep()
