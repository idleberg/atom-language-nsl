import { CompositeDisposable } from 'atom';
import { satisfyDependencies } from 'atom-satisfy-dependencies';
import { transpile } from './nsl.js';
import { isPathSetup } from './util.js';

interface LanguageNSLPackage {
	config: typeof config;
	subscriptions: CompositeDisposable | null;
	consolePanel: any;
	activate(): void;
	deactivate(): void;
	consumeConsolePanel(consolePanel: any): void;
}

const config = {
	pathToJar: {
		title: 'Path To JAR',
		description: 'Specify the full path to `nsL.jar`',
		type: 'string' as const,
		default: '',
		order: 0,
	},
	mutePathWarning: {
		title: 'Mute Path Warning',
		description: 'When enabled, warnings about missing path to `nsL.jar` will be muted',
		type: 'boolean' as const,
		default: false,
		order: 1,
	},
	customArguments: {
		title: 'Custom Arguments',
		description: 'Specify your preferred arguments for nsL Assembler, separated by commas',
		type: 'array' as const,
		default: ['/nomake', '/nopause'],
		items: {
			type: 'string' as const,
		},
		order: 2,
	},
	alwaysShowOutput: {
		title: 'Always Show Output',
		description: 'Displays compiler output in console panel. When deactivated, it will only show on errors',
		type: 'boolean' as const,
		default: true,
		order: 3,
	},
	showBuildNotifications: {
		title: 'Show Build Notifications',
		description: 'Displays color-coded notifications that close automatically after 5 seconds',
		type: 'boolean' as const,
		default: true,
		order: 4,
	},
	clearConsole: {
		title: 'Clear Console',
		description:
			"When `console-panel` isn't available, build logs will be printed using `console.log()`. This setting clears the console prior to building.",
		type: 'boolean' as const,
		default: true,
		order: 5,
	},
	manageDependencies: {
		title: 'Manage Dependencies',
		description: 'When enabled, third-party dependencies will be installed automatically',
		type: 'boolean' as const,
		default: true,
		order: 6,
	},
};

export default {
	config,
	subscriptions: null,
	consolePanel: undefined,

	async activate(): Promise<void> {
		this.subscriptions = new CompositeDisposable();

		// Register commands
		this.subscriptions.add(
			atom.commands.add('atom-workspace', {
				'nsl-assembler:save-&-transpile': () => transpile(this.consolePanel),
			}),
		);

		if (atom.config.get('language-nsl.manageDependencies') === true) {
			satisfyDependencies('language-nsl');
		}

		if (atom.config.get('language-nsl.mutePathWarning') === false) {
			await isPathSetup();
		}
	},

	deactivate(): void {
		if (this.subscriptions != null) {
			this.subscriptions.dispose();
		}

		this.subscriptions = null;
	},

	consumeConsolePanel(consolePanel: any): void {
		this.consolePanel = consolePanel;
	},
} as LanguageNSLPackage;
