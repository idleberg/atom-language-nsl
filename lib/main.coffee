# Dependencies
{spawn} = require 'child_process'
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
    @subscriptions.add atom.commands.add 'atom-workspace', 'nsl-assembler:save-&-transpile': => @buildScript()

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

      @getPath (data) ->
        nslJar  = atom.config.get('language-nsl.pathToJar')

        if not nslJar
          atom.notifications.addError("**language-nsl**: no valid `nsL.jar` was specified in your config", dismissable: false)
          return

        defaultArguments = ["-jar", nslJar]
        customArguments = atom.config.get('language-nsl.customArguments').trim().split(" ")

        if os.platform() is 'win32'
          customArguments.push("\"#{script}\"")
        else
          customArguments.push(script)

        args = defaultArguments.concat(customArguments)
        nslCmd = spawn('java', args);

        nslCmd.stderr.on 'data', (data) ->
          atom.notifications.addError("Transpiling failed", detail: data, dismissable: true)
          return

        nslCmd.stdout.on 'data', (data) ->
          atom.notifications.addSuccess("Transpiled successfully", detail: data, dismissable: false)
          return
    else
      # Something went wrong
      atom.beep()

  getPath: (callback) ->
    if os.platform() is 'win32'
      whichJava = spawn('where', ['java']);
    else
      whichJava = spawn('which', ['java']);

    # Find Java
    whichJava.stderr.on 'data', (data) ->
      atom.notifications.addError("**language-nsl**: Java is not in your `PATH` [environmental variable](http://superuser.com/a/284351/195953)", dismissable: true)
      return

    whichJava.stdout.on 'data', (data) ->
      callback data
      return
