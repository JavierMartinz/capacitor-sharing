import { WebPlugin } from '@capacitor/core';

import type {
  CanShareToOptions,
  ShareOptions,
  ShareToInstagramStoriesOptions,
  ShareToOptions,
  SharingPlugin,
} from './definitions';

export class SharingWeb extends WebPlugin implements SharingPlugin {
  // share via navigator API
  async share(options: ShareOptions) {
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

  async shareTo(options: ShareToOptions) {
    const shareTo = (options as any).shareTo;

    // For Instagram Feed, we can at least open Instagram website
    if (shareTo === 'instagramFeed') {
      try {
        window.open('https://www.instagram.com/create/story', '_blank');
        return { value: true };
      } catch (e) {
        console.warn('Failed to open Instagram website');
      }
    }

    console.warn(`${shareTo || 'shareTo'} is not fully supported on web`);
    return { value: false };
  }

  async canShareTo(options: CanShareToOptions) {
    if (options.shareTo === 'native') {
      return { value: !!navigator && !!navigator.share };
    }

    // For Instagram Feed, we'll return true if we can open windows
    if (options.shareTo === 'instagramFeed') {
      return { value: true }; // We can always try to open the Instagram website
    }

    return { value: false };
  }

  /**
   * @deprecated Use shareTo instead
   */
  async shareToInstagramStories(
      _: ShareToInstagramStoriesOptions,
  ): Promise<void> {
    console.warn('shareToInstagramStories is not implemented on web');
  }

  /**
   * @deprecated Use canShareTo instead
   */
  async canShareToInstagramStories(): Promise<{ value: boolean }> {
    return { value: false };
  }
}
