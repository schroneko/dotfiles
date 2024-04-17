/// <reference types="cheerio" />
export default function enhance({ $, graphsCache, fileDirectoryPath, imageDirectoryPath, plantumlServer, plantumlJarPath, kirokiServer, }: {
    $: CheerioStatic;
    graphsCache: {
        [key: string]: string;
    };
    fileDirectoryPath: string;
    imageDirectoryPath: string;
    plantumlServer: string;
    plantumlJarPath: string;
    kirokiServer: string;
}): Promise<void>;
