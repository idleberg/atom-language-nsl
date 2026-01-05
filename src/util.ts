import { access, constants } from "fs";
import { basename, dirname, extname, join } from "path";
import meta from "../package.json";

export function isPathSetup(): void {
	const pathToJar = atom.config.get(`${meta.name}.pathToJar`) as string;

	access(pathToJar, constants.R_OK | constants.W_OK, (error) => {
		if (error) {
			const notification = atom.notifications.addWarning(
				`**${meta.name}**: No valid \`nsL.jar\` was specified in your settings`,
				{
					dismissable: true,
					buttons: [
						{
							text: "Open Settings",
							className: "icon icon-gear",
							onDidClick() {
								atom.workspace.open(`atom://config/packages/${meta.name}`, { pending: true, searchAllPanes: true });
								notification.dismiss();
							}
						},
						{
							text: "Ignore",
							onDidClick() {
								atom.config.set(`${meta.name}.mutePathWarning`, true);
								notification.dismiss();
							}
						}
					]
				}
			);
		}
	});
}

export function notifyOnSucess(): void {
	if (atom.config.get(`${meta.name}.showBuildNotifications`)) {
		const notification = atom.notifications.addSuccess(
			"Transpiled successfully",
			{
				dismissable: true,
				buttons: [
					{
						text: "Open",
						className: "icon icon-pencil",
						onDidClick() {
							openScript();
							notification.dismiss();
						}
					},
					{
						text: "Cancel",
						onDidClick() {
							notification.dismiss();
						}
					}
				]
			}
		);
	}
}

export function openScript(): void {
	const doc = atom.workspace.getActiveTextEditor()?.buffer?.file?.path;

	if (!doc) {
		return;
	}

	const dirName = dirname(doc);
	const extName = extname(doc);
	const baseName = basename(doc, extName);
	const outName = baseName + '.nsi';
	const nsisFile = join(dirName, outName);

	atom.workspace.open(nsisFile);
}
