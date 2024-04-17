import Token from 'markdown-it/lib/token';
export interface Reference {
    elementId: string;
    parentToken: Token | null;
    token: Token;
    text: string;
    link: string;
}
export declare class ReferenceMap {
    map: {
        [key: string]: {
            [key: string]: Reference[];
        };
    };
    constructor();
    addReference(noteFilePath: string, referredByNoteFilePath: string, reference?: Reference): void;
    deleteReferences(noteFilePath: string, referredByNoteFilePath: string): void;
    hasRelation(filePath1: string, filePath2: string): boolean;
    getReferences(noteFilePath: string, referredByNoteFilePath: string): Reference[];
    noteHasReferences(filePath: string): boolean;
    getReferredByNotesCount(noteFilePath: string): number;
}
