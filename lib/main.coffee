# Dependencies
{exec} = require 'child_process'

module.exports = NslCore =
  subscriptions: null
  which: null
  prefix: null

  activate: (state) ->
    {CompositeDisposable} = require 'atom'

    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    # Register commands
    @subscriptions.add atom.commands.add 'atom-workspace', 'nsl-assembler:save-&-compile': => @buildScript()

  buildScript: ->
    editor = atom.workspace.getActiveTextEditor()
    script = editor.getPath()
    scope  = editor.getGrammar().scopeName

    if script? and scope.startsWith 'source.nsl'
      editor.save()

      @getPath (stdout) ->
        nslJar  = atom.config.get('language-nsl.pathToJar')

        exec "\"java\" -jar \"#{nslJar}\" \"#{script}\"", (error, stdout, stderr) ->
          if error isnt null
            # nslJar error from stdout, not error!
            atom.notifications.addError(script, detail: error, dismissable: true)
          else
            atom.notifications.addSuccess("Compiled successfully", detail: stdout, dismissable: false)
    else
      # Something went wrong
      atom.beep()

  getPath: (callback) ->
    @getPlatform()

    # If stored, return pathToJar
    pathToJar = atom.config.get('language-nsl.pathToJar')
    if pathToJar?
      callback pathToJar
      return

    # Find nsL.jar
    exec "\"#{@which}\" java", (error, stdout, stderr) ->
      if error isnt null
        atom.notifications.addError("**language-nsl**: Java is not in your `PATH` [environmental variable](http://superuser.com/a/284351/195953)", dismissable: false)
      else
        callback stdout
      return

  getPlatform: ->
    os = require 'os'

    if os.platform() is 'win32'
      @which  = "where"
      @prefix = "/"
    else
      @which  = "which"
      @prefix = "-"
