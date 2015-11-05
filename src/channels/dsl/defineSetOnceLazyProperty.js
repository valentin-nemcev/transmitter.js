export default function defineSetOnceLazyProperty(obj, prop, name, getValue) {
  const hiddenProp = '_' + prop;
  Object.defineProperty(obj, prop, {
    set(newValue) {
      if (this.hasOwnProperty(hiddenProp)) {
        throw new Error(name + ' already specified');
      }
      this[hiddenProp] = newValue;
      return this;
    },

    get() {
      if (!this.hasOwnProperty(hiddenProp)) {
        this[hiddenProp] = getValue.call(this);
      }
      return this[hiddenProp];
    },
  });
}

