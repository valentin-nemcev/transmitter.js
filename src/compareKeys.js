export default function compareKeys(a, b) {
  if (a === b) return 0;

  if (a === null) return -1;
  if (b === null) return +1;

  if (a === false) return -1;
  if (b === false) return +1;

  if (a === true) return -1;
  if (b === true) return +1;

  if (typeof a === 'number' && typeof b === 'number') return a - b;
  if (typeof a === 'number') return -1;
  if (typeof b === 'number') return +1;

  if (typeof a === 'string' && typeof b === 'string') {
    // return a.localeCompare(b);
    if (a < b) return -1;
    if (a > b) return 1;
    return 0;
  }
  if (typeof a === 'string') return -1;
  if (typeof b === 'string') return +1;

  if (Array.isArray(a) && Array.isArray(b)) {
    for (let i = 0; i < a.length && i < b.length; i++) {
      const c = compareKeys(a[i], b[i]);
      if (c !== 0) return c;
    }
    return a.length - b.length;
  }

  return 0;
}
