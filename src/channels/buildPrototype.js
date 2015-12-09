class PrototypeBuilder {

  inspect() { return '[PrototypeBuilder]'; }

  constructor() {
    this.proto = {};
  }

  freezeAndReturn() {
    return Object.freeze(this.proto);
  }

  dataProperty(prop, {value, writeable}) {
    Object.defineProperty(this.proto, prop, {
      enumerable: true,
      writeable,
      value,
    });
    return this;
  }

  accessorProperty(prop, {get, set}) {
    Object.defineProperty(this.proto, prop, {
      enumerable: true,
      get,
      set,
    });
    return this;
  }

  include(otherProto, {rename = {}} = {}) {
    for (const propName of Object.keys(otherProto)) {
      const newPropName = rename[propName] || propName;
      const desc = Object.getOwnPropertyDescriptor(otherProto, propName);
      Object.defineProperty(this.proto, newPropName, desc);
    }
    return this;
  }

  method(prop, method) {
    return this.dataProperty(prop, {value: method});
  }

  methods(methods) {
    for (const [prop, method] of Object.entries(methods)) {
      this.method(prop, method);
    }
    return this;
  }

  readOnlyProperty(prop, value) {
    return this.dataProperty(prop, {value});
  }

  setOnceMandatoryProperty(prop, {title}) {
    const hiddenProp = '_' + prop;
    return this.accessorProperty(prop, {
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
    return this.accessorProperty(prop, {
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
    return this.accessorProperty(prop, {
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
