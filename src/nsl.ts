import { spawn } from 'node:child_process';
import meta from '../package.json';
import { notifyOnSucess } from './util.js';

export function transpile(consolePanel: any): void {
	const editor = atom.workspace.getActiveTextEditor();

	if (editor == null) {
		atom.notifications.addWarning(`**${meta.name}**: No active editor`, { dismissable: false });
		return;
	}

	const script = editor.getPath();
	const scope = editor.getGrammar().scopeName;

	if (script != null && scope.startsWith('source.nsl')) {
		editor.save().then(() => {
			const nslJar = atom.config.get('language-nsl.pathToJar') as string;
			const defaultArguments = ['-jar', `${nslJar}`];
			const customArguments = [...(atom.config.get('language-nsl.customArguments') as string[])];
			customArguments.push(script);
			const args = defaultArguments.concat(customArguments);

			try {
				consolePanel.clear();
			} catch {
				if (atom.config.get('language-nsl.clearConsole')) {
					console.clear();
				}
			}

			// Let's go
			const nslCmd = spawn('java', args);
			let hasError = false;

			nslCmd.stdout.on('data', (data: Buffer) => {
				try {
					if (atom.config.get('language-nsl.alwaysShowOutput')) {
						consolePanel.log(data.toString());
					}
				} catch {
					console.log(data.toString());
				}
			});

			nslCmd.stderr.on('data', (data: Buffer) => {
				hasError = true;
				try {
					consolePanel.error(data.toString());
				} catch {
					console.error(data.toString());
				}
			});

			nslCmd.on('close', (errorCode: number | null) => {
				if (errorCode === 0 && hasError === false) {
					if (atom.config.get('language-nsl.showBuildNotifications')) {
						notifyOnSucess();
					}
				} else {
					if (atom.config.get('language-nsl.showBuildNotifications')) {
						atom.notifications.addError('Transpile failed', { dismissable: false });
					}
				}
			});
		});
	} else {
		// Something went wrong
		atom.beep();
	}
}
