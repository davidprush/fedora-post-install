"use strict";
const vscode = require("vscode");
const cp = require("child_process");
const pathUtil_1 = require("./pathUtil");
const diffUtils_1 = require("../src/diffUtils");
class Formatter {
    constructor() {
        this.formatCommand = "shfmt";
    }
    formatDocument(document) {
        const start = new vscode.Position(0, 0);
        const end = new vscode.Position(document.lineCount - 1, document.lineAt(document.lineCount - 1).text.length);
        const range = new vscode.Range(start, end);
        const content = document.getText(range);
        return this.formatDocumentWithContent(content, document.fileName);
    }
    formatDocumentWithContent(content, filename) {
        return new Promise((resolve, reject) => {
            try {
                let formatFlags = []; //todo add user configuration
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
                let fmtSpawn = cp.spawn(this.formatCommand, formatFlags);
                let output = [];
                let errorOutput = [];
                let textEdits = [];
                fmtSpawn.stdout.on("data", chunk => {
                    let bc;
                    if (chunk instanceof Buffer) {
                        bc = chunk;
                    }
                    else {
                        bc = new Buffer(chunk);
                    }
                    output.push(bc);
                });
                fmtSpawn.stderr.on("data", chunk => {
                    let bc;
                    if (chunk instanceof Buffer) {
                        bc = chunk;
                    }
                    else {
                        bc = new Buffer(chunk);
                    }
                    errorOutput.push(bc);
                });
                fmtSpawn.on("close", code => {
                    if (code == 0) {
                        if (output.length == 0) {
                            resolve(null);
                        }
                        else {
                            let result = Buffer.concat(output).toString();
                            let filePatch = diffUtils_1.getEdits(filename, content, result);
                            filePatch.edits.forEach(edit => {
                                textEdits.push(edit.apply());
                            });
                            resolve(textEdits);
                        }
                    }
                    else {
                        let errMsg = "";
                        if (errorOutput.length != 0) {
                            errMsg = Buffer.concat(errorOutput).toString();
                            const showError = settings["showError"];
                            if (showError) {
                                vscode.window.showErrorMessage(errMsg);
                            }
                        }
                        // vscode.window.showWarningMessage('shell format error  please commit one issue to me:' + errMsg);
                        reject(errMsg);
                    }
                });
                fmtSpawn.stdin.write(content);
                fmtSpawn.stdin.end();
            }
            catch (e) {
                reject("Internal issues when formatted content");
            }
        });
    }
}
exports.Formatter = Formatter;
class ShellDocumentFormattingEditProvider {
    constructor(formatter) {
        if (formatter) {
            this.formatter = formatter;
        }
        else {
            this.formatter = new Formatter();
        }
        this.settings = vscode.workspace.getConfiguration("shellformat");
    }
    provideDocumentFormattingEdits(document, options, token) {
        // const onSave = this.settings["onsave"];
        // if (!onSave) {
        //   console.log(onSave);
        // }
        return this.formatter.formatDocument(document);
    }
}
exports.ShellDocumentFormattingEditProvider = ShellDocumentFormattingEditProvider;
//# sourceMappingURL=shFormat.js.map