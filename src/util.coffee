meta = require('../package.json')

module.exports =
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
              text: "Open Settings"
              className: "icon icon-gear"
              onDidClick: ->
                atom.workspace.open("atom://config/packages/#{meta.name}", {pending: true, searchAllPanes: true})
                notification.dismiss()
            }
            {
              text: "Ignore",
              onDidClick: ->
                atom.config.set("#{meta.name}.mutePathWarning", true)
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
            this.openScript()
            notification.dismiss()
        }
        {
          text: "Cancel"
          onDidClick: ->
            notification.dismiss()
        }
      ]
    ) if atom.config.get("#{meta.name}.showBuildNotifications")

  openScript: ->
    { basename, dirname, extname, join } = require "path"
    doc = atom.workspace.getActiveTextEditor().buffer?.file.path
    dirName = dirname(doc)
    extName = extname(doc)
    baseName = basename(doc, extName)
    outName = baseName + '.nsi'
    nsisFile = join(dirName, outName)

    atom.workspace.open(nsisFile)
