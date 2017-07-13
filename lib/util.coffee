module.exports = Util =
  isPathSetup: () ->
    meta = require "../package.json"
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
                atom.workspace.open("atom://config/packages/#{meta.name}")
                notification.dismiss()
            }
            {
              text: 'Ignore',
              onDidClick: ->
                atom.config.set("#{meta.name}.mutePathWarning", true)
                notification.dismiss()
            }
          ]
        )

  satisfyDependencies: () ->
    meta = require "../package.json"
    require("atom-package-deps").install(meta.name)

    for k, v of meta["package-deps"]
      if atom.packages.isPackageDisabled(v)
        console.log "Enabling package '#{v}'" if atom.inDevMode()
        atom.packages.enablePackage(v)

  successNslAssembler: () ->
    { basename, dirname, extname, join } = require "path"
    doc = atom.workspace.getActiveTextEditor().buffer?.file.path
    dirName = dirname(doc)
    extName = extname(doc)
    baseName = basename(doc, extName)
    outName = baseName + '.nsi'
    nsisFile = join(dirName, outName)

    atom.workspace.open(nsisFile)
