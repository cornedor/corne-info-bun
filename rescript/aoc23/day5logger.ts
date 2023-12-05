function convertNanosecondsToTime(nanoseconds: number) {
  const milliseconds = nanoseconds / 1000000;
  const seconds = Math.floor((milliseconds / 1000) % 60);
  const minutes = Math.floor((milliseconds / (1000 * 60)) % 60);

  return {
    minutes: String(minutes),
    seconds: String(seconds).padStart(2, "0"),
  };
}

export function logWithTime(...items: any) {
  const time = convertNanosecondsToTime(Bun.nanoseconds());
  console.log(`[${time.minutes}m${time.seconds}s]`, ...items);
}
