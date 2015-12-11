function iterateOwnPropertiesAndSymbols(object) {
  return [
    ...Object.getOwnPropertyNames(object),
    ...Object.getOwnPropertySymbols(object),
  ].values();
}

class PrototypeBuilder {

  inspect() { return '[PrototypeBuilder]'; }

  constructor(name = 'Anonymous') {
    this.name = name;
    this.proto = {};
  }

  freezeAndReturnPrototype() {
    return Object.freeze(this.proto);
  }

  freezeAndReturnConstructor() {
    // http://discourse.wicg.io/t/proposal-let-the-
    //   function-constructor-accept-a-name-for-creating-named-functions/1172
    /* eslint-disable no-new-func */
    const body = this._getInitializerMethodNames().map(
      (prop) => `this.${prop}();`
    ).join('\n');
    const constructor = new Function(
      `return function ${this.name} () { \n${body}\n }`
    )();
    constructor.prototype = this.proto;
    constructor.prototype.constructor = constructor;
    return constructor;
  }

  dataProperty(prop, {value, writable}) {
    Object.defineProperty(this.proto, prop, {
      enumerable: true,
      writable,
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


  copyPropertiesFrom(otherProto, {rename = {}} = {}) {
    for (const propName of iterateOwnPropertiesAndSymbols(otherProto)) {
      const newPropName = rename[propName] || propName;
      const desc = Object.getOwnPropertyDescriptor(otherProto, propName);
      Object.defineProperty(this.proto, newPropName, desc);
    }
    return this;
  }


  method(prop, method) {
    return this.dataProperty(prop, {value: method});
  }

  writableMethod(prop, method) {
    return this.dataProperty(prop, {value: method, writable: true});
  }

  methods(methods) {
    for (const prop of iterateOwnPropertiesAndSymbols(methods)) {
      this.method(prop, methods[prop]);
    }
    return this;
  }

  initializer(name, initializer) {
    this.method('__init_' + name, initializer);
    return this;
  }

  _getInitializerMethodNames() {
    return Object.keys(this.proto).filter( (prop) => prop.match(/^__init/) );
  }


  propertyInitializer(prop, initializer) {
    this.initializer(prop, function() {
      this[prop] = initializer.call(this);
    });
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
      get() {
        if (!this.hasOwnProperty(hiddenProp)) {
          this[hiddenProp] = getValue.call(this);
        }
        return this[hiddenProp];
      },
    });
  }
}

export default function buildPrototype(...args) {
  return new PrototypeBuilder(...args);
}
