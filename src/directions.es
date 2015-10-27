export const forward = Object.freeze({
  isForward: true,
  inspect() { return '→'; },
  reverse() { return backward; },
  matches(other) { return other.isOmni || other.isForward; },
});

export const backward = Object.freeze({
  isBackward: true,
  inspect() { return '←'; },
  reverse() { return forward; },
  matches(other) { return other.isOmni || other.isBackward; },
});

export const nullDir = Object.freeze({
  isNull: true,
  inspect() { return '-'; },
  reverse() { return nullDir; },
  matches(other) { return other.isOmni || other.isNull; },
});

export const omni = Object.freeze({
  isOmni: true,
  inspect() { return '↔'; },
  reverse() { return omni; },
  matches() { return true; },
});
