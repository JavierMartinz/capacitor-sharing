export interface SharingPlugin {
  share(options: ShareOptions): Promise<void>;
  shareToFacebookStories(options: ShareToStoriesOptions): Promise<void>;
  shareToInstagramStories(options: ShareToStoriesOptions): Promise<void>;
  canShareToFacebookStories(options: CanShareToStoriesOptions): Promise<{ value: boolean }>;
  canShareToInstagramStories(options: CanShareToStoriesOptions): Promise<{ value: boolean }>;
}

export interface ShareOptions {
  title?: string;
  text?: string;
  url?: string;
  imageBase64?: string;
}

export interface ShareToStoriesOptions {
  facebookAppId: string;
  backgroundTopColor?: string;
  backgroundBottomColor?: string;
  stickerImageBase64?: string;
  backgroundImageBase64?: string;
}

export interface CanShareToStoriesOptions {
  facebookAppId: string;
}
