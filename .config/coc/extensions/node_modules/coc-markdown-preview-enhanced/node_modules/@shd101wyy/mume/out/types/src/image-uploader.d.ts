export declare function uploadImage(imageFilePath: string, { method, qiniu, }: {
    method?: string | undefined;
    qiniu?: {
        AccessKey: string;
        SecretKey: string;
        Bucket: string;
        Domain: string;
    } | undefined;
}): Promise<string>;
