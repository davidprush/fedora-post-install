"use strict";
const vscode = require("vscode");
const cp = require("child_process");
const pathUtil_1 = require("./pathUtil");
const pathUtil_2 = require("./pathUtil");
class ShfmtFormatter {
    constructor() {
        this.formatCommand = "shfmt";
    }
    formatDocument(document) {
        let filename = document.uri.path; // document.fileName;
        let formatFlags = [];
        let settings = vscode.workspace.getConfiguration("shellformat");
        if (settings) {
            let flag = settings["flag"];
            if (flag) {
                if (flag.includes("-w")) {
                    vscode.window.showWarningMessage("can not set -w flag  please fix config");
                }
                let flags = flag.split(" ");
                formatFlags.push(flags);
            }
            let binPath = settings["path"];
            if (binPath) {
                if (pathUtil_1.fileExists(binPath)) {
                    this.formatCommand = binPath;
                }
                else {
                    vscode.window.showErrorMessage("the config shellformat.path file not exists please fix it");
                }
            }
        }
        let result = cp.execFileSync(this.formatCommand, [...formatFlags, filename], { encoding: "utf8" });
        return result;
    }
    checkEnv() {
        let settings = vscode.workspace.getConfiguration("shellformat");
        let configBinPath = false;
        if (settings) {
            let flag = settings["flag"];
            if (flag) {
                if (flag.includes("-w")) {
                    vscode.window.showWarningMessage("can not set -w flag  please fix config");
                }
            }
            let binPath = settings["path"];
            if (binPath) {
                configBinPath = true;
                if (pathUtil_1.fileExists(binPath)) {
                    this.formatCommand = binPath;
                }
                else {
                    vscode.window.showErrorMessage("the config shellformat.path file not exists please fix it");
                }
            }
        }
        if (!configBinPath && !this.isExecutedFmtCommand()) {
            vscode.window.showErrorMessage("shellformat.path not config please download  https://github.com/mvdan/sh/releases or go get -u github.com/mvdan/sh/cmd/shfmt to install");
        }
    }
    formatCurrentDocumentWithContent(content) {
        let formatFlags = [];
        let settings = vscode.workspace.getConfiguration("shellformat");
        if (settings) {
            let flag = settings["flag"];
            if (flag) {
                if (flag.includes("-w")) {
                    vscode.window.showWarningMessage("can not set -w flag  please fix config");
                }
                let flags = flag.split(" ");
                formatFlags.push(...flags);
            }
            let binPath = settings["path"];
            if (binPath) {
                if (pathUtil_1.fileExists(binPath)) {
                    this.formatCommand = binPath;
                }
                else {
                    vscode.window.showErrorMessage("the config shellformat.path file not exists please fix it");
                }
            }
        }
        let cmdSpawn = cp.spawnSync(this.formatCommand, formatFlags, {
            encoding: "utf8",
            input: content
        });
        if (cmdSpawn.status == 0) {
            return cmdSpawn.stdout;
        }
        else {
            vscode.window.showWarningMessage("shell format error:" + cmdSpawn.stderr);
            return null;
        }
    }
    isExecutedFmtCommand() {
        return pathUtil_2.getExecutableFileUnderPath(this.formatCommand) != null;
    }
}
exports.ShfmtFormatter = ShfmtFormatter;
//# sourceMappingURL=shfmtFormat.js.map