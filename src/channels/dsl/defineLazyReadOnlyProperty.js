export default function defineSetOnceMandatoryProperty(obj, prop, getValue) {
  const hiddenProp = '_' + prop;
  Object.defineProperty(obj, prop, {
    writeable: false,

    get() {
      if (!this.hasOwnProperty(hiddenProp)) {
        this[hiddenProp] = getValue.call(this);
      }
      return this[hiddenProp];
    },
  });
}
