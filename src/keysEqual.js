export default function keysEqual(a, b) {
  if (a === b) return true;

  if (Array.isArray(a) && Array.isArray(b)) {
    if (a.length !== b.length) return false;
    for (let i = 0; i < a.length; i++) {
      if (!keysEqual(a[i], b[i])) return false;
    }
    return true;
  }

  return false;
}
