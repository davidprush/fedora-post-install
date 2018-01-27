"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
var __metadata = (this && this.__metadata) || function (k, v) {
    if (typeof Reflect === "object" && typeof Reflect.metadata === "function") return Reflect.metadata(k, v);
};
var __awaiter = (this && this.__awaiter) || function (thisArg, _arguments, P, generator) {
    return new (P || (P = Promise))(function (resolve, reject) {
        function fulfilled(value) { try { step(generator.next(value)); } catch (e) { reject(e); } }
        function rejected(value) { try { step(generator["throw"](value)); } catch (e) { reject(e); } }
        function step(result) { result.done ? resolve(result.value) : new P(function (resolve) { resolve(result.value); }).then(fulfilled, rejected); }
        step((generator = generator.apply(thisArg, _arguments || [])).next());
    });
};
Object.defineProperty(exports, "__esModule", { value: true });
const inversify_1 = require("inversify");
const vscode_1 = require("vscode");
const types_1 = require("../adapter/parsers/types");
const commandManager_1 = require("../application/types/commandManager");
const types_2 = require("../commandHandlers/types");
const types_3 = require("../common/types");
const types_4 = require("../ioc/types");
const types_5 = require("../types");
const types_6 = require("./types");
// tslint:disable-next-line:no-require-imports no-var-requires
let ApiController = class ApiController {
    constructor(app, gitServiceFactory, serviceContainer, stateStore, commandManager) {
        this.app = app;
        this.gitServiceFactory = gitServiceFactory;
        this.serviceContainer = serviceContainer;
        this.stateStore = stateStore;
        this.commandManager = commandManager;
        // tslint:disable-next-line:cyclomatic-complexity member-ordering
        this.getLogEntries = (request, response) => __awaiter(this, void 0, void 0, function* () {
            const id = decodeURIComponent(request.query.id);
            const currentState = this.stateStore.getState(id);
            const refresh = request.query.refresh === 'true';
            let searchText = request.query.searchText;
            if (currentState && currentState.searchText && typeof searchText !== 'string') {
                searchText = currentState.searchText;
            }
            searchText = typeof searchText === 'string' && searchText.length === 0 ? undefined : searchText;
            let pageIndex = request.query.pageIndex ? parseInt(request.query.pageIndex, 10) : undefined;
            if (currentState && currentState.pageIndex && typeof pageIndex !== 'number') {
                pageIndex = currentState.pageIndex;
            }
            let branch = request.query.branch;
            if (currentState && currentState.branch && typeof branch !== 'string') {
                branch = currentState.branch;
            }
            let pageSize = request.query.pageSize ? parseInt(request.query.pageSize, 10) : undefined;
            if (currentState && currentState.pageSize && (typeof pageSize !== 'number' || pageSize === 0)) {
                pageSize = currentState.pageSize;
            }
            const filePath = request.query.file;
            let file = filePath ? vscode_1.Uri.file(filePath) : undefined;
            if (currentState && currentState.file && !file) {
                file = currentState.file;
            }
            let branchSelection = request.query.pageSize ? parseInt(request.query.branchSelection, 10) : undefined;
            if (currentState && currentState.branchSelection && typeof branchSelection !== 'number') {
                branchSelection = currentState.branchSelection;
            }
            let promise;
            const branchesMatch = currentState && (currentState.branch === branch);
            const noBranchDefinedByClient = !currentState;
            if (!refresh && searchText === undefined && pageIndex === undefined && pageSize === undefined &&
                file === undefined &&
                currentState && currentState.entries && (branchesMatch || noBranchDefinedByClient)) {
                let selected;
                if (currentState.lastFetchedCommit) {
                    selected = yield currentState.lastFetchedCommit;
                }
                promise = currentState.entries.then(data => {
                    // tslint:disable-next-line:no-unnecessary-local-variable
                    const entriesResponse = Object.assign({}, data, { branch: currentState.branch, branchSelection: currentState.branchSelection, file: currentState.file, pageIndex: currentState.pageIndex, pageSize: currentState.pageSize, searchText: currentState.searchText, selected: selected });
                    return entriesResponse;
                });
            }
            else if (!refresh && currentState &&
                (currentState.searchText === (searchText || '')) &&
                currentState.pageIndex === pageIndex &&
                (typeof branch === 'string' && currentState.branch === branch) &&
                currentState.pageSize === pageSize &&
                currentState.file === file &&
                currentState.entries) {
                promise = currentState.entries;
            }
            else {
                promise = this.getRepository(decodeURIComponent(request.query.id))
                    .getLogEntries(pageIndex, pageSize, branch, searchText, file)
                    .then(data => {
                    // tslint:disable-next-line:no-unnecessary-local-variable
                    const entriesResponse = Object.assign({}, data, { branch,
                        branchSelection,
                        file,
                        pageIndex,
                        pageSize,
                        searchText, selected: undefined });
                    return entriesResponse;
                });
                this.stateStore.updateEntries(id, promise, pageIndex, pageSize, branch, searchText, file, branchSelection);
            }
            promise
                .then(data => response.send(data))
                .catch(err => response.status(500).send(err));
        });
        // tslint:disable-next-line:cyclomatic-complexity
        this.getBranches = (request, response) => {
            const id = decodeURIComponent(request.query.id);
            this.getRepository(id)
                .getBranches()
                .then(data => response.send(data))
                .catch(err => response.status(500).send(err));
        };
        this.getCommit = (request, response) => __awaiter(this, void 0, void 0, function* () {
            const fileStatParserFactory = this.serviceContainer.get(types_1.IFileStatParser);
            // tslint:disable-next-line:no-console
            console.log(fileStatParserFactory);
            const id = decodeURIComponent(request.query.id);
            const hash = request.params.hash;
            const currentState = this.stateStore.getState(id);
            let commitPromise;
            // tslint:disable-next-line:possible-timing-attack
            if (currentState && currentState.lastFetchedHash === hash && currentState.lastFetchedCommit) {
                commitPromise = currentState.lastFetchedCommit;
            }
            else {
                commitPromise = this.getRepository(id).getCommit(hash);
                this.stateStore.updateLastHashCommit(id, hash, commitPromise);
            }
            commitPromise
                .then(data => {
                response.send(data);
                if (data && currentState) {
                    this.commitViewer.viewCommitTree(new types_3.CommitDetails(currentState.workspaceFolder, currentState.branch, data));
                }
            })
                .catch(err => {
                response.status(500).send(err);
            });
        });
        this.clearSelectedCommit = (request, response) => __awaiter(this, void 0, void 0, function* () {
            const id = decodeURIComponent(request.query.id);
            yield this.stateStore.clearLastHashCommit(id);
            response.send('');
        });
        this.doSomethingWithCommit = (request, response) => __awaiter(this, void 0, void 0, function* () {
            response.status(200).send('');
            const id = decodeURIComponent(request.query.id);
            const workspaceFolder = this.getWorkspace(id);
            const currentState = this.stateStore.getState(id);
            const logEntry = request.body;
            this.commandManager.executeCommand('git.commit.doSomething', new types_3.CommitDetails(workspaceFolder, currentState.branch, logEntry));
        });
        this.selectCommittedFile = (request, response) => __awaiter(this, void 0, void 0, function* () {
            response.status(200).send('');
            const id = decodeURIComponent(request.query.id);
            const body = request.body;
            const workspaceFolder = this.getWorkspace(id);
            const currentState = this.stateStore.getState(id);
            this.commandManager.executeCommand('git.commit.file.select', new types_3.FileCommitDetails(workspaceFolder, currentState.branch, body.logEntry, body.committedFile));
        });
        // tslint:disable-next-line:no-any
        this.handleRequest = (handler) => {
            return (request, response) => __awaiter(this, void 0, void 0, function* () {
                try {
                    yield handler(request, response);
                }
                catch (err) {
                    response.status(500).send(err);
                }
            });
        };
        this.commitViewer = this.serviceContainer.get(types_2.IGitCommitViewDetailsCommandHandler);
        this.app.get('/log', this.handleRequest(this.getLogEntries.bind(this)));
        this.app.get('/branches', this.handleRequest(this.getBranches.bind(this)));
        this.app.get('/log/:hash', this.handleRequest(this.getCommit.bind(this)));
        this.app.post('/log/clearSelection', this.handleRequest(this.clearSelectedCommit.bind(this)));
        this.app.post('/log/:hash', this.handleRequest(this.doSomethingWithCommit.bind(this)));
        this.app.post('/log/:hash/committedFile', this.handleRequest(this.selectCommittedFile.bind(this)));
    }
    // tslint:disable-next-line:no-empty member-ordering
    dispose() { }
    getWorkspace(id) {
        return this.stateStore.getState(id).workspaceFolder;
    }
    getRepository(id) {
        const workspaceFolder = this.getWorkspace(id);
        return this.gitServiceFactory.createGitService(workspaceFolder);
    }
};
ApiController = __decorate([
    inversify_1.injectable(),
    __metadata("design:paramtypes", [Function, Object, Object, Object, Object])
], ApiController);
exports.ApiController = ApiController;
//# sourceMappingURL=apiController.js.map