class PrototypeBuilder {

  inspect() { return '[PrototypeBuilder]'; }

  constructor() {
    this.proto = {};
  }

  freezeAndReturn() {
    return Object.freeze(this.proto);
  }

  defineDataProperty(prop, {value, writeable}) {
    Object.defineProperty(this.proto, prop, {
      enumerable: true,
      writeable,
      value,
    });
    return this;
  }

  defineAccessorProperty(prop, {get, set}) {
    Object.defineProperty(this.proto, prop, {
      enumerable: true,
      get,
      set,
    });
    return this;
  }

  include(otherProto, {override = {}} = {}) {
    const withoutSet = new Set(Object.keys(override));
    for (const propName of Object.keys(otherProto)) {
      if (withoutSet.has(propName)) continue;
      const desc = Object.getOwnPropertyDescriptor(otherProto, propName);
      Object.defineProperty(this.proto, propName, desc);
    }
    for (const [prop, newMethod] of Object.entries(override)) {
      const oldMethod = otherProto[prop];
      const oldMethodProp = '_super_' + prop;
      this.method(prop, function(...args) {
        if (this[oldMethodProp] == null) {
          this[oldMethodProp] = oldMethod.bind(this);
        }
        return newMethod.call(this, this[oldMethodProp], ...args);
      });
    }
    return this;
  }

  method(prop, method) {
    return this.defineDataProperty(prop, {value: method});
  }

  methods(methods) {
    for (const [prop, method] of Object.entries(methods))
      this.method(prop, method);
    return this;
  }

  readOnlyProperty(prop, value) {
    return this.defineDataProperty(prop, {value});
  }

  setOnceMandatoryProperty(prop, {title}) {
    const hiddenProp = '_' + prop;
    return this.defineAccessorProperty(prop, {
      set(newValue) {
        if (this.hasOwnProperty(hiddenProp)) {
          throw new Error(title + ' already specified');
        }
        this[hiddenProp] = newValue;
        return this;
      },

      get() {
        if (!this.hasOwnProperty(hiddenProp)) {
          throw new Error(title + ' was not specified');
        }
        return this[hiddenProp];
      },
    });
  }

  setOnceLazyProperty(prop, getValue, {title}) {
    const hiddenProp = '_' + prop;
    return this.defineAccessorProperty(prop, {
      set(newValue) {
        if (this.hasOwnProperty(hiddenProp)) {
          throw new Error(title + ' already specified');
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

  lazyReadOnlyProperty(prop, getValue) {
    const hiddenProp = '_' + prop;
    return this.defineAccessorProperty(prop, {
      writeable: false,

      get() {
        if (!this.hasOwnProperty(hiddenProp)) {
          this[hiddenProp] = getValue.call(this);
        }
        return this[hiddenProp];
      },
    });
  }
}

export default function buildPrototype() {
  return new PrototypeBuilder();
}
