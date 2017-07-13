module.exports = Nsl =

  transpile: (consolePanel) ->
    meta = require "../package.json"
    { spawn } = require "child_process"
    { successNslAssembler } = require "./util"

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
          console.log "1"
          notification = atom.notifications.addSuccess(
            "Transpiled successfully",
            dismissable: true,
            buttons: [
              {
                text: 'Open'
                onDidClick: ->
                  successNslAssembler()
                  notification.dismiss()
              }
              {
                text: 'Cancel'
                onDidClick: ->
                  notification.dismiss()
              }
            ]
          ) if atom.config.get("#{meta.name}.showBuildNotifications")
        else
          atom.notifications.addError("Transpile failed", dismissable: false) if atom.config.get("#{meta.name}.showBuildNotifications")
    else
      # Something went wrong
      atom.beep()
