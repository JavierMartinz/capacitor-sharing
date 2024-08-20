export interface SharingPlugin {
  share(options: NativeShareOptions): Promise<NativeShareResult>;
  canShareTo(options: CanShareToOptions): Promise<ShareResult>;
  shareTo(options: ShareToOptions): Promise<ShareResult>;

  /**
   * @deprecated Use shareTo instead
   */
  shareToInstagramStories(
    options: ShareToInstagramStoriesOptions,
  ): Promise<void>;
  /**
   * @deprecated Use canShareTo instead
   */
  canShareToInstagramStories(
    options: CanShareToInstagramStoriesOptions,
  ): Promise<ShareResult>;
}

export type CanShareToOptions =
  | {
      shareTo: 'native';
    }
  | {
      shareTo: 'facebookStories' | 'instagramStories';
      facebookAppId: string;
    };

export type ShareToOptions =
  | {
      shareTo: 'facebookStories' | 'instagramStories';
      facebookAppId: string;

      backgroundTopColor?: string;
      backgroundBottomColor?: string;
      stickerImageBase64?: string;
      backgroundImageBase64?: string;
    }
  | {};

export type NativeShareResult = {
  status: 'success' | 'cancelled';
  target?: string;
};

export type ShareResult = {
  value: boolean;
};

export type ShareOptions = NativeShareOptions;

export type NativeShareOptions = {
  title?: string;
  text?: string;
  url?: string;
  imageBase64?: string;
};

// for backward compatibility

/**
 * @deprecated Use ShareToOptions instead
 */
export interface ShareToInstagramStoriesOptions {
  facebookAppId: string;
  backgroundTopColor?: string;
  backgroundBottomColor?: string;
  stickerImageBase64?: string;
  backgroundImageBase64?: string;
}
/**
 * @deprecated Use CanShareToOptions instead
 */
export interface CanShareToInstagramStoriesOptions {
  facebookAppId: string;
}
