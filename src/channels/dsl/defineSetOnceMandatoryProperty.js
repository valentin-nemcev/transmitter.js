export default function defineSetOnceMandatoryProperty(obj, prop, name) {
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
        throw new Error(name + ' was not specified');
      }
      return this[hiddenProp];
    },
  });
}
