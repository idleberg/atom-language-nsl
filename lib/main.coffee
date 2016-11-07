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
    {CompositeDisposable} = require 'atom'

    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    # Register commands
    @subscriptions.add atom.commands.add 'atom-workspace', 'nsl-assembler:save-&-compile': => @buildScript()

  deactivate: ->
    @subscriptions?.dispose()
    @subscriptions = null

  buildScript: ->
    editor = atom.workspace.getActiveTextEditor()

    unless editor?
      atom.notifications.addWarning("**language-nsl**: No active editor", dismissable: false)
      return

    script = editor.getPath()
    scope  = editor.getGrammar().scopeName

    if script? and scope.startsWith 'source.nsl'
      editor.save() if editor.isModified()

      @getPath (stdout) ->
        nslJar  = atom.config.get('language-nsl.pathToJar')

        if not nslJar
          atom.notifications.addError("**language-nsl**: no valid `nsL.jar` was specified in your config", dismissable: false)
          return

        defaultArguments = ["java", "-jar", nslJar]
        customArguments = atom.config.get('language-nsl.customArguments').trim().split(" ")

        if os.platform() is 'win32'
          customArguments.push("\"#{script}\"")
        else
          customArguments.push(script)

        nslCmd = defaultArguments.concat(customArguments)

        exec nslCmd.join(" "), (error, stdout, stderr) ->
          if error isnt null
            # nslJar error from stdout, not error!
            atom.notifications.addError("**#{script}**", detail: error, dismissable: true)
          else
            atom.notifications.addSuccess("Compiled successfully", detail: stdout, dismissable: false)
    else
      # Something went wrong
      atom.beep()

  getPath: (callback) ->
    if os.platform() is 'win32'
      which  = "where"
    else
      which  = "which"

    # Find Java
    exec "\"#{which}\" java", (error, stdout, stderr) ->
      if error isnt null
        atom.notifications.addError("**language-nsl**: Java is not in your `PATH` [environmental variable](http://superuser.com/a/284351/195953)", dismissable: true)
      else
        callback stdout
      return
