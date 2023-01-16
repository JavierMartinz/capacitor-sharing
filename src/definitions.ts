export interface SharingPlugin {
  share(options: ShareOptions): Promise<void>;
  shareToInstagramStories(options: ShareToInstagramStoriesOptions): Promise<void>;
  canShareToInstagramStories(options: CanShareToInstagramStoriesOptions): Promise<{ value: boolean }>;
}

export interface ShareOptions {
  title?: string;
  text?: string;
  url?: string;
  imageBase64?: string;
}

export interface ShareToInstagramStoriesOptions {
  facebookAppId: string;
  backgroundTopColor?: string;
  backgroundBottomColor?: string;
  stickerImageBase64?: string;
  backgroundImageBase64?: string;
}

export interface CanShareToInstagramStoriesOptions {
  facebookAppId: string;
}