export interface SharingPlugin {
  echo(options: { value: string }): Promise<{ value: string }>;
}
