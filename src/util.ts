import { access, constants } from 'node:fs/promises';
import meta from '../package.json';

export async function isPathSetup(): Promise<void> {
	const pathToJar = atom.config.get(`${meta.name}.pathToJar`) as string;

	if (await fileExists(pathToJar)) {
		return;
	}

	const notification = atom.notifications.addWarning(
		`**${meta.name}**: No valid \`nsL.jar\` was specified in your settings`,
		{
			dismissable: true,
			buttons: [
				{
					text: 'Open Settings',
					className: 'icon icon-gear',
					onDidClick() {
						atom.workspace.open(`atom://config/packages/${meta.name}`, { pending: true, searchAllPanes: true });
						notification.dismiss();
					},
				},
				{
					text: 'Ignore',
					onDidClick() {
						atom.config.set(`${meta.name}.mutePathWarning`, true);
						notification.dismiss();
					},
				},
			],
		},
	);
}

export function notifyOnSucess(): void {
	if (atom.config.get(`${meta.name}.showBuildNotifications`) === false) {
		return;
	}

	const notification = atom.notifications.addSuccess('Transpiled successfully', {
		dismissable: true,
		buttons: [
			{
				text: 'Open',
				className: 'icon icon-pencil',
				onDidClick() {
					openScript();
					notification.dismiss();
				},
			},
			{
				text: 'Cancel',
				onDidClick() {
					notification.dismiss();
				},
			},
		],
	});
}

export function openScript(): void {
	const doc = atom.workspace.getActiveTextEditor()?.getPath();

	if (!doc) {
		return;
	}

	const nsisFile = doc.replace(/\.nsl$/, '.nsi');

	atom.workspace.open(nsisFile);
}

export async function fileExists(filePath: string): Promise<boolean> {
	try {
		await access(filePath, constants.F_OK);
	} catch {
		return false;
	}

	return true;
}
