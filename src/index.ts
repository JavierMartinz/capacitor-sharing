import { registerPlugin } from '@capacitor/core';

import { CanShareToInstagramStoriesOptions, ShareOptions, ShareToInstagramStoriesOptions, SharingPlugin } from './definitions';

const CapacitorSharing = registerPlugin<SharingPlugin>('Sharing', {
  web: () => import('./web').then(m => new m.SharingWeb()),
});

export class Sharing {
  plugin = CapacitorSharing;
  share(options: ShareOptions): Promise<void> {
    return this.plugin.share(options);
  }

  shareToInstagramStories(options: ShareToInstagramStoriesOptions): Promise<void> {
    return this.plugin.shareToInstagramStories(options);
  }

  canShareToInstagramStories(options: CanShareToInstagramStoriesOptions): Promise<boolean> {
    return this.plugin.canShareToInstagramStories(options).then(result => result.value);
  }
}

export * from './definitions';

