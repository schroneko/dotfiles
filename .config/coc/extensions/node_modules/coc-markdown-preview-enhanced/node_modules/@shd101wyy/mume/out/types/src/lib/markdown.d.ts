import { JsonObject } from 'type-fest';
export declare const TagStopRegExp: RegExp;
export declare function getTags(markdown: string): string[];
export declare function sanitizeTag(tagName: string): string;
export declare function sanitizeNoteTitle(noteTitle: string): string;
export interface MatterOutput {
    data: JsonObject;
    content: string;
}
export declare function matter(markdown: string): MatterOutput;
export declare function matterStringify(markdown: string, frontMatter: JsonObject): string;
