module.exports = Util =
  isPathSetup: () ->
    { access, constants} = require "fs"

    pathToJar = atom.config.get("language-nsl.pathToJar")

    access pathToJar, constants.R_OK | constants.W_OK, (error) ->
      if error
        notification = atom.notifications.addWarning(
          "**language-nsl**: No valid \`nsL.jar\` was specified in your settings",
          dismissable: true,
          buttons: [
            {
              text: "Open Settings"
              className: "icon icon-gear"
              onDidClick: ->
                require("./ga").sendEvent "util", "Open Settings"
                atom.workspace.open("atom://config/packages/language-nsl", {pending: true, searchAllPanes: true})
                notification.dismiss()
            }
            {
              text: "Ignore",
              onDidClick: ->
                require("./ga").sendEvent "util", "Mute Path Warning"
                atom.config.set("language-nsl.mutePathWarning", true)
                notification.dismiss()
            }
          ]
        )

  notifyOnSucess: ->
    notification = atom.notifications.addSuccess(
      "Transpiled successfully",
      dismissable: true,
      buttons: [
        {
          text: "Open"
          className: "icon icon-pencil"
          onDidClick: ->
            require("./ga").sendEvent "util", "Open Transpiled Script"
            Util.openScript()
            notification.dismiss()
        }
        {
          text: "Cancel"
          onDidClick: ->
            notification.dismiss()
        }
      ]
    ) if atom.config.get("language-nsl.showBuildNotifications")

  openScript: ->
    { basename, dirname, extname, join } = require "path"
    doc = atom.workspace.getActiveTextEditor().buffer?.file.path
    dirName = dirname(doc)
    extName = extname(doc)
    baseName = basename(doc, extName)
    outName = baseName + '.nsi'
    nsisFile = join(dirName, outName)

    atom.workspace.open(nsisFile)

  satisfyDependencies: () ->
    meta = require "../package.json"

    require("./ga").sendEvent "util", "Satisfy Dependencies"
    require("atom-package-deps").install(meta.name)

    for k, v of meta["package-deps"]
      if atom.packages.isPackageDisabled(v)
        console.log "Enabling package '#{v}'" if atom.inDevMode()
        atom.packages.enablePackage(v)
