import { WebPlugin } from '@capacitor/core';

import type {
  CanShareToInstagramStoriesOptions,
  CanShareToOptions,
  NativeShareResult,
  ShareOptions,
  ShareResult,
  ShareToInstagramStoriesOptions,
  ShareToOptions,
  SharingPlugin,
} from './definitions';

export class SharingWeb extends WebPlugin implements SharingPlugin {
  /**
   * Check if the app has permission to save photos to the photo library (iOS only)
   * On web, this will always return false as web doesn't have access to photo library
   */
  async canSaveToPhotoLibrary(): Promise<ShareResult> {
    console.warn('Photo library permissions are not available on web');
    return { value: false };
  }
  
  /**
   * Request permission to save photos to the photo library (iOS only)
   * On web, this will always return false as web doesn't have access to photo library
   */
  async requestPhotoLibraryPermissions(): Promise<ShareResult> {
    console.warn('Photo library permissions cannot be requested on web');
    return { value: false };
  }
  
  // share via navigator API
  async share(options: ShareOptions): Promise<NativeShareResult> {
    const { title, text, url } = options;
    if (navigator.share) {
      return navigator
          .share({
            title,
            text,
            url,
          })
          .then(() => ({ status: 'success' as const }));
    } else {
      console.warn('Share is not supported on this browser');
      return Promise.reject('Share is not supported on this browser');
    }
  }

  async shareTo(options: ShareToOptions): Promise<ShareResult> {
    const shareTo = (options as any).shareTo;

    // For Instagram Feed on web, we can only open Instagram website
    if (shareTo === 'instagramFeed') {
      try {
        // This is the best we can do on web - redirect to Instagram
        window.open('https://www.instagram.com/', '_blank');
        return { value: true };
      } catch (e) {
        console.error('Error sharing to Instagram Feed', e);
        return { value: false };
      }
    } else if (shareTo === 'instagramStories' || shareTo === 'facebookStories') {
      console.warn(`Sharing to ${shareTo} is not supported on web`);
      return { value: false };
    } else if (shareTo === 'native') {
      // Use the native share if available
      try {
        await this.share(options);
        return { value: true };
      } catch {
        return { value: false };
      }
    } else {
      console.warn(`Sharing to ${shareTo || 'unknown target'} is not supported`);
      return { value: false };
    }
  }

  async canShareTo(options: CanShareToOptions): Promise<ShareResult> {
    const { shareTo } = options;
    
    if (shareTo === 'native') {
      return { value: !!navigator && !!navigator.share };
    } else if (shareTo === 'instagramFeed') {
      // On web, we can always try to open Instagram in a new tab
      return { value: true };
    } else {
      // Stories sharing not supported on web
      return { value: false };
    }
  }

  /**
   * @deprecated Use shareTo instead
   */
  async shareToInstagramStories(options: ShareToInstagramStoriesOptions): Promise<void> {
    await this.shareTo({
      shareTo: 'instagramStories',
      ...options,
    });
  }

  /**
   * @deprecated Use canShareTo instead
   */
  async canShareToInstagramStories(options: CanShareToInstagramStoriesOptions): Promise<ShareResult> {
    return this.canShareTo({
      shareTo: 'instagramStories',
      ...options,
    });
  }
}
