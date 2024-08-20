import { registerPlugin } from '@capacitor/core';

import {
  CanShareToInstagramStoriesOptions,
  CanShareToOptions,
  ShareOptions,
  ShareToInstagramStoriesOptions,
  ShareToOptions,
  SharingPlugin,
} from './definitions';

const CapacitorSharing = registerPlugin<SharingPlugin>('Sharing', {
  web: () => import('./web').then(m => new m.SharingWeb()),
});

export class Sharing {
  plugin = CapacitorSharing;
  /**
   * Native sharing dialog
   */
  share(options: ShareOptions) {
    return this.plugin.share(options);
  }

  shareTo(options: ShareToOptions) {
    return this.plugin.shareTo(options).then(({ value }) => value);
  }

  canShareTo(options: CanShareToOptions) {
    return this.plugin.canShareTo(options).then(({ value }) => value);
  }

  /**
   * @deprecated Use shareTo instead
   */
  shareToInstagramStories(options: ShareToInstagramStoriesOptions) {
    return this.plugin.shareTo({
      shareTo: 'instagramStories',
      ...options,
    });
  }

  /**
   * @deprecated Use canShareTo instead
   */
  canShareToInstagramStories(options: CanShareToInstagramStoriesOptions) {
    return this.plugin.canShareTo({
      shareTo: 'instagramStories',
      ...options,
    });
  }
}

export * from './definitions';
