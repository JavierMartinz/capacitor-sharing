import { WebPlugin } from '@capacitor/core';

import type {
  ShareOptions,
  ShareToInstagramStoriesOptions,
  SharingPlugin,
} from './definitions';

export class SharingWeb extends WebPlugin implements SharingPlugin {
  // share via navigator API
  async share(options: ShareOptions): Promise<void> {
    const { title, text, url } = options;
    if (navigator.share) {
      await navigator.share({
        title,
        text,
        url,
      });
    } else {
      console.warn('Share is not supported on this browser');
    }
  }

  async shareToInstagramStories(
    _: ShareToInstagramStoriesOptions,
  ): Promise<void> {
    console.warn('shareToInstagramStories is not implemented on web');
  }

  async canShareToInstagramStories(): Promise<{ value: boolean }> {
    return { value: false };
  }
}
