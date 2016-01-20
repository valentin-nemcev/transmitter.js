export default {
  toMapUpdate(map) {
    return new MapUpdatePayload(this, map);
  },
};


class MapUpdatePayload {
  constructor(source, map) {
    this.source = source;
    this.map = map;
  }

  deliver(target) {
    let prevKey = null;
    for (const [key, value] of this.source) {
      if (!target.hasAt(key)) {
        target.setAt(key, this.map.call(null, value, key));
      }
      target.moveAfter(key, prevKey);
      target.visitKey(key);
      prevKey = key;
    }
    target.removeUnvisitedKeys();
    return this;
  }
}
