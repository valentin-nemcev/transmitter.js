import PayloadBase from './PayloadBase';

export default {
  groupKeysByValue() {
    return new GroupingKeysByValuePayload(this);
  },
};

class GroupingKeysByValuePayload extends PayloadBase {
  constructor(source) {
    super();
    this.source = source;
  }

  getAt(key) {
    const result = [];
    for (const [sourceKey, value] of this.source) {
      if (key === value) result.push(sourceKey);
    }
    return result;
  }

  [Symbol.iterator]() {
    const result = new Map();
    for (const [key, value] of this.source) {
      if (!result.has(value)) result.set(value, []);
      result.get(value).push(key);
    }
    return result.entries();
  }
}
