import { WebPlugin } from '@capacitor/core';

import type { SharingPlugin } from './definitions';

export class SharingWeb extends WebPlugin implements SharingPlugin {
  async echo(options: { value: string }): Promise<{ value: string }> {
    console.log('ECHO', options);
    return options;
  }
}
