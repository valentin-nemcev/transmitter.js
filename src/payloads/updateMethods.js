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

  deliver(map) {
    let prevKey = null;
    for (const [key, value] of this.source) {
      if (!map.hasAt(key)) map.setAt(key, this.map.call(null, value, key));
      map.moveAfter(key, prevKey);
      map.visitKey(key);
      prevKey = key;
    }
    map.removeUnvisitedKeys();
    return this;
  }
}
