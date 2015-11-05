export default function assertSingleArgument(count) {
  if (count !== 1) {
    throw new Error(`Single argument expected, got ${count} instead`);
  }
  return this;
}
