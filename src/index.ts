import { registerPlugin } from '@capacitor/core';

import type { CanShareToStoriesOptions, ShareOptions, ShareToStoriesOptions, SharingPlugin } from './definitions';

const CapacitorSharing = registerPlugin<SharingPlugin>('Sharing', {
  web: () => import('./web').then(m => new m.SharingWeb()),
});

export class Sharing {
  plugin = CapacitorSharing;
  share(options: ShareOptions): Promise<void> {
    return this.plugin.share(options);
  }

  shareToFacebookStories(options: ShareToStoriesOptions): Promise<void> {
    return this.plugin.shareToFacebookStories(options);
  }

  canShareToFacebookStories(options: CanShareToStoriesOptions): Promise<boolean> {
    return this.plugin.canShareToFacebookStories(options).then(result => result.value);
  }

  shareToInstagramStories(options: ShareToStoriesOptions): Promise<void> {
    return this.plugin.shareToInstagramStories(options);
  }

  canShareToInstagramStories(options: CanShareToStoriesOptions): Promise<boolean> {
    return this.plugin.canShareToInstagramStories(options).then(result => result.value);
  }
}

export * from './definitions';

